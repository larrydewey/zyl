//! Evaluator / Interpreter for Zyl
//! 
//! Bootstrap implementation - evaluates Zyl programs directly.
//! Per specification section 7:
//! - Strict left-to-right evaluation order
//! - Big-step semantics
//! - Deterministic execution

use std::cell::RefCell;
use std::rc::Rc;

use crate::ast::*;
use crate::actor::{ActorId, ActorMessage, ActorSystem};
use crate::ffi::{FfiArg, FfiResult, FfiRegistry};
use thiserror::Error;

// ============================================================================
// EVALUATION ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error)]
pub enum EvalError {
    #[error("Undefined variable: {name}")]
    UndefinedVariable { name: String },
    
    #[error("Type error: {msg}")]
    TypeError { msg: String },
    
    #[error("Assertion failed: {message}")]
    AssertFail { message: String },
    
    #[error("Runtime error: {msg}")]
    RuntimeError { msg: String },
    
    #[error("Division by zero")]
    DivisionByZero,
    
    #[error("Stack overflow")]
    StackOverflow,
    
    #[error("Actor error: {0}")]
    ActorError(String),
    
    #[error("FFI error: {0}")]
    FfiError(String),
    
    // Testing framework (§20.5 — v3.3)
    #[error("Test failure: {msg}")]
    TestFailure { msg: String },
    
    #[error("Test runner error: {msg}")]
    TestRunnerError { msg: String },
}

// ============================================================================
// RUNTIME VALUES (Section 3: Value Model)
// ============================================================================

#[derive(Debug)]
pub enum Value {
    Int(i64),
    Float(f64),
    Bool(bool),
    StringVal(String),
    Tuple(Vec<Value>),
    Closure {
        params: Vec<String>,
        body: Box<Expr>,
        env: Env,
        /// Self-reference for recursive function calls (Rc allows the closure to
        /// be stored in its own captured environment).
        self_ref: Option<Rc<RefCell<Value>>>,
    },
    ActorRef(ActorId),
    Unit,
}

impl Clone for Value {
    fn clone(&self) -> Self {
        match self {
            Value::Int(v) => Value::Int(*v),
            Value::Float(v) => Value::Float(*v),
            Value::Bool(v) => Value::Bool(*v),
            Value::StringVal(s) => Value::StringVal(s.clone()),
            Value::Tuple(vals) => Value::Tuple(vals.clone()),
            Value::Closure { params, body, env, self_ref } => Value::Closure {
                params: params.clone(),
                body: body.clone(),
                env: env.clone(),
                self_ref: self_ref.clone(),
            },
            Value::ActorRef(id) => Value::ActorRef(*id),
            Value::Unit => Value::Unit,
        }
    }
}

impl Value {
    pub fn is_truthy(&self) -> bool {
        match self {
            Value::Bool(b) => *b,
            Value::Int(n) => *n != 0,
            Value::Float(f) => *f != 0.0,
            Value::StringVal(s) => !s.is_empty(),
            Value::Unit => false,
            _ => true, // Non-false values are truthy
        }
    }
}

impl std::fmt::Display for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Value::Int(v) => write!(f, "{}", v),
            Value::Float(v) => write!(f, "{}", v),
            Value::Bool(v) => write!(f, "{}", v),
            Value::StringVal(v) => write!(f, "\"{}\"", v),
            Value::Tuple(vals) => {
                let vals_str: Vec<String> = vals.iter().map(|v| v.to_string()).collect();
                write!(f, "({})", vals_str.join(", "))
            }
            Value::Closure { .. } => write!(f, "<closure>"),
            Value::ActorRef(id) => write!(f, "{}", id),
            Value::Unit => write!(f, "unit"),
        }
    }
}

// ============================================================================
// ENVIRONMENT (Section 7: Σ = State)
// ============================================================================

#[derive(Debug, Clone)]
pub struct Env {
    /// Variable bindings: name -> value
    bindings: std::collections::HashMap<String, Value>,
    /// Parent environment (for scoping)
    parent: Option<Box<Env>>,
}

impl Env {
    pub fn new() -> Self {
        Self {
            bindings: std::collections::HashMap::new(),
            parent: None,
        }
    }
    
    pub fn with_parent(parent: Env) -> Self {
        Self {
            bindings: std::collections::HashMap::new(),
            parent: Some(Box::new(parent)),
        }
    }
    
    pub fn bind(&mut self, name: String, value: Value) {
        self.bindings.insert(name, value);
    }
    
    pub fn extend(&self) -> Self {
        Self {
            bindings: std::collections::HashMap::new(),
            parent: Some(Box::new(self.clone())),
        }
    }
    
    pub fn lookup(&self, name: &str) -> Result<&Value, EvalError> {
        if let Some(value) = self.bindings.get(name) {
            Ok(value)
        } else if let Some(parent) = &self.parent {
            parent.lookup(name)
        } else {
            Err(EvalError::UndefinedVariable { name: name.to_string() })
        }
    }
    
    pub fn get_mut(&mut self, name: &str) -> Option<&mut Value> {
        if self.bindings.contains_key(name) {
            self.bindings.get_mut(name)
        } else if let Some(ref mut parent) = self.parent {
            parent.get_mut(name)
        } else {
            None
        }
    }
    
    /// Get all bindings in this environment (for REPL introspection)
    pub fn get_bindings(&self) -> &std::collections::HashMap<String, Value> {
        &self.bindings
    }
    
    /// Get the parent environment (for REPL introspection)
    pub fn get_parent(&self) -> Option<&Env> {
        self.parent.as_deref()
    }
}

// ============================================================================
// EVALUATION STATE (Section 7: Σ = ⟨H, S, R, A, F, M⟩)
// ============================================================================

pub struct EvalState {
    /// Environment (stack bindings)
    pub env: Env,
    /// Actor system
    pub actors: ActorSystem,
    /// FFI registry
    pub ffi: FfiRegistry,
    /// Recursion depth limit (for stack overflow protection)
    pub depth: usize,
    pub max_depth: usize,
    /// Test registry (§20.5 — v3.3)
    pub test_registry: Vec<TestRegistration>,
    /// Test results
    pub test_results: Vec<TestResult>,
}

impl EvalState {
    pub fn new() -> Self {
        Self {
            env: Env::new(),
            actors: ActorSystem::new(),
            ffi: FfiRegistry::new(),
            depth: 0,
            max_depth: 10000,
            test_registry: Vec::new(),
            test_results: Vec::new(),
        }
    }
    
    pub fn with_env(env: Env) -> Self {
        Self {
            env,
            actors: ActorSystem::new(),
            ffi: FfiRegistry::new(),
            depth: 0,
            max_depth: 10000,
            test_registry: Vec::new(),
            test_results: Vec::new(),
        }
    }
    
    fn check_depth(&self) -> Result<(), EvalError> {
        if self.depth >= self.max_depth {
            Err(EvalError::StackOverflow)
        } else {
            Ok(())
        }
    }
}

// ============================================================================
// BUILTIN OPERATIONS
// ============================================================================

fn eval_builtin(op: &str, args: &[Value]) -> Result<Value, EvalError> {
    match op {
        // Arithmetic
        "+" => {
            if args.is_empty() {
                return Ok(Value::Int(0));
            }
            if args.len() == 1 {
                // Unary identity: (+ x) → x
                return Ok(args[0].clone());
            }
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("+ expects 1 or 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Int(a.wrapping_add(*b))),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Float(a + b)),
                (Value::Int(a), Value::Float(b)) => Ok(Value::Float(*a as f64 + b)),
                (Value::Float(a), Value::Int(b)) => Ok(Value::Float(a + *b as f64)),
                _ => Err(EvalError::TypeError { msg: "+ requires numeric arguments".into() }),
            }
        }
        "-" => {
            if args.len() == 1 {
                // Unary negation: (- x) → -x
                match &args[0] {
                    Value::Int(v) => Ok(Value::Int(v.wrapping_neg())),
                    Value::Float(v) => Ok(Value::Float(-v)),
                    _ => Err(EvalError::TypeError { msg: "- requires numeric argument".into() }),
                }
            } else if args.len() == 2 {
                // Binary subtraction
                match (&args[0], &args[1]) {
                    (Value::Int(a), Value::Int(b)) => Ok(Value::Int(a.wrapping_sub(*b))),
                    (Value::Float(a), Value::Float(b)) => Ok(Value::Float(a - b)),
                    (Value::Int(a), Value::Float(b)) => Ok(Value::Float(*a as f64 - b)),
                    (Value::Float(a), Value::Int(b)) => Ok(Value::Float(a - *b as f64)),
                    _ => Err(EvalError::TypeError { msg: "- requires numeric arguments".into() }),
                }
            } else {
                Err(EvalError::TypeError { msg: format!("- expects 1 or 2 args, got {}", args.len()) })
            }
        }
        "*" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("* expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Int(a.wrapping_mul(*b))),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Float(a * b)),
                (Value::Int(a), Value::Float(b)) => Ok(Value::Float(*a as f64 * b)),
                (Value::Float(a), Value::Int(b)) => Ok(Value::Float(a * *b as f64)),
                _ => Err(EvalError::TypeError { msg: "* requires numeric arguments".into() }),
            }
        }
        "/" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("/ expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => {
                    if *b == 0 { Err(EvalError::DivisionByZero) }
                    else { Ok(Value::Int(a.wrapping_div(*b))) }
                }
                (Value::Float(a), Value::Float(b)) => {
                    if *b == 0.0 { Err(EvalError::DivisionByZero) }
                    else { Ok(Value::Float(a / b)) }
                }
                _ => Err(EvalError::TypeError { msg: "/ requires numeric arguments".into() }),
            }
        }
        "%" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("% expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => {
                    if *b == 0 { Err(EvalError::DivisionByZero) }
                    else { Ok(Value::Int(a.wrapping_rem(*b))) }
                }
                _ => Err(EvalError::TypeError { msg: "% requires integer arguments".into() }),
            }
        }
        
        // Comparison
        "==" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("== expects 2 args, got {}", args.len()) });
            }
            Ok(Value::Bool(values_equal(&args[0], &args[1])))
        }
        "!=" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("!= expects 2 args, got {}", args.len()) });
            }
            Ok(Value::Bool(!values_equal(&args[0], &args[1])))
        }
        "<" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("< expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Bool(a < b)),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Bool(a < b)),
                _ => Err(EvalError::TypeError { msg: "< requires comparable arguments".into() }),
            }
        }
        ">" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("> expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Bool(a > b)),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Bool(a > b)),
                _ => Err(EvalError::TypeError { msg: "> requires comparable arguments".into() }),
            }
        }
        "<=" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!("<= expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Bool(a <= b)),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Bool(a <= b)),
                _ => Err(EvalError::TypeError { msg: "<= requires comparable arguments".into() }),
            }
        }
        ">=" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: format!(">= expects 2 args, got {}", args.len()) });
            }
            match (&args[0], &args[1]) {
                (Value::Int(a), Value::Int(b)) => Ok(Value::Bool(a >= b)),
                (Value::Float(a), Value::Float(b)) => Ok(Value::Bool(a >= b)),
                _ => Err(EvalError::TypeError { msg: ">= requires comparable arguments".into() }),
            }
        }
        
        // Boolean
        "not" => {
            if args.len() != 1 {
                return Err(EvalError::TypeError { msg: "not expects 1 arg".into() });
            }
            // Truthiness negation: not any-value → !is_truthy(value)
            Ok(Value::Bool(!args[0].is_truthy()))
        }
        "and" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: "and expects 2 args".into() });
            }
            Ok(Value::Bool(args[0].is_truthy() && args[1].is_truthy()))
        }
        "or" => {
            if args.len() != 2 {
                return Err(EvalError::TypeError { msg: "or expects 2 args".into() });
            }
            Ok(Value::Bool(args[0].is_truthy() || args[1].is_truthy()))
        }
        
        // Type checking
        "int?" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "int? expects 1 arg".into() }); }
            Ok(Value::Bool(matches!(&args[0], Value::Int(_))))
        }
        "float?" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "float? expects 1 arg".into() }); }
            Ok(Value::Bool(matches!(&args[0], Value::Float(_))))
        }
        "bool?" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "bool? expects 1 arg".into() }); }
            Ok(Value::Bool(matches!(&args[0], Value::Bool(_))))
        }
        "string?" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "string? expects 1 arg".into() }); }
            Ok(Value::Bool(matches!(&args[0], Value::StringVal(_))))
        }
        
        // String operations
        "len" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "len expects 1 arg".into() }); }
            match &args[0] {
                Value::StringVal(s) => Ok(Value::Int(s.len() as i64)),
                _ => Err(EvalError::TypeError { msg: "len requires a string".into() }),
            }
        }
        
        // Unit
        "unit" => Ok(Value::Unit),
        
        // IO (via FFI registry)
        "print" => {
            if args.is_empty() {
                return Err(EvalError::TypeError { msg: "print expects at least 1 arg".into() });
            }
            for arg in args {
                println!("{}", arg);
            }
            Ok(Value::Unit)
        }
        "read-line" => {
            if !args.is_empty() {
                return Err(EvalError::TypeError { msg: "read-line expects 0 args".into() });
            }
            let mut input = String::new();
            std::io::stdin().read_line(&mut input).ok();
            input = input.trim_end_matches('\n').trim_end_matches('\r').to_string();
            Ok(Value::StringVal(input))
        }
        "exit" => {
            let code = match args.first() {
                Some(Value::Int(v)) => *v as i32,
                _ => 0,
            };
            std::process::exit(code);
        }
        
        // begin: evaluate multiple expressions, return last
        "begin" => {
            if args.is_empty() {
                return Ok(Value::Unit);
            }
            let mut result = Value::Unit;
            for arg in args {
                result = arg.clone();
            }
            Ok(result)
        }
        
        // --- List operations (stdlib builtins) ---
        
        "first" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "first expects 1 arg".into() }); }
            match &args[0] {
                Value::Tuple(vals) => {
                    if vals.is_empty() { Ok(Value::Unit) } else { Ok(vals[0].clone()) }
                }
                _ => Err(EvalError::TypeError { msg: "first requires a list".into() }),
            }
        }
        
        "rest" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "rest expects 1 arg".into() }); }
            match &args[0] {
                Value::Tuple(vals) => {
                    if vals.is_empty() { Ok(Value::Tuple(Vec::new())) }
                    else { Ok(Value::Tuple(vals[1..].to_vec())) }
                }
                _ => Err(EvalError::TypeError { msg: "rest requires a list".into() }),
            }
        }
        
        "nth" => {
            if args.len() != 2 { return Err(EvalError::TypeError { msg: "nth expects 2 args".into() }); }
            match (&args[0], &args[1]) {
                (Value::Tuple(vals), Value::Int(i)) => {
                    let idx = *i as usize;
                    if idx < vals.len() { Ok(vals[idx].clone()) }
                    else { Err(EvalError::RuntimeError { msg: format!("nth index {} out of bounds", idx) }) }
                }
                _ => Err(EvalError::TypeError { msg: "nth requires (list, int)".into() }),
            }
        }
        
        "length" => {
            if args.len() != 1 { return Err(EvalError::TypeError { msg: "length expects 1 arg".into() }); }
            match &args[0] {
                Value::Tuple(vals) => Ok(Value::Int(vals.len() as i64)),
                _ => Err(EvalError::TypeError { msg: "length requires a list".into() }),
            }
        }
        
        "cons" => {
            if args.len() != 2 { return Err(EvalError::TypeError { msg: "cons expects 2 args".into() }); }
            match &args[1] {
                Value::Tuple(vals) => {
                    let mut new_vals = vec![args[0].clone()];
                    new_vals.extend_from_slice(vals);
                    Ok(Value::Tuple(new_vals))
                }
                _ => Err(EvalError::TypeError { msg: "cons requires (value, list)".into() }),
            }
        }
        
        "append" => {
            if args.len() != 2 { return Err(EvalError::TypeError { msg: "append expects 2 args".into() }); }
            match (&args[0], &args[1]) {
                (Value::Tuple(a), Value::Tuple(b)) => {
                    let mut result = a.clone();
                    result.extend_from_slice(b);
                    Ok(Value::Tuple(result))
                }
                _ => Err(EvalError::TypeError { msg: "append requires two lists".into() }),
            }
        }
        
        "list" => {
            // list takes any number of args and returns them as a tuple
            Ok(Value::Tuple(args.to_vec()))
        }
        
        _ => Err(EvalError::RuntimeError { msg: format!("Unknown builtin: {}", op) }),
    }
}

// ============================================================================
// EVALUATOR (Big-step semantics - Section 7)
// ============================================================================

pub struct Evaluator<'a> {
    state: &'a mut EvalState,
}

impl<'a> Evaluator<'a> {
    pub fn new(state: &'a mut EvalState) -> Self {
        Self { state }
    }
    
    /// Evaluate an expression (big-step judgment: ⟨E, Σ⟩ → ⟨V, Σ'⟩)
    pub fn eval(&mut self, expr: &Expr) -> Result<Value, EvalError> {
        self.state.check_depth()?;
        self.state.depth += 1;
        
        let result = match expr {
            Expr::Atom(kind) => self.eval_atom(kind),
            Expr::App(op, args) => self.eval_app(op, args),
            Expr::AppExpr(operator, args) => {
                // Evaluate the operator expression first (could be a nested call)
                let func_val = self.eval(operator)?;
                // Evaluate arguments left-to-right
                let evaluated_args: Vec<Value> = args.iter()
                    .map(|a| self.eval(a))
                    .collect::<Result<Vec<_>, _>>()?;
                
                match func_val {
                    Value::Closure { params, body, env: closure_env, self_ref } => {
                        if params.len() != evaluated_args.len() {
                            return Err(EvalError::TypeError {
                                msg: format!("Function expects {} args, got {}", params.len(), evaluated_args.len()),
                            });
                        }
                        
                        // Create new environment with bound parameters
                        let mut new_env = closure_env.extend();
                        for (param, arg) in params.iter().zip(&evaluated_args) {
                            new_env.bind(param.clone(), arg.clone());
                        }
                        
                        // Bind self_ref for recursive calls
                        if let Some(ref ref_cell) = self_ref {
                            let actual_closure = ref_cell.borrow().clone();
                            new_env.bind("__self__".to_string(), actual_closure);
                        }
                        
                        let saved_env = std::mem::replace(&mut self.state.env, new_env);
                        let result = self.eval(body.as_ref());
                        self.state.env = saved_env;
                        result
                    }
                    _ => Err(EvalError::TypeError { msg: "Operator is not a function".into() }),
                }
            }
            Expr::Def(name, body) => {
                let val = self.eval(body)?;
                self.state.env.bind(name.clone(), val.clone());
                Ok(val)
            }
            Expr::Defn { name, params, body, .. } => {
                // Create a self-referential closure for recursive function support.
                // 1. Create an env extending current with a placeholder for the function.
                // 2. Create Rc<RefCell<Value>> holding the placeholder.
                // 3. Bind the Rc to the env (so both original and clone share it).
                // 4. Create closure with this env + self_ref.
                // 5. Replace placeholder with actual closure via the Rc.
                let mut closure_env = self.state.env.clone();
                let placeholder = Value::Unit;
                let self_ref: Rc<RefCell<Value>> = Rc::new(RefCell::new(placeholder));
                // Bind a placeholder closure to the env (with Rc for self-ref)
                closure_env.bind(name.clone(), Value::Closure {
                    params: params.clone(),
                    body: body.clone(),
                    env: closure_env.clone(),
                    self_ref: Some(self_ref.clone()),
                });
                // Create the actual closure
                let closure = Value::Closure {
                    params: params.clone(),
                    body: body.clone(),
                    env: closure_env,
                    self_ref: Some(self_ref.clone()),
                };
                // Replace placeholder in the shared Rc with the actual closure
                *self_ref.borrow_mut() = closure.clone();
                self.state.env.bind(name.clone(), closure);
                Ok(Value::Unit)
            }
            Expr::Let { name, value, body } => {
                let val = self.eval(value)?;
                let mut new_env = self.state.env.extend();
                new_env.bind(name.clone(), val);
                let saved_env = std::mem::replace(&mut self.state.env, new_env);
                let result = self.eval(body);
                self.state.env = saved_env;
                result
            }
            Expr::LetMut { name, value, body } => {
                // Mutable bindings work like regular let in the interpreter
                // (mutability is enforced at compile time via region inference)
                let val = self.eval(value)?;
                let mut new_env = self.state.env.extend();
                new_env.bind(name.clone(), val);
                let saved_env = std::mem::replace(&mut self.state.env, new_env);
                let result = self.eval(body);
                self.state.env = saved_env;
                result
            }
            Expr::If { cond, then_branch, else_branch } => {
                let cond_val = self.eval(cond)?;
                if cond_val.is_truthy() {
                    self.eval(then_branch)
                } else {
                    self.eval(else_branch)
                }
            }
            Expr::TryCatch { body, catch_var, handler } => {
                match self.eval(body) {
                    Ok(val) => Ok(val),
                    Err(e) => {
                        // Bind error to catch variable and evaluate handler
                        let mut new_env = self.state.env.extend();
                        new_env.bind(catch_var.clone(), Value::StringVal(e.to_string()));
                        let saved_env = std::mem::replace(&mut self.state.env, new_env);
                        let result = self.eval(handler);
                        self.state.env = saved_env;
                        result
                    }
                }
            }
            Expr::Spawn(body) => {
                // Spawn creates a new actor
                // The body should be a defn (function to run as actor)
                match self.eval(body)? {
                    Value::Closure { self_ref: _, .. } => {
                        let actor_id = self.state.actors.spawn(vec![]);
                        Ok(Value::ActorRef(actor_id))
                    }
                    _ => Err(EvalError::RuntimeError { msg: "spawn requires a function".into() }),
                }
            }
            Expr::Send { target, message } => {
                let target_val = self.eval(target)?;
                let msg_val = self.eval(message)?;
                
                match target_val {
                    Value::ActorRef(id) => {
                        let actor_msg = value_to_actor_message(msg_val);
                        self.state.actors.send(id, actor_msg).map_err(|e| {
                            EvalError::ActorError(e.to_string())
                        })?;
                        Ok(Value::Unit)
                    }
                    _ => Err(EvalError::TypeError { msg: "send target must be an ActorRef".into() }),
                }
            }
            Expr::FfiCall { name, args, timeout_ms } => {
                let ffi_args: Vec<FfiArg> = args.iter().map(|a| self.eval_to_ffi_arg(a)).collect::<Result<Vec<_>, _>>()?;
                let result = self.state.ffi.call(name, &ffi_args, *timeout_ms as u64)
                    .map_err(|e| EvalError::FfiError(e.to_string()))?;
                ffi_result_to_value(result)
            }
            Expr::FfiPin(inner) => {
                // Pinning is a compile-time concern; at runtime it's a no-op
                self.eval(inner)
            }
            Expr::Assert { condition, message } => {
                let cond_val = self.eval(condition)?;
                if !cond_val.is_truthy() {
                    Err(EvalError::AssertFail { message: message.clone() })
                } else {
                    Ok(Value::Unit)
                }
            }
            
            // Closures (§7)
            Expr::Fn { params, body } => {
                let closure = Value::Closure {
                    params: params.clone(),
                    body: body.clone(),
                    env: self.state.env.clone(),
                    self_ref: None,
                };
                Ok(closure)
            }
            
            // While loop (§12.5)
            Expr::While { condition, body } => {
                loop {
                    let cond_val = self.eval(condition)?;
                    if !cond_val.is_truthy() {
                        return Ok(Value::Unit);
                    }
                    self.eval(body)?;
                }
            }
            
            // For loop (§12.6)
            Expr::For { name, iterator, body } => {
                let iter_val = self.eval(iterator)?;
                match iter_val {
                    Value::StringVal(s) => {
                        for ch in s.chars() {
                            let mut new_env = self.state.env.extend();
                            new_env.bind(name.clone(), Value::StringVal(ch.to_string()));
                            let saved_env = std::mem::replace(&mut self.state.env, new_env);
                            self.eval(body)?;
                            self.state.env = saved_env;
                        }
                    }
                    _ => {
                        // For now, treat as a sequence via len + indexing
                        // A full implementation would have Vec/Map iteration
                        return Err(EvalError::TypeError {
                            msg: format!("For loop requires iterable value, got {:?}", iter_val),
                        });
                    }
                }
                Ok(Value::Unit)
            }
            
            // Cond (§12.7)
            Expr::Cond(clauses) => {
                for (cond, body) in clauses {
                    let cond_val = self.eval(cond)?;
                    if cond_val.is_truthy() {
                        return self.eval(body);
                    }
                }
                Ok(Value::Unit)
            }
            
            // Match (§8.3)
            Expr::Match { scrutinee, clauses } => {
                let scrutinee_val = self.eval(scrutinee)?;
                
                for clause in clauses {
                    if self.match_variant(&scrutinee_val, &clause.variant, &clause.patterns) {
                        // Bind patterns and evaluate body
                        let mut new_env = self.state.env.extend();
                        self.bind_match_patterns(&scrutinee_val, &clause.patterns, &mut new_env)?;
                        let saved_env = std::mem::replace(&mut self.state.env, new_env);
                        let result = self.eval(clause.body.as_ref());
                        self.state.env = saved_env;
                        return result;
                    }
                }
                
                Err(EvalError::RuntimeError {
                    msg: format!("Match exhausted: no clause matched {:?}", scrutinee_val),
                })
            }
            
            // Deftype (§8) - ADT declarations are compile-time only
            Expr::Deftype { .. } => Ok(Value::Unit),
            
            // TraitDecl (§5) - compile-time only
            Expr::TraitDecl { .. } => Ok(Value::Unit),
            
            // Impl (§5) - compile-time only
            Expr::Impl { .. } => Ok(Value::Unit),
            
            // Use/Export/Pub (§24) - handled at module level
            Expr::Use { .. } => Ok(Value::Unit),
            Expr::Export(body) => self.eval(body),
            Expr::Pub(body) => self.eval(body),
            
            // Contracts (§23)
            Expr::Requires(_) => Ok(Value::Unit), // Contract checks are compile-time in bootstrap
            Expr::Ensures { condition: _, body } => {
                let result = self.eval(body)?;
                // In bootstrap mode, ensures is a no-op (contracts disabled)
                Ok(result)
            }
            Expr::Invariant(_) => Ok(Value::Unit),
            Expr::Recover { handlers, body } => {
                match self.eval(body) {
                    Ok(val) => Ok(val),
                    Err(e) => {
                        // Try to find a matching handler
                        let err_msg = e.to_string();
                        for (err_type, fallback) in handlers {
                            if err_msg.contains(err_type.as_str()) {
                                let mut new_env = self.state.env.extend();
                                new_env.bind("error".into(), Value::StringVal(err_msg.clone()));
                                let saved_env = std::mem::replace(&mut self.state.env, new_env);
                                let result = self.eval(fallback);
                                self.state.env = saved_env;
                                return result;
                            }
                        }
                        Err(e)
                    }
                }
            }
            Expr::Checkpoint(body) => {
                // In bootstrap mode, checkpoint is a no-op
                self.eval(body)
            }
            Expr::Contracts(_) => Ok(Value::Unit),
            
            // Begin (§12.8)
            Expr::Begin(exprs) => {
                if exprs.is_empty() {
                    return Ok(Value::Unit);
                }
                let mut result = Value::Unit;
                for (i, expr) in exprs.iter().enumerate() {
                    result = self.eval(expr)?;
                    // Don't discard the last expression's value
                    if i == exprs.len() - 1 {
                        return Ok(result);
                    }
                }
                Ok(result)
            }
            
            // ========================================================================
            // TESTING FRAMEWORK EVALUATION (§20.5 — v3.3)
            // ========================================================================
            Expr::TestSuite { name, tests, keywords } => {
                // Register test suite (no execution at registration time)
                self.state.test_registry.push(TestRegistration {
                    kind: TestKind::Suite(name.clone()),
                    tests: tests.clone(),
                    keywords: keywords.clone(),
                });
                Ok(Value::Unit)
            }
            
            Expr::Test { name, body, keywords } => {
                // Register individual test
                self.state.test_registry.push(TestRegistration {
                    kind: TestKind::Test(name.clone()),
                    tests: vec![Expr::Test { name: "".into(), body: body.clone(), keywords: keywords.clone() }],
                    keywords: keywords.clone(),
                });
                Ok(Value::Unit)
            }
            
            Expr::AssertEqual { expected, actual } => {
                let exp_val = self.eval(expected)?;
                let act_val = self.eval(actual)?;
                if !values_equal(&exp_val, &act_val) {
                    return Err(EvalError::TestFailure {
                        msg: format!("assert-equal failed: expected {:?}, got {:?}", exp_val, act_val),
                    });
                }
                Ok(Value::Unit)
            }
            
            Expr::AssertFail { expr, message } => {
                match self.eval(expr) {
                    Ok(_) => Err(EvalError::TestFailure {
                        msg: format!("assert-fail failed: expected error but got success{:?}", message),
                    }),
                    Err(e) => {
                        // Error occurred as expected
                        if let Some(msg) = message {
                            if !e.to_string().contains(msg.as_str()) {
                                return Err(EvalError::TestFailure {
                                    msg: format!("assert-fail message mismatch: expected '{}' in '{}'", msg, e),
                                });
                            }
                        }
                        Ok(Value::Unit)
                    }
                }
            }
            
            Expr::AssertTrue { expr, message } => {
                let val = self.eval(expr)?;
                if !matches!(val, Value::Bool(true)) {
                    return Err(EvalError::TestFailure {
                        msg: format!("assert-true failed: expected true, got {:?}{:?}", val, message),
                    });
                }
                Ok(Value::Unit)
            }
            
            Expr::AssertFalse { expr, message } => {
                let val = self.eval(expr)?;
                if !matches!(val, Value::Bool(false)) {
                    return Err(EvalError::TestFailure {
                        msg: format!("assert-false failed: expected false, got {:?}{:?}", val, message),
                    });
                }
                Ok(Value::Unit)
            }
            
            Expr::TestProperty { name, generator, property_fn } => {
                // Property-based testing with built-in generators
                let gen_values = generate_values(&generator, 10);
                for val in gen_values {
                    // Create a fresh environment for each property check
                    let mut new_env = self.state.env.extend();
                    // Bind generator variables to the generated value
                    if let Expr::Fn { params, body: _ } = property_fn.as_ref() {
                        if !params.is_empty() {
                            new_env.bind(params[0].clone(), val.clone());
                        }
                    }
                    let saved_env = std::mem::replace(&mut self.state.env, new_env);
                    let result = self.eval(property_fn.as_ref());
                    self.state.env = saved_env;
                    
                    match result {
                        Ok(Value::Bool(true)) => {}, // Property holds
                        Ok(_) => {
                            return Err(EvalError::TestFailure {
                                msg: format!("property '{}' failed for value {:?}: expected true", name, val),
                            });
                        }
                        Err(e) => {
                            return Err(EvalError::TestFailure {
                                msg: format!("property '{}' raised error for value {:?}: {}", name, val, e),
                            });
                        }
                    }
                }
                Ok(Value::Unit)
            }
            
            Expr::Setup(bodies) => {
                // Setup is executed before each test (handled by test runner)
                for body in bodies {
                    self.eval(&body)?;
                }
                Ok(Value::Unit)
            }
            
            Expr::Teardown(bodies) => {
                // Teardown is executed after each test (handled by test runner)
                for body in bodies {
                    self.eval(&body)?;
                }
                Ok(Value::Unit)
            }
            
            Expr::RunTests { verbose, fail_fast, parallel } => {
                // Execute all registered tests
                let results = self.run_test_suite(*verbose, *fail_fast, *parallel)?;
                // Print results
                print_test_results(&results, *verbose);
                // Set exit code based on results
                if results.iter().any(|r| !r.passed) {
                    std::process::exit(1);
                }
                Ok(Value::Unit)
            }
            
            Expr::TestCompile { expr: _, expect_error } => {
                // Compile-time test (invoke compiler pipeline)
                // Note: compiler module is private in binary crate; this is a placeholder
                // TODO: Make compiler module public or create a separate test harness
                if *expect_error {
                    return Err(EvalError::TestRunnerError {
                        msg: "test-compile: compiler module not accessible (binary crate)".into(),
                    });
                }
                // For now, skip compile-time tests in interpreter mode
                Ok(Value::Unit)
            }
            
            // Quote — return the expression literally without evaluating
            Expr::Quote(inner) => Self::expr_to_value(inner),
        };
        
        self.state.depth -= 1;
        result
    }
    
    /// Convert an AST expression to a runtime value without evaluation (for quote)
    fn expr_to_value(expr: &Expr) -> Result<Value, EvalError> {
        match expr {
            Expr::Atom(kind) => Self::atom_kind_to_value(kind),
            Expr::Quote(inner) => Self::expr_to_value(inner),
            // For list expressions like (1 2 3), convert to Tuple including operator
            Expr::App(op, args) => {
                if op.is_empty() && args.is_empty() {
                    // Empty list ()
                    Ok(Value::Tuple(Vec::new()))
                } else {
                    let mut vals: Vec<Value> = vec![Self::op_to_value(op)?];
                    for a in args {
                        vals.push(Self::expr_to_value(a)?);
                    }
                    Ok(Value::Tuple(vals))
                }
            }
            Expr::AppExpr(op, args) => {
                let mut vals: Vec<Value> = vec![Self::expr_to_value(op)?];
                for a in args {
                    vals.push(Self::expr_to_value(a)?);
                }
                Ok(Value::Tuple(vals))
            }
            // For other complex expressions, convert sub-expressions recursively
            Expr::Let { value, body, .. } => {
                let v = Self::expr_to_value(value)?;
                let b = Self::expr_to_value(body)?;
                Ok(Value::Tuple(vec![v, b]))
            }
            Expr::Def(_, body) => Ok(Value::Tuple(vec![Self::expr_to_value(body)?])),
            Expr::If { cond, then_branch, else_branch } => {
                let c = Self::expr_to_value(cond)?;
                let t = Self::expr_to_value(then_branch)?;
                let e = Self::expr_to_value(else_branch)?;
                Ok(Value::Tuple(vec![c, t, e]))
            }
            Expr::Defn { name, params, body, .. } => {
                Ok(Value::Tuple(vec![
                    Value::StringVal(name.clone()),
                    Value::Tuple(params.iter().map(|p| Value::StringVal(p.clone())).collect()),
                    Self::expr_to_value(body)?,
                ]))
            }
            Expr::Fn { params, body } => {
                Ok(Value::Tuple(vec![
                    Value::Tuple(params.iter().map(|p| Value::StringVal(p.clone())).collect()),
                    Self::expr_to_value(body)?,
                ]))
            }
            // For everything else, convert to a string representation
            other => Ok(Value::StringVal(format!("{}", other))),
        }
    }
    
    /// Convert an AtomKind to a Value
    fn atom_kind_to_value(kind: &AtomKind) -> Result<Value, EvalError> {
        match kind {
            AtomKind::Int(v) => Ok(Value::Int(*v)),
            AtomKind::Float(v) => Ok(Value::Float(*v)),
            AtomKind::Bool(v) => Ok(Value::Bool(*v)),
            AtomKind::StringLit(s) => Ok(Value::StringVal(s.clone())),
            AtomKind::Ident(s) => Ok(Value::StringVal(s.clone())),
        }
    }
    
    /// Convert an App operator string to a Value (tries number parsing first)
    fn op_to_value(op: &str) -> Result<Value, EvalError> {
        // Try parsing as integer
        if let Ok(v) = op.parse::<i64>() {
            return Ok(Value::Int(v));
        }
        // Try parsing as float
        if let Ok(v) = op.parse::<f64>() {
            return Ok(Value::Float(v));
        }
        // Otherwise treat as identifier/string
        Ok(Value::StringVal(op.to_string()))
    }
    
    /// Evaluate an atom literal
    fn eval_atom(&mut self, kind: &AtomKind) -> Result<Value, EvalError> {
        match kind {
            AtomKind::Int(v) => Ok(Value::Int(*v)),
            AtomKind::Float(v) => Ok(Value::Float(*v)),
            AtomKind::Bool(v) => Ok(Value::Bool(*v)),
            AtomKind::StringLit(v) => Ok(Value::StringVal(v.clone())),
            AtomKind::Ident(name) => self.state.env.lookup(name).cloned(),
        }
    }
    
    /// Evaluate a function application (strict left-to-right - Section 7)
    fn eval_app(&mut self, op: &str, args: &[Expr]) -> Result<Value, EvalError> {
        // Strict left-to-right evaluation order (P5)
        let evaluated_args: Vec<Value> = args.iter()
            .map(|a| self.eval(a))
            .collect::<Result<Vec<_>, _>>()?;
        
        // Check if it's a builtin
        if is_builtin(op) {
            return eval_builtin(op, &evaluated_args);
        }
        
        // Otherwise, look up the function in the environment
        let func_val = self.state.env.lookup(op)?.clone();
        
        match func_val {
            Value::Closure { params, body, env: closure_env, self_ref } => {
                if params.len() != evaluated_args.len() {
                    return Err(EvalError::TypeError {
                        msg: format!("Function {} expects {} args, got {}", op, params.len(), evaluated_args.len()),
                    });
                }
                
                // Create new environment with bound parameters
                let mut new_env = closure_env.extend();
                for (param, arg) in params.iter().zip(&evaluated_args) {
                    new_env.bind(param.clone(), arg.clone());
                }
                
                // If this is a recursive function (has self_ref), also bind it
                // so the recursive call can find itself in the extended env.
                if let Some(ref ref_cell) = self_ref {
                    let actual_closure = ref_cell.borrow().clone();
                    new_env.bind(op.to_string(), actual_closure);
                }
                
                let saved_env = std::mem::replace(&mut self.state.env, new_env);
                let result = self.eval(body.as_ref());
                self.state.env = saved_env;
                result
            }
            _ => Err(EvalError::TypeError { msg: format!("{} is not a function", op) }),
        }
    }
    
    /// Convert a runtime value to an FFI argument
    fn eval_to_ffi_arg(&mut self, expr: &Expr) -> Result<FfiArg, EvalError> {
        let val = self.eval(expr)?;
        match val {
            Value::Int(v) => Ok(FfiArg::Int(v)),
            Value::Float(v) => Ok(FfiArg::Float(v)),
            Value::Bool(v) => Ok(FfiArg::Bool(v)),
            Value::StringVal(v) => Ok(FfiArg::String(v)),
            _ => Err(EvalError::FfiError(format!("Cannot convert {:?} to FFI argument", val))),
        }
    }
    
    /// Evaluate a program and return the result
    pub fn eval_program(&mut self, program: &Program) -> Result<Value, EvalError> {
        // Evaluate all definitions first
        for def in &program.defs {
            self.eval(def)?;
        }
        
        // Then evaluate the body
        self.eval(&program.body)
    }
    
    /// Check if a value matches a variant name
    fn match_variant(&self, val: &Value, variant: &str, patterns: &[crate::ast::MatchPattern]) -> bool {
        // Wildcard matches anything
        if variant == "_" {
            return true;
        }
        // Simple variant matching based on the value's structure
        // For ADTs, we encode variant info in the value
        // Also supports literal matching (e.g., match x (0 "zero") ...)
        match val {
            Value::Tuple(fields) => {
                // Check if the first field is the variant tag
                if let Some(Value::StringVal(tag)) = fields.first() {
                    if tag == variant {
                        // Check pattern count matches remaining fields
                        return fields.len() - 1 == patterns.len();
                    }
                }
                false
            }
            Value::StringVal(s) => {
                // For simple variants like None, Red, etc.
                if variant == s {
                    return patterns.is_empty();
                }
                false
            }
            Value::Int(v) => {
                // Literal integer matching: match x (0 "zero") ...
                if let Ok(n) = variant.parse::<i64>() {
                    if *v == n {
                        return patterns.is_empty();
                    }
                }
                false
            }
            Value::Float(v) => {
                // Literal float matching: match x (0.0 "zero") ...
                if let Ok(n) = variant.parse::<f64>() {
                    if (*v - n).abs() < f64::EPSILON {
                        return patterns.is_empty();
                    }
                }
                false
            }
            Value::Bool(b) => {
                // Literal boolean matching
                if variant == "true" && *b {
                    return patterns.is_empty();
                }
                if variant == "false" && !*b {
                    return patterns.is_empty();
                }
                false
            }
            _ => false,
        }
    }
    
    /// Bind match patterns to environment variables
    fn bind_match_patterns(
        &self,
        val: &Value,
        patterns: &[crate::ast::MatchPattern],
        env: &mut Env,
    ) -> Result<(), EvalError> {
        match val {
            Value::Tuple(fields) => {
                // Skip the variant tag (first field)
                let data_fields = &fields[1..];
                for (pattern, field) in patterns.iter().zip(data_fields) {
                    match pattern {
                        crate::ast::MatchPattern::Wildcard => {
                            // No binding
                        }
                        crate::ast::MatchPattern::Bind(name) => {
                            env.bind(name.clone(), field.clone());
                        }
                        crate::ast::MatchPattern::Literal(lit) => {
                            // Check literal matches
                            let lit_val = match lit {
                                AtomKind::Int(v) => Value::Int(*v),
                                AtomKind::Bool(b) => Value::Bool(*b),
                                AtomKind::StringLit(s) => Value::StringVal(s.clone()),
                                _ => continue,
                            };
                            if !values_equal(&lit_val, field) {
                                return Err(EvalError::RuntimeError {
                                    msg: format!("Literal pattern mismatch: {:?} != {:?}", lit_val, field),
                                });
                            }
                        }
                    }
                }
            }
            Value::StringVal(_s) => {
                // For simple variants with no fields
                for pattern in patterns {
                    match pattern {
                        crate::ast::MatchPattern::Bind(name) => {
                            env.bind(name.clone(), val.clone());
                        }
                        _ => {}
                    }
                }
            }
            _ => {
                // For other values, bind the whole value to wildcards
                for pattern in patterns {
                    if let crate::ast::MatchPattern::Bind(name) = pattern {
                        env.bind(name.clone(), val.clone());
                    }
                }
            }
        }
        Ok(())
    }
}

// ============================================================================
// HELPERS
// ============================================================================

fn is_builtin(op: &str) -> bool {
    matches!(op,
        "+" | "-" | "*" | "/" | "%" |
        "==" | "!=" | "<" | ">" | "<=" | ">=" |
        "not" | "and" | "or" |
        "int?" | "float?" | "bool?" | "string?" |
        "len" | "unit" | "print" | "read-line" | "exit" |
        "begin" |
        // List operations
        "first" | "rest" | "nth" | "length" | "cons" | "append" | "list"
    )
}

fn value_to_actor_message(val: Value) -> ActorMessage {
    match val {
        Value::Int(v) => ActorMessage::Int(v),
        Value::Float(v) => ActorMessage::Float(v),
        Value::Bool(v) => ActorMessage::Bool(v),
        Value::StringVal(v) => ActorMessage::String(v),
        Value::Tuple(vals) => ActorMessage::Tuple(vals.into_iter().map(value_to_actor_message).collect()),
        Value::ActorRef(id) => ActorMessage::ActorRef(id),
        Value::Unit => ActorMessage::Unit,
        Value::Closure { .. } => ActorMessage::Unit, // Closures aren't directly sendable
    }
}

/// Compare two values for equality (Value can't derive PartialEq due to Closure)
fn values_equal(a: &Value, b: &Value) -> bool {
    match (a, b) {
        (Value::Int(x), Value::Int(y)) => x == y,
        (Value::Float(x), Value::Float(y)) => {
            // Canonicalize NaN per spec §16
            if x.is_nan() && y.is_nan() { return true; }
            x == y
        }
        (Value::Bool(x), Value::Bool(y)) => x == y,
        (Value::StringVal(x), Value::StringVal(y)) => x == y,
        (Value::Tuple(xs), Value::Tuple(ys)) => {
            xs.len() == ys.len() && xs.iter().zip(ys.iter()).all(|(x, y)| values_equal(x, y))
        }
        (Value::ActorRef(x), Value::ActorRef(y)) => x == y,
        (Value::Unit, Value::Unit) => true,
        // Closures are never equal (different environments)
        (Value::Closure { .. }, Value::Closure { .. }) => false,
        _ => false,
    }
}

fn ffi_result_to_value(result: FfiResult) -> Result<Value, EvalError> {
    match result {
        FfiResult::Int(v) => Ok(Value::Int(v)),
        FfiResult::Float(v) => Ok(Value::Float(v)),
        FfiResult::Bool(v) => Ok(Value::Bool(v)),
        FfiResult::String(v) => Ok(Value::StringVal(v)),
        FfiResult::Buffer(_) => Ok(Value::Unit),
        FfiResult::Unit => Ok(Value::Unit),
        FfiResult::Error(e) => Err(EvalError::FfiError(e.to_string())),
    }
}

// ============================================================================
// TESTING FRAMEWORK DATA STRUCTURES & HELPERS (§20.5 — v3.3)
// ============================================================================

#[derive(Debug, Clone)]
pub enum TestKind {
    Suite(String),
    Test(String),
}

#[derive(Debug, Clone)]
pub struct TestRegistration {
    pub kind: TestKind,
    pub tests: Vec<Expr>,
    pub keywords: Vec<(String, String)>,
}

#[derive(Debug, Clone)]
pub struct TestResult {
    pub name: String,
    pub passed: bool,
    pub duration_ms: f64,
    pub error_msg: Option<String>,
}

/// Generate random values for property-based testing
fn generate_values(generator: &crate::ast::Generator, count: usize) -> Vec<Value> {
    use std::time::{SystemTime, UNIX_EPOCH};
    let seed = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos() as u64;
    
    let mut values = Vec::with_capacity(count);
    for i in 0..count {
        let val = match generator {
            crate::ast::Generator::GenInt => {
                Value::Int(((seed.wrapping_add(i as u64)) % 1000) as i64 - 500)
            }
            crate::ast::Generator::GenBool => {
                Value::Bool((i % 2) == 0)
            }
            crate::ast::Generator::GenString => {
                Value::StringVal(format!("test-{}", i))
            }
            crate::ast::Generator::GenFloat => {
                Value::Float(((seed.wrapping_add(i as u64)) % 1000) as f64 / 10.0 - 50.0)
            }
        };
        values.push(val);
    }
    values
}

/// Run the test suite and collect results
impl<'a> Evaluator<'a> {
    fn run_test_suite(&mut self, _verbose: bool, fail_fast: bool, _parallel: bool) -> Result<Vec<TestResult>, EvalError> {
        let mut results = Vec::new();
        
        // Collect all tests from registry
        let mut all_tests: Vec<(String, Expr, Vec<(String, String)>)> = Vec::new();
        for reg in &self.state.test_registry {
            match &reg.kind {
                TestKind::Suite(name) => {
                    for test in &reg.tests {
                        if let Expr::Test { name: tname, body, keywords } = test {
                            all_tests.push((format!("{}/{}", name, tname), body.as_ref().clone(), keywords.clone()));
                        }
                    }
                }
                TestKind::Test(_name) => {
                    if let Some(test) = reg.tests.first() {
                        if let Expr::Test { name: tname, body, keywords } = test {
                            all_tests.push((tname.clone(), body.as_ref().clone(), keywords.clone()));
                        }
                    }
                }
            }
        }
        
        // Execute each test
        for (name, body, _keywords) in &all_tests {
            let start = std::time::Instant::now();
            
            // Create fresh environment for isolation
            let mut new_state = EvalState::with_env(self.state.env.extend());
            let mut new_evaluator = Evaluator::new(&mut new_state);
            
            let result = new_evaluator.eval(&body);
            let duration = start.elapsed().as_millis() as f64;
            
            let passed = result.is_ok();
            let error_msg = if let Err(e) = result {
                Some(e.to_string())
            } else {
                None
            };
            
            results.push(TestResult {
                name: name.clone(),
                passed,
                duration_ms: duration,
                error_msg,
            });
            
            if !passed && fail_fast {
                break;
            }
        }
        
        Ok(results)
    }
}

/// Print test results in TAP format (+ detailed if verbose)
fn print_test_results(results: &[TestResult], verbose: bool) {
    let total = results.len();
    let passed = results.iter().filter(|r| r.passed).count();
    let failed = total - passed;
    
    // TAP output (always)
    for (i, result) in results.iter().enumerate() {
        if result.passed {
            println!("ok {} {}", i + 1, result.name);
        } else {
            println!("not ok {} {} - {}", i + 1, result.name, result.error_msg.as_deref().unwrap_or("unknown"));
        }
    }
    println!("1..{}", total);
    
    // Detailed output (when verbose)
    if verbose {
        println!();
        for result in results {
            let status = if result.passed { "PASS" } else { "FAIL" };
            let dots = ".".repeat(15 - result.name.len().min(15));
            if result.passed {
                println!("  test: {} {}... {} ({:.3}s)", result.name, dots, status, result.duration_ms / 1000.0);
            } else {
                println!("  test: {} {}... {} ({:.3}s) - {}", result.name, dots, status, result.duration_ms / 1000.0, result.error_msg.as_deref().unwrap_or("unknown"));
            }
        }
        println!();
        println!("Summary: {} tests, {} passed, {} failed", total, passed, failed);
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Evaluate a Zyl expression
pub fn evaluate(expr: &Expr) -> Result<Value, EvalError> {
    let mut state = EvalState::new();
    let mut evaluator = Evaluator::new(&mut state);
    evaluator.eval(expr)
}

/// Evaluate a Zyl program
pub fn evaluate_program(program: &Program) -> Result<Value, EvalError> {
    let mut state = EvalState::new();
    let mut evaluator = Evaluator::new(&mut state);
    evaluator.eval_program(program)
}


