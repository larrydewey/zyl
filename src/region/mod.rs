//! Region inference for Zyl
//! 
//! Per specification sections 5 and 5.1:
//! - R1: Local stack allocation (no escape)
//! - R2: Escape allocation (returned or captured)
//! - R3: Actor transfer requires Send-capable type
//! - R4: FFI rule requires Pin region

use crate::ast::*;

use std::collections::HashMap;
use thiserror::Error;

// ============================================================================
// REGION INFERENCE ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error)]
pub enum RegionError {
    #[error("Region escape: variable '{name}' escapes from {from} to {to}")]
    EscapeViolation { name: String, from: Region, to: Region },
    
    #[error("Variable '{name}' used after mutation in region {region}")]
    UseAfterMutate { name: String, region: Region },
    
    #[error("FFI call requires pinned memory for argument: {name}")]
    FfiUnpinnable { name: String },
    
    #[error("Actor transfer requires Send-capable type for '{name}'")]
    NotSendableForTransfer { name: String },
    
    #[error("Circular reference detected in region {region}")]
    CircularViolation { region: Region },
}

// ============================================================================
// REGION MAP
// ============================================================================

/// Maps variable names to their allocated regions
#[derive(Debug, Clone)]
pub struct RegionMap {
    bindings: HashMap<String, Region>,
    /// Track which variables escape
    escapes: HashMap<String, bool>,
    /// Track mutable bindings
    mutable: HashMap<String, bool>,
}

impl RegionMap {
    pub fn new() -> Self {
        Self {
            bindings: HashMap::new(),
            escapes: HashMap::new(),
            mutable: HashMap::new(),
        }
    }
    
    pub fn bind(&mut self, name: &str, region: Region) {
        self.bindings.insert(name.to_string(), region);
    }
    
    pub fn get(&self, name: &str) -> Option<Region> {
        self.bindings.get(name).copied()
    }
    
    pub fn mark_escape(&mut self, name: &str) {
        self.escapes.insert(name.to_string(), true);
    }
    
    pub fn is_escaped(&self, name: &str) -> bool {
        self.escapes.get(name).copied().unwrap_or(false)
    }
    
    pub fn mark_mutable(&mut self, name: &str) {
        self.mutable.insert(name.to_string(), true);
    }
    
    pub fn is_mutable(&self, name: &str) -> bool {
        self.mutable.get(name).copied().unwrap_or(false)
    }
    
    /// Check if a variable's region allows the given operation
    pub fn check_access(&self, name: &str, op: &RegionAccessOp) -> Result<(), RegionError> {
        let region = self.get(name).ok_or_else(|| RegionError::EscapeViolation {
            name: name.to_string(),
            from: Region::Stack,
            to: Region::Heap,
        })?;
        
        match op {
            RegionAccessOp::Read => Ok(()), // All regions allow read
            RegionAccessOp::Write => {
                if region == Region::Global {
                    Err(RegionError::UseAfterMutate {
                        name: name.to_string(),
                        region: Region::Global,
                    })
                } else {
                    Ok(())
                }
            }
            RegionAccessOp::Transfer => {
                if region == Region::Stack {
                    Err(RegionError::NotSendableForTransfer {
                        name: name.to_string(),
                    })
                } else {
                    Ok(())
                }
            }
            RegionAccessOp::Pin => {
                if region != Region::Pin && region != Region::Heap {
                    Err(RegionError::FfiUnpinnable {
                        name: name.to_string(),
                    })
                } else {
                    Ok(())
                }
            }
        }
    }
    
    /// Promote a variable's region (for escape analysis)
    pub fn promote(&mut self, name: &str, to: Region) {
        if let Some(current) = self.get(name) {
            // Only promote to a "larger" region
            if current != to {
                self.bindings.insert(name.to_string(), to);
                self.mark_escape(name);
            }
        }
    }
}

/// Types of region access operations
#[derive(Debug, Clone)]
pub enum RegionAccessOp {
    Read,
    Write,
    Transfer, // Used in spawn/send
    Pin,      // Used in ffi-pin
}

// ============================================================================
// REGION INFERENCER
// ============================================================================

pub struct RegionInferencer {
    region_map: RegionMap,
    current_region: Region,
    /// Track which expressions escape their scope
    escaping: Vec<String>,
}

impl RegionInferencer {
    pub fn new() -> Self {
        Self {
            region_map: RegionMap::new(),
            current_region: Region::Stack,
            escaping: Vec::new(),
        }
    }
    
    /// Infer regions for an expression
    pub fn infer(&mut self, expr: &Expr) -> Result<RegionMap, RegionError> {
        match expr {
            Expr::Atom(_) => {
                // Atoms don't have region concerns
            }
            Expr::App(op, args) => {
                // Check if op is a variable reference
                if let Some(_region) = self.region_map.get(op) {
                    self.region_map.check_access(op, &RegionAccessOp::Read)?;
                }
                for arg in args {
                    let arg_region = self.infer(arg)?;
                    // Mark any variables used in arguments as escaping
                    // (they're passed to a function which may store them)
                    for name in arg_region.escapes.keys() {
                        self.region_map.mark_escape(name);
                    }
                    // Also mark direct variable references in arguments
                    if let Expr::Atom(AtomKind::Ident(name)) = arg {
                        self.region_map.mark_escape(name);
                    }
                }
            }
            Expr::AppExpr(operator, args) => {
                // Infer regions for the operator expression (higher-order call)
                let op_region = self.infer(operator)?;
                for name in op_region.escapes.keys() {
                    self.region_map.mark_escape(name);
                }
                // Same escaping logic as App
                for arg in args {
                    let arg_region = self.infer(arg)?;
                    for name in arg_region.escapes.keys() {
                        self.region_map.mark_escape(name);
                    }
                    if let Expr::Atom(AtomKind::Ident(name)) = arg {
                        self.region_map.mark_escape(name);
                    }
                }
            }
            Expr::Def(name, body) => {
                // def binds at the current scope level
                let body_region = self.infer(body)?;
                // The definition itself is at the enclosing region
                if body_region.is_escaped(name) {
                    self.region_map.promote(name, Region::Heap);
                } else {
                    self.region_map.bind(name, self.current_region);
                }
            }
            Expr::Defn { name: _, params, body, .. } => {
                // Function body is evaluated in a new stack frame
                let saved_region = self.current_region;
                self.current_region = Region::Stack;
                
                // Bind parameters to the function's stack frame
                for param in params {
                    self.region_map.bind(param, Region::Stack);
                }
                
                let body_region = self.infer(body)?;
                self.current_region = saved_region;
                
                // Check if any parameter escapes
                for param in params {
                    if body_region.is_escaped(param) {
                        self.region_map.promote(param, Region::Heap);
                    }
                }
            }
            Expr::Let { name, value, body } => {
                let val_region = self.infer(value)?;
                
                // Check if value escapes
                if val_region.is_escaped(name) || self.value_escapes(value, body) {
                    self.region_map.promote(name, Region::Heap);
                } else {
                    self.region_map.bind(name, self.current_region);
                }
                
                self.infer(body)?;
            }
            Expr::LetMut { name, value, body } => {
                let val_region = self.infer(value)?;
                
                // Mutable bindings are always on the heap (or current region if no escape)
                if val_region.is_escaped(name) || self.value_escapes(value, body) {
                    self.region_map.promote(name, Region::Heap);
                } else {
                    self.region_map.bind(name, self.current_region);
                }
                
                self.region_map.mark_mutable(name);
                self.infer(body)?;
            }
            Expr::If { cond, then_branch, else_branch } => {
                self.infer(cond)?;
                let then_region = self.infer(then_branch)?;
                let else_region = self.infer(else_branch)?;
                
                // Merge escape information from both branches
                for name in then_region.escapes.keys().chain(else_region.escapes.keys()) {
                    self.region_map.mark_escape(name);
                }
            }
            Expr::TryCatch { body, catch_var, handler } => {
                let body_region = self.infer(body)?;
                
                // Bind catch variable in handler
                let saved = self.region_map.get(catch_var);
                self.region_map.bind(catch_var, Region::Stack);
                let handler_region = self.infer(handler)?;
                
                if let Some(orig) = saved {
                    self.region_map.bind(catch_var, orig);
                } else {
                    self.region_map.bindings.remove(catch_var);
                }
                
                // Merge escapes
                for name in body_region.escapes.keys().chain(handler_region.escapes.keys()) {
                    self.region_map.mark_escape(name);
                }
            }
            Expr::Spawn(body) => {
                let body_region = self.infer(body)?;
                
                // R3: Actor transfer requires Send-capable type
                // All captured variables must not be in stack region
                for name in body_region.escapes.keys() {
                    if let Some(region) = self.region_map.get(name) {
                        if region == Region::Stack {
                            return Err(RegionError::NotSendableForTransfer {
                                name: name.clone(),
                            });
                        }
                    }
                }
            }
            Expr::Send { target, message } => {
                let _target_region = self.infer(target)?;
                let msg_region = self.infer(message)?;
                
                // Check target is ActorRef (region doesn't matter for the ref itself)
                // Message must be sendable
                for name in msg_region.escapes.keys() {
                    if let Some(_region) = self.region_map.get(name) {
                        if _region == Region::Stack {
                            return Err(RegionError::NotSendableForTransfer {
                                name: name.clone(),
                            });
                        }
                    }
                }
            }
            Expr::FfiCall { name: _, args, timeout_ms: _ } => {
                for arg in args {
                    let _arg_region = self.infer(arg)?;
                    
                    // R4: FFI requires pinned memory
                    // Check if the argument can be pinned
                    if let Expr::Atom(AtomKind::Ident(name)) = arg {
                        if let Some(_region) = self.region_map.get(name) {
                            if _region != Region::Pin && _region != Region::Heap {
                                return Err(RegionError::FfiUnpinnable {
                                    name: name.clone(),
                                });
                            }
                        }
                    }
                }
            }
            Expr::FfiPin(expr) => {
                let _expr_region = self.infer(expr)?;
                
                // Pin the expression to the Pin region
                if let Expr::Atom(AtomKind::Ident(name)) = expr.as_ref() {
                    if let Some(_region) = self.region_map.get(name) {
                        if _region != Region::Pin {
                            self.region_map.promote(name, Region::Pin);
                        }
                    }
                }
            }
            Expr::Assert { condition, message: _ } => {
                self.infer(condition)?;
            }
            
            // Testing framework (§20.5)
            Expr::TestSuite { tests, .. } => {
                for test in tests {
                    let _ = self.infer(test)?;
                }
            }
            Expr::RunTests { .. } => {}
            Expr::Test { body, .. } => { let _ = self.infer(body.as_ref())?; }
            Expr::AssertEqual { expected, actual } => {
                let _ = self.infer(expected.as_ref())?;
                let _ = self.infer(actual.as_ref())?;
            }
            Expr::AssertFail { expr, .. } => { let _ = self.infer(expr.as_ref())?; }
            Expr::AssertTrue { expr, .. } => { let _ = self.infer(expr.as_ref())?; }
            Expr::AssertFalse { expr, .. } => { let _ = self.infer(expr.as_ref())?; }
            Expr::TestProperty { property_fn, .. } => { let _ = self.infer(property_fn.as_ref())?; }
            Expr::Setup(bodies) | Expr::Teardown(bodies) => {
                for body in bodies {
                    let _ = self.infer(body)?;
                }
            }
            Expr::TestCompile { expr, .. } => { let _ = self.infer(expr.as_ref())?; }
            Expr::Quote(inner) => { let _ = self.infer(inner.as_ref())?; }
            
            // Closures (§7) - captured variables may escape
            Expr::Fn { params, body } => {
                let saved_region = self.current_region;
                self.current_region = Region::Stack;
                for param in params {
                    self.region_map.bind(param, Region::Stack);
                }
                self.infer(body)?;
                self.current_region = saved_region;
            }
            
            // While loop (§12.5)
            Expr::While { condition, body } => {
                self.infer(condition)?;
                self.infer(body)?;
            }
            
            // For loop (§12.6)
            Expr::For { name, iterator, body } => {
                self.infer(iterator)?;
                let saved_region = self.current_region;
                self.current_region = Region::Stack;
                self.region_map.bind(name, Region::Stack);
                let _body_region = self.infer(body)?;
                self.current_region = saved_region;
            }
            
            // Cond (§12.7)
            Expr::Cond(clauses) => {
                for (cond, body) in clauses {
                    self.infer(cond)?;
                    self.infer(body)?;
                }
            }
            
            // Match (§8.3)
            Expr::Match { scrutinee, clauses } => {
                self.infer(scrutinee)?;
                for clause in clauses {
                    for pattern in &clause.patterns {
                        if let crate::ast::MatchPattern::Bind(name) = pattern {
                            self.region_map.bind(name, Region::Stack);
                        }
                    }
                    self.infer(clause.body.as_ref())?;
                }
            }
            
            // Deftype, TraitDecl, Impl - compile-time only
            Expr::Deftype { .. } => {}
            Expr::TraitDecl { .. } => {}
            Expr::Impl { .. } => {}
            
            // Use/Export/Pub
            Expr::Use { .. } => {}
            Expr::Export(body) => { let _ = self.infer(body)?; }
            Expr::Pub(body) => { let _ = self.infer(body)?; },
            
            // Contracts (§23)
            Expr::Requires(condition) => { let _ = self.infer(condition)?; }
            Expr::Ensures { condition: _, body } => { let _ = self.infer(body)?; }
            Expr::Invariant(_) => {}
            Expr::Recover { handlers, body } => {
                let _ = handlers;
                let _ = self.infer(body)?;
            }
            Expr::Checkpoint(body) => { let _ = self.infer(body)?; }
            Expr::Contracts(_) => {}
            
            // Begin (§12.8)
            Expr::Begin(exprs) => {
                for expr in exprs {
                    let _ = self.infer(expr)?;
                }
            }
        }
        
        Ok(self.region_map.clone())
    }
    
    /// Check if a value escapes from one expression to another
    fn value_escapes(&self, value: &Expr, body: &Expr) -> bool {
        match (value, body) {
            (Expr::Atom(AtomKind::Ident(name)), _) => {
                // A variable reference in the value escapes if it's used in the body
                // after the let binding
                self.uses_variable(body, name)
            }
            (Expr::App(_, args), _) => {
                args.iter().any(|a| self.value_escapes(a, body))
            }
            _ => false,
        }
    }
    
    /// Check if an expression uses a variable
    fn uses_variable(&self, expr: &Expr, name: &str) -> bool {
        match expr {
            Expr::Atom(AtomKind::Ident(n)) => n == name,
            Expr::App(_, args) => args.iter().any(|a| self.uses_variable(a, name)),
            Expr::Let { value, body, .. } | Expr::LetMut { value, body, .. } => {
                self.uses_variable(value, name) || self.uses_variable(body, name)
            }
            Expr::If { cond, then_branch, else_branch } => {
                self.uses_variable(cond, name)
                    || self.uses_variable(then_branch, name)
                    || self.uses_variable(else_branch, name)
            }
            Expr::Defn { body, .. } => self.uses_variable(body, name),
            Expr::TryCatch { body, handler, .. } => {
                self.uses_variable(body, name) || self.uses_variable(handler, name)
            }
            Expr::Spawn(inner) | Expr::FfiPin(inner) => self.uses_variable(inner, name),
            Expr::Send { target, message } => {
                self.uses_variable(target, name) || self.uses_variable(message, name)
            }
            Expr::FfiCall { args, .. } => args.iter().any(|a| self.uses_variable(a, name)),
            Expr::Assert { condition, .. } => self.uses_variable(condition, name),
            Expr::Def(_, body) => self.uses_variable(body, name),
            // New variants
            Expr::Fn { body, .. } => self.uses_variable(body, name),
            Expr::While { condition, body } => {
                self.uses_variable(condition, name) || self.uses_variable(body, name)
            }
            Expr::For { iterator, body, .. } => {
                self.uses_variable(iterator, name) || self.uses_variable(body, name)
            }
            Expr::Cond(clauses) => clauses.iter().any(|(c, b)| {
                self.uses_variable(c, name) || self.uses_variable(b, name)
            }),
            Expr::Match { scrutinee, clauses } => {
                self.uses_variable(scrutinee, name)
                    || clauses.iter().any(|c| self.uses_variable(c.body.as_ref(), name))
            }
            Expr::Export(body) | Expr::Pub(body) | Expr::Checkpoint(body) => {
                self.uses_variable(body, name)
            }
            Expr::Requires(condition) | Expr::Invariant(condition) => {
                self.uses_variable(condition, name)
            }
            Expr::Ensures { condition: _, body } => self.uses_variable(body, name),
            Expr::Recover { handlers, body } => {
                let _ = handlers;
                self.uses_variable(body, name)
            }
            Expr::Begin(exprs) => exprs.iter().any(|e| self.uses_variable(e, name)),
            // Testing framework (§20.5)
            Expr::TestSuite { tests, .. } => tests.iter().any(|t| self.uses_variable(t, name)),
            Expr::Test { body, .. } => self.uses_variable(body.as_ref(), name),
            Expr::AssertEqual { expected, actual } => {
                self.uses_variable(expected.as_ref(), name) || self.uses_variable(actual.as_ref(), name)
            }
            Expr::AssertFail { expr, .. } | Expr::AssertTrue { expr, .. } | Expr::AssertFalse { expr, .. } => {
                self.uses_variable(expr.as_ref(), name)
            }
            Expr::TestProperty { property_fn, .. } => self.uses_variable(property_fn.as_ref(), name),
            Expr::Setup(bodies) | Expr::Teardown(bodies) => bodies.iter().any(|b| self.uses_variable(b, name)),
            Expr::RunTests { .. } => false,
            Expr::TestCompile { expr, .. } => self.uses_variable(expr.as_ref(), name),
            Expr::Quote(inner) => self.uses_variable(inner.as_ref(), name),
            // Compile-time only
            Expr::Deftype { .. } | Expr::TraitDecl { .. } | Expr::Impl { .. }
            | Expr::Use { .. } | Expr::Contracts(_) => false,
            _ => false,
        }
    }
    
    /// Get the final region map after inference
    pub fn get_region_map(&self) -> RegionMap {
        self.region_map.clone()
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Infer regions for an expression
pub fn infer_regions(expr: &Expr) -> Result<RegionMap, RegionError> {
    let mut inferencer = RegionInferencer::new();
    inferencer.infer(expr)
}

/// Infer regions for a program
pub fn infer_program_regions(program: &Program) -> Result<RegionMap, RegionError> {
    let mut inferencer = RegionInferencer::new();
    
    // Infer regions for all definitions
    for def in &program.defs {
        inferencer.infer(def)?;
    }
    
    // Then infer for the body
    inferencer.infer(&program.body)?;
    
    Ok(inferencer.get_region_map())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::AtomKind;
    
    #[test]
    fn test_stack_allocation() {
        let expr = Expr::Let {
            name: "x".into(),
            value: Box::new(Expr::Atom(AtomKind::Int(42))),
            body: Box::new(Expr::Atom(AtomKind::Ident("x".into()))),
        };
        let regions = infer_regions(&expr).unwrap();
        assert_eq!(regions.get("x"), Some(Region::Stack));
    }
    
    #[test]
    fn test_heap_allocation_on_escape() {
        // When a value is returned from a function, it escapes to heap
        let expr = Expr::Defn {
            name: "make_pair".into(),
            params: vec!["a".into(), "b".into()],
            body: Box::new(Expr::App("tuple".into(), vec![
                Expr::Atom(AtomKind::Ident("a".into())),
                Expr::Atom(AtomKind::Ident("b".into())),
            ])),
            ret_type: None,
        };
        let regions = infer_regions(&expr).unwrap();
        // Parameters that escape should be promoted to heap
        assert!(regions.is_escaped("a") || regions.get("a") == Some(Region::Heap));
    }
}
