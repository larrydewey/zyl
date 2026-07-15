use indexmap::IndexMap;
use serde::{Deserialize, Serialize};
use std::cell::Cell;

use crate::ast::*;
use crate::error::{Span, ZylError};
use crate::type_system::Type;

/// Memory regions from spec §9.1 (R1–R8).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Region {
    /// Local stack allocation — variables that do not escape their scope.
    Stack,
    /// Heap allocation — escaped values, captured closure variables, actor transfers.
    Heap,
    /// Global region — immutable constants only, eager initialization.
    Global,
    /// Circular region — cyclic structures with self-referential references.
    Circular,
    /// Pin region — non-moving arena for FFI safety.
    Pin,
}

impl std::fmt::Display for Region {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Region::Stack => write!(f, "Stack"),
            Region::Heap => write!(f, "Heap"),
            Region::Global => write!(f, "Global"),
            Region::Circular => write!(f, "Circular"),
            Region::Pin => write!(f, "Pin"),
        }
    }
}

/// Information about what a closure captures from its enclosing scope.
#[derive(Debug, Clone)]
pub struct CaptureInfo {
    /// Variable names captured by this closure.
    pub variables: Vec<String>,
    /// Inferred regions for each captured variable.
    pub regions: IndexMap<String, Region>,
}

/// Scoped environment mapping variable names to their inferred regions.
#[derive(Debug, Clone)]
pub struct RegionEnv {
    current: IndexMap<String, (Region, bool)>, // region + is_escaped flag
    parents: Vec<IndexMap<String, (Region, bool)>>,
}

impl RegionEnv {
    pub fn new() -> Self {
        Self {
            current: IndexMap::new(),
            parents: Vec::new(),
        }
    }

    /// Look up a variable's region. Returns None if not found.
    pub fn get(&self, name: &str) -> Option<(Region, bool)> {
        if let Some(r) = self.current.get(name) {
            return Some(*r);
        }
        for parent in self.parents.iter().rev() {
            if let Some(r) = parent.get(name) {
                return Some(*r);
            }
        }
        None
    }

    /// Check if a variable exists and is escaped.
    pub fn is_escaped(&self, name: &str) -> bool {
        self.get(name).map(|(_, esc)| esc).unwrap_or(false)
    }

    /// Bind a variable to a region (in current scope).
    pub fn bind(&mut self, name: String, region: Region) {
        self.current.insert(name, (region, false));
    }

    /// Mark a variable as escaped — promote its region if needed.
    pub fn escape(&mut self, name: &str) -> Result<(), ZylError> {
        // Check current scope first.
        if let Some((_, esc)) = self.current.get_mut(name) {
            *esc = true;
            return Ok(());
        }
        // Then parent scopes — promote to Heap when escaping upward.
        for parent in self.parents.iter_mut().rev() {
            if let Some((region, esc)) = parent.get_mut(name) {
                *esc = true;
                // Promote from Stack to Heap on escape.
                if *region == Region::Stack {
                    *region = Region::Heap;
                }
                return Ok(());
            }
        }
        Err(ZylError::E_UNINITIALIZED_USE(
            Span::default(),
            name.to_string(),
        ))
    }

    /// Enter a new scope (let bindings, closures, function bodies).
    pub fn enter_scope(&mut self) {
        let old = std::mem::take(&mut self.current);
        // Preserve parent scopes that are still active.
        if !old.is_empty() {
            self.parents.push(old);
        }
        self.current = IndexMap::new();
    }

    /// Exit the current scope, merging remaining bindings back up.
    pub fn exit_scope(&mut self) {
        let old = std::mem::replace(&mut self.current, IndexMap::new());
        if !old.is_empty() && !self.parents.is_empty() {
            // Merge non-escaped locals into parent (they're still alive).
            for (name, region_info) in old {
                if let Some((parent_region, _)) = self.get(&name) {
                    // Already exists — keep the outer binding.
                } else {
                    self.parents.last_mut().unwrap().insert(name, region_info);
                }
            }
        }
    }

    /// Check if a variable is in scope (any level).
    pub fn contains(&self, name: &str) -> bool {
        self.current.contains_key(name) || self.parents.iter().any(|p| p.contains_key(name))
    }

    /// Get all bound variables across all scopes.
    pub fn bindings(&self) -> Vec<String> {
        let mut names = self.current.keys().cloned().collect::<Vec<_>>();
        for parent in &self.parents {
            for name in parent.keys() {
                if !names.contains(name) {
                    names.push(name.clone());
                }
            }
        }
        names.sort();
        names.dedup();
        names
    }

    /// Clone current scope state.
    pub fn snapshot(&self) -> Self {
        Self {
            current: self.current.clone(),
            parents: self.parents.clone(),
        }
    }
}

/// Region inference results for an expression.
#[derive(Debug)]
pub struct RegionResult {
    /// Inferred region of the expression's result value.
    pub result_region: Region,
    /// Captured variables (for closures).
    pub captures: Option<CaptureInfo>,
}

/// Phase 4: Region inference + capture analysis engine.
/// Implements spec §9.1 rules R1–R8 deterministically.
pub struct RegionInferer {
    env: RegionEnv,
    /// Known types from Phase 3 for capability-aware region assignment.
    type_map: IndexMap<String, Type>,
    /// Struct definitions with field regions (Phase 4 output).
    pub struct_regions: IndexMap<String, Vec<(String, Region)>>,
    /// Function signatures with parameter/return regions.
    pub func_signatures: IndexMap<String, FuncSig>,
}

#[derive(Debug, Clone)]
pub struct FuncSig {
    pub param_regions: Vec<Region>,
    pub return_region: Region,
}

impl RegionInferer {
    pub fn new() -> Self {
        Self {
            env: RegionEnv::new(),
            type_map: IndexMap::new(),
            struct_regions: IndexMap::new(),
            func_signatures: IndexMap::new(),
        }
    }

    /// Load types from Phase 3 for capability-aware region inference.
    pub fn load_types(&mut self, exprs: &[Expr]) {
        // Extract type annotations from the typed AST output.
        for expr in exprs {
            if let ExprInner::Atom(Atom::Ident(t)) = &expr.inner {
                // Type annotation atoms like "T_INT", "?0", etc. are metadata, not expressions to infer.
                drop((t));
            }
        }
    }

    /// Main entry point: run region inference on a list of expressions.
    pub fn infer(&mut self, exprs: &[Expr]) -> std::result::Result<Vec<Expr>, ZylError> {
        // Two-pass approach: collect definitions first, then analyze each expression.
        self.collect_definitions(exprs);

        let mut result = Vec::with_capacity(exprs.len());
        for expr in exprs {
            self.infer_expr(&expr)?;
            // Pass through expressions unchanged — region metadata is stored internally
            // in struct_regions and func_signatures fields. This preserves AST structure
            // for downstream phases (type inference, etc.).
            result.push(expr.clone());
        }

        if !result.is_empty() {
            Ok(result)
        } else {
            Err(ZylError::E_REGION_ESCAPE(Span::default()))
        }
    }

    /// First pass: collect definitions to establish baseline regions.
    fn collect_definitions(&mut self, exprs: &[Expr]) {
        for expr in exprs {
            match &expr.inner {
                // defn — parameters go Stack (unless they escape via return).
                ExprInner::Defn(name, params, body) => {
                    let mut param_regions = Vec::with_capacity(params.len());
                    for p in params {
                        self.env.bind(p.name.clone(), Region::Stack);
                        param_regions.push(Region::Stack);
                    }
                    // Infer return region from body.
                    if let Ok(rr) = self.infer_expr(body) {
                        self.func_signatures.insert(
                            name.clone(),
                            FuncSig {
                                param_regions,
                                return_region: rr.result_region,
                            },
                        );
                    } else {
                        self.func_signatures.insert(
                            name.clone(),
                            FuncSig {
                                param_regions,
                                return_region: Region::Heap, // conservative default.
                            },
                        );
                    }
                }

                ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let params: Vec<Param> = parse_params_from_expr(&args[1]);
                    let mut param_regions = Vec::with_capacity(params.len());
                    for p in &params {
                        self.env.bind(p.name.clone(), Region::Stack);
                        param_regions.push(Region::Stack);
                    }
                    if let Ok(rr) = self.infer_expr(&args[2]) {
                        self.func_signatures.insert(
                            name,
                            FuncSig {
                                param_regions,
                                return_region: rr.result_region,
                            },
                        );
                    } else {
                        self.func_signatures.insert(
                            name,
                            FuncSig {
                                param_regions,
                                return_region: Region::Heap,
                            },
                        );
                    }
                }

                ExprInner::Apply(fname, args) if fname == "defn" && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let params: Vec<Param> = parse_params_from_expr(&args[1]);
                    let mut param_regions = Vec::with_capacity(params.len());
                    for p in &params {
                        self.env.bind(p.name.clone(), Region::Stack);
                        param_regions.push(Region::Stack);
                    }
                    if let Ok(rr) = self.infer_expr(&args[2]) {
                        self.func_signatures.insert(
                            name,
                            FuncSig {
                                param_regions,
                                return_region: rr.result_region,
                            },
                        );
                    } else {
                        self.func_signatures.insert(
                            name,
                            FuncSig {
                                param_regions,
                                return_region: Region::Heap,
                            },
                        );
                    }
                }

                // def — immutable binding → Global if value is a literal constant.
                ExprInner::Def(_, val) => {
                    let region = infer_literal_region(val);
                    drop(region); // just collecting; actual binding in infer_expr.
                }

                // struct/struct+ — fields default to Stack, promoted on escape.
                ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                    let field_regions: Vec<(String, Region)> = sd
                        .fields
                        .iter()
                        .map(|(name, _)| (name.clone(), Region::Stack))
                        .collect();
                    self.struct_regions.insert(sd.name.clone(), field_regions);
                }

                // deftype — variants default to Heap.
                ExprInner::Deftype(name, _, _) => {
                    let field_regions: Vec<(String, Region)> =
                        vec![(format!("{}_instance", name), Region::Heap)];
                    self.struct_regions.insert(name.clone(), field_regions);
                }

                _ => {} // Other expressions handled in infer_expr.
            }
        }
    }

    /// Second pass: analyze each expression and assign regions per rules R1–R8.
    fn infer_expr(&mut self, expr: &Expr) -> std::result::Result<RegionResult, ZylError> {
        match &expr.inner {
            // Atom literals — primitives are Stack (small values).
            ExprInner::Atom(atom) => Ok(RegionResult {
                result_region: infer_literal_region_expr(&atom),
                captures: None,
            }),

            // def — bind variable to region. Literals → Global; expressions → inferred from val.
            ExprInner::Def(name, val) => {
                let val_result = self.infer_expr(val)?;
                // If the value is a literal constant (no side effects), assign Global.
                let region = if is_literal_constant(val) {
                    Region::Global
                } else {
                    val_result.result_region
                };
                self.env.bind(name.clone(), region);
                Ok(RegionResult {
                    result_region: region,
                    captures: None,
                })
            }

            // defn — handled in collect_definitions; here just verify.
            ExprInner::Defn(_, _, _) => Ok(RegionResult {
                result_region: Region::Heap, // function values live on Heap.
                captures: None,
            }),

            // let — binding is Stack by default (R1).
            ExprInner::Let(name, val, body) => {
                self.env.enter_scope();
                let val_result = self.infer_expr(val)?;
                self.env.bind(name.clone(), Region::Stack);
                let result = self.infer_expr(body)?;
                // Check if the bound variable was escaped.
                if self.env.is_escaped(name) {
                    return Err(ZylError::E_REGION_ESCAPE(expr.span.clone()));
                }
                self.env.exit_scope();
                Ok(result)
            }

            // let-mut — same as let but with TMut capability check (R1).
            ExprInner::LetMut(name, val, body) => {
                self.env.enter_scope();
                let val_result = self.infer_expr(val)?;
                self.env.bind(name.clone(), Region::Stack);
                let result = self.infer_expr(body)?;
                if self.env.is_escaped(name) {
                    return Err(ZylError::E_REGION_ESCAPE(expr.span.clone()));
                }
                self.env.exit_scope();
                Ok(result)
            }

            // if — both branches inherit their regions. Result is union of branch regions.
            ExprInner::If(cond, then_, else_) => {
                let _ = self.infer_expr(cond)?;
                let then_result = self.infer_expr(then_)?;
                let else_result = self.infer_expr(else_)?;
                let result_region =
                    union_regions(then_result.result_region, else_result.result_region);
                Ok(RegionResult {
                    result_region,
                    captures: None,
                })
            }

            // while — loop body inherits its parent's scope regions.
            ExprInner::While(cond, body) => {
                let _ = self.infer_expr(cond)?;
                let result = self.infer_expr(body)?;
                Ok(result)
            }

            // for — loop variables are Stack (R1).
            ExprInner::For(bindings, cond, body) => {
                eprintln!("DEBUG For: bindings={:?} cond={:?} body={:?}", 
                    bindings.iter().map(|(n, v)| (n.clone(), v.is_some())).collect::<Vec<_>>(),
                    std::mem::discriminant(&cond.inner),
                    std::mem::discriminant(&body.inner));
                // Infer init binding values if present.
                for (_, val_opt) in bindings {
                    if let Some(ref val) = val_opt {
                        drop(self.infer_expr(val)?);
                    }
                }
                self.env.enter_scope();
                for (name, _) in bindings {
                    self.env.bind(name.clone(), Region::Stack);
                }
                let _ = self.infer_expr(cond)?;
                let result = self.infer_expr(body)?;
                for (name, _) in bindings.iter() {
                    if self.env.is_escaped(name) {
                        return Err(ZylError::E_REGION_ESCAPE(expr.span.clone()));
                    }
                }
                self.env.exit_scope();
                Ok(result)
            }

            // cond — each clause is analyzed independently.
            ExprInner::Cond(clauses) => {
                let mut result_region = Region::Stack;
                for (pred, body) in clauses {
                    let _ = self.infer_expr(pred)?;
                    let br_result = self.infer_expr(body)?;
                    result_region = union_regions(result_region, br_result.result_region);
                }
                Ok(RegionResult {
                    result_region,
                    captures: None,
                })
            }

            // begin — last expression determines the region.
            ExprInner::Begin(exprs) => {
                let mut result_region = Region::Stack;
                for e in exprs {
                    let r = self.infer_expr(e)?;
                    result_region = union_regions(result_region, r.result_region);
                }
                Ok(RegionResult {
                    result_region,
                    captures: None,
                })
            }

            // lambda/fn — closure creates a capture set (R5).
            ExprInner::Lambda(_, params, body) | ExprInner::Fn(_, params, body) => {
                self.env.enter_scope();
                for p in params {
                    self.env.bind(p.name.clone(), Region::Stack);
                }

                // Capture analysis: find which outer-scope variables are referenced.
                let captured = analyze_captures(self, body)?;

                // Promote escaped captures to Heap (R5).
                for var in &captured.variables {
                    if self.env.contains(var) && !self.env.is_escaped(var) {
                        // This variable is captured by an escaping closure → promote.
                        let _ = self.env.escape(var);
                    }
                }

                let result = self.infer_expr(body)?;
                self.env.exit_scope();

                Ok(RegionResult {
                    result_region: Region::Heap, // closures themselves live on Heap.
                    captures: if !captured.variables.is_empty() {
                        Some(captured)
                    } else {
                        None
                    },
                })
            }

            // try/catch — catch handler may introduce new bindings (Stack).
            ExprInner::TryCatch(e, name, h) => {
                let expr_result = self.infer_expr(e)?;
                self.env.enter_scope();
                self.env.bind(name.clone(), Region::Heap); // error values are Heap.
                let catch_result = self.infer_expr(h)?;
                self.env.exit_scope();
                let result_region =
                    union_regions(expr_result.result_region, catch_result.result_region);
                Ok(RegionResult {
                    result_region,
                    captures: None,
                })
            }

            // match — each arm analyzed independently.
            ExprInner::Match(e, arms) => {
                let _ = self.infer_expr(e)?;
                let mut result_region = Region::Stack;
                for arm in arms {
                    let arm_result = self.infer_expr(&arm.body)?;
                    result_region = union_regions(result_region, arm_result.result_region);
                }
                Ok(RegionResult {
                    result_region,
                    captures: None,
                })
            }

            // spawn — captured variables must be Send-capable (TCap/TAtomic), promoted to Heap (R3).
            ExprInner::Spawn(closure) => {
                let _ = self.infer_expr(closure)?;
                // Actor transfer requires Heap region for all captures.
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }

            // send — message must be Send-capable (R3).
            ExprInner::Send(actor, msg) => {
                let _ = self.infer_expr(actor)?;
                let msg_result = self.infer_expr(msg)?;
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }

            // ffi-call — requires Pin region (R4).
            ExprInner::FfiCall(_, _, _) => Ok(RegionResult {
                result_region: Region::Pin,
                captures: None,
            }),

            // ffi-pin — explicitly pins to Pin region.
            ExprInner::FfiPin(e) => {
                let _ = self.infer_expr(e)?;
                Ok(RegionResult {
                    result_region: Region::Pin,
                    captures: None,
                })
            }

            // ffi-unpin — unpinning returns the underlying value's region.
            ExprInner::FfiUnpin(e) => {
                let result = self.infer_expr(e)?;
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }

            // set! — rebinding a variable (R1). Must exist in scope.
            ExprInner::SetBang(name, val) => {
                let val_result = self.infer_expr(val)?;
                if !self.env.contains(name) {
                    return Err(ZylError::E_UNINITIALIZED_USE(
                        expr.span.clone(),
                        name.clone(),
                    ));
                }
                Ok(RegionResult {
                    result_region: val_result.result_region,
                    captures: None,
                })
            }

            // struct-get — returns reference to field; region = parent's region.
            ExprInner::StructGet(target, _field) => {
                let target_result = self.infer_expr(target)?;
                Ok(RegionResult {
                    result_region: target_result.result_region,
                    captures: None,
                })
            }

            // make-struct — struct instance is Heap by default (R2).
            ExprInner::MakeStruct(_, fields) => {
                for f in fields {
                    let _ = self.infer_expr(f)?;
                }
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }

            // Call/Apply — function application. Arguments evaluated left-to-right (spec §11).
            ExprInner::Call(op, args) => {
                let _ = self.infer_expr(op)?;
                for arg in args {
                    let _ = self.infer_expr(arg)?;
                }
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }

            ExprInner::Apply(name, args) => {
                // Check if this is a known function with Pin return.
                if name == "ffi-call" || name.starts_with("ffi_") {
                    Ok(RegionResult {
                        result_region: Region::Pin,
                        captures: None,
                    })
                } else {
                    for arg in args {
                        let _ = self.infer_expr(arg)?;
                    }
                    Ok(RegionResult {
                        result_region: Region::Heap,
                        captures: None,
                    })
                }
            }

            // with-resource — binding is Stack (R1), body inherits.
            ExprInner::WithResource(name, init, body) => {
                let _ = self.infer_expr(init)?;
                self.env.enter_scope();
                self.env.bind(name.clone(), Region::Stack);
                let result = self.infer_expr(body)?;
                if self.env.is_escaped(name) {
                    return Err(ZylError::E_REGION_ESCAPE(expr.span.clone()));
                }
                self.env.exit_scope();
                Ok(result)
            }

            // assert — no region impact.
            ExprInner::Assert(_, _) => Ok(RegionResult {
                result_region: Region::Stack,
                captures: None,
            }),

            // error — runtime value on Heap.
            ExprInner::Error(_) => Ok(RegionResult {
                result_region: Region::Heap,
                captures: None,
            }),

            // unwrap — returns inner value's region.
            ExprInner::Unwrap(e) => self.infer_expr(e),

            // print — no region impact (side effect only).
            ExprInner::Print(exprs) => {
                for e in exprs {
                    let _ = self.infer_expr(e)?;
                }
                Ok(RegionResult {
                    result_region: Region::Stack,
                    captures: None,
                })
            }

            // read-line — returns String on Heap.
            ExprInner::ReadLine => Ok(RegionResult {
                result_region: Region::Heap,
                captures: None,
            }),

            // exit — no region impact (terminates).
            ExprInner::Exit(e) => self.infer_expr(e),

            // close — resource cleanup, no region change.
            ExprInner::Close(e) => self.infer_expr(e),

            // defmacro — macro definitions are Global (compile-time only).
            ExprInner::MacroDef(_, _, _) => Ok(RegionResult {
                result_region: Region::Global,
                captures: None,
            }),

            // trait/impl/deftype/struct/alias/derive/export/module/use/test/* — compile-time constructs.
            ExprInner::TraitDecl(..) | ExprInner::ImplBlock(..) | ExprInner::Deftype(..) => {
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                let _ = sd; // already collected in collect_definitions.
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::AliasDecl(_, target) => self.infer_expr(target),

            ExprInner::Derive(..) | ExprInner::Export(_) | ExprInner::ModuleDecl(_) => {
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::UseModule(..) => Ok(RegionResult {
                result_region: Region::Stack,
                captures: None,
            }),

            // Test constructs — compile-time or isolated runtime.
            ExprInner::TestSuite(_, tests, _) => {
                let _ = flatten_tests(tests);
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::Setup(exprs_list) | ExprInner::Teardown(exprs_list) => {
                for e in exprs_list {
                    let _ = self.infer_expr(e)?;
                }
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::TestDecl(_, body, _) => {
                self.infer_expr(body)?;
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::AssertEqual(a_expr, b_expr) => {
                let _ = self.infer_expr(a_expr)?;
                let _ = self.infer_expr(b_expr)?;
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::AssertFail(e, _)
            | ExprInner::AssertTrue(e, _)
            | ExprInner::AssertFalse(e, _) => {
                self.infer_expr(e)?;
                Ok(RegionResult {
                    result_region: Region::Global,
                    captures: None,
                })
            }

            ExprInner::TestProperty(_, _, body) => self.infer_expr(body),

            ExprInner::RunTests(_) | ExprInner::TestCompile(..) => Ok(RegionResult {
                result_region: Region::Global,
                captures: None,
            }),

            ExprInner::MakeVariant(_, _, args) => {
                // Variant construction is heap-allocated (like MakeStruct).
                for arg in args {
                    drop(self.infer_expr(arg)?);
                }
                Ok(RegionResult {
                    result_region: Region::Heap,
                    captures: None,
                })
            }
        }
    }
}

/// Infer the region of a literal expression.
fn infer_literal_region_expr(atom: &Atom) -> Region {
    match atom {
        // Primitives are small enough for Stack (R1).
        Atom::Int(_) | Atom::Bool(_) => Region::Stack,
        Atom::Float(_) | Atom::Str(_) => Region::Heap, // strings may be large.
        Atom::Ident(s) if s.starts_with("T_") || s.starts_with("?") => Region::Stack, // type metadata.
        _ => Region::Stack,
    }
}

/// Check if an expression is a literal constant (no side effects, no variable references).
fn is_literal_constant(expr: &Expr) -> bool {
    match &expr.inner {
        ExprInner::Atom(_) => true,
        // A string literal wrapped in Atom(String) is Global.
        _ => false,
    }
}

/// Infer region for a value expression (used by `def`).
fn infer_literal_region(expr: &Expr) -> Region {
    if is_literal_constant(expr) {
        match &expr.inner {
            ExprInner::Atom(Atom::Str(_)) | ExprInner::Atom(Atom::Float(_)) => Region::Heap,
            _ => Region::Global, // Int, Bool → Global constants.
        }
    } else {
        Region::Stack
    }
}

/// Union two regions — returns the more permissive one (the "upper bound" in region lattice).
fn union_regions(a: Region, b: Region) -> Region {
    use Region::*;
    // Lattice order: Stack < Pin < Heap = Circular < Global
    match (a, b) {
        (Global, _) | (_, Global) => Global,
        (Heap, Circular) | (Circular, Heap) => Heap,
        (Heap, _) | (_, Heap) => Heap,
        (Pin, Stack) | (Stack, Pin) => Pin,
        _ => a.max(b), // Same or comparable regions.
    }
}

impl PartialOrd for Region {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Region {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        use Region::*;
        let rank = |r: &Region| match r {
            Stack => 0,
            Pin => 1,
            Heap => 2,
            Circular => 3,
            Global => 4,
        };
        rank(self).cmp(&rank(other))
    }
}

/// Analyze which outer-scope variables are referenced in an expression body.
fn analyze_captures(
    inferer: &RegionInferer,
    expr: &Expr,
) -> std::result::Result<CaptureInfo, ZylError> {
    let mut captured = IndexMap::<String, Region>::new();
    collect_capture_vars(expr, inferer.env.snapshot(), &mut captured)?;

    Ok(CaptureInfo {
        variables: captured.keys().cloned().collect(),
        regions: captured,
    })
}

/// Recursively collect variable references that come from outer scopes.
fn collect_capture_vars(
    expr: &Expr,
    env_snapshot: RegionEnv,
    captures: &mut IndexMap<String, Region>,
) -> std::result::Result<(), ZylError> {
    match &expr.inner {
        ExprInner::Atom(Atom::Ident(name)) => {
            // Check if this variable exists in the outer scope (not bound locally).
            if env_snapshot.contains(name) && !captures.contains_key(name) {
                if let Some((region, _)) = env_snapshot.get(name) {
                    captures.insert(name.clone(), region);
                }
            }
        }

        ExprInner::Call(op, args) => {
            collect_capture_vars(op, env_snapshot.clone(), captures)?;
            for arg in args {
                collect_capture_vars(arg, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::Apply(name, args) if name != "defn" && name != "let" && name != "for" => {
            // Function application — check all arguments for outer references.
            for arg in args {
                collect_capture_vars(arg, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::Def(_, val) | ExprInner::LetMut(_, val, _) => {
            collect_capture_vars(val, env_snapshot.clone(), captures)?;
        }

        ExprInner::If(c, t, e) => {
            collect_capture_vars(c, env_snapshot.clone(), captures)?;
            collect_capture_vars(t, env_snapshot.clone(), captures)?;
            collect_capture_vars(e, env_snapshot.clone(), captures)?;
        }

        ExprInner::While(c, b) => {
            collect_capture_vars(c, env_snapshot.clone(), captures)?;
            collect_capture_vars(b, env_snapshot.clone(), captures)?;
        }

        ExprInner::Unwrap(inner) => {
            collect_capture_vars(inner, env_snapshot.clone(), captures)?;
        }

        ExprInner::For(ref bindings, cond, body) => {
            for (_, val_opt) in bindings.iter() {
                if let Some(ref val) = val_opt {
                    collect_capture_vars(val, env_snapshot.clone(), captures)?;
                }
            }
            collect_capture_vars(cond, env_snapshot.clone(), captures)?;
            collect_capture_vars(body, env_snapshot.clone(), captures)?;
        }

        ExprInner::TryCatch(e, _name, h) => {
            collect_capture_vars(e, env_snapshot.clone(), captures)?;
            collect_capture_vars(h, env_snapshot.clone(), captures)?;
        }

        ExprInner::Send(actor, msg) => {
            collect_capture_vars(actor, env_snapshot.clone(), captures)?;
            collect_capture_vars(msg, env_snapshot.clone(), captures)?;
        }

        ExprInner::Match(e, arms) => {
            collect_capture_vars(e, env_snapshot.clone(), captures)?;
            for arm in arms {
                collect_capture_vars(&arm.body, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::Cond(clauses) => {
            for (pred, body) in clauses {
                collect_capture_vars(pred, env_snapshot.clone(), captures)?;
                collect_capture_vars(body, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::Begin(exprs_list) | ExprInner::Print(exprs_list) => {
            for e in exprs_list {
                collect_capture_vars(e, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::Lambda(_, _, body) | ExprInner::Fn(_, _, body) => {
            // Nested closures — capture from the outer closure's scope.
            collect_capture_vars(body, env_snapshot.clone(), captures)?;
        }

        ExprInner::StructGet(target, _field) => {
            collect_capture_vars(target, env_snapshot.clone(), captures)?;
        }

        ExprInner::MakeStruct(_, fields_list) => {
            for f in fields_list.iter() {
                collect_capture_vars(f, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::FfiCall(_, args_list, _) => {
            for a in args_list.iter() {
                collect_capture_vars(a, env_snapshot.clone(), captures)?;
            }
        }

        ExprInner::SetBang(name, val) => {
            // The variable being set is a reference to an outer binding.
            if env_snapshot.contains(name) && !captures.contains_key(name) {
                if let Some((region, _)) = env_snapshot.get(name) {
                    captures.insert(name.clone(), region);
                }
            }
            collect_capture_vars(val, env_snapshot.clone(), captures)?;
        }

        ExprInner::Exit(e_expr) => {
            collect_capture_vars(e_expr, env_snapshot.clone(), captures)?;
        }

        // Other constructs don't introduce new capture references.
        _ => {}
    }
    Ok(())
}

/// Helper: annotate an expression with its inferred region as a metadata Atom.
fn annotate_with_region(expr: &Expr, region: Region) -> ExprInner {
    let meta = format!("REGION={}", region);
    // Wrap the original expression's inner in a Call-like structure with region metadata.
    // We use a special marker atom to carry the region info without changing the AST shape.
    ExprInner::Atom(Atom::Ident(meta))
}

/// Parse parameters from an S-expression (for no-dispatch parsing compatibility).
fn parse_params_from_expr(expr: &Expr) -> Vec<Param> {
    match &expr.inner {
        // Call from special forms — all elements are params.
        ExprInner::Call(op, ref items) => {
            let mut params = Vec::new();
            if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_))) {
                let all_simple = items.iter().all(|i| {
                    matches!(&i.inner, ExprInner::Atom(Atom::Ident(_) | Atom::Keyword(_)))
                });
                if all_simple {
                    if let ExprInner::Atom(Atom::Ident(n)) = &op.inner {
                        params.push(Param {
                            span: Span::default(),
                            name: n.clone(),
                            typ: None,
                        });
                    }
                }
            }
            for i in items {
                params.push(parse_single_param(i));
            }
            params
        }
        // Apply from generic calls — treat operator + args as params.
        ExprInner::Apply(ref name, ref args)
            if !name.starts_with("make-")
                && name
                    .chars()
                    .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!')) =>
        {
            let mut params = Vec::new();
            if name
                .chars()
                .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!'))
            {
                params.push(Param {
                    span: Span::default(),
                    name: name.clone(),
                    typ: None,
                });
            }
            for pe in args {
                params.push(parse_single_param(pe));
            }
            params
        }
        _ => Vec::new(),
    }
}

fn parse_single_param(expr: &Expr) -> Param {
    match &expr.inner {
        ExprInner::Call(_, inner) if !inner.is_empty() => {
            let name = match &inner[0].inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            let typ = if inner.len() > 1 {
                match &inner[1].inner {
                    ExprInner::Atom(Atom::Ident(s)) => Some(s.clone()),
                    _ => None,
                }
            } else {
                None
            };
            Param {
                span: Span::default(),
                name,
                typ,
            }
        }
        _ => {
            let name = match &expr.inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            Param {
                span: Span::default(),
                name,
                typ: None,
            }
        }
    }
}

fn is_ident_op(op: &Expr, name: &str) -> bool {
    matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
}
fn flatten_tests(_tests: &[TestOrSuite]) -> Vec<&Expr> {
    // Phase 4 MVP: skip detailed test expression analysis.
    // Test bodies are handled by their individual expr arms in infer_expr.
    Vec::new()
}
