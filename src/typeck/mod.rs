//! Type system for Zyl
//! 
//! Hindley-Milner-like inference with region + capability constraints.
//! Per specification section 4.

use crate::ast::*;
use std::collections::HashMap;
use thiserror::Error;

// ============================================================================
// TYPE VARIABLES AND CONSTRAINTS
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct TypeVarId(pub usize);

impl std::fmt::Display for TypeVarId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "α{}", self.0)
    }
}

#[allow(dead_code)]
/// A type in the inference system
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Ty {
    /// Primitive types
    Prim(PrimType),
    
    /// Type variable (for inference)
    Var(TypeVarId),
    
    /// Capability wrapper: TCap<T>, TMut<T>, etc.
    Cap { cap: CapType, inner: Box<Ty> },
    
    /// Function type: TFun([T*], TReturn)
    Fun { args: Vec<Ty>, ret: Box<Ty> },
    
    /// Tuple type
    Tuple(Vec<Ty>),
    
    /// Region-annotated type
    Region { inner: Box<Ty>, region: Region },
    
    /// Actor reference type
    ActorRef,
    
    /// Address type (Region, ID)
    Address { region: Region, id: TypeVarId },
    
    /// Generic type parameter
    Generic(String),
}

#[allow(dead_code)]
impl Ty {
    pub fn prim(t: PrimType) -> Self {
        Ty::Prim(t)
    }
    
    pub fn var(id: TypeVarId) -> Self {
        Ty::Var(id)
    }
    
    pub fn cap(cap: CapType, inner: Ty) -> Self {
        Ty::Cap { cap, inner: Box::new(inner) }
    }
    
    pub fn fun(args: Vec<Ty>, ret: Ty) -> Self {
        Ty::Fun { args, ret: Box::new(ret) }
    }
    
    pub fn actor_ref() -> Self {
        Ty::ActorRef
    }
}

impl std::fmt::Display for Ty {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Ty::Prim(t) => write!(f, "{}", t),
            Ty::Var(id) => write!(f, "{}", id),
            Ty::Cap { cap, inner } => write!(f, "{}<{}>", cap, inner),
            Ty::Fun { args, ret } => {
                let args_str: Vec<String> = args.iter().map(|t| t.to_string()).collect();
                write!(f, "TFun([{}], {})", args_str.join(", "), ret)
            }
            Ty::Tuple(types) => {
                let types_str: Vec<String> = types.iter().map(|t| t.to_string()).collect();
                write!(f, "({})", types_str.join(", "))
            }
            Ty::Region { inner, region } => write!(f, "{}@{}", inner, region),
            Ty::ActorRef => write!(f, "ActorRef"),
            Ty::Address { region, id } => write!(f, "Address({}, {})", region, id),
            Ty::Generic(name) => write!(f, "{}", name),
        }
    }
}

// ============================================================================
// TYPE ENVIRONMENT
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone)]
pub struct TypeEnv {
    /// Variable -> Type mapping
    bindings: HashMap<String, Ty>,
    /// Generic type parameters in scope
    generics: Vec<String>,
}

#[allow(dead_code)]
impl TypeEnv {
    pub fn new() -> Self {
        Self {
            bindings: HashMap::new(),
            generics: Vec::new(),
        }
    }
    
    pub fn empty() -> Self {
        Self::new()
    }
    
    pub fn with_binding(&self, name: String, ty: Ty) -> Self {
        let mut new = self.clone();
        new.bindings.insert(name, ty);
        new
    }
    
    pub fn get(&self, name: &str) -> Option<&Ty> {
        self.bindings.get(name)
    }
    
    pub fn insert(&mut self, name: String, ty: Ty) {
        self.bindings.insert(name, ty);
    }
    
    pub fn extend(&self) -> Self {
        Self {
            bindings: self.bindings.clone(),
            generics: self.generics.clone(),
        }
    }
    
    pub fn with_generics(mut self, generics: Vec<String>) -> Self {
        self.generics = generics;
        self
    }
}

// ============================================================================
// TYPE SUBSTITUTION (for HM inference)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone, Default)]
pub struct Substitution {
    map: HashMap<TypeVarId, Ty>,
}

#[allow(dead_code)]
impl Substitution {
    pub fn new() -> Self {
        Self::default()
    }
    
    pub fn extend(&self, id: TypeVarId, ty: Ty) -> Self {
        let mut map = self.map.clone();
        map.insert(id, ty);
        Self { map }
    }
    
    pub fn apply(&self, ty: &Ty) -> Ty {
        match ty {
            Ty::Var(id) => {
                if let Some(replacement) = self.map.get(id) {
                    self.apply(replacement)
                } else {
                    ty.clone()
                }
            }
            Ty::Cap { cap, inner } => Ty::Cap {
                cap: cap.clone(),
                inner: Box::new(self.apply(inner)),
            },
            Ty::Fun { args, ret } => Ty::Fun {
                args: args.iter().map(|a| self.apply(a)).collect(),
                ret: Box::new(self.apply(ret)),
            },
            Ty::Tuple(types) => Ty::Tuple(types.iter().map(|t| self.apply(t)).collect()),
            Ty::Region { inner, region } => Ty::Region {
                inner: Box::new(self.apply(inner)),
                region: *region,
            },
            other => other.clone(),
        }
    }
    
    pub fn compose(&self, other: &Substitution) -> Self {
        let mut map = self.map.clone();
        for (id, ty) in &other.map {
            map.insert(*id, self.apply(ty));
        }
        Self { map }
    }
    
    pub fn is_empty(&self) -> bool {
        self.map.is_empty()
    }
}

// ============================================================================
// TYPE CONSTRAINTS
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone)]
pub enum Constraint {
    /// Types must be equal
    Equal(Ty, Ty),
    /// Type must be a subtype of another
    #[allow(dead_code)]
    Subtype(Ty, Ty),
    /// Type must be sendable (for actor messages)
    Sendable(Ty),
    /// Type must be FFI-pinnable
    Pinnable(Ty),
    /// Region constraint: type must live in region
    InRegion(Ty, Region),
}

impl std::fmt::Display for Constraint {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Constraint::Equal(t1, t2) => write!(f, "{} = {}", t1, t2),
            Constraint::Subtype(t1, t2) => write!(f, "{} <: {}", t1, t2),
            Constraint::Sendable(t) => write!(f, "Sendable({})", t),
            Constraint::Pinnable(t) => write!(f, "Pinnable({})", t),
            Constraint::InRegion(t, r) => write!(f, "{} @ {}", t, r),
        }
    }
}

// ============================================================================
// TYPE ERRORS (Section 19)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Error)]
pub enum TypeError {
    #[error("Type mismatch: expected {expected}, got {got}")]
    TypeMismatch { expected: Ty, got: Ty },
    
    #[error("Undefined variable: {name}")]
    UndefinedVariable { name: String },
    
    #[allow(dead_code)]
    #[error("Mutable conflict for variable: {name}")]
    MutConflict { name: String },
    
    #[allow(dead_code)]
    #[error("Region escape: value escapes to {expected}, assigned to {actual}")]
    RegionEscape { expected: Region, actual: Region },
    
    #[error("Type not sendable for actor communication: {ty}")]
    NotSendable { ty: Ty },
    
    #[error("Type not FFI-pinnable: {ty}")]
    NotPinnable { ty: Ty },
    
    #[error("Unification failed: {msg}")]
    UnificationFailed { msg: String },
    
    #[error("Infinite type detected")]
    OccursCheck,
}

// ============================================================================
// TYPE INFERENCER (Hindley-Milner with regions and capabilities)
// ============================================================================

pub struct TypeInferencer {
    env: TypeEnv,
    constraints: Vec<Constraint>,
    substitutions: Substitution,
    type_var_counter: usize,
}

impl TypeInferencer {
    pub fn new() -> Self {
        Self {
            env: TypeEnv::new(),
            constraints: Vec::new(),
            substitutions: Substitution::new(),
            type_var_counter: 0,
        }
    }
    
    /// Generate a fresh type variable
    fn fresh_var(&mut self) -> TypeVarId {
        let id = TypeVarId(self.type_var_counter);
        self.type_var_counter += 1;
        id
    }
    
    /// Infer the type of an expression
    pub fn infer(&mut self, expr: &Expr) -> Result<Ty, TypeError> {
        match expr {
            Expr::Atom(kind) => self.infer_atom(kind),
            Expr::App(op, args) => self.infer_app(op, args),
            Expr::AppExpr(operator, args) => {
                // Infer the operator type (should be a function)
                let op_ty = self.infer(operator)?;
                // Infer argument types
                let arg_tys: Vec<Ty> = args.iter()
                    .map(|a| self.infer(a))
                    .collect::<Result<Vec<_>, _>>()?;
                // The operator should be a function that accepts these args
                let ret_ty = Ty::Var(self.fresh_var());
                self.constraints.push(Constraint::Equal(op_ty, Ty::Fun { args: arg_tys, ret: Box::new(ret_ty.clone()) }));
                Ok(ret_ty)
            }
            Expr::Def(name, body) => {
                let body_ty = self.infer(body)?;
                // Add the defined name to the environment for later references
                self.env.insert(name.clone(), body_ty.clone());
                Ok(body_ty)
            }
            Expr::Defn { name, params, body, ret_type } => {
                // Create parameter types
                let param_types: Vec<Ty> = (0..params.len())
                    .map(|_| Ty::Var(self.fresh_var()))
                    .collect();
                
                // Compute the function type (will be refined by constraints)
                let func_ty = Ty::Fun { args: param_types.clone(), ret: Box::new(Ty::Var(self.fresh_var())) };
                
                // Extend environment with parameters AND the function name itself (for recursion)
                let mut env = self.env.extend();
                for (param, ty) in params.iter().zip(&param_types) {
                    env = env.with_binding(param.clone(), ty.clone());
                }
                // Add the function name to enable recursive calls
                env = env.with_binding(name.clone(), func_ty.clone());
                
                let saved_env = std::mem::replace(&mut self.env, env.clone());
                let body_ty = self.infer(body)?;
                
                // Restore environment but keep the function name bound for later references
                self.env = env;
                
                // If return type is specified, add constraint
                if let Some(ret) = ret_type {
                    let ret_ty = self.type_from_expr(ret)?;
                    self.constraints.push(Constraint::Equal(body_ty.clone(), ret_ty));
                }
                
                // Add constraint that body type equals function return type
                if let Ty::Fun { ret, .. } = &func_ty {
                    self.constraints.push(Constraint::Equal(ret.as_ref().clone(), body_ty.clone()));
                }
                
                Ok(Ty::Fun { args: param_types, ret: Box::new(body_ty) })
            }
            Expr::Let { name, value, body } => {
                let val_ty = self.infer(value)?;
                let new_env = self.env.with_binding(name.clone(), val_ty);
                let saved_env = std::mem::replace(&mut self.env, new_env);
                let body_ty = self.infer(body)?;
                self.env = saved_env;
                Ok(body_ty)
            }
            Expr::LetMut { name, value, body } => {
                let val_ty = self.infer(value)?;
                // Wrap in TMut for mutable binding
                let mut_ty = Ty::Cap { cap: CapType::Mutable, inner: Box::new(val_ty) };
                let new_env = self.env.with_binding(name.clone(), mut_ty);
                let saved_env = std::mem::replace(&mut self.env, new_env);
                let body_ty = self.infer(body)?;
                self.env = saved_env;
                Ok(body_ty)
            }
            Expr::If { cond, then_branch, else_branch } => {
                let cond_ty = self.infer(cond)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                
                let then_ty = self.infer(then_branch)?;
                let else_ty = self.infer(else_branch)?;
                self.constraints.push(Constraint::Equal(then_ty, else_ty.clone()));
                
                Ok(else_ty)
            }
            Expr::TryCatch { body, catch_var: _, handler } => {
                let body_ty = self.infer(body)?;
                let handler_ty = self.infer(handler)?;
                // Both must have the same type (or handler is Unit)
                self.constraints.push(Constraint::Equal(body_ty.clone(), handler_ty));
                Ok(body_ty)
            }
            Expr::Spawn(body) => {
                let body_ty = self.infer(body)?;
                self.constraints.push(Constraint::Sendable(body_ty));
                Ok(Ty::actor_ref())
            }
            Expr::Send { target, message } => {
                let target_ty = self.infer(target)?;
                let msg_ty = self.infer(message)?;
                self.constraints.push(Constraint::Sendable(msg_ty));
                // Target must be ActorRef
                self.constraints.push(Constraint::Equal(target_ty, Ty::actor_ref()));
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::FfiCall { name: _, args, timeout_ms: _ } => {
                for arg in args {
                    let arg_ty = self.infer(arg)?;
                    self.constraints.push(Constraint::Pinnable(arg_ty.clone()));
                    self.constraints.push(Constraint::InRegion(arg_ty, Region::Pin));
                }
                // FFI call returns a fresh type (unknown to the type system)
                Ok(Ty::Var(self.fresh_var()))
            }
            Expr::FfiPin(expr) => {
                let expr_ty = self.infer(expr)?;
                self.constraints.push(Constraint::InRegion(expr_ty, Region::Pin));
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::Assert { condition, message: _ } => {
                let cond_ty = self.infer(condition)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                Ok(Ty::prim(PrimType::Unit))
            }
            
            // Closures (§7)
            Expr::Fn { params, body } => {
                let param_types: Vec<Ty> = (0..params.len())
                    .map(|_| Ty::Var(self.fresh_var()))
                    .collect();
                
                // Extend environment with lambda parameters
                let mut new_env = self.env.clone();
                for (param, ty) in params.iter().zip(&param_types) {
                    new_env.insert(param.clone(), ty.clone());
                }
                
                let saved_env = std::mem::replace(&mut self.env, new_env);
                let body_ty = self.infer(body)?;
                self.env = saved_env;
                
                Ok(Ty::Fun { args: param_types, ret: Box::new(body_ty) })
            }
            
            // While loop (§12.5)
            Expr::While { condition, body } => {
                let cond_ty = self.infer(condition)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                self.infer(body)?;
                Ok(Ty::prim(PrimType::Unit))
            }
            
            // For loop (§12.6)
            Expr::For { name, iterator, body } => {
                let _iter_ty = self.infer(iterator)?;
                let fresh_ty = Ty::Var(self.fresh_var());
                let new_env = self.env.with_binding(name.clone(), fresh_ty);
                let saved_env = std::mem::replace(&mut self.env, new_env);
                let _body_ty = self.infer(body)?;
                self.env = saved_env;
                Ok(Ty::prim(PrimType::Unit))
            }
            
            // Cond (§12.7)
            Expr::Cond(clauses) => {
                let result_ty = Ty::Var(self.fresh_var());
                for (cond, body) in clauses {
                    let cond_ty = self.infer(cond)?;
                    self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                    let body_ty = self.infer(body)?;
                    self.constraints.push(Constraint::Equal(result_ty.clone(), body_ty));
                }
                Ok(result_ty)
            }
            
            // Match (§8.3)
            Expr::Match { scrutinee, clauses } => {
                let _scrut_ty = self.infer(scrutinee)?;
                let result_ty = Ty::Var(self.fresh_var());
                for clause in clauses {
                    for pattern in &clause.patterns {
                        if let crate::ast::MatchPattern::Bind(name) = pattern {
                            let pat_ty = Ty::Var(self.fresh_var());
                            let new_env = self.env.with_binding(name.clone(), pat_ty);
                            let saved_env = std::mem::replace(&mut self.env, new_env);
                            let _body_ty = self.infer(clause.body.as_ref())?;
                            self.constraints.push(Constraint::Equal(result_ty.clone(), _body_ty));
                            self.env = saved_env;
                        } else {
                            let body_ty = self.infer(clause.body.as_ref())?;
                            self.constraints.push(Constraint::Equal(result_ty.clone(), body_ty));
                        }
                    }
                }
                Ok(result_ty)
            }
            
            // Deftype, TraitDecl, Impl - compile-time only
            Expr::Deftype { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::TraitDecl { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::Impl { .. } => Ok(Ty::prim(PrimType::Unit)),
            
            // Use/Export/Pub - handled at module level
            Expr::Use { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::Export(body) => self.infer(body),
            Expr::Pub(body) => self.infer(body),
            
            // Contracts (§23)
            Expr::Requires(condition) => {
                let cond_ty = self.infer(condition)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::Ensures { condition: _, body } => self.infer(body),
            Expr::Invariant(_) => Ok(Ty::prim(PrimType::Unit)),
            Expr::Recover { handlers, body } => {
                let _ = handlers;
                self.infer(body)
            }
            Expr::Checkpoint(body) => self.infer(body),
            Expr::Contracts(_) => Ok(Ty::prim(PrimType::Unit)),
            
            // Begin (§12.8)
            Expr::Begin(exprs) => {
                if exprs.is_empty() {
                    Ok(Ty::prim(PrimType::Unit))
                } else {
                    for expr in &exprs[..exprs.len()-1] {
                        self.infer(expr)?;
                    }
                    self.infer(&exprs[exprs.len()-1])
                }
            }
            
            // Testing framework (§20.5 — v3.3)
            Expr::TestSuite { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::Test { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::AssertEqual { expected, actual } => {
                let _exp_ty = self.infer(expected)?;
                let _act_ty = self.infer(actual)?;
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::AssertFail { expr, .. } => {
                let _expr_ty = self.infer(expr)?;
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::AssertTrue { expr, .. } => {
                let cond_ty = self.infer(expr)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::AssertFalse { expr, .. } => {
                let cond_ty = self.infer(expr)?;
                self.constraints.push(Constraint::Equal(cond_ty, Ty::prim(PrimType::Bool)));
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::TestProperty { property_fn, .. } => {
                let fn_ty = self.infer(property_fn)?;
                // Property function should return Bool
                if let Ty::Fun { ret, .. } = &fn_ty {
                    self.constraints.push(Constraint::Equal(*ret.clone(), Ty::prim(PrimType::Bool)));
                }
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::Setup(bodies) => {
                for body in bodies {
                    self.infer(body)?;
                }
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::Teardown(bodies) => {
                for body in bodies {
                    self.infer(body)?;
                }
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::RunTests { .. } => Ok(Ty::prim(PrimType::Unit)),
            Expr::TestCompile { expr, .. } => {
                let _expr_ty = self.infer(expr)?;
                Ok(Ty::prim(PrimType::Unit))
            }
            Expr::Quote(inner) => self.infer(inner),
        }
    }
    
    /// Infer type of an atom literal
    fn infer_atom(&self, kind: &AtomKind) -> Result<Ty, TypeError> {
        match kind {
            AtomKind::Int(_) => Ok(Ty::prim(PrimType::Int)),
            AtomKind::Float(_) => Ok(Ty::prim(PrimType::Float)),
            AtomKind::Bool(_) => Ok(Ty::prim(PrimType::Bool)),
            AtomKind::StringLit(_) => Ok(Ty::prim(PrimType::String)),
            AtomKind::Ident(name) => {
                self.env.get(name).cloned().ok_or_else(|| TypeError::UndefinedVariable {
                    name: name.clone(),
                })
            }
        }
    }
    
    /// Infer type of a function application
    fn infer_app(&mut self, op: &str, args: &[Expr]) -> Result<Ty, TypeError> {
        // Check for built-in operations
        if let Some(builtin_ty) = self.get_builtin_type(op) {
            return self.check_builtin(op, &builtin_ty, args);
        }
        
        // Otherwise, treat as a variable reference to a function
        let func_ty = self.env.get(op).cloned().ok_or_else(|| TypeError::UndefinedVariable {
            name: op.to_string(),
        })?;
        
        // Infer argument types
        let arg_tys: Vec<Ty> = args.iter().map(|a| self.infer(a)).collect::<Result<Vec<_>, _>>()?;
        
        // Check that function type matches
        match func_ty {
            Ty::Fun { args: expected_args, ret } => {
                if expected_args.len() != arg_tys.len() {
                    return Err(TypeError::TypeMismatch {
                        expected: Ty::Fun { args: expected_args, ret: ret.clone() },
                        got: Ty::Fun { args: arg_tys.clone(), ret: ret.clone() },
                    });
                }
                
                // Check each argument type
                for (expected, actual) in expected_args.iter().zip(&arg_tys) {
                    self.constraints.push(Constraint::Equal(expected.clone(), actual.clone()));
                }
                
                Ok(*ret.clone())
            }
            Ty::Var(_) => {
                // Fresh function type variable
                let ret = Ty::Var(self.fresh_var());
                let expected_args: Vec<Ty> = (0..arg_tys.len()).map(|_| Ty::Var(self.fresh_var())).collect();
                
                for (expected, actual) in expected_args.iter().zip(&arg_tys) {
                    self.constraints.push(Constraint::Equal(expected.clone(), actual.clone()));
                }
                
                Ok(ret)
            }
            other => Err(TypeError::TypeMismatch {
                expected: Ty::Fun { args: vec![], ret: Box::new(other.clone()) },
                got: Ty::Fun { args: arg_tys, ret: Box::new(other.clone()) },
            }),
        }
    }
    
    /// Get built-in operation types
    fn get_builtin_type(&mut self, op: &str) -> Option<Ty> {
        match op {
            "+" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "-" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "*" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "/" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "%" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "==" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "!=" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "<" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            ">" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "<=" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            ">=" => Some(Ty::Fun { args: vec![Ty::prim(PrimType::Int), Ty::prim(PrimType::Int)], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "not" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "and" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "or" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Bool)) }),
            "print" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Unit)) }),
            "len" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var())], ret: Box::new(Ty::prim(PrimType::Int)) }),
            // List operations
            "first" => Some(Ty::Fun { args: vec![Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])], ret: Box::new(Ty::Var(self.fresh_var())) }),
            "rest" => Some(Ty::Fun { args: vec![Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])], ret: Box::new(Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])) }),
            "nth" => Some(Ty::Fun { args: vec![Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())]), Ty::prim(PrimType::Int)], ret: Box::new(Ty::Var(self.fresh_var())) }),
            "length" => Some(Ty::Fun { args: vec![Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])], ret: Box::new(Ty::prim(PrimType::Int)) }),
            "cons" => Some(Ty::Fun { args: vec![Ty::Var(self.fresh_var()), Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])], ret: Box::new(Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])) }),
            "append" => Some(Ty::Fun { args: vec![Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())]), Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])], ret: Box::new(Ty::Tuple(vec![Ty::Var(self.fresh_var()), Ty::Var(self.fresh_var())])) }),
            "list" => Some(Ty::Fun { args: vec![], ret: Box::new(Ty::Tuple(vec![])) }),
            _ => None,
        }
    }
    
    /// Check builtin application against its type
    fn check_builtin(&mut self, _op: &str, builtin_ty: &Ty, args: &[Expr]) -> Result<Ty, TypeError> {
        match builtin_ty {
            Ty::Fun { args: expected_args, ret } => {
                if expected_args.len() != args.len() {
                    return Err(TypeError::TypeMismatch {
                        expected: Ty::Fun { args: expected_args.clone(), ret: ret.clone() },
                        got: Ty::Fun { args: vec![], ret: ret.clone() },
                    });
                }
                
                let arg_tys: Vec<Ty> = args.iter().map(|a| self.infer(a)).collect::<Result<Vec<_>, _>>()?;
                
                for (expected, actual) in expected_args.iter().zip(&arg_tys) {
                    self.constraints.push(Constraint::Equal(expected.clone(), actual.clone()));
                }
                
                Ok(*ret.clone())
            }
            other => Err(TypeError::TypeMismatch {
                expected: Ty::Fun { args: vec![], ret: Box::new(other.clone()) },
                got: Ty::Fun { args: vec![], ret: Box::new(other.clone()) },
            }),
        }
    }
    
    /// Convert a type expression to an internal type
    fn type_from_expr(&self, expr: &TypeExpr) -> Result<Ty, TypeError> {
        match expr {
            TypeExpr::Prim(p) => Ok(Ty::prim(p.clone())),
            TypeExpr::Cap { cap, inner } => {
                let inner_ty = self.type_from_expr(inner)?;
                Ok(Ty::Cap { cap: cap.clone(), inner: Box::new(inner_ty) })
            }
            TypeExpr::Fun { args, ret } => {
                let arg_tys: Result<Vec<Ty>, _> = args.iter().map(|a| self.type_from_expr(a)).collect();
                let ret_ty = self.type_from_expr(ret)?;
                Ok(Ty::Fun { args: arg_tys?, ret: Box::new(ret_ty) })
            }
            TypeExpr::Tuple(types) => {
                let tys: Result<Vec<Ty>, _> = types.iter().map(|t| self.type_from_expr(t)).collect();
                Ok(Ty::Tuple(tys?))
            }
            TypeExpr::Region { inner, region } => {
                let inner_ty = self.type_from_expr(inner)?;
                Ok(Ty::Region { inner: Box::new(inner_ty), region: *region })
            }
            TypeExpr::Generic(name) => Ok(Ty::Generic(name.clone())),
            TypeExpr::App { name, args } => {
                let arg_tys: Result<Vec<Ty>, _> = args.iter().map(|a| self.type_from_expr(a)).collect();
                Ok(Ty::Generic(format!("{}<{}>", name, arg_tys?.iter().map(|t| t.to_string()).collect::<Vec<_>>().join(", "))))
            }
        }
    }
    
    /// Solve constraints and produce final substitution
    pub fn solve(&mut self) -> Result<Substitution, TypeError> {
        // Simple unification loop
        while !self.constraints.is_empty() {
            let constraint = self.constraints.remove(0);
            match constraint {
                Constraint::Equal(t1, t2) => {
                    self.unify(&t1, &t2)?;
                }
                Constraint::Subtype(t1, t2) => {
                    // For now, subtype is equality
                    self.unify(&t1, &t2)?;
                }
                Constraint::Sendable(ty) => {
                    // Check if type is sendable (no mutable references, no closures with captures)
                    if !self.is_sendable(&ty) {
                        return Err(TypeError::NotSendable { ty });
                    }
                }
                Constraint::Pinnable(ty) => {
                    // Only primitives and pinned types are FFI-pinnable
                    if !self.is_pinnable(&ty) {
                        return Err(TypeError::NotPinnable { ty });
                    }
                }
                Constraint::InRegion(ty, region) => {
                    let fresh = Ty::Var(self.fresh_var());
                    self.constraints.push(Constraint::Equal(ty, Ty::Region {
                        inner: Box::new(fresh),
                        region,
                    }));
                }
            }
        }
        
        Ok(std::mem::take(&mut self.substitutions))
    }
    
    /// Unify two types (core HM algorithm)
    fn unify(&mut self, t1: &Ty, t2: &Ty) -> Result<(), TypeError> {
        match (t1, t2) {
            // Same type - trivially unifiable
            (a, b) if a == b => Ok(()),
            
            // Type variable on left
            (Ty::Var(id), ty) | (ty, Ty::Var(id)) => {
                if self.occurs_check(id, ty) {
                    return Err(TypeError::OccursCheck);
                }
                let id_val = *id;
                self.substitutions = self.substitutions.extend(id_val, ty.clone());
                Ok(())
            }
            
            // Both function types
            (Ty::Fun { args: a1, ret: r1 }, Ty::Fun { args: a2, ret: r2 }) => {
                if a1.len() != a2.len() {
                    return Err(TypeError::UnificationFailed {
                        msg: format!("Function arity mismatch: {} vs {}", a1.len(), a2.len()),
                    });
                }
                for (x, y) in a1.iter().zip(a2.iter()) {
                    self.unify(x, y)?;
                }
                self.unify(r1.as_ref(), r2.as_ref())
            }
            
            // Both tuples
            (Ty::Tuple(t1s), Ty::Tuple(t2s)) => {
                if t1s.len() != t2s.len() {
                    return Err(TypeError::UnificationFailed {
                        msg: format!("Tuple size mismatch: {} vs {}", t1s.len(), t2s.len()),
                    });
                }
                for (x, y) in t1s.iter().zip(t2s.iter()) {
                    self.unify(x, y)?;
                }
                Ok(())
            }
            
            // Capability wrappers must match
            (Ty::Cap { cap: c1, inner: i1 }, Ty::Cap { cap: c2, inner: i2 }) => {
                if c1 != c2 {
                    return Err(TypeError::UnificationFailed {
                        msg: format!("Capability mismatch: {} vs {}", c1, c2),
                    });
                }
                self.unify(i1, i2)
            }
            
            // Region annotations must match
            (Ty::Region { inner: i1, region: r1 }, Ty::Region { inner: i2, region: r2 }) => {
                if r1 != r2 {
                    return Err(TypeError::UnificationFailed {
                        msg: format!("Region mismatch: {} vs {}", r1, r2),
                    });
                }
                self.unify(i1, i2)
            }
            
            // Everything else - type error
            (t1, t2) => Err(TypeError::TypeMismatch {
                expected: t1.clone(),
                got: t2.clone(),
            }),
        }
    }
    
    /// Occurs check: does type variable occur in type?
    fn occurs_check(&self, id: &TypeVarId, ty: &Ty) -> bool {
        match ty {
            Ty::Var(v) => v == id,
            Ty::Cap { inner, .. } | Ty::Region { inner, .. } => self.occurs_check(id, inner),
            Ty::Fun { args, ret } => {
                args.iter().any(|a| self.occurs_check(id, a)) || self.occurs_check(id, ret)
            }
            Ty::Tuple(types) => types.iter().any(|t| self.occurs_check(id, t)),
            _ => false,
        }
    }
    
    /// Check if a type is sendable (can be sent between actors)
    fn is_sendable(&self, ty: &Ty) -> bool {
        match ty {
            Ty::Prim(_) | Ty::ActorRef => true,
            Ty::Var(_) => true, // Assume sendable until proven otherwise
            Ty::Cap { cap, inner } => {
                // Only immutable and atomic are sendable
                matches!(cap, CapType::Immutable | CapType::Atomic) && self.is_sendable(inner)
            }
            Ty::Fun { .. } => false, // Closures may capture non-sendable state
            Ty::Tuple(types) => types.iter().all(|t| self.is_sendable(t)),
            Ty::Region { inner, region } => {
                *region != Region::Stack && self.is_sendable(inner)
            }
            _ => true,
        }
    }
    
    /// Check if a type is FFI-pinnable
    fn is_pinnable(&self, ty: &Ty) -> bool {
        matches!(ty, Ty::Prim(PrimType::Int | PrimType::Float | PrimType::Bool))
            || matches!(ty, Ty::Cap { cap: CapType::Pinned, .. })
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Type-check an expression and return its type
#[allow(dead_code)]
pub fn check(expr: &Expr) -> Result<Ty, TypeError> {
    let mut inferencer = TypeInferencer::new();
    let ty = inferencer.infer(expr)?;
    inferencer.solve()?;
    Ok(ty)
}

/// Type-check a program and return the environment
pub fn check_program(program: &Program) -> Result<(TypeEnv, Substitution), TypeError> {
    let mut inferencer = TypeInferencer::new();
    
    // Check all definitions first
    for def in &program.defs {
        inferencer.infer(def)?;
    }
    
    // Then check the body
    inferencer.infer(&program.body)?;
    
    let substitutions = inferencer.solve()?;
    
    Ok((inferencer.env, substitutions))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::AtomKind;
    
    #[test]
    fn test_infer_int() {
        let expr = Expr::Atom(AtomKind::Int(42));
        let ty = check(&expr).unwrap();
        assert_eq!(ty, Ty::prim(PrimType::Int));
    }
    
    #[test]
    fn test_infer_addition() {
        let expr = Expr::App("+".into(), vec![
            Expr::Atom(AtomKind::Int(1)),
            Expr::Atom(AtomKind::Int(2)),
        ]);
        let ty = check(&expr).unwrap();
        assert_eq!(ty, Ty::prim(PrimType::Int));
    }
    
    #[test]
    fn test_infer_let() {
        let expr = Expr::Let {
            name: "x".into(),
            value: Box::new(Expr::Atom(AtomKind::Int(5))),
            body: Box::new(Expr::App("+".into(), vec![
                Expr::Atom(AtomKind::Ident("x".into())),
                Expr::Atom(AtomKind::Int(1)),
            ])),
        };
        let ty = check(&expr).unwrap();
        assert_eq!(ty, Ty::prim(PrimType::Int));
    }
    
    #[test]
    fn test_infer_undefined_var() {
        let expr = Expr::Atom(AtomKind::Ident("undefined".into()));
        assert!(check(&expr).is_err());
    }
}
