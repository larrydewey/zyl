//! Macro system for Zyl
//! 
//! Per specification section 15:
//! - AST-only (no ICNF visibility)
//! - Hygienic by default (gensym-based)
//! - Deterministic expansion order
//! - Innermost first, lexical order, stable module order

use crate::ast::*;
use std::collections::HashMap;
use thiserror::Error;

// ============================================================================
// MACRO ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error)]
pub enum MacroError {
    #[error("Macro '{name}' did not terminate after {max} expansions")]
    NonTermination { name: String, max: usize },
    
    #[error("Illegal macro access: macros cannot observe runtime values")]
    IllegalAccess,
    
    #[error("Macro '{name}' not found")]
    NotFound { name: String },
    
    #[error("Pattern mismatch in macro '{name}': {msg}")]
    PatternMismatch { name: String, msg: String },
    
    #[error("Duplicate macro definition: {name}")]
    DuplicateDefinition { name: String },
}

// ============================================================================
// GENSYM (Hygiene - Section 15)
// ============================================================================

#[derive(Debug, Clone)]
pub struct GensymContext {
    counter: usize,
    context_hash: u64,
}

impl GensymContext {
    pub fn new(context_hash: u64) -> Self {
        Self {
            counter: 0,
            context_hash,
        }
    }
    
    /// Generate a unique symbol: gensym(x, context) = x#hash(context,x,callsite)
    pub fn gensym(&mut self, prefix: &str) -> String {
        let id = self.counter;
        self.counter += 1;
        format!("{}#{}_{:x}", prefix, id, self.context_hash ^ (id as u64))
    }
    
    /// Create a new context for a different callsite
    pub fn fork(&self) -> Self {
        Self {
            counter: 0,
            context_hash: self.context_hash ^ 0xdeadbeef,
        }
    }
}

// ============================================================================
// MACRO DEFINITION
// ============================================================================

#[derive(Debug, Clone)]
pub struct MacroDef {
    pub name: String,
    /// Pattern to match (can contain wildcards and capture variables)
    pub pattern: MacroPattern,
    /// Template to produce (with variable substitution)
    pub template: Expr,
}

/// A macro pattern that can match AST nodes
#[derive(Debug, Clone)]
pub enum MacroPattern {
    /// Match any single expression
    Any(String),           // Variable name for capture
    /// Match a specific atom
    Atom(AtomKind),
    /// Match an application with sub-patterns
    App(String, Vec<MacroPattern>),
    /// Match a list of patterns
    List(Vec<MacroPattern>),
}

impl MacroPattern {
    /// Try to match a pattern against an expression
    pub fn match_expr(&self, expr: &Expr) -> Option<HashMap<String, Expr>> {
        match (self, expr) {
            // Variable capture - matches anything
            (MacroPattern::Any(var), _) => {
                let mut bindings = HashMap::new();
                bindings.insert(var.clone(), expr.clone());
                Some(bindings)
            }
            
            // Match atom
            (MacroPattern::Atom(expected), Expr::Atom(actual)) => {
                if expected == actual {
                    Some(HashMap::new())
                } else {
                    None
                }
            }
            
            // Match application
            (MacroPattern::App(op, patterns), Expr::App(actual_op, args)) => {
                if op != "*" && op != actual_op {
                    return None;
                }
                if patterns.len() != args.len() {
                    return None;
                }
                
                let mut bindings = HashMap::new();
                for (pat, arg) in patterns.iter().zip(args) {
                    match pat.match_expr(arg) {
                        Some(sub_bindings) => {
                            bindings.extend(sub_bindings);
                        }
                        None => return None,
                    }
                }
                Some(bindings)
            }
            
            // Match list (for special forms like defn)
            (MacroPattern::List(patterns), Expr::App(op, _args)) => {
                let full_pattern: Vec<MacroPattern> = vec![MacroPattern::Atom(AtomKind::Ident(op.clone()))]
                    .into_iter()
                    .chain(patterns.iter().cloned())
                    .collect();
                MacroPattern::List(full_pattern).match_expr(expr)
            }
            
            _ => None,
        }
    }
    
    /// Substitute captured variables in a template
    pub fn substitute(&self, template: &Expr, bindings: &HashMap<String, Expr>) -> Expr {
        match template {
            Expr::Atom(AtomKind::Ident(name)) if bindings.contains_key(name) => {
                bindings.get(name).unwrap().clone()
            }
            Expr::Atom(kind) => Expr::Atom(kind.clone()),
            Expr::App(op, args) => {
                let new_args: Vec<Expr> = args.iter()
                    .map(|a| self.substitute(a, bindings))
                    .collect();
                Expr::App(op.clone(), new_args)
            }
            Expr::Let { name, value, body } => {
                // Avoid capturing the let-bound name
                let mut new_bindings = bindings.clone();
                new_bindings.remove(name);
                Expr::Let {
                    name: name.clone(),
                    value: Box::new(self.substitute(value, &new_bindings)),
                    body: Box::new(self.substitute(body, &new_bindings)),
                }
            }
            Expr::Defn { name, params, body, ret_type } => {
                // Avoid capturing defn-bound names
                let mut new_bindings = bindings.clone();
                for p in params {
                    new_bindings.remove(p);
                }
                Expr::Defn {
                    name: name.clone(),
                    params: params.clone(),
                    body: Box::new(self.substitute(body, &new_bindings)),
                    ret_type: ret_type.clone(),
                }
            }
            other => other.clone(),
        }
    }
}

// ============================================================================
// MACRO ENVIRONMENT
// ============================================================================

#[derive(Debug, Clone)]
pub struct MacroEnv {
    macros: HashMap<String, MacroDef>,
}

impl MacroEnv {
    pub fn new() -> Self {
        Self {
            macros: HashMap::new(),
        }
    }
    
    pub fn register(&mut self, def: MacroDef) -> Result<(), MacroError> {
        if self.macros.contains_key(&def.name) {
            return Err(MacroError::DuplicateDefinition { name: def.name.clone() });
        }
        self.macros.insert(def.name.clone(), def);
        Ok(())
    }
    
    pub fn find(&self, name: &str) -> Option<&MacroDef> {
        self.macros.get(name)
    }
}

// ============================================================================
// MACRO EXPANDER (Section 15)
// ============================================================================

pub struct MacroExpander {
    env: MacroEnv,
    max_expansions: usize,
}

impl MacroExpander {
    pub fn new() -> Self {
        Self {
            env: MacroEnv::new(),
            max_expansions: 100, // Prevent infinite loops
        }
    }
    
    /// Register a macro definition
    pub fn register(&mut self, def: MacroDef) -> Result<(), MacroError> {
        self.env.register(def)
    }
    
    /// Expand all macros in an expression
    pub fn expand(&mut self, expr: &Expr) -> Result<Expr, MacroError> {
        let mut expansion_count = 0;
        let mut result = expr.clone();
        
        loop {
            let expanded = self.expand_once(&result)?;
            if expanded == result {
                break; // No more expansions
            }
            result = expanded;
            expansion_count += 1;
            
            if expansion_count > self.max_expansions {
                return Err(MacroError::NonTermination {
                    name: "unknown".into(),
                    max: self.max_expansions,
                });
            }
        }
        
        Ok(result)
    }
    
    /// Expand macros in a program
    pub fn expand_program(&mut self, program: &Program) -> Result<Program, MacroError> {
        let expanded_defs: Vec<Expr> = program.defs.iter()
            .map(|def| self.expand(def))
            .collect::<Result<Vec<_>, _>>()?;
        
        let expanded_body = self.expand(&program.body)?;
        
        Ok(Program::new(expanded_defs, expanded_body))
    }
    
    /// Expand a single level of macros (innermost first)
    fn expand_once(&mut self, expr: &Expr) -> Result<Expr, MacroError> {
        match expr {
            Expr::App(op, args) => {
                // Check if op is a macro name
                if let Some(macro_def) = self.env.find(op) {
                    let macro_def_clone = macro_def.clone();
                    return self.expand_macro(&macro_def_clone, args);
                }
                
                // Otherwise, expand arguments (innermost first)
                let expanded_args: Vec<Expr> = args.iter()
                    .map(|a| self.expand_once(a))
                    .collect::<Result<Vec<_>, _>>()?;
                
                Ok(Expr::App(op.clone(), expanded_args))
            }
            Expr::Def(name, body) => {
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::Def(name.clone(), Box::new(expanded_body)))
            }
            Expr::Defn { name, params, body, ret_type } => {
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::Defn {
                    name: name.clone(),
                    params: params.clone(),
                    body: Box::new(expanded_body),
                    ret_type: ret_type.clone(),
                })
            }
            Expr::Let { name, value, body } => {
                let expanded_value = self.expand_once(value)?;
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::Let {
                    name: name.clone(),
                    value: Box::new(expanded_value),
                    body: Box::new(expanded_body),
                })
            }
            Expr::LetMut { name, value, body } => {
                let expanded_value = self.expand_once(value)?;
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::LetMut {
                    name: name.clone(),
                    value: Box::new(expanded_value),
                    body: Box::new(expanded_body),
                })
            }
            Expr::If { cond, then_branch, else_branch } => {
                let expanded_cond = self.expand_once(cond)?;
                let expanded_then = self.expand_once(then_branch)?;
                let expanded_else = self.expand_once(else_branch)?;
                Ok(Expr::If {
                    cond: Box::new(expanded_cond),
                    then_branch: Box::new(expanded_then),
                    else_branch: Box::new(expanded_else),
                })
            }
            Expr::TryCatch { body, catch_var, handler } => {
                let expanded_body = self.expand_once(body)?;
                let expanded_handler = self.expand_once(handler)?;
                Ok(Expr::TryCatch {
                    body: Box::new(expanded_body),
                    catch_var: catch_var.clone(),
                    handler: Box::new(expanded_handler),
                })
            }
            Expr::Spawn(inner) => {
                let expanded = self.expand_once(inner)?;
                Ok(Expr::Spawn(Box::new(expanded)))
            }
            Expr::Send { target, message } => {
                let expanded_target = self.expand_once(target)?;
                let expanded_message = self.expand_once(message)?;
                Ok(Expr::Send {
                    target: Box::new(expanded_target),
                    message: Box::new(expanded_message),
                })
            }
            Expr::FfiCall { name, args, timeout_ms } => {
                let expanded_args: Vec<Expr> = args.iter()
                    .map(|a| self.expand_once(a))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::FfiCall {
                    name: name.clone(),
                    args: expanded_args,
                    timeout_ms: *timeout_ms,
                })
            }
            Expr::FfiPin(inner) => {
                let expanded = self.expand_once(inner)?;
                Ok(Expr::FfiPin(Box::new(expanded)))
            }
            Expr::Assert { condition, message } => {
                let expanded_condition = self.expand_once(condition)?;
                Ok(Expr::Assert {
                    condition: Box::new(expanded_condition),
                    message: message.clone(),
                })
            }
            // New variants
            Expr::Fn { params, body } => {
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::Fn { params: params.clone(), body: Box::new(expanded_body) })
            }
            Expr::While { condition, body } => {
                let expanded_cond = self.expand_once(condition)?;
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::While { condition: Box::new(expanded_cond), body: Box::new(expanded_body) })
            }
            Expr::For { name, iterator, body } => {
                let expanded_iter = self.expand_once(iterator)?;
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::For { name: name.clone(), iterator: Box::new(expanded_iter), body: Box::new(expanded_body) })
            }
            Expr::Cond(clauses) => {
                let expanded_clauses: Vec<(Expr, Expr)> = clauses.iter()
                    .map(|(c, b)| {
                        Ok((self.expand_once(c)?, self.expand_once(b)?))
                    })
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Cond(expanded_clauses))
            }
            Expr::Match { scrutinee, clauses } => {
                let expanded_scrut = self.expand_once(scrutinee)?;
                let expanded_clauses: Vec<crate::ast::MatchClause> = clauses.iter()
                    .map(|c| {
                        Ok(crate::ast::MatchClause {
                            variant: c.variant.clone(),
                            patterns: c.patterns.clone(),
                            body: Box::new(self.expand_once(c.body.as_ref())?),
                        })
                    })
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Match { scrutinee: Box::new(expanded_scrut), clauses: expanded_clauses })
            }
            Expr::Deftype { name, variants } => {
                let expanded_variants: Vec<crate::ast::AdtVariant> = variants.iter()
                    .map(|v| Ok(crate::ast::AdtVariant {
                        name: v.name.clone(),
                        fields: v.fields.clone(),
                    }))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Deftype { name: name.clone(), variants: expanded_variants })
            }
            Expr::TraitDecl { name, methods, bound } => {
                let expanded_methods: Vec<crate::ast::TraitMethod> = methods.iter()
                    .map(|m| Ok(crate::ast::TraitMethod {
                        name: m.name.clone(),
                        params: m.params.clone(),
                        return_type: m.return_type.clone(),
                    }))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::TraitDecl { name: name.clone(), methods: expanded_methods, bound: bound.clone() })
            }
            Expr::Impl { trait_name, type_name, body } => {
                let expanded_body: Vec<Expr> = body.iter()
                    .map(|b| self.expand_once(b))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Impl { trait_name: trait_name.clone(), type_name: type_name.clone(), body: expanded_body })
            }
            Expr::Use { module, symbols } => {
                let _ = (module, symbols);
                Ok(expr.clone())
            }
            Expr::Export(body) => {
                let expanded = self.expand_once(body)?;
                Ok(Expr::Export(Box::new(expanded)))
            }
            Expr::Pub(body) => {
                let expanded = self.expand_once(body)?;
                Ok(Expr::Pub(Box::new(expanded)))
            }
            Expr::Requires(condition) => {
                let expanded = self.expand_once(condition)?;
                Ok(Expr::Requires(Box::new(expanded)))
            }
            Expr::Ensures { condition, body } => {
                let expanded_cond = self.expand_once(condition)?;
                let expanded_body = self.expand_once(body)?;
                Ok(Expr::Ensures { condition: Box::new(expanded_cond), body: Box::new(expanded_body) })
            }
            Expr::Invariant(condition) => {
                let expanded = self.expand_once(condition)?;
                Ok(Expr::Invariant(Box::new(expanded)))
            }
            Expr::Recover { handlers, body } => {
                let expanded_body = self.expand_once(body)?;
                let expanded_handlers: Vec<(String, Expr)> = handlers.iter()
                    .map(|(err, fb)| Ok((err.clone(), self.expand_once(fb)?)))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Recover { handlers: expanded_handlers, body: Box::new(expanded_body) })
            }
            Expr::Checkpoint(body) => {
                let expanded = self.expand_once(body)?;
                Ok(Expr::Checkpoint(Box::new(expanded)))
            }
            Expr::Contracts(profile) => {
                let _ = profile;
                Ok(expr.clone())
            }
            Expr::Begin(exprs) => {
                let expanded: Vec<Expr> = exprs.iter()
                    .map(|e| self.expand_once(e))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::Begin(expanded))
            }
            _ => Ok(expr.clone()),
        }
    }
    
    /// Expand a macro call
    fn expand_macro(&mut self, macro_def: &MacroDef, args: &[Expr]) -> Result<Expr, MacroError> {
        // Build pattern from macro definition
        let pattern = match &macro_def.pattern {
            MacroPattern::Any(_) => MacroPattern::App("*".into(), vec![]),
            other => other.clone(),
        };
        
        // Create a synthetic expression to match against
        let synthetic = Expr::App(macro_def.name.clone(), args.to_vec());
        
        // Clone the template before borrowing self.env
        let template = macro_def.template.clone();
        let name = macro_def.name.clone();
        
        // Try to match
        if let Some(bindings) = pattern.match_expr(&synthetic) {
            // Substitute variables in template
            let mut context = GensymContext::new(0);
            self.substitute_with_gensym(&template, &bindings, &mut context)
        } else {
            Err(MacroError::PatternMismatch {
                name,
                msg: format!("Expected pattern {:?}, got {:?}", pattern, synthetic),
            })
        }
    }
    
    /// Substitute with gensym hygiene
    fn substitute_with_gensym(
        &self,
        expr: &Expr,
        bindings: &HashMap<String, Expr>,
        context: &mut GensymContext,
    ) -> Result<Expr, MacroError> {
        match expr {
            Expr::Atom(AtomKind::Ident(name)) => {
                // Check if it's a bound variable or a gensym placeholder
                if name.starts_with("#") {
                    // This is a gensym placeholder - generate fresh name
                    Ok(Expr::Atom(AtomKind::Ident(context.gensym("g"))))
                } else if bindings.contains_key(name) {
                    Ok(bindings.get(name).unwrap().clone())
                } else {
                    Ok(Expr::Atom(AtomKind::Ident(name.clone())))
                }
            }
            Expr::App(op, args) => {
                let expanded_args: Vec<Expr> = args.iter()
                    .map(|a| self.substitute_with_gensym(a, bindings, context))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(Expr::App(op.clone(), expanded_args))
            }
            Expr::Let { name, value, body } => {
                // Freshen the bound variable to avoid capture
                let fresh_name = context.gensym(name);
                let mut new_bindings = bindings.clone();
                new_bindings.insert(fresh_name.clone(), bindings.get(name).cloned().unwrap_or_else(|| Expr::Atom(AtomKind::Ident(name.clone()))));
                
                Ok(Expr::Let {
                    name: fresh_name,
                    value: Box::new(self.substitute_with_gensym(value, &new_bindings, context)?),
                    body: Box::new(self.substitute_with_gensym(body, &new_bindings, context)?),
                })
            }
            Expr::Defn { name, params, body, ret_type } => {
                let fresh_params: Vec<String> = params.iter()
                    .map(|p| context.gensym(p))
                    .collect();
                
                let mut new_bindings = bindings.clone();
                for (orig, fresh) in params.iter().zip(&fresh_params) {
                    new_bindings.insert(fresh.clone(), Expr::Atom(AtomKind::Ident(orig.clone())));
                }
                
                Ok(Expr::Defn {
                    name: context.gensym(name),
                    params: fresh_params,
                    body: Box::new(self.substitute_with_gensym(body, &new_bindings, context)?),
                    ret_type: ret_type.clone(),
                })
            }
            other => Ok(other.clone()),
        }
    }
}

// ============================================================================
// BUILT-IN MACROS (Standard Library - Section 20)
// ============================================================================

/// Register built-in macros for the standard library
pub fn register_builtin_macros(expander: &mut MacroExpander) {
    // unless macro: (unless cond body) => (if (not cond) body)
    expander.register(MacroDef {
        name: "unless".into(),
        pattern: MacroPattern::App("unless".into(), vec![
            MacroPattern::Any("cond".into()),
            MacroPattern::List(vec![MacroPattern::Any("body".into())]),
        ]),
        template: Expr::If {
            cond: Box::new(Expr::App("not".into(), vec![
                Expr::Atom(AtomKind::Ident("cond".into())),
            ])),
            then_branch: Box::new(Expr::App("begin".into(), vec![
                Expr::Atom(AtomKind::Ident("body".into())),
            ])),
            else_branch: Box::new(Expr::Atom(AtomKind::Ident("unit".into()))),
        },
    }).ok();
    
    // when macro: (when cond body) => (if cond body unit)
    expander.register(MacroDef {
        name: "when".into(),
        pattern: MacroPattern::App("when".into(), vec![
            MacroPattern::Any("cond".into()),
            MacroPattern::List(vec![MacroPattern::Any("body".into())]),
        ]),
        template: Expr::If {
            cond: Box::new(Expr::Atom(AtomKind::Ident("cond".into()))),
            then_branch: Box::new(Expr::App("begin".into(), vec![
                Expr::Atom(AtomKind::Ident("body".into())),
            ])),
            else_branch: Box::new(Expr::Atom(AtomKind::Ident("unit".into()))),
        },
    }).ok();
    
    // cond macro: (cond (pred1 body1) (pred2 body2) ...) => nested if
    expander.register(MacroDef {
        name: "cond".into(),
        pattern: MacroPattern::App("cond".into(), vec![
            MacroPattern::Any("clauses".into()),
        ]),
        template: Expr::Atom(AtomKind::Ident("cond_impl".into())), // Handled specially
    }).ok();
    
    // defmacro macro: define a new macro
    expander.register(MacroDef {
        name: "defmacro".into(),
        pattern: MacroPattern::App("defmacro".into(), vec![
            MacroPattern::Any("name".into()),
            MacroPattern::List(vec![
                MacroPattern::Any("params".into()),
                MacroPattern::Any("body".into()),
            ]),
        ]),
        template: Expr::Atom(AtomKind::Ident("defmacro_impl".into())), // Handled specially
    }).ok();
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Create a new macro expander with built-in macros
pub fn new_expander() -> MacroExpander {
    let mut expander = MacroExpander::new();
    register_builtin_macros(&mut expander);
    expander
}

/// Expand macros in an expression
pub fn expand(expr: &Expr) -> Result<Expr, MacroError> {
    let mut expander = new_expander();
    expander.expand(expr)
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_gensym() {
        let mut ctx = GensymContext::new(0x1234);
        let g1 = ctx.gensym("x");
        let g2 = ctx.gensym("x");
        assert_ne!(g1, g2);
        assert!(g1.starts_with("x#"));
        assert!(g2.starts_with("x#"));
    }
    
    #[test]
    fn test_pattern_match_any() {
        let pat = MacroPattern::Any("x".into());
        let expr = Expr::Atom(AtomKind::Int(42));
        let bindings = pat.match_expr(&expr).unwrap();
        assert_eq!(bindings.len(), 1);
        assert_eq!(bindings.get("x").unwrap(), &expr);
    }
    
    #[test]
    fn test_pattern_match_app() {
        let pat = MacroPattern::App("+".into(), vec![
            MacroPattern::Any("a".into()),
            MacroPattern::Any("b".into()),
        ]);
        let expr = Expr::App("+".into(), vec![
            Expr::Atom(AtomKind::Int(1)),
            Expr::Atom(AtomKind::Int(2)),
        ]);
        let bindings = pat.match_expr(&expr).unwrap();
        assert_eq!(bindings.len(), 2);
    }
}
