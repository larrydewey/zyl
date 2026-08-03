use indexmap::IndexMap;
use std::collections::HashMap;

use crate::ast::*;
use crate::error::{Span, ZylError};
use crate::type_inference::{is_generic_param, TypeInferer};
use crate::type_system::*;

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
    #[allow(dead_code)]
    mono_cache: HashMap<String, MonoInstance>,

    /// All known nominal types (for ADT monomorphization).
    known_types: IndexMap<String, Type>,

    /// Struct definitions for field-level monomorphization.
    #[allow(dead_code)]
    struct_defs: IndexMap<String, Vec<(String, Option<Type>)>>,

    /// ADT definitions (variant names + field type names).
    adt_defs: IndexMap<String, Vec<(String, Vec<String>)>>,

    /// ADT instantiation info from type inference.
    adt_instantiations: IndexMap<String, Vec<String>>,

    /// Span used for generated expressions.
    span: Span,
}

impl MonoContext {
    pub fn new(inferer: &TypeInferer) -> Self {
        let ctx = Self {
            generic_functions: IndexMap::new(),
            known_functions: inferer.get_known_functions().clone(),
            function_returns: inferer.get_function_returns().clone(),
            trait_ctx: inferer.get_trait_context().clone(),
            mono_cache: HashMap::new(),
            known_types: inferer.get_known_types().clone(),
            struct_defs: inferer.get_struct_defs().clone(),
            adt_defs: inferer.get_adt_defs().clone(),
            adt_instantiations: inferer.get_adt_instantiations().clone(),
            span: Span::default(),
        };

        // Discover generic functions from AST (done externally via discover_generics).
        ctx
    }

    /// Register a generic function definition.
    #[allow(dead_code)]
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
                    let all_params: Vec<Expr> = match &args[1].inner {
                        ExprInner::Call(ref op_expr, ref pexprs) => {
                            let mut ps: Vec<Expr> = vec![*op_expr.clone()]; // First param = operator itself
                            for p in pexprs {
                                ps.push(p.clone());
                            }
                            ps
                        }
                        ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                        _ => continue,
                    };

                    let params: Vec<Param> =
                        all_params.iter().map(parse_single_param).collect();
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
                    let all_params: Vec<Expr> = match &args[1].inner {
                        ExprInner::Call(ref op_expr, ref pexprs) => {
                            let mut ps: Vec<Expr> = vec![*op_expr.clone()]; // First param = operator itself
                            for p in pexprs {
                                ps.push(p.clone());
                            }
                            ps
                        }
                        ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                        _ => continue,
                    };

                    let params: Vec<Param> =
                        all_params.iter().map(parse_single_param).collect();
                    let generics = Self::extract_generics(&params);
                    if !generics.is_empty() {
                        self.generic_functions.insert(n, generics);
                    }
                }

                // Deftype with generic variants.
                ExprInner::Deftype(name, variants, _, _) => {
                    let has_generic = variants
                        .iter()
                        .any(|v| v.fields.iter().any(is_uppercase_ident));
                    if has_generic {
                        self.known_types.insert(name.clone(), Type::Var(0)); // Mark as generic ADT.
                    } else {
                        self.known_types
                            .entry(name.clone())
                            .or_insert(Type::Nominal(name.clone()));
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
                                self.known_types
                                    .entry(name.clone())
                                    .or_insert_with(|| Type::Nominal(name.clone()));
                            }
                        }
                    }
                }

                // StructDef with generic fields.
                ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                    let has_generic = sd
                        .fields
                        .iter()
                        .any(|(_, t)| matches!(t, Some(s) if is_uppercase_ident(s)));
                    if has_generic {
                        self.known_types
                            .entry(sd.name.clone())
                            .or_insert(Type::Var(0));
                    } else {
                        self.known_types
                            .entry(sd.name.clone())
                            .or_insert_with(|| Type::Nominal(sd.name.clone()));
                    }
                }

                ExprInner::Call(op, args) if is_ident_op(op, "defstruct") && args.len() >= 2 => {
                    let sname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                        _ => None,
                    };

                    if let Some(ref name) = sname {
                        self.known_types
                            .entry(name.clone())
                            .or_insert_with(|| Type::Nominal(name.clone()));
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
                        for mono in
                            self.generate_instantiations(name, generics, params.clone(), body)?
                        {
                            result.push(Expr {
                                span: self.span.clone(),
                                inner: ExprInner::Defn(
                                    mono.canonical_name,
                                    mono.params.clone(),
                                    mono.body,
                                ),
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
                            let all_params: Vec<Expr> = match &args[1].inner {
                                ExprInner::Call(ref op_expr, ref pexprs) => {
                                    let mut ps: Vec<Expr> = vec![*op_expr.clone()];
                                    for p in pexprs {
                                        ps.push(p.clone());
                                    }
                                    ps
                                }
                                ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                                _ => Vec::new(),
                            };
                            let params: Vec<Param> =
                                all_params.iter().map(parse_single_param).collect();

                            for mono in
                                self.generate_instantiations(name, generics, params, &args[2])?
                            {
                                result.push(Expr {
                                    span: self.span.clone(),
                                    inner: ExprInner::Defn(
                                        mono.canonical_name,
                                        mono.params.clone(),
                                        mono.body,
                                    ),
                                });
                            }

                            // Keep original as reference.
                            if !result.is_empty()
                                && matches!(result.last().unwrap().inner, ExprInner::Defn(_, _, _))
                            {
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
                            let all_params: Vec<Expr> = match &args[1].inner {
                                ExprInner::Call(ref op_expr, ref pexprs) => {
                                    let mut ps: Vec<Expr> = vec![*op_expr.clone()];
                                    for p in pexprs {
                                        ps.push(p.clone());
                                    }
                                    ps
                                }
                                ExprInner::Apply(_, ref pexprs) => pexprs.clone(),
                                _ => Vec::new(),
                            };
                            let params: Vec<Param> =
                                all_params.iter().map(parse_single_param).collect();

                            for mono in
                                self.generate_instantiations(name, generics, params, &args[2])?
                            {
                                result.push(Expr {
                                    span: self.span.clone(),
                                    inner: ExprInner::Defn(
                                        mono.canonical_name,
                                        mono.params.clone(),
                                        mono.body,
                                    ),
                                });
                            }

                            if !result.is_empty()
                                && matches!(result.last().unwrap().inner, ExprInner::Defn(_, _, _))
                            {
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

                ExprInner::Deftype(name, variants, _, bound) => {
                    let has_generic = variants
                        .iter()
                        .any(|v| v.fields.iter().any(is_uppercase_ident));
                    if has_generic
                        && self
                            .known_types
                            .get(name)
                            .is_some_and(|t| matches!(t, Type::Var(_)))
                    {
                        let instantiations = self.collect_adt_instantiations(name, variants);
                        for (concrete_name, mono_variants) in instantiations {
                            result.push(Expr {
                                    span: self.span.clone(),
                                    inner: ExprInner::Deftype(
                                        concrete_name,
                                        mono_variants,
                                        Vec::new(),
                                        bound.clone(),
                                    ),
                                });
                        }

                        if !result.is_empty()
                            && matches!(result.last().unwrap().inner, ExprInner::Deftype(..))
                        {
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
                        if self
                            .known_types
                            .get(name)
                            .is_some_and(|t| matches!(t, Type::Var(_)))
                            && args.len() > 1
                        {
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
                    } else if is_builtin_op(fname)
                        || matches!(
                            fname.as_str(),
                            "+" | "-"
                                | "*"
                                | "/"
                                | "=="
                                | "!="
                                | "<"
                                | ">"
                                | "<="
                                | ">="
                                | "not"
                                | "and"
                                | "or"
                        )
                    {
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
                        if self.generic_functions.contains_key(name.as_str())
                            && !is_builtin_op(name)
                        {
                            let generics = &self.generic_functions[name];
                            match self.resolve_call_site(name, generics, args)? {
                                Some(canonical_name) => {
                                    let op = Box::new(Expr {
                                        span: expr.span.clone(),
                                        inner: ExprInner::Atom(Atom::Ident(canonical_name)),
                                    });
                                    result.push(Expr {
                                        span: expr.span.clone(),
                                        inner: ExprInner::Call(op, args.to_vec()),
                                    });
                                }
                                None => {
                                    result.push(expr.clone());
                                }
                            }
                        } else {
                            result.push(self.substitute_in_expr(expr));
                        }
                    } else {
                        result.push(self.substitute_in_expr(expr));
                    }
                }

                // Trait impl bodies become concrete top-level functions
                // (Trait.method_Type) so they compile to native code. The receiver-type
                // dispatch (Trait.method -> Trait.method_Type) is done in substitution.
                ExprInner::ImplBlock(trait_name, type_name, bodies) => {
                    for body in bodies {
                        let concrete_name =
                            format!("{}.{}_{}", trait_name, body.defn.name, type_name);
                        // Type the receiver (self) param as the impl type so struct-get
                        // resolution and ICNF param binding know its layout.
                        let mut params = body.defn.params.clone();
                        if let Some(first) = params.first_mut() {
                            first.typ = Some(type_name.clone());
                        }
                        let defn = Expr {
                            span: expr.span.clone(),
                            inner: ExprInner::Defn(
                                concrete_name,
                                params,
                                body.defn.body.clone(),
                            ),
                        };
                        result.push(self.substitute_in_expr(&defn));
                    }
                    // Keep the ImplBlock as a declaration reference (ICNF skips it).
                    result.push(expr.clone());
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
        let unique_names: Vec<String> = type_names
            .iter()
            .filter(|n| seen.insert(n.as_str()))
            .cloned()
            .collect();

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

            for param_info in known.iter() {
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

                        let (_, _expected_arg_type) = &known[j];
                        // We need to find actual argument types — but we don't have call site info here.
                        // Instead, derive from the known_types and function_returns.
                    }
                }

                Type::Nominal(trait_name) => {
                    // Bounded generic — check what concrete types satisfy this bound.
                    let satisfying_types = self.find_satisfying_types(trait_name);
                    for ty in satisfying_types {
                        let mut inst: IndexMap<String, Type> = instantiation_sets
                            .iter()
                            .find(|&m| m.contains_key(param_name))
                            .cloned()
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
                .filter(|_n| {
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
                let substituted_params: Vec<Param> = params
                    .iter()
                    .map(|p| {
                        if is_uppercase_ident(&p.name) && type_map.contains_key(&p.name) {
                            Param {
                                span: p.span.clone(),
                                name: p.name.clone(),
                                typ: Some(format!("{}", type_map[&p.name])),
                            }
                        } else {
                            p.clone()
                        }
                    })
                    .collect();

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
                if !result
                    .iter()
                    .any(|t| matches!(t, Type::Prim(PrimType::Int)))
                {
                    result.push(Type::Prim(PrimType::Int));
                }
                if !result
                    .iter()
                    .any(|t| matches!(t, Type::Prim(PrimType::Float)))
                {
                    result.push(Type::Prim(PrimType::Float));
                }
                if !result
                    .iter()
                    .any(|t| matches!(t, Type::Prim(PrimType::Bool)))
                {
                    result.push(Type::Prim(PrimType::Bool));
                }
            }
            "Clone" | "Hash" if !result.iter().any(|t| matches!(t, Type::Prim(_))) => {
                for prim in [PrimType::Int, PrimType::Float, PrimType::Bool] {
                    result.push(Type::Prim(prim));
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
        if let Type::Prim(_) = ty {
            if matches!(trait_name, "Eq" | "Ord" | "Debug") {
                return Ok(true);
            }
        }

        // Check registered impls.
        for impl_info in &self.trait_ctx.impls {
            if impl_info.trait_name == trait_name
                && format!("{}", impl_info.impl_type) == format!("{}", ty)
            {
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
            ExprInner::Atom(Atom::Keyword(kw)) if kw.as_str() == "___skip_" => Type::Prim(PrimType::Unit),

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
                } else if fname == "vec"
                    || is_ident_op(
                        &Expr {
                            span: Span::default(),
                            inner: ExprInner::Atom(Atom::Ident("vec".to_string())),
                        },
                        "vec",
                    )
                {
                    // vec constructor — infer element type from first arg.
                    args.first()
                        .map(|a| self.infer_arg_type(a))
                        .unwrap_or(Type::Var(0))
                } else if let Some(params) = self.known_functions.get(fname).cloned() {
                    // Try to match against known function params.
                    for (i, (_, _expected_ty)) in params.iter().enumerate() {
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
                    args.first()
                        .map(|a| self.infer_arg_type(a))
                        .unwrap_or(Type::Prim(PrimType::Int))
                } else if matches!(op_name.as_str(), "==" | "!=" | "<" | ">" | "<=" | ">=") {
                    Type::Prim(PrimType::Bool)
                } else if let Some(ret_ty) = self.function_returns.get(&op_name).cloned() {
                    ret_ty
                } else {
                    args.first()
                        .map(|a| self.infer_arg_type(a))
                        .unwrap_or(Type::Var(0))
                }
            }

            ExprInner::If(_, then_, else_) => {
                let tt = self.infer_arg_type(then_);
                if is_skip_placeholder(else_.as_ref()) {
                    tt
                } else {
                    let et = self.infer_arg_type(else_);
                    if format!("{}", tt) == format!("{}", et) {
                        tt
                    } else {
                        Type::Var(0) // Ambiguous.
                    }
                }
            }

            ExprInner::Let(_, val, _) => self.infer_arg_type(val),
            ExprInner::Begin(exprs) => exprs
                .last()
                .map(|e| self.infer_arg_type(e))
                .unwrap_or(Type::Prim(PrimType::Unit)),
            ExprInner::MakeStruct(name, _) => Type::Nominal(name.clone()),
            ExprInner::MakeVariant(adt_name, _, _) => Type::Nominal(adt_name.clone()),
            _ => Type::Var(0), // Unknown.
        }
    }

    /// Resolve the concrete type of a trait-method receiver expression.
    /// Variables are resolved from the threaded var→type environment; other
    /// expressions fall back to `infer_arg_type`.
    fn receiver_type(&self, expr: &Expr, var_types: &std::collections::HashMap<String, Type>) -> Option<Type> {
        match &expr.inner {
            ExprInner::Atom(Atom::Ident(name)) => var_types.get(name).cloned(),
            _ => {
                let t = self.infer_arg_type(expr);
                match &t {
                    Type::Var(_) => None,
                    _ => Some(t),
                }
            }
        }
    }

    /// Receiver-type dispatch: given a trait method and the receiver's type,
    /// return the concrete impl function name (Trait.method_Type) if an impl
    /// exists for that (trait, type) pair.
    fn resolve_trait_method(
        &self,
        trait_name: &str,
        method_name: &str,
        recv_ty: Option<Type>,
    ) -> Option<String> {
        let ty = recv_ty?;
        let type_name = match &ty {
            Type::Nominal(n) => n.clone(),
            _ => return None,
        };
        let has_impl = self
            .trait_ctx
            .impls
            .iter()
            .any(|i| i.trait_name == trait_name && format!("{}", i.impl_type) == type_name);
        if has_impl {
            Some(format!("{}.{}_{}", trait_name, method_name, type_name))
        } else {
            None
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
            (Type::Prim(PrimType::Int), Type::Prim(PrimType::Float))
            | (Type::Prim(PrimType::Float), Type::Prim(PrimType::Int)) => Ok(()),

            _ => Err(ZylError::E_TYPE_MISMATCH(
                self.span.clone(),
                format!("{}", t1),
                format!("{}", t2),
            )),
        }
    }

    /// Substitute type variables in an expression with concrete types.
    fn substitute_types(&self, expr: &Expr, type_map: &IndexMap<String, Type>) -> Expr {
        self.subst_expr(expr, type_map)
    }

    fn subst_expr(&self, expr: &Expr, type_map: &IndexMap<String, Type>) -> Expr {
        self.subst_expr_with_var_map(expr, type_map, &std::collections::HashMap::new(), &std::collections::HashMap::new())
    }

    fn subst_expr_with_var_map(
        &self,
        expr: &Expr,
        type_map: &IndexMap<String, Type>,
        var_renames: &std::collections::HashMap<String, String>,
        var_types: &std::collections::HashMap<String, Type>,
    ) -> Expr {
        let new_inner = match &expr.inner {
            ExprInner::Defn(name, params, body) => {
                // Substitute in parameters and body. Bind typed params to var_types so
                // trait-method receiver dispatch can resolve them.
                let mut child_types = var_types.clone();
                for p in params {
                    if let Some(ref t) = p.typ {
                        let ty = param_type_from_str(t);
                        child_types.insert(p.name.clone(), ty);
                    }
                }
                let new_params: Vec<Param> = params
                    .iter()
                    .map(|p| {
                        if is_uppercase_ident(&p.name) && type_map.contains_key(&p.name) {
                            Param {
                                span: p.span.clone(),
                                name: p.name.clone(),
                                typ: Some(format!("{}", type_map[&p.name])),
                            }
                        } else {
                            p.clone()
                        }
                    })
                    .collect();

                ExprInner::Defn(
                    name.clone(),
                    new_params,
                    Box::new(self.subst_expr_with_var_map(body, type_map, var_renames, &child_types)),
                )
            }

            ExprInner::Call(op, args) => {
                // Trait method call with receiver-type dispatch:
                // (Trait.method receiver rest...) -> (Trait.method_Type receiver rest...)
                let op_name = match &op.inner {
                    ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()),
                    _ => None,
                };
                if let Some(ref n) = op_name {
                    if let Some((trait_name, method_name)) = n.split_once('.') {
                        if !args.is_empty() {
                            let recv_ty = self.receiver_type(&args[0], var_types);
                            if let Some(concrete) = self.resolve_trait_method(trait_name, method_name, recv_ty) {
                                let new_op = Box::new(Expr {
                                    span: expr.span.clone(),
                                    inner: ExprInner::Atom(Atom::Ident(concrete)),
                                });
                                let new_args: Vec<Expr> =
                                    args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                                ExprInner::Call(new_op, new_args)
                            } else {
                                let new_op = self.subst_expr_with_var_map(op, type_map, var_renames, var_types);
                                let new_args: Vec<Expr> =
                                    args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                                ExprInner::Call(Box::new(new_op), new_args)
                            }
                        } else {
                            let new_op = self.subst_expr_with_var_map(op, type_map, var_renames, var_types);
                            let new_args: Vec<Expr> =
                                args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                            ExprInner::Call(Box::new(new_op), new_args)
                        }
                    } else {
                        let new_op = self.subst_expr_with_var_map(op, type_map, var_renames, var_types);
                        let new_args: Vec<Expr> =
                            args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                        ExprInner::Call(Box::new(new_op), new_args)
                    }
                } else {
                    let new_op = self.subst_expr_with_var_map(op, type_map, var_renames, var_types);
                    let new_args: Vec<Expr> =
                        args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                    ExprInner::Call(Box::new(new_op), new_args)
                }
            }

            ExprInner::Apply(fname, args) => {
                // Same receiver-type dispatch for Apply-form trait method calls.
                if let Some((trait_name, method_name)) = fname.split_once('.') {
                    if !args.is_empty() {
                        let recv_ty = self.receiver_type(&args[0], var_types);
                        if let Some(concrete) = self.resolve_trait_method(trait_name, method_name, recv_ty) {
                            let new_args: Vec<Expr> =
                                args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                            ExprInner::Apply(concrete, new_args)
                        } else {
                            let new_args: Vec<Expr> =
                                args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                            ExprInner::Apply(fname.clone(), new_args)
                        }
                    } else {
                        let new_args: Vec<Expr> =
                            args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                        ExprInner::Apply(fname.clone(), new_args)
                    }
                } else {
                    let new_args: Vec<Expr> =
                        args.iter().map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types)).collect();
                    ExprInner::Apply(fname.clone(), new_args)
                }
            }

            ExprInner::Let(name, val, body) => {
                let mut child_renames = var_renames.clone();
                child_renames.insert(name.clone(), name.clone());
                let mut child_types = var_types.clone();
                child_types.insert(name.clone(), self.infer_arg_type(val));
                let renamed_val = Box::new(self.subst_expr_with_var_map(val, type_map, &child_renames, var_types));
                let renamed_body = Box::new(self.subst_expr_with_var_map(body, type_map, &child_renames, &child_types));
                ExprInner::Let(name.clone(), renamed_val, renamed_body)
            }

            ExprInner::If(cond, then_, else_) => ExprInner::If(
                Box::new(self.subst_expr_with_var_map(cond, type_map, var_renames, var_types)),
                Box::new(self.subst_expr_with_var_map(then_, type_map, var_renames, var_types)),
                Box::new(self.subst_expr_with_var_map(else_, type_map, var_renames, var_types)),
            ),

            ExprInner::Lambda(name, params, body) => {
                // Create a shadowed scope for lambda params.
                let mut child_renames = var_renames.clone();
                let mut child_types = var_types.clone();
                for p in params {
                    // Lambda params shadow outer variables.
                    child_renames.remove(&p.name);
                    if let Some(ref t) = p.typ {
                        child_types.insert(p.name.clone(), param_type_from_str(t));
                    }
                }
                let new_params: Vec<Param> = params.to_vec();
                ExprInner::Lambda(
                    name.clone(),
                    new_params,
                    Box::new(self.subst_expr_with_var_map(body, type_map, &child_renames, &child_types)),
                )
            }

            ExprInner::Fn(name, params, body) => {
                // Same as Lambda - create shadowed scope.
                let mut child_renames = var_renames.clone();
                let mut child_types = var_types.clone();
                for p in params {
                    child_renames.remove(&p.name);
                    if let Some(ref t) = p.typ {
                        child_types.insert(p.name.clone(), param_type_from_str(t));
                    }
                }
                let new_params: Vec<Param> = params.to_vec();
                ExprInner::Fn(
                    name.clone(),
                    new_params,
                    Box::new(self.subst_expr_with_var_map(body, type_map, &child_renames, &child_types)),
                )
            }

            ExprInner::Begin(exprs) => {
                ExprInner::Begin(exprs.iter().map(|e| self.subst_expr_with_var_map(e, type_map, var_renames, var_types)).collect())
            }

            ExprInner::While(cond, body) => ExprInner::While(
                Box::new(self.subst_expr_with_var_map(cond, type_map, var_renames, var_types)),
                Box::new(self.subst_expr_with_var_map(body, type_map, var_renames, var_types)),
            ),

            ExprInner::For(bindings, cond, body) => {
                let mut child_renames = var_renames.clone();
                let mut child_types = var_types.clone();
                let new_bindings: Vec<(String, Option<Box<Expr>>)> = bindings
                    .iter()
                    .map(|(name, val)| {
                        child_renames.insert(name.clone(), name.clone());
                        if let Some(ref v) = val {
                            child_types.insert(name.clone(), self.infer_arg_type(v));
                        }
                        let new_val = val.as_ref().map(|v| Box::new(self.subst_expr_with_var_map(v, type_map, var_renames, var_types)));
                        (name.clone(), new_val)
                    })
                    .collect();
                ExprInner::For(new_bindings, Box::new(self.subst_expr_with_var_map(cond, type_map, var_renames, var_types)), Box::new(self.subst_expr_with_var_map(body, type_map, &child_renames, &child_types)))
            },

            ExprInner::Cond(clauses) => {
                let new_clauses: Vec<(Box<Expr>, Box<Expr>)> = clauses
                    .iter()
                    .map(|(c, b)| {
                        (
                            Box::new(self.subst_expr_with_var_map(c, type_map, var_renames, var_types)),
                            Box::new(self.subst_expr_with_var_map(b, type_map, var_renames, var_types)),
                        )
                    })
                    .collect();
                ExprInner::Cond(new_clauses)
            }

            ExprInner::Match(subject, arms) => {
                let new_subject = self.subst_expr_with_var_map(subject, type_map, var_renames, var_types);
                let new_arms: Vec<MatchArm> = arms
                    .iter()
                    .map(|arm| MatchArm {
                        variant: arm.variant.clone(),
                        patterns: arm
                            .patterns
                            .iter()
                            .map(|p| self.subst_expr_with_var_map(p, type_map, var_renames, var_types))
                            .collect(),
                        body: Box::new(self.subst_expr_with_var_map(&arm.body, type_map, var_renames, var_types)),
                    })
                    .collect();
                ExprInner::Match(Box::new(new_subject), new_arms)
            }

            // For atoms and other simple nodes, substitute in any nested expressions.
            // Handle variable renaming for captured variables.
            ExprInner::Atom(atom) => {
                let new_atom = if let crate::ast::Atom::Ident(name) = atom {
                    if let Some(new_name) = var_renames.get(name.as_str()) {
                        crate::ast::Atom::Ident(new_name.clone())
                    } else {
                        atom.clone()
                    }
                } else {
                    atom.clone()
                };
                crate::ast::ExprInner::Atom(new_atom)
            }
            ExprInner::MakeVariant(adt_name, variant_name, args) => {
                if let Some(concrete_adt) = self.resolve_make_variant_adt(adt_name, variant_name, args) {
                    let new_args: Vec<Expr> = args
                        .iter()
                        .map(|a| self.subst_expr_with_var_map(a, type_map, var_renames, var_types))
                        .collect();
                    ExprInner::MakeVariant(concrete_adt, variant_name.clone(), new_args)
                } else {
                    expr.inner.clone()
                }
            }
            _ => expr.inner.clone(),
        };

        Expr {
            span: expr.span.clone(),
            inner: new_inner,
        }
    }

    /// Substitute type variables throughout an expression (for non-generic functions).
    fn substitute_in_expr(&self, expr: &Expr) -> Expr {
        self.subst_expr(expr, &IndexMap::new())
    }

    /// Substitute in ADT expressions.
    fn substitute_in_adt(&self, expr: &Expr) -> Expr {
        match &expr.inner {
            ExprInner::Deftype(name, variants, _, bound) => {
                let new_variants = variants
                    .iter()
                    .map(|v| ADTVariant {
                        name: v.name.clone(),
                        fields: v
                            .fields
                            .iter()
                            .filter(|f| !is_uppercase_ident(f))
                            .cloned()
                            .collect(),
                    })
                    .collect();

                Expr {
                    span: expr.span.clone(),
                    inner: ExprInner::Deftype(
                        name.clone(),
                        new_variants,
                        Vec::new(),
                        bound.clone(),
                    ),
                }
            }

            _ => self.substitute_in_expr(expr),
        }
    }

    /// Resolve a MakeVariant to its concrete ADT instantiation name.
    fn resolve_make_variant_adt(
        &self,
        adt_name: &str,
        variant_name: &str,
        args: &[Expr],
    ) -> Option<String> {
        if !self.known_types.contains_key(adt_name) {
            return None;
        }
        let variant_field_types: Vec<(String, Vec<String>)> = self
            .adt_defs
            .get(adt_name)
            .cloned()
            .unwrap_or_default();
        let concrete_types: Vec<String> = self
            .adt_instantiations
            .get(adt_name)
            .cloned()
            .unwrap_or_default();
        let mut seen_types = std::collections::HashSet::new();
        let unique_types: Vec<String> = concrete_types
            .into_iter()
            .filter(|t| seen_types.insert(t.clone()))
            .collect();
        let variant_info = variant_field_types
            .iter()
            .find(|(vname, _)| vname == variant_name)
            .map(|(_, fields)| fields.clone());
        for concrete_ty in &unique_types {
            if let Some(ref fields) = variant_info {
                let is_match = args.iter().zip(fields.iter()).all(|(arg, field_type)| {
                    is_generic_param(field_type) && arg_type_matches(&arg.inner, concrete_ty)
                });
                if is_match {
                    return Some(format!("{}_{}", adt_name, concrete_ty));
                }
            }
        }
        if !unique_types.is_empty() {
            return Some(format!("{}_{}", adt_name, unique_types[0]));
        }
        None
    }

    /// Collect ADT instantiations for a generic type.
    fn collect_adt_instantiations(
        &self,
        name: &str,
        variants: &[ADTVariant],
    ) -> Vec<(String, Vec<ADTVariant>)> {
        let mut instantiations: IndexMap<String, Vec<ADTVariant>> = IndexMap::new();

        // Get the variant field types from ADT definition.
        let variant_field_types: Vec<(String, Vec<String>)> = self
            .adt_defs
            .get(name)
            .cloned()
            .unwrap_or_default();

        // Get concrete type instantiations from type inference.
        let concrete_types: Vec<String> = self
            .adt_instantiations
            .get(name)
            .cloned()
            .unwrap_or_default();

        // Deduplicate concrete types (preserve order).
        let mut seen_types = std::collections::HashSet::new();
        let unique_types: Vec<String> = concrete_types
            .into_iter()
            .filter(|t| seen_types.insert(t.clone()))
            .collect();

        // If we have concrete instantiations, create one per type.
        if !unique_types.is_empty() {
            for concrete_ty in &unique_types {
                let inst_name = format!("{}_{}", name, concrete_ty);
                let mono_variants: Vec<ADTVariant> = variants
                    .iter()
                    .map(|v| {
                        // Find the matching variant in variant_field_types.
                        let fields: Vec<String> = variant_field_types
                            .iter()
                            .find(|(vname, _)| vname == &v.name)
                            .map(|(_, fields)| {
                                fields
                                    .iter()
                                    .map(|f| {
                                        if is_generic_param(f) {
                                            concrete_ty.clone()
                                        } else {
                                            f.clone()
                                        }
                                    })
                                    .collect()
                            })
                            .unwrap_or_default();

                        ADTVariant {
                            name: v.name.clone(),
                            fields,
                        }
                    })
                    .collect();

                instantiations.insert(inst_name, mono_variants);
            }
        }

        // If no instantiations found, generate one with Int as default.
        if instantiations.is_empty() {
            let inst_name = format!("{}_Int", name);
            let mono_variants: Vec<ADTVariant> = variants
                .iter()
                .map(|v| {
                    let fields: Vec<String> = variant_field_types
                        .iter()
                        .find(|(vname, _)| vname == &v.name)
                        .map(|(_, fields)| {
                            fields
                                .iter()
                                .map(|f| {
                                    if is_generic_param(f) {
                                        "Int".to_string()
                                    } else {
                                        f.clone()
                                    }
                                })
                                .collect()
                        })
                        .unwrap_or_default();

                    ADTVariant {
                        name: v.name.clone(),
                        fields,
                    }
                })
                .collect();

            instantiations.insert(inst_name, mono_variants);
        }

        instantiations.into_iter().collect()
    }
}

// ── Helpers ────────────────────────────────────────────────────────────────

fn is_uppercase_ident<T: AsRef<str>>(s: T) -> bool {
    let s = s.as_ref();
    !s.is_empty()
        && s.chars()
            .next()
            .map(|c| c.is_ascii_uppercase())
            .unwrap_or(false)
        && !matches!(s, "TCap" | "TMut" | "TBox" | "TPin" | "TAtomic" | "TFun")
}

fn arg_type_matches(inner: &ExprInner, concrete_ty: &str) -> bool {
    match (inner, concrete_ty) {
        (ExprInner::Atom(Atom::Int(_)), "Int") => true,
        (ExprInner::Atom(Atom::Float(_)), "Float") => true,
        (ExprInner::Atom(Atom::Bool(_)), "Bool") => true,
        (ExprInner::Atom(Atom::Str(_)), "String") => true,
        (_, _) => false,
    }
}

/// Parse a concrete type name into a `Type` for trait dispatch.
fn param_type_from_str(t: &str) -> Type {
    match t {
        "Int" => Type::Prim(PrimType::Int),
        "Float" => Type::Prim(PrimType::Float),
        "Bool" => Type::Prim(PrimType::Bool),
        "String" => Type::Prim(PrimType::String),
        "Unit" => Type::Prim(PrimType::Unit),
        other => Type::Nominal(other.to_string()),
    }
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
                ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                    Some(t.clone())
                }
                _ => None,
            };
            return Param {
                span: crate::error::Span::default(),
                name: nm,
                typ: tp,
            };
        }

        // Multi-element Call — extract first element as param.
        if !inner.is_empty() {
            let nm = match &inner[0].inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            let typ = if inner.len() > 1 {
                match &inner[1].inner {
                    ExprInner::Atom(Atom::Ident(s)) | ExprInner::Atom(Atom::Keyword(s)) => {
                        Some(s.clone())
                    }
                    _ => None,
                }
            } else {
                None
            };
            return Param {
                span: crate::error::Span::default(),
                name: nm,
                typ,
            };
        }
    }

    // Handle Apply form — treat as single identifier param.
    if let ExprInner::Apply(ref name, _) = expr.inner {
        if !name.starts_with("make-")
            && name
                .chars()
                .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!'))
        {
            return Param {
                span: crate::error::Span::default(),
                name: name.clone(),
                typ: None,
            };
        }
    }

    // Fallback — extract identifier from atom.
    let name = match &expr.inner {
        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
        _ => "___".to_string(),
    };
    Param {
        span: crate::error::Span::default(),
        name,
        typ: None,
    }
}

fn is_builtin_op(name: &str) -> bool {
    matches!(
        name,
        "+" | "-"
            | "*"
            | "/"
            | "%"
            | "=="
            | "!="
            | "<"
            | ">"
            | "<="
            | ">="
            | "not"
            | "and"
            | "or"
            | "if"
            | "let"
            | "let-mut"
            | "while"
            | "for"
            | "cond"
            | "try"
            | "match"
            | "defn"
            | "defun"
            | "def"
            | "deftype"
            | "trait"
            | "impl"
            | "defstruct"
            | "defstruct+"
            | "alias"
            | "derive"
            | "fn"
            | "lambda"
            | "begin"
            | "set!"
            | "export"
            | "use"
            | "test-suite"
            | "setup"
            | "teardown"
            | "run-tests"
            | "print"
            | "read-line"
            | "exit"
            | "close"
            | "file-open"
            | "file-read"
            | "file-write"
            | "file-close"
            | "assert-equal"
            | "assert-fail"
            | "assert-true"
            | "assert-false"
            | "spawn"
            | "send"
            | "send-closure"
            | "ffi-call"
            | "ffi-pin"
            | "ffi-unpin"
            | "with-resource"
            | "struct-get"
            | "make-struct"
            | "is-some"
            | "is-none"
            | "is-ok"
            | "is-err"
            | "str"
            | "int"
            | "float"
            | "vec"
            | "map"
    )
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
                if fname
                    .chars()
                    .next()
                    .map(|c| c.is_ascii_uppercase())
                    .unwrap_or(false)
                    && !fname.starts_with("make-")
                {
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

/// Check if an expression is a `___skip_` keyword placeholder (intentionally omitted branch).
fn is_skip_placeholder(expr: &Expr) -> bool {
    matches!(&expr.inner, ExprInner::Atom(Atom::Keyword(kw)) if kw == "___skip_")
}
