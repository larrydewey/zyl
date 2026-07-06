use indexmap::IndexMap;
use std::collections::{HashMap, HashSet};

use crate::ast::*;
use crate::error::{Span, ZylError};
use crate::type_system::*;
use crate::type_inference::{TypeInferer, is_generic_param};

/// A single generic parameter with its trait bounds.
#[derive(Debug, Clone)]
pub struct GenericParam {
    /// Parameter name (e.g., "T", "U").
    pub name: String,
    /// Trait bounds this type parameter must satisfy (e.g., ["Ord"], ["Eq", "Hash"]).
    pub bounds: Vec<String>,
}

/// A monomorphized function instance.
#[derive(Debug, Clone)]
pub struct MonoInstance {
    /// Canonical name of the specialized function (e.g., "min_Int_String").
    pub canonical_name: String,
    /// The original generic function body to specialize (with type vars substituted).
    pub body: Box<Expr>,

    /// Substituted parameters with concrete types.
    pub params: Vec<Param>,
}

/// Monomorphization context — holds all data needed for Phase 6.
pub struct MonoContext {
    /// Generic functions discovered from AST + type inference.
    /// Maps (original_name, canonical_name) → instantiation info.
    generic_functions: IndexMap<String, Vec<GenericParam>>,

    /// Known function signatures from type inference.
    known_functions: IndexMap<String, Vec<(String, Type)>>,

    /// Function return types from type inference.
    function_returns: IndexMap<String, Type>,

    /// Trait context for bound verification.
    trait_ctx: TraitContext,

    /// Cache of monomorphized functions by canonical name.
    mono_cache: HashMap<String, MonoInstance>,

    /// All known nominal types (for ADT monomorphization).
    known_types: IndexMap<String, Type>,

    /// Struct definitions for field-level monomorphization.
    struct_defs: IndexMap<String, Vec<(String, Option<Type>)>>,

    /// Span used for generated expressions.
    span: Span,
}

impl MonoContext {
    pub fn new(inferer: &TypeInferer) -> Self {
        let mut ctx = Self {
            generic_functions: IndexMap::new(),
            known_functions: inferer.get_known_functions().clone(),
            function_returns: inferer.get_function_returns().clone(),
            trait_ctx: inferer.get_trait_context().clone(),
            mono_cache: HashMap::new(),
            known_types: inferer.get_known_types().clone(),
            struct_defs: inferer.get_struct_defs().clone(),
            span: Span::default(),
        };

        // Discover generic functions from AST (done externally via discover_generics).
        ctx
    }

    /// Register a generic function definition.
    pub fn register_generic(&mut self, name: String, params: Vec<GenericParam>) {
        if !params.is_empty() {
            self.generic_functions.insert(name, params);
        }
    }

    /// Discover all generic functions from the AST by scanning Defn nodes.
    /// A function is generic if any parameter has an uppercase name (generic param convention).
    pub fn discover_from_ast(&mut self, exprs: &[Expr]) {
        for expr in exprs {
            match &expr.inner {
                ExprInner::Defn(name, params, _) => {
                        let generics = Self::extract_generics(params);
                    if !generics.is_empty() {
                        self.generic_functions.insert(name.clone(), generics);
                    }
                }

                // Raw Call form for defn (from no-dispatch parsing).
                ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                    let n = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };

                    // Extract params from the params list (Call form: first element is param name, rest are more params).
                    let mut all_params: Vec<Expr> = match &args[1].inner {
                        ExprInner::Call(ref op_expr, ref pexprs) => {
                            let mut ps: Vec<Expr> = vec![*op_expr.clone()];  // First param = operator itself
                            for p in pexprs { ps.push(p.clone()); }
                            ps
                        }
                        ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                        _ => continue,
                    };

                    let params: Vec<Param> = all_params.iter().map(|pe| parse_single_param(pe)).collect();
                    let generics = Self::extract_generics(&params);
                    if !generics.is_empty() {
                        self.generic_functions.insert(n, generics);
                    }
                }

                // Apply form for defn.
                ExprInner::Apply(fname, args) if fname == "defn" && args.len() >= 3 => {
                    let n = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };

                    // Extract params from the params list.
                    let mut all_params: Vec<Expr> = match &args[1].inner {
                        ExprInner::Call(ref op_expr, ref pexprs) => {
                            let mut ps: Vec<Expr> = vec![*op_expr.clone()];  // First param = operator itself
                            for p in pexprs { ps.push(p.clone()); }
                            ps
                        }
                        ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                        _ => continue,
                    };

                    let params: Vec<Param> = all_params.iter().map(|pe| parse_single_param(pe)).collect();
                    let generics = Self::extract_generics(&params);
                    if !generics.is_empty() {
                        self.generic_functions.insert(n, generics);
                    }
                }

                // Deftype with generic variants.
                ExprInner::Deftype(name, variants, _) => {
                    let has_generic = variants.iter().any(|v| v.fields.iter().any(is_uppercase_ident));
                    if has_generic {
                        self.known_types.insert(name.clone(), Type::Var(0)); // Mark as generic ADT.
                    } else {
                        self.known_types.entry(name.clone()).or_insert(Type::Nominal(name.clone()));
                    }
                }

                ExprInner::Apply(fname, args) if fname == "deftype" && args.len() >= 2 => {
                    let tname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = tname {
                        // Check for generic variants in Apply form.
                        if args.len() > 1 {
                            let has_generic = check_apply_for_generics(&args[1..]);
                            if has_generic {
                                self.known_types.insert(name.clone(), Type::Var(0));
                            } else {
                                self.known_types.entry(name.clone()).or_insert_with(|| Type::Nominal(name.clone()));
                            }
                        }
                    }
                }

                // StructDef with generic fields.
                ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                    let has_generic = sd.fields.iter().any(|(_, t)| {
                        matches!(t, Some(s) if is_uppercase_ident(s))
                    });
                    if has_generic {
                        self.known_types.entry(sd.name.clone()).or_insert(Type::Var(0));
                    } else {
                        self.known_types.entry(sd.name.clone()).or_insert_with(|| Type::Nominal(sd.name.clone()));
                    }
                }

                ExprInner::Call(op, args) if is_ident_op(op, "defstruct") && args.len() >= 2 => {
                    let sname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = sname {
                        self.known_types.entry(name.clone()).or_insert_with(|| Type::Nominal(name.clone()));
                    }
                }

                _ => {}
            }
        }
    }

    /// Extract generic parameters from a list of function params.
    fn extract_generics(params: &[Param]) -> Vec<GenericParam> {
        let mut generics = Vec::new();
        for param in params {
            if is_uppercase_ident(&param.name) {
                // This parameter name follows the generic convention (uppercase).
                let bounds = Self::resolve_trait_bounds(&param.typ);
                generics.push(GenericParam {
                    name: param.name.clone(),
                    bounds,
                });
            }
        }
        generics
    }

    /// Resolve trait bounds from a parameter's type annotation.
    /// `(T : Ord)` → typ = Some("Ord") → if "Ord" is a registered trait, bound = ["Ord"].
    fn resolve_trait_bounds(typ: &Option<String>) -> Vec<String> {
        match typ {
            None => vec![], // No explicit type annotation — unbounded generic.
            Some(t) => {
                let mut bounds = Vec::new();

                // Check if the type string matches a registered trait name.
                if crate::type_inference::is_generic_param(t) || is_uppercase_ident(t) {
                    // It's an uppercase identifier — could be a trait bound or nominal type.
                    // If it's in known traits, treat as a bound.
                    bounds.push(t.clone());
                }

                bounds
            }
        }
    }

    /// Process all expressions: monomorphize generic functions and replace call sites.
    pub fn process(&mut self, exprs: &[Expr]) -> Result<Vec<Expr>, ZylError> {
        let mut result = Vec::new();


        for expr in exprs {
            match &expr.inner {
                // Monomorphize generic function definitions themselves.
                ExprInner::Defn(name, params, body) => {
                    if self.generic_functions.contains_key(name) {
                        let generics = &self.generic_functions[name];
                        for mono in self.generate_instantiations(name, generics, params.clone(), body)? {
                            result.push(Expr {
                                span: self.span.clone(),
                                inner: ExprInner::Defn(mono.canonical_name, mono.params.clone(), mono.body),
                            });
                        }
                        // Keep original as reference.
                        result.push(expr.clone());
                    } else {
                        result.push(self.substitute_in_expr(expr));
                    }
                }

                ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                    let n = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = n {
                        if self.generic_functions.contains_key(name) {
                            let generics = &self.generic_functions[name];
                            let mut all_params: Vec<Expr> = match &args[1].inner {
                                ExprInner::Call(ref op_expr, ref pexprs) => {
                                    let mut ps: Vec<Expr> = vec![*op_expr.clone()];
                                    for p in pexprs { ps.push(p.clone()); }
                                    ps
                                }
                                ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                                _ => Vec::new(),
                            };
                            let params: Vec<Param> = all_params.iter().map(|pe| parse_single_param(pe)).collect();

                            for mono in self.generate_instantiations(name, generics, params, &args[2])? {
                                result.push(Expr {
                                    span: self.span.clone(),
                                    inner: ExprInner::Defn(mono.canonical_name, mono.params.clone(), mono.body),
                                });
                            }

                            // Keep original as reference.
                            if !result.is_empty() && matches!(result.last().unwrap().inner, ExprInner::Defn(_, _, _)) {
                                result.push(expr.clone());
                            } else {
                                result.push(self.substitute_in_expr(expr));
                            }
                        } else {
                            result.push(self.substitute_in_expr(expr));
                        }
                    } else {
                        result.push(expr.clone());
                    }
                }

                ExprInner::Apply(fname, args) if fname == "defn" && args.len() >= 3 => {
                    let n = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = n {
                        if self.generic_functions.contains_key(name) {
                            let generics = &self.generic_functions[name];
                            let mut all_params: Vec<Expr> = match &args[1].inner {
                                ExprInner::Call(ref op_expr, ref pexprs) => {
                                    let mut ps: Vec<Expr> = vec![*op_expr.clone()];
                                    for p in pexprs { ps.push(p.clone()); }
                                    ps
                                }
                                ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                                _ => Vec::new(),
                            };
                            let params: Vec<Param> = all_params.iter().map(|pe| parse_single_param(pe)).collect();

                            for mono in self.generate_instantiations(name, generics, params, &args[2])? {
                                result.push(Expr {
                                    span: self.span.clone(),
                                    inner: ExprInner::Defn(mono.canonical_name, mono.params.clone(), mono.body),
                                });
                            }

                            if !result.is_empty() && matches!(result.last().unwrap().inner, ExprInner::Defn(_, _, _)) {
                                result.push(expr.clone());
                            } else {
                                result.push(self.substitute_in_expr(expr));
                            }
                        } else {
                            result.push(self.substitute_in_expr(expr));
                        }
                    } else {
                        result.push(expr.clone());
                    }
                }

                ExprInner::Deftype(name, variants, bound) => {
                    let has_generic = variants.iter().any(|v| v.fields.iter().any(is_uppercase_ident));
                    if has_generic && self.known_types.get(name).map_or(false, |t| matches!(t, Type::Var(_))) {
                        let instantiations = self.collect_adt_instantiations(name, variants);
                        for (concrete_name, mono_variants) in instantiations {
                            result.push(Expr {
                                span: self.span.clone(),
                                inner: ExprInner::Deftype(concrete_name, mono_variants, bound.as_ref().map(|b| b.clone())),
                            });
                        }

                        if !result.is_empty() && matches!(result.last().unwrap().inner, ExprInner::Deftype(_, _, _)) {
                            result.push(expr.clone());
                        } else {
                            result.push(self.substitute_in_adt(expr));
                        }
                    } else {
                        result.push(self.substitute_in_adt(expr));
                    }
                }

                ExprInner::Apply(fname, args) if fname == "deftype" && args.len() >= 2 => {
                    let tname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = tname {
                        if self.known_types.get(name).map_or(false, |t| matches!(t, Type::Var(_))) && args.len() > 1 {
                            result.push(expr.clone());
                        } else if self.known_types.contains_key(name) {
                            result.push(self.substitute_in_expr(expr));
                        } else {
                            result.push(expr.clone());
                        }
                    } else {
                        result.push(expr.clone());
                    }
                }

                // Handle function calls — replace generic calls with monomorphized references.
                ExprInner::Apply(fname, args) => {
                    if let Some(generics) = self.generic_functions.get(fname.as_str()) {
                        match self.resolve_call_site(fname, generics, args)? {
                            Some(canonical_name) => {
                                // Keep as Apply form with canonical name and original args.
                                result.push(Expr {
                                    span: expr.span.clone(),
                                    inner: ExprInner::Apply(canonical_name, args.to_vec()),
                                });
                            }
                            None => {
                                result.push(expr.clone());
                            }
                        }
                    } else if is_builtin_op(fname) || matches!(fname.as_str(), "+" | "-" | "*" | "/" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "not" | "and" | "or") {
                        result.push(self.substitute_in_expr(expr));
                    } else if self.known_functions.contains_key(fname) || self.function_returns.contains_key(fname) {
                        result.push(self.substitute_in_expr(expr));
                    } else {
                        result.push(self.substitute_in_expr(expr));
                    }
                }

                ExprInner::Call(op, args) => {
                    let op_name = match &op.inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = op_name {
                        if self.generic_functions.contains_key(name.as_str()) && !is_builtin_op(name) {
                            let generics = &self.generic_functions[name];
                             match self.resolve_call_site(name, generics, args)? {
                                 Some(canonical_name) => {
                                     let op = Box::new(Expr { span: expr.span.clone(), inner: ExprInner::Atom(Atom::Ident(canonical_name)) });
                                     result.push(Expr {
                                         span: expr.span.clone(),
                                         inner: ExprInner::Call(op, args.to_vec()),
                                     });
                                 }
                                 None => {
                                    result.push(expr.clone());
                                }
                            }
                        } else if is_builtin_op(name) || matches!(name.as_str(), "+" | "-" | "*" | "/" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "not" | "and" | "or") {
                            result.push(self.substitute_in_expr(expr));
                        } else if self.known_functions.contains_key(name) || self.function_returns.contains_key(name) {
                            result.push(self.substitute_in_expr(expr));
                        } else {
                            result.push(self.substitute_in_expr(expr));
                        }
                    } else {
                        result.push(self.substitute_in_expr(expr));
                    }
                }

                _ => {
                    result.push(self.substitute_in_expr(expr));
                }
            }
        }

        Ok(result)
    }

    /// Resolve a call site: determine the canonical name for a generic function call.
    fn resolve_call_site(
        &self,
        fname: &str,
        generics: &[GenericParam],
        args: &[Expr],
    ) -> Result<Option<String>, ZylError> {
        if generics.is_empty() {
            return Ok(None); // Not actually generic.
        }

        let known = self.known_functions.get(fname).cloned().unwrap_or_default();

        // Infer concrete types for each generic parameter by matching argument types to param types.
        let mut type_map: IndexMap<String, Type> = IndexMap::new();

        for (i, arg) in args.iter().enumerate() {
            if i >= known.len() {
                break;
            }

            let (_, expected_type) = &known[i];

            // Infer the concrete type of this argument.
            let arg_type = self.infer_arg_type(arg);

            match (expected_type, &arg_type) {
                // Unbounded generic: param has a fresh var as its type — use arg's inferred type directly.
                (Type::Var(_), _) => {
                    if !type_map.contains_key(fname) || true {
                        // Use the first occurrence to determine the concrete type for this generic param.
                        // We need to map which parameter index corresponds to which generic.
                    }

                    // Find which generic param this argument maps to.
                    let (param_name, _) = &known[i];
                    if is_uppercase_ident(param_name) {
                        // This is a generic param — record its inferred type.
                        type_map.insert(param_name.clone(), arg_type);
                    } else {
                        // Regular typed parameter — unify with expected type.
                        self.unify_types(&arg_type, expected_type)?;
                    }
                }

                // Bounded generic: param has Nominal("Trait") as its type.
                (Type::Nominal(trait_name), concrete) => {
                    // Verify the trait bound is satisfied by the inferred argument type.
                    if !self.check_trait_bound(concrete, trait_name)? {
                        return Ok(None); // Bound not satisfied — skip this instantiation.
                    }

                    // Record that this generic param maps to the concrete arg type.
                    let (param_name, _) = &known[i];
                    type_map.insert(param_name.clone(), concrete.clone());
                }

                _ => {
                    // Concrete expected type — unify with argument.
                    self.unify_types(&arg_type, expected_type)?;
                }
            }
        }

        if type_map.is_empty() && !generics.is_empty() {
            return Ok(None); // No concrete types inferred for any generic param.
        }

        // Generate canonical name from the mapped types (sorted alphabetically).
        let mut sorted_types: Vec<(&String, &Type)> = type_map.iter().collect();
        sorted_types.sort_by(|a, b| a.0.cmp(b.0));

        let type_names: Vec<String> = sorted_types
            .iter()
            .map(|(_, ty)| format!("{}", ty))
            .collect();

        // Deduplicate — if multiple generic params map to the same concrete type, only include once.
        let mut seen = std::collections::HashSet::new();
        let unique_names: Vec<String> = type_names.iter().filter(|n| {
            seen.insert(n.clone())
        }).cloned().collect();

        // Sort alphabetically for determinism (spec §6.4).
        let mut canonical_parts = unique_names;
        canonical_parts.sort();

        let canonical_name = format!("{}_{}", fname, canonical_parts.join("_"));

        Ok(Some(canonical_name))
    }

    /// Generate all monomorphized instantiations for a generic function.
    fn generate_instantiations(
        &self,
        name: &str,
        generics: &[GenericParam],
        params: Vec<Param>,
        body: &Expr,
    ) -> Result<Vec<MonoInstance>, ZylError> {
        let known = self.known_functions.get(name).cloned().unwrap_or_default();

        // Collect all unique type instantiations from call sites.
        let mut instantiation_sets: Vec<IndexMap<String, Type>> = Vec::new();

        for (i, param_info) in known.iter().enumerate() {
            let (param_name, expected_type) = param_info;

            if !is_uppercase_ident(param_name) {
                continue; // Not a generic parameter.
            }

            match expected_type {
                Type::Var(_) => {
                    // Unbounded generic — find concrete types from arguments that map to this param.
                    for (j, arg_expr_idx) in known.iter().enumerate() {
                        if j >= known.len() || is_uppercase_ident(&arg_expr_idx.0) {
                            continue;
                        }

                        let (_, expected_arg_type) = &known[j];
                        // We need to find actual argument types — but we don't have call site info here.
                        // Instead, derive from the known_types and function_returns.
                    }
                }

                Type::Nominal(trait_name) => {
                    // Bounded generic — check what concrete types satisfy this bound.
                    let satisfying_types = self.find_satisfying_types(trait_name);
                    for ty in satisfying_types {
                        let mut inst: IndexMap<String, Type> = instantiation_sets.iter().cloned()
                            .find(|m| m.contains_key(param_name))
                            .unwrap_or_default();

                        if !inst.contains_key(param_name) || *inst.get(param_name).unwrap() != ty {
                            // Check if this exact mapping already exists.
                            let mut found = false;
                            for inst_set in &mut instantiation_sets {
                                if inst_set.get(param_name) == Some(&ty) {
                                    found = true;
                                    break;
                                }
                            }

                            if !found {
                                inst.insert(param_name.clone(), ty);
                                instantiation_sets.push(inst);
                            }
                        }
                    }
                }

                _ => {}
            }
        }

        // If no instantiations found from call sites, generate one per known type that satisfies bounds.
        if instantiation_sets.is_empty() {
            let mut inst: IndexMap<String, Type> = IndexMap::new();
            for generic in generics {
                if !generic.bounds.is_empty() {
                    // Bounded — find a satisfying concrete type.
                    for bound in &generic.bounds {
                        let types = self.find_satisfying_types(bound);
                        if let Some(ty) = types.first().cloned() {
                            inst.insert(generic.name.clone(), ty);
                            break;
                        }
                    }
                } else {
                    // Unbounded — use Int as default.
                    inst.insert(generic.name.clone(), Type::Prim(PrimType::Int));
                }
            }

            if !inst.is_empty() {
                instantiation_sets.push(inst);
            }
        }

        let mut instances = Vec::new();

        for type_map in &instantiation_sets {
            // Generate canonical name.
            let mut sorted_types: Vec<(&String, &Type)> = type_map.iter().collect();
            sorted_types.sort_by(|a, b| a.0.cmp(b.0));

            let unique_names: std::collections::HashSet<String> = sorted_types
                .iter()
                .map(|(_, ty)| format!("{}", ty))
                .filter(|n| {
                    // Deduplicate by type name (not param name).
                    true
                })
                .collect();

            let mut canonical_parts: Vec<String> = unique_names.into_iter().collect();
            canonical_parts.sort();

            if !canonical_parts.is_empty() {
                let canonical_name = format!("{}_{}", name, canonical_parts.join("_"));

                // Substitute type variables in the body.
                let substituted_body = self.substitute_types(body, type_map);
                

                // Substitute type vars in parameters too.
                let substituted_params: Vec<Param> = params.iter().map(|p| {
                    if is_uppercase_ident(&p.name) && type_map.contains_key(&p.name) {
                        Param { span: p.span.clone(), name: p.name.clone(), typ: Some(format!("{}", type_map[&p.name])) }
                    } else {
                        p.clone()
                    }
                }).collect();

                instances.push(MonoInstance {
                    canonical_name,
                    body: Box::new(substituted_body),
                    params: substituted_params,
                });
            }
        }

        Ok(instances)
    }

    /// Find concrete types that satisfy a given trait bound.
    fn find_satisfying_types(&self, trait_name: &str) -> Vec<Type> {
        let mut result = Vec::new();

        // Check registered impls for this trait.
        for impl_info in &self.trait_ctx.impls {
            if impl_info.trait_name == trait_name && !matches!(impl_info.impl_type, Type::Var(_)) {
                result.push(impl_info.impl_type.clone());
            }
        }

        // Also check known_types for primitives that satisfy common traits.
        match trait_name {
            "Eq" | "Ord" | "Debug" => {
                if !result.iter().any(|t| matches!(t, Type::Prim(PrimType::Int))) {
                    result.push(Type::Prim(PrimType::Int));
                }
                if !result.iter().any(|t| matches!(t, Type::Prim(PrimType::Float))) {
                    result.push(Type::Prim(PrimType::Float));
                }
                if !result.iter().any(|t| matches!(t, Type::Prim(PrimType::Bool))) {
                    result.push(Type::Prim(PrimType::Bool));
                }
            }
            "Clone" | "Hash" => {
                if !result.iter().any(|t| matches!(t, Type::Prim(_))) {
                    for prim in [PrimType::Int, PrimType::Float, PrimType::Bool] {
                        result.push(Type::Prim(prim));
                    }
                }
            }
            _ => {}
        }

        // Deduplicate.
        result.sort_by(|a, b| format!("{}", a).cmp(&format!("{}", b)));
        result.dedup();

        result
    }

    /// Check if a concrete type satisfies a trait bound.
    fn check_trait_bound(&self, ty: &Type, trait_name: &str) -> Result<bool, ZylError> {
        // Primitives satisfy Eq, Ord, Debug by default (per spec).
        match ty {
            Type::Prim(_) => {
                if matches!(trait_name, "Eq" | "Ord" | "Debug") {
                    return Ok(true);
                }
            }

            _ => {}
        }

        // Check registered impls.
        for impl_info in &self.trait_ctx.impls {
            if impl_info.trait_name == trait_name && format!("{}", impl_info.impl_type) == format!("{}", ty) {
                return Ok(true);
            }
        }

        // For now, assume nominal types satisfy their own-named traits.
        if let Type::Nominal(name) = ty {
            if name == trait_name || is_uppercase_ident(trait_name) {
                return Ok(true);
            }
        }

        Ok(false)
    }

    /// Infer the concrete type of an expression argument.
    fn infer_arg_type(&self, expr: &Expr) -> Type {
        match &expr.inner {
            ExprInner::Atom(Atom::Int(_)) => Type::Prim(PrimType::Int),
            ExprInner::Atom(Atom::Float(_)) => Type::Prim(PrimType::Float),
            ExprInner::Atom(Atom::Bool(_)) => Type::Prim(PrimType::Bool),
            ExprInner::Atom(Atom::Str(_)) => Type::Prim(PrimType::String),

            ExprInner::Atom(Atom::Ident(name)) => {
                if let Some(ty) = self.known_types.get(name).cloned() {
                    ty
                } else if is_generic_param(name) || is_uppercase_ident(name) {
                    Type::Var(0) // Unknown generic.
                } else {
                    Type::Nominal(name.clone())
                }
            }

            ExprInner::Apply(fname, args) => {
                if let Some(ret_ty) = self.function_returns.get(fname).cloned() {
                    ret_ty
                } else if fname == "vec" || is_ident_op(&Expr { span: Span::default(), inner: ExprInner::Atom(Atom::Ident("vec".to_string())) }, "vec") {
                    // vec constructor — infer element type from first arg.
                    args.first().map(|a| self.infer_arg_type(a)).unwrap_or(Type::Var(0))
                } else if let Some(params) = self.known_functions.get(fname).cloned() {
                    // Try to match against known function params.
                    for (i, (_, expected_ty)) in params.iter().enumerate() {
                        if i < args.len() {
                            return self.infer_arg_type(&args[i]);
                        }
                    }
                    Type::Var(0)
                } else {
                    Type::Nominal(fname.clone())
                }
            }

            ExprInner::Call(op, args) => {
                let op_name = match &op.inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return Type::Var(0),
                };

                if matches!(op_name.as_str(), "+" | "-" | "*" | "/") {
                    // Arithmetic — could be Int or Float. Default to Int.
                    args.first().map(|a| self.infer_arg_type(a)).unwrap_or(Type::Prim(PrimType::Int))
                } else if matches!(op_name.as_str(), "==" | "!=" | "<" | ">" | "<=" | ">=") {
                    Type::Prim(PrimType::Bool)
                } else if let Some(ret_ty) = self.function_returns.get(&op_name).cloned() {
                    ret_ty
                } else {
                    args.first().map(|a| self.infer_arg_type(a)).unwrap_or(Type::Var(0))
                }
            }

            ExprInner::If(_, then_, else_) => {
                let tt = self.infer_arg_type(then_);
                let et = self.infer_arg_type(else_);
                if format!("{}", tt) == format!("{}", et) {
                    tt
                } else {
                    Type::Var(0) // Ambiguous.
                }
            }

            ExprInner::Let(_, val, _) => self.infer_arg_type(val),
            ExprInner::Begin(exprs) => exprs.last().map(|e| self.infer_arg_type(e)).unwrap_or(Type::Prim(PrimType::Unit)),
            _ => Type::Var(0), // Unknown.
        }
    }

    /// Unify two types (simplified — just check compatibility).
    fn unify_types(&self, t1: &Type, t2: &Type) -> Result<(), ZylError> {
        match (t1, t2) {
            (a, b) if a == b => Ok(()),

            // Type vars can unify with anything.
            (Type::Var(_), _) | (_, Type::Var(_)) => Ok(()),

            // Primitives must match exactly for arithmetic ops.
            (Type::Prim(p1), Type::Prim(p2)) if p1 == p2 => Ok(()),

            // Int and Float can unify in mixed arithmetic contexts.
            (Type::Prim(PrimType::Int), Type::Prim(PrimType::Float)) |
            (Type::Prim(PrimType::Float), Type::Prim(PrimType::Int)) => Ok(()),

            _ => Err(ZylError::E_TYPE_MISMATCH(self.span.clone(), format!("{}", t1), format!("{}", t2))),
        }
    }

    /// Substitute type variables in an expression with concrete types.
    fn substitute_types(&self, expr: &Expr, type_map: &IndexMap<String, Type>) -> Expr {
        self.subst_expr(expr, type_map)
    }

    fn subst_expr(&self, expr: &Expr, type_map: &IndexMap<String, Type>) -> Expr {
        let new_inner = match &expr.inner {
            ExprInner::Defn(name, params, body) => {
                // Substitute in parameters and body.
                let new_params: Vec<Param> = params.iter().map(|p| {
                    if is_uppercase_ident(&p.name) && type_map.contains_key(&p.name) {
                        Param {
                            span: p.span.clone(),
                            name: p.name.clone(),
                            typ: Some(format!("{}", type_map[&p.name])),
                        }
                    } else {
                        p.clone()
                    }
                }).collect();

                ExprInner::Defn(name.clone(), new_params, Box::new(self.subst_expr(body, type_map)))
            }

            ExprInner::Call(op, args) => {
                let new_op = self.subst_expr(op, type_map);
                let new_args: Vec<Expr> = args.iter().map(|a| self.subst_expr(a, type_map)).collect();
                ExprInner::Call(Box::new(new_op), new_args)
            }

            ExprInner::Apply(fname, args) => {
                let new_args: Vec<Expr> = args.iter().map(|a| self.subst_expr(a, type_map)).collect();
                ExprInner::Apply(fname.clone(), new_args)
            }

            ExprInner::Let(name, val, body) => {
                ExprInner::Let(
                    name.clone(),
                    Box::new(self.subst_expr(val, type_map)),
                    Box::new(self.subst_expr(body, type_map)),
                )
            }

            ExprInner::If(cond, then_, else_) => {
                ExprInner::If(
                    Box::new(self.subst_expr(cond, type_map)),
                    Box::new(self.subst_expr(then_, type_map)),
                    Box::new(self.subst_expr(else_, type_map)),
                )
            }

            ExprInner::Lambda(name, params, body) => {
                let new_params: Vec<Param> = params.iter().map(|p| p.clone()).collect();
                ExprInner::Lambda(name.clone(), new_params, Box::new(self.subst_expr(body, type_map)))
            }

            ExprInner::Fn(name, params, body) => {
                let new_params: Vec<Param> = params.iter().map(|p| p.clone()).collect();
                ExprInner::Fn(name.clone(), new_params, Box::new(self.subst_expr(body, type_map)))
            }

            ExprInner::Begin(exprs) => {
                ExprInner::Begin(exprs.iter().map(|e| self.subst_expr(e, type_map)).collect())
            }

            ExprInner::While(cond, body) => {
                ExprInner::While(
                    Box::new(self.subst_expr(cond, type_map)),
                    Box::new(self.subst_expr(body, type_map)),
                )
            }

            ExprInner::For(name, iter, body) => {
                ExprInner::For(
                    name.clone(),
                    Box::new(self.subst_expr(iter, type_map)),
                    Box::new(self.subst_expr(body, type_map)),
                )
            }

            ExprInner::Cond(clauses) => {
                let new_clauses: Vec<(Box<Expr>, Box<Expr>)> = clauses.iter().map(|(c, b)| {
                    (Box::new(self.subst_expr(c, type_map)), Box::new(self.subst_expr(b, type_map)))
                }).collect();
                ExprInner::Cond(new_clauses)
            }

            ExprInner::Match(subject, arms) => {
                let new_subject = self.subst_expr(subject, type_map);
                let new_arms: Vec<MatchArm> = arms.iter().map(|arm| MatchArm {
                    variant: arm.variant.clone(),
                    patterns: arm.patterns.iter().map(|p| self.subst_expr(p, type_map)).collect(),
                    body: Box::new(self.subst_expr(&arm.body, type_map)),
                }).collect();
                ExprInner::Match(Box::new(new_subject), new_arms)
            }

            // For atoms and other simple nodes, substitute in any nested expressions.
            _ => expr.inner.clone(),
        };

        Expr { span: expr.span.clone(), inner: new_inner }
    }

    /// Substitute type variables throughout an expression (for non-generic functions).
    fn substitute_in_expr(&self, expr: &Expr) -> Expr {
        self.subst_expr(expr, &IndexMap::new())
    }

    /// Substitute in ADT expressions.
    fn substitute_in_adt(&self, expr: &Expr) -> Expr {
        match &expr.inner {
            ExprInner::Deftype(name, variants, bound) => {
                let new_variants = variants.iter().map(|v| {
                    ADTVariant {
                        name: v.name.clone(),
                        fields: v.fields.iter().filter(|f| !is_uppercase_ident(f)).cloned().collect(),
                    }
                }).collect();

                Expr { span: expr.span.clone(), inner: ExprInner::Deftype(name.clone(), new_variants, bound.as_ref().map(|b| b.clone())) }
            }

            _ => self.substitute_in_expr(expr),
        }
    }

    /// Collect ADT instantiations for a generic type.
    fn collect_adt_instantiations(&self, name: &str, variants: &[ADTVariant]) -> Vec<(String, Vec<ADTVariant>)> {
        // Find all concrete types used in the known_types that could instantiate this ADT.
        let mut instantiations: IndexMap<String, Vec<ADTVariant>> = IndexMap::new();

        for variant in variants {
            for field_type in &variant.fields {
                if is_uppercase_ident(field_type) && self.known_types.contains_key(field_type) {
                    // This field type IS a concrete known type (not just a generic param).
                    let ty = &self.known_types[field_type];

                    match ty {
                        Type::Var(_) => {
                            // Generic — will be instantiated later.
                            continue;
                        }
                        _ => {
                            let inst_name = format!("{}_{}", name, ty);

                            instantiations.entry(inst_name.clone()).or_insert_with(|| {
                                variant.fields.iter().map(|f| ADTVariant {
                                    name: f.clone(),
                                    fields: vec![], // Simplified.
                                }).collect()
                            });
                        }
                    }
                } else if !is_uppercase_ident(field_type) && self.known_types.contains_key(field_type) {
                    let ty = &self.known_types[field_type];

                    match ty {
                        Type::Var(_) => continue,
                        _ => {
                            let inst_name = format!("{}_{}", name, ty);

                            instantiations.entry(inst_name.clone()).or_insert_with(|| {
                                variant.fields.iter().map(|f| ADTVariant {
                                    name: f.clone(),
                                    fields: vec![],
                                }).collect()
                            });
                        }
                    }
                }
            }
        }

        // If no instantiations found, generate one with Int as default.
        if instantiations.is_empty() {
            let inst_name = format!("{}_Int", name);
            let mono_variants: Vec<ADTVariant> = variants.iter().map(|v| ADTVariant {
                name: v.name.clone(),
                fields: v.fields.iter().filter_map(|f| {
                    if is_uppercase_ident(f) && self.known_types.contains_key(f) {
                        Some(format!("{}", self.known_types[f]))
                    } else if !is_uppercase_ident(f) {
                        // Keep non-generic field names.
                        None
                    } else {
                        Some("Int".to_string())
                    }
                }).collect(),
            }).collect();

            instantiations.insert(inst_name, mono_variants);
        }

        instantiations.into_iter().collect()
    }
}

// ── Helpers ────────────────────────────────────────────────────────────────

fn is_uppercase_ident<T: AsRef<str>>(s: T) -> bool {
    let s = s.as_ref();
    s.len() >= 1 && s.chars().next().map(|c| c.is_ascii_uppercase()).unwrap_or(false)
        && !matches!(s, "TCap" | "TMut" | "TBox" | "TPin" | "TAtomic" | "TFun")
}

fn is_ident_op(op: &Expr, name: &str) -> bool {
    matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
}

fn parse_single_param(expr: &Expr) -> Param {
    // Handle two-element Call form like (T Ord) or (x Int).
    if let ExprInner::Call(_, ref inner) = expr.inner {
        if inner.len() == 2 {
            let nm = match &inner[0].inner {
                ExprInner::Atom(Atom::Ident(nn)) => nn.clone(),
                _ => "?".to_string(),
            };
            let tp = match &inner[1].inner {
                ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => Some(t.clone()),
                _ => None,
            };
            return Param { span: crate::error::Span::default(), name: nm, typ: tp };
        }

        // Multi-element Call — extract first element as param.
        if !inner.is_empty() {
            let nm = match &inner[0].inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            let typ = if inner.len() > 1 {
                match &inner[1].inner {
                    ExprInner::Atom(Atom::Ident(s)) | ExprInner::Atom(Atom::Keyword(s)) => Some(s.clone()),
                    _ => None,
                }
            } else { None };
            return Param { span: crate::error::Span::default(), name: nm, typ };
        }
    }

    // Handle Apply form — treat as single identifier param.
    if let ExprInner::Apply(ref name, _) = expr.inner {
        if !name.starts_with("make-") && name.chars().all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!')) {
            return Param { span: crate::error::Span::default(), name: name.clone(), typ: None };
        }
    }

    // Fallback — extract identifier from atom.
    let name = match &expr.inner {
        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
        _ => "___".to_string(),
    };
    Param { span: crate::error::Span::default(), name, typ: None }
}

fn is_builtin_op(name: &str) -> bool {
    matches!(name, "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | ">" | "<=" | ">="
        | "not" | "and" | "or" | "if" | "let" | "let-mut" | "while" | "for" | "cond"
        | "try" | "match" | "defn" | "defun" | "def" | "deftype" | "trait" | "impl"
        | "defstruct" | "defstruct+" | "alias" | "derive" | "fn" | "lambda"
        | "begin" | "set!" | "export" | "use" | "test-suite" | "setup" | "teardown"
        | "run-tests" | "print" | "read-line" | "exit" | "close" | "assert-equal"
        | "assert-fail" | "assert-true" | "assert-false" | "spawn" | "send"
        | "ffi-call" | "ffi-pin" | "ffi-unpin" | "with-resource" | "struct-get"
        | "make-struct" | "is-some" | "is-none" | "is-ok" | "is-err" | "str"
        | "int" | "float" | "vec" | "map")
}

fn check_apply_for_generics(args: &[Expr]) -> bool {
    for arg in args {
        match &arg.inner {
            ExprInner::Call(_, ref inner) => {
                // Check if any field is an uppercase identifier.
                for item in inner {
                    if let ExprInner::Atom(Atom::Ident(n)) = &item.inner {
                        if is_uppercase_ident(n) && n.len() <= 3 {
                            return true;
                        }
                    }
                }
            }

            ExprInner::Apply(fname, ref aargs) => {
                // Check variant name and args.
                if fname.chars().next().map(|c| c.is_ascii_uppercase()).unwrap_or(false) && !fname.starts_with("make-") {
                    return true;
                }
                for item in aargs {
                    if let ExprInner::Atom(Atom::Ident(n)) = &item.inner {
                        if is_uppercase_ident(n) && n.len() <= 3 {
                            return true;
                        }
                    }
                }
            }

            _ => {}
        }
    }
    false
}
