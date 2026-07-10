use indexmap::IndexMap;
use std::cell::{Cell, RefCell};

use crate::ast::*;
use crate::error::{Span, ZylError};
use crate::type_system::*;

pub struct TypeInferer {
    env: TypeEnv,
    trait_ctx: TraitContext,
    known_types: IndexMap<String, Type>,
    known_functions: IndexMap<String, Vec<(String, Type)>>,
    function_returns: IndexMap<String, Type>,
    struct_defs: IndexMap<String, Vec<(String, Option<Type>)>>,
    generics_in_scope: RefCell<std::collections::HashSet<String>>,
    var_gen_counter: Cell<usize>,
    subst: Subst,
}

impl TypeInferer {
    pub fn new() -> Self {
        let mut known = IndexMap::new();
        known.insert("Int".to_string(), Type::Prim(PrimType::Int));
        known.insert("Float".to_string(), Type::Prim(PrimType::Float));
        known.insert("Bool".to_string(), Type::Prim(PrimType::Bool));
        known.insert("String".to_string(), Type::Prim(PrimType::String));
        known.insert("Unit".to_string(), Type::Prim(PrimType::Unit));

        Self {
            env: TypeEnv::new(),
            trait_ctx: TraitContext::new(),
            known_types: known,
            known_functions: IndexMap::new(),
            function_returns: IndexMap::new(),
            struct_defs: IndexMap::new(),
            generics_in_scope: RefCell::new(std::collections::HashSet::new()),
            var_gen_counter: Cell::new(0),
            subst: Subst::new(),
        }
    }

    fn fresh_var(&self) -> usize {
        let n = self.var_gen_counter.get();
        self.var_gen_counter.set(n + 1);
        n
    }

    pub fn infer(&mut self, exprs: &[Expr]) -> std::result::Result<Vec<Expr>, ZylError> {
        let mut result = Vec::with_capacity(exprs.len());
        // collect_definitions is called by monomorphization before this.

        for expr in exprs {
            let ty = self.infer_expr(&expr)?;
            result.push(Expr {
                span: expr.span.clone(),
                inner: ExprInner::Atom(match &ty {
                    Type::Prim(p) => match p {
                        PrimType::Int => Atom::Ident("T_INT".into()),
                        PrimType::Float => Atom::Ident("T_FLOAT".into()),
                        PrimType::Bool => Atom::Ident("T_BOOL".into()),
                        PrimType::String => Atom::Ident("T_STRING".into()),
                        PrimType::Unit => Atom::Ident("T_UNIT".into()),
                    },
                    Type::Var(n) => Atom::Ident(format!("?{}", n)),
                    _ => Atom::Ident(format!("{}", ty)),
                }),
            });
        }

        if !result.is_empty() {
            Ok(result)
        } else {
            Err(ZylError::E_TYPE_MISMATCH(
                Span::default(),
                "empty".into(),
                "no expressions".into(),
            ))
        }
    }

    /// Collect function definitions from expressions (populates known_functions etc.).
    /// Called by Phase 6 monomorphization to gather type info without destroying AST.
    pub fn collect(&mut self, exprs: &[Expr]) {
        self.collect_definitions(exprs);
    }

    fn collect_definitions(&mut self, exprs: &[Expr]) {
        for expr in exprs {
            match &expr.inner {
                ExprInner::Defn(name, params, body) => {
                    let param_types: Vec<Type> =
                        params.iter().map(|p| self.parse_type_str(&p.typ)).collect();
                    if let Ok(ret_ty) = self.infer_expr(body) {
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name.clone(), ret_ty);
                    } else {
                        let fresh = Type::Var(self.fresh_var());
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name.clone(), fresh);
                    }
                }

                ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let params: Vec<Param> = parse_params_from_expr(&args[1]);
                    // Bind parameters to environment first.
                    for p in &params {
                        drop(self.env.bind(p.name.clone(), Type::Var(self.fresh_var())));
                    }
                    if let Ok(ret_ty) = self.infer_expr(&args[2]) {
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name, ret_ty);
                    } else {
                        let fresh = Type::Var(self.fresh_var());
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name, fresh);
                    }
                }

                ExprInner::Apply(fname, args) if fname == "defn" && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let params: Vec<Param> = parse_params_from_expr(&args[1]);
                    if let Ok(ret_ty) = self.infer_expr(&args[2]) {
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name, ret_ty);
                    } else {
                        let fresh = Type::Var(self.fresh_var());
                        self.known_functions.insert(
                            name.clone(),
                            params
                                .iter()
                                .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                                .collect(),
                        );
                        self.function_returns.insert(name, fresh);
                    }
                }

                ExprInner::Deftype(name, variants, _) => {
                    let has_generic = variants
                        .iter()
                        .any(|v| v.fields.iter().any(|f| is_generic_param(f)));
                    if has_generic {
                        self.known_types
                            .insert(name.clone(), Type::Var(self.fresh_var()));
                    } else {
                        self.known_types
                            .insert(name.clone(), Type::Nominal(name.clone()));
                    }
                }

                ExprInner::TraitDecl(trait_name, methods, _) => {
                    let mut trait_info = TraitInfo {
                        name: trait_name.clone(),
                        methods: IndexMap::new(),
                        return_types: IndexMap::new(),
                    };
                    for method in methods {
                        let param_list: Vec<(String, Type)> = method
                            .params
                            .iter()
                            .map(|p| (p.name.clone(), self.parse_type_str(&p.typ)))
                            .collect();
                        trait_info.methods.insert(method.name.clone(), param_list);
                        let ret_type = self
                            .resolve_type_name(&method.return_type)
                            .unwrap_or_else(|| Type::Var(self.fresh_var()));
                        trait_info
                            .return_types
                            .insert(method.name.clone(), ret_type);
                    }
                    self.trait_ctx.register_trait(trait_info);
                }

                ExprInner::ImplBlock(_trait_name, type_name, bodies) => {
                    let impl_type = self
                        .resolve_type_name(type_name)
                        .unwrap_or_else(|| Type::Nominal(type_name.clone()));
                    if let Err(e) = self.trait_ctx.register_impl(ImplInfo {
                        trait_name: _trait_name.clone(),
                        impl_type: impl_type.clone(),
                        methods: IndexMap::new(),
                    }) {
                        drop(e);
                    }

                    for body in bodies {
                        let mname = &body.defn.name;
                        let full_name = format!("{}.{}", _trait_name, mname);
                        self.known_functions.insert(
                            full_name.clone(),
                            body.defn
                                .params
                                .iter()
                                .map(|p| (p.name.clone(), Type::Var(self.fresh_var())))
                                .collect(),
                        );
                        self.function_returns
                            .insert(full_name, Type::Var(self.fresh_var()));
                    }
                }

                ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                    let typed_fields: Vec<(String, Option<Type>)> = sd
                        .fields
                        .iter()
                        .map(|(name, typ)| {
                            (
                                name.clone(),
                                typ.as_ref().map(|t| {
                                    self.resolve_type_name(t)
                                        .unwrap_or(Type::Var(self.fresh_var()))
                                }),
                            )
                        })
                        .collect();
                    self.struct_defs.insert(sd.name.clone(), typed_fields);

                    let has_generic = sd
                        .fields
                        .iter()
                        .any(|(_, t)| matches!(t, Some(t_str) if is_generic_param(t_str)));
                    if has_generic {
                        self.known_types
                            .insert(sd.name.clone(), Type::Var(self.fresh_var()));
                    } else {
                        self.known_types
                            .insert(sd.name.clone(), Type::Nominal(sd.name.clone()));
                    }
                }

                // Raw Call form for deftype.
                ExprInner::Call(op, args) if is_ident_op(op, "deftype") && args.len() >= 2 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    // For Phase 3 MVP, just register as a nominal type.
                    self.known_types.insert(name.clone(), Type::Nominal(name));
                }

                ExprInner::Apply(name, args) if name == "deftype" && args.len() >= 2 => {
                    let tname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    self.known_types.insert(tname.clone(), Type::Nominal(tname));
                }

                // Raw trait.
                ExprInner::Call(op, args) if is_ident_op(op, "trait") && args.len() >= 2 => {
                    let tname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    self.trait_ctx.register_trait(TraitInfo {
                        name: tname,
                        methods: IndexMap::new(),
                        return_types: IndexMap::new(),
                    });
                }

                // Raw impl.
                ExprInner::Call(op, args) if is_ident_op(op, "impl") && args.len() >= 3 => {
                    let trait_name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let type_name = match &args[1].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    drop(self.trait_ctx.register_impl(ImplInfo {
                        trait_name,
                        impl_type: Type::Nominal(type_name),
                        methods: IndexMap::new(),
                    }));
                }

                // Raw struct.
                ExprInner::Call(op, args) if is_ident_op(op, "defstruct") && args.len() >= 2 => {
                    let sname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    self.struct_defs.insert(sname.clone(), Vec::new());
                    self.known_types.insert(sname.clone(), Type::Nominal(sname));
                }

                // Raw alias.
                ExprInner::Call(op, args) if is_ident_op(op, "alias") && args.len() >= 2 => {
                    let aname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    drop(self.infer_expr(&args[1])); // infer target type.
                }

                ExprInner::AliasDecl(name, target) => {
                    if let Ok(alias_type) = self.infer_expr(target) {
                        self.known_types.insert(name.clone(), alias_type);
                    } else {
                        self.known_types
                            .insert(name.clone(), Type::Var(self.fresh_var()));
                    }
                }

                _ => {}
            }
        }

        // Register built-in trait impls for primitives.
        let prim_types = vec![
            Type::Prim(PrimType::Int),
            Type::Prim(PrimType::Float),
            Type::Prim(PrimType::Bool),
        ];
        for ty in &prim_types {
            for tn in ["Eq", "Ord", "Debug"] {
                let _ = self.trait_ctx.register_impl(ImplInfo {
                    trait_name: tn.to_string(),
                    impl_type: ty.clone(),
                    methods: IndexMap::new(),
                });
            }
        }
    }

    fn infer_expr(&mut self, expr: &Expr) -> std::result::Result<Type, ZylError> {
        match &expr.inner {
            ExprInner::Atom(Atom::Int(_)) => Ok(Type::Prim(PrimType::Int)),
            ExprInner::Atom(Atom::Float(_)) => Ok(Type::Prim(PrimType::Float)),
            ExprInner::Atom(Atom::Bool(_)) => Ok(Type::Prim(PrimType::Bool)),
            ExprInner::Atom(Atom::Str(_)) => Ok(Type::Prim(PrimType::String)),

            ExprInner::Atom(Atom::Ident(name))
                if !self.generics_in_scope.borrow().contains(name) =>
            {
                match name.as_str() {
                    "Unit" => Ok(Type::Prim(PrimType::Unit)),
                    "Int" => Ok(Type::Prim(PrimType::Int)),
                    "Float" => Ok(Type::Prim(PrimType::Float)),
                    "Bool" => Ok(Type::Prim(PrimType::Bool)),
                    "String" => Ok(Type::Prim(PrimType::String)),
                    _ => match self.env.get(name).cloned() {
                        Some(ty) => Ok(ty),
                        None => Err(ZylError::E_UNBOUND_VARIABLE(
                            expr.span.clone(),
                            name.clone(),
                        )),
                    },
                }
            }

            ExprInner::Atom(Atom::Ident(name))
                if self.generics_in_scope.borrow().contains(name) =>
            {
                if let Some(ty) = self.known_types.get(name).cloned() {
                    Ok(ty)
                } else {
                    Ok(Type::Var(self.fresh_var()))
                }
            }

            ExprInner::Def(_, val) => self.infer_expr(val),

            ExprInner::Let(name, val, body) => {
                let vt = self.infer_expr(val)?;
                drop(self.env.bind(name.clone(), vt));
                self.infer_expr(body)
            }

            // Handle raw Call/Apply forms of special forms (from no-dispatch parsing).
            ExprInner::Call(op, args) if is_ident_op(op, "if") && !args.is_empty() => {
                let cond_type = self.infer_expr(&args[0])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                let then_ = if args.len() > 1 {
                    self.infer_expr(&args[1])?
                } else {
                    Type::Var(self.fresh_var())
                };
                let els = if args.len() > 2 {
                    self.infer_expr(&args[2])?
                } else {
                    Type::Var(self.fresh_var())
                };
                self.unify(&then_, &els)?;
                Ok(then_)
            }

            ExprInner::Apply(name, args) if name == "if" && !args.is_empty() => {
                let cond_type = self.infer_expr(&args[0])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                let then_ = if args.len() > 1 {
                    self.infer_expr(&args[1])?
                } else {
                    Type::Var(self.fresh_var())
                };
                let els = if args.len() > 2 {
                    self.infer_expr(&args[2])?
                } else {
                    Type::Var(self.fresh_var())
                };
                self.unify(&then_, &els)?;
                Ok(then_)
            }

            ExprInner::Call(op, args) if is_ident_op(op, "let") && args.len() >= 3 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "identifier".to_string(),
                            "expected ident for let name".into(),
                        ))
                    }
                };
                // This won't work with `continue` in a closure — need different approach.
                self.infer_expr(&Expr {
                    span: expr.span.clone(),
                    inner: ExprInner::Let(
                        name,
                        Box::new(args[1].clone()),
                        Box::new(args[2].clone()),
                    ),
                })
            }

            ExprInner::Apply(name, args) if name == "let" && args.len() >= 3 => {
                let lname = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "identifier".to_string(),
                            "expected ident for let name".into(),
                        ))
                    }
                };
                self.infer_expr(&Expr {
                    span: expr.span.clone(),
                    inner: ExprInner::Let(
                        lname,
                        Box::new(args[1].clone()),
                        Box::new(args[2].clone()),
                    ),
                })
            }

            // Handle raw while.
            ExprInner::Call(op, args) if is_ident_op(op, "while") && args.len() >= 2 => {
                let cond_type = self.infer_expr(&args[0])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Apply(name, args) if name == "while" && args.len() >= 2 => {
                let cond_type = self.infer_expr(&args[0])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            // Handle raw for.
            ExprInner::Call(op, args) if is_ident_op(op, "for") && args.len() >= 5 => {
                let fname = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "identifier".to_string(),
                            "expected ident".into(),
                        ))
                    }
                };
                drop(self.infer_expr(&args[1])?);
                let cond_type = self.infer_expr(&args[2])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(&args[3])?);
                self.env.bind(fname.clone(), Type::Var(self.fresh_var()))?;
                drop(self.infer_expr(&args[4])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Apply(name, args) if name == "for" && args.len() >= 5 => {
                let fname = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "identifier".to_string(),
                            "expected ident".into(),
                        ))
                    }
                };
                drop(self.infer_expr(&args[1])?);
                let cond_type = self.infer_expr(&args[2])?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(&args[3])?);
                self.env.bind(fname.clone(), Type::Var(self.fresh_var()))?;
                drop(self.infer_expr(&args[4])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            // Handle raw cond.
            ExprInner::Call(op, args) if is_ident_op(op, "cond") && !args.is_empty() => {
                let mut rt: Option<Type> = None;
                for a in args {
                    match &a.inner {
                        ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                            if !inner.is_empty() =>
                        {
                            let pt = self.infer_expr(&inner[0])?;
                            self.unify(&pt, &Type::Prim(PrimType::Bool))?;
                            let bt = if inner.len() > 1 {
                                self.infer_expr(&inner[1])?
                            } else {
                                Type::Var(self.fresh_var())
                            };
                            if let Some(ref r) = rt {
                                drop(self.unify(r, &bt));
                            } else {
                                rt = Some(bt);
                            }
                        }
                        _ => {}
                    }
                }
                Ok(rt.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            ExprInner::Apply(name, args) if name == "cond" && !args.is_empty() => {
                let mut rt: Option<Type> = None;
                for a in args {
                    match &a.inner {
                        ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                            if !inner.is_empty() =>
                        {
                            let pt = self.infer_expr(&inner[0])?;
                            self.unify(&pt, &Type::Prim(PrimType::Bool))?;
                            let bt = if inner.len() > 1 {
                                self.infer_expr(&inner[1])?
                            } else {
                                Type::Var(self.fresh_var())
                            };
                            if let Some(ref r) = rt {
                                drop(self.unify(r, &bt));
                            } else {
                                rt = Some(bt);
                            }
                        }
                        _ => {}
                    }
                }
                Ok(rt.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            // Handle raw try-catch.
            ExprInner::Call(op, args) if is_ident_op(op, "try") && args.len() >= 3 => {
                let et = self.infer_expr(&args[0])?;
                let cn = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___catch_".to_string(),
                };
                drop(self.env.bind(cn, Type::Prim(PrimType::Unit)));
                let ht = self.infer_expr(&args[2])?;
                self.unify(&et, &ht)?;
                Ok(et)
            }

            ExprInner::Apply(name, args) if name == "try" && args.len() >= 3 => {
                let et = self.infer_expr(&args[0])?;
                let cn = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___catch_".to_string(),
                };
                drop(self.env.bind(cn, Type::Prim(PrimType::Unit)));
                let ht = self.infer_expr(&args[2])?;
                self.unify(&et, &ht)?;
                Ok(et)
            }

            // Handle raw match.
            ExprInner::Call(op, args) if is_ident_op(op, "match") && !args.is_empty() => {
                drop(self.infer_expr(&args[0])?);
                let mut first: Option<Type> = None;
                for arm in &args[1..] {
                    match &arm.inner {
                        ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                            if !inner.is_empty() =>
                        {
                            drop(
                                inner
                                    .iter()
                                    .skip(1)
                                    .map(|p| self.infer_expr(p))
                                    .collect::<Vec<_>>(),
                            );
                            let abt = self.infer_expr(&*inner.last().unwrap())?;
                            if let Some(ref t) = first {
                                drop(self.unify(t, &abt));
                            } else {
                                first = Some(abt);
                            }
                        }
                        _ => {}
                    }
                }
                Ok(first.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            ExprInner::Apply(name, args) if name == "match" && !args.is_empty() => {
                drop(self.infer_expr(&args[0])?);
                let mut first: Option<Type> = None;
                for arm in &args[1..] {
                    match &arm.inner {
                        ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                            if !inner.is_empty() =>
                        {
                            drop(
                                inner
                                    .iter()
                                    .skip(1)
                                    .map(|p| self.infer_expr(p))
                                    .collect::<Vec<_>>(),
                            );
                            let abt = self.infer_expr(&*inner.last().unwrap())?;
                            if let Some(ref t) = first {
                                drop(self.unify(t, &abt));
                            } else {
                                first = Some(abt);
                            }
                        }
                        _ => {}
                    }
                }
                Ok(first.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            ExprInner::If(cond, then_, else_) => {
                let ct = self.infer_expr(cond)?;
                self.unify(&ct, &Type::Prim(PrimType::Bool))?;
                let tt = self.infer_expr(then_)?;
                let et = self.infer_expr(else_)?;
                self.unify(&tt, &et)?;
                Ok(tt)
            }

            // Raw defn/def — definitions don't produce value types, return Unit.
            ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "defn" && args.len() >= 3 => {
                Ok(Type::Prim(PrimType::Unit))
            }

            // Raw def.
            ExprInner::Call(op, args) if is_ident_op(op, "def") && args.len() >= 2 => {
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "def" && args.len() >= 2 => {
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            // Raw deftype, trait, impl, struct — return Unit.
            ExprInner::Call(op, args) if is_ident_op(op, "deftype") && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "deftype" && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Call(op, args) if is_ident_op(op, "trait") && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "trait" && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Call(op, args) if is_ident_op(op, "impl") && args.len() >= 3 => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "impl" && args.len() >= 3 => {
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Call(op, args) if is_ident_op(op, "defstruct") && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "defstruct" && args.len() >= 2 => {
                Ok(Type::Prim(PrimType::Unit))
            }

            // Raw derive.
            ExprInner::Call(op, args) if is_ident_op(op, "derive") && args.len() >= 2 => {
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Apply(name, args) if name == "derive" && args.len() >= 2 => {
                drop(self.infer_expr(&args[1])?);
                Ok(Type::Prim(PrimType::Unit))
            }

            // Raw struct-get.
            ExprInner::Call(op, args) if is_ident_op(op, "struct-get") && args.len() >= 2 => {
                drop(self.infer_expr(&args[0])?);
                Ok(Type::Var(self.fresh_var()))
            }
            ExprInner::Apply(name, args) if name == "struct-get" && args.len() >= 2 => {
                drop(self.infer_expr(&args[0])?);
                Ok(Type::Var(self.fresh_var()))
            }

            // Raw make-struct.
            ExprInner::Begin(exprs) => {
                if exprs.is_empty() {
                    return Ok(Type::Prim(PrimType::Unit));
                }
                for e in &exprs[..exprs.len() - 1] {
                    drop(self.infer_expr(e)?);
                }
                self.infer_expr(exprs.last().unwrap())
            }

            ExprInner::Lambda(_n, params, body) | ExprInner::Fn(_n, params, body) => {
                let pt: Vec<Type> = params.iter().map(|p| self.parse_type_str(&p.typ)).collect();
                for p in params {
                    drop(self.env.bind(p.name.clone(), Type::Var(self.fresh_var())));
                }
                let rt = self.infer_expr(body)?;
                Ok(Type::Fun(pt, Box::new(rt)))
            }

            ExprInner::Apply(name, args) => self.handle_apply(name, args),
            ExprInner::Call(op, args) => self.handle_call(expr, op, args),

            ExprInner::While(cond, body) => {
                let ct = self.infer_expr(cond)?;
                self.unify(&ct, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(body)?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::For(name, iter, cond, step, body) => {
                let _ = self.infer_expr(iter)?;
                self.env.enter_scope();
                drop(self.env.bind(name.clone(), Type::Cap(CapKind::TMut, Box::new(Type::Prim(PrimType::Int)))));
                let cond_type = self.infer_expr(cond)?;
                self.unify(&cond_type, &Type::Prim(PrimType::Bool))?;
                drop(self.infer_expr(step)?);
                let body_type = self.infer_expr(body)?;
                self.env.exit_scope();
                Ok(body_type)
            }

            ExprInner::Cond(clauses) => {
                let mut rt: Option<Type> = None;
                for (pred, body) in clauses {
                    let pt = self.infer_expr(pred)?;
                    self.unify(&pt, &Type::Prim(PrimType::Bool))?;
                    let bt = self.infer_expr(body)?;
                    if let Some(ref r) = rt {
                        self.unify(r, &bt)?;
                    } else {
                        rt = Some(bt);
                    }
                }
                Ok(rt.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            ExprInner::TryCatch(eh, _cn, handler) => {
                let et = self.infer_expr(eh)?;
                drop(self.infer_expr(handler));
                Ok(et)
            }
            ExprInner::Match(subject, arms) => {
                drop(self.infer_expr(subject)?);
                let mut first: Option<Type> = None;
                for arm in arms {
                    drop(
                        arm.patterns
                            .iter()
                            .map(|p| self.infer_expr(p))
                            .collect::<Vec<_>>(),
                    );
                    let abt = self.infer_expr(&arm.body)?;
                    {
                        if let Some(ref t) = first {
                            drop(self.unify(t, &abt));
                        } else {
                            first = Some(abt);
                        }
                    }
                }
                Ok(first.unwrap_or(Type::Prim(PrimType::Unit)))
            }

            ExprInner::Spawn(_closure) => Ok(Type::Nominal("ActorHandle".to_string())),
            ExprInner::Send(_, _msg) => Ok(Type::Prim(PrimType::Unit)),
            ExprInner::FfiCall(_, args, _) => {
                for arg in args {
                    drop(self.infer_expr(arg)?);
                }
                Ok(Type::Cap(
                    CapKind::TBox,
                    Box::new(Type::Var(self.fresh_var())),
                ))
            }
            ExprInner::FfiPin(e) => {
                let it = self.infer_expr(e)?;
                Ok(Type::Cap(CapKind::TPin, Box::new(it)))
            }
            ExprInner::Assert(cond, _) => {
                let ct = self.infer_expr(cond)?;
                self.unify(&ct, &Type::Prim(PrimType::Bool))?;
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Error(_) => Ok(Type::Prim(PrimType::Unit)),

            ExprInner::StructGet(_se, _fn) => {
                drop(self.infer_expr(_se)?);
                Ok(Type::Var(self.fresh_var()))
            }
            ExprInner::MakeStruct(name, fields) => {
                for field in fields {
                    drop(self.infer_expr(field)?);
                }
                Ok(Type::Nominal(name.clone()))
            }

            ExprInner::SetBang(target, val) => {
                let vt = self.infer_expr(val)?;
                if let Some(ty) = self.env.get(target).cloned() {
                    match ty {
                        Type::Cap(CapKind::TMut, _) => {}
                        _ => {
                            return Err(ZylError::E_INVALID_CAPABILITY(
                                expr.span.clone(),
                                format!("non-mutable variable '{}'", target),
                                "set!".to_string(),
                            ))
                        }
                    }
                } else {
                    return Err(ZylError::E_UNBOUND_VARIABLE(
                        expr.span.clone(),
                        target.clone(),
                    ));
                };
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::WithResource(_name, init, body) => {
                drop(self.infer_expr(init)?);
                self.infer_expr(body)
            }
            ExprInner::Deftype(name, variants, bound) => {
                if let Some(b) = bound {
                    drop(b);
                }
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::StructDef(sd, ..) | ExprInner::StructDefPlus(sd, ..) => {
                for (_, ftype) in &sd.fields {
                    if let Some(t_str) = ftype {
                        self.resolve_type_name(t_str);
                    }
                }
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::AliasDecl(_, target) => {
                drop(self.infer_expr(target)?);
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::Derive(type_name, traits) => {
                let ty = self
                    .resolve_type_name(type_name)
                    .unwrap_or(Type::Nominal(type_name.clone()));
                for tn in traits.iter() {
                    if !self.trait_ctx.check_derivable(&ty, tn) {
                        return Err(ZylError::E_TRAIT_NOT_DERIVABLE(
                            expr.span.clone(),
                            tn.clone(),
                            type_name.clone(),
                        ));
                    }
                }
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::MacroDef(_, _, _) => Ok(Type::Prim(PrimType::Unit)),
            ExprInner::TestSuite(_n, tests, _k) => {
                for tos in tests.iter().flat_map(|t| match t {
                    crate::ast::TestOrSuite::Test(td) => vec![&td.body],
                    crate::ast::TestOrSuite::Suite(s) => s
                        .tests
                        .iter()
                        .filter_map(|to| match to {
                            crate::ast::TestOrSuite::Test(td) => Some(&td.body),
                            _ => None,
                        })
                        .collect::<Vec<_>>(),
                }) {
                    drop(self.infer_expr(tos)?);
                }
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Setup(exprs) | ExprInner::Teardown(exprs) => {
                for e in exprs {
                    drop(self.infer_expr(e)?);
                }
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::TestDecl(_, body, _) => {
                drop(self.infer_expr(body)?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::AssertEqual(l, r) => {
                drop(self.infer_expr(l)?);
                drop(self.infer_expr(r)?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::AssertFail(e, _)
            | ExprInner::AssertTrue(e, _)
            | ExprInner::AssertFalse(e, _) => {
                drop(self.infer_expr(e)?);
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::TestProperty(_, _, body) => self.infer_expr(body),

            ExprInner::RunTests(_) => Ok(Type::Prim(PrimType::Unit)),
            ExprInner::TestCompile(e, _) => {
                drop(self.infer_expr(e)?);
                Ok(Type::Prim(PrimType::Unit))
            }

            ExprInner::ModuleDecl(_) | ExprInner::UseModule(_, _, _) | ExprInner::Export(_) => {
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Print(exprs) => {
                for e in exprs {
                    drop(self.infer_expr(e)?);
                }
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::ReadLine => Ok(Type::Prim(PrimType::String)),

            ExprInner::Exit(code) => {
                let ct = self.infer_expr(code)?;
                match &ct {
                    Type::Prim(PrimType::Int | PrimType::Bool) => {}
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "Int or Bool".to_string(),
                            format!("{}", ct),
                        ))
                    }
                };
                Ok(Type::Prim(PrimType::Unit))
            }
            ExprInner::Close(resource) => {
                drop(self.infer_expr(resource)?);
                Ok(Type::Prim(PrimType::Unit))
            }

            _ => Ok(Type::Var(self.fresh_var())),
        }
    }

    fn handle_apply(&mut self, name: &str, args: &[Expr]) -> std::result::Result<Type, ZylError> {
        if let Some(ret_type) = self.function_returns.get(name).cloned() {
            let expected_params: Vec<(String, Type)> =
                self.known_functions.get(name).cloned().unwrap_or_default();
            if args.len() != expected_params.len() {
                return Err(ZylError::E_ARITY_MISMATCH(
                    name.to_string(),
                    expected_params.len(),
                    args.len(),
                ));
            }
            for (i, arg) in args.iter().enumerate() {
                let at = self.infer_expr(arg)?;
                self.unify(&at, &expected_params[i].1)?;
            }
            Ok(ret_type)
        } else if let Some(ty) = self.env.get(name).cloned() {
            match ty {
                Type::Fun(expected_params, return_type) => {
                    if args.len() != expected_params.len() {
                        return Err(ZylError::E_ARITY_MISMATCH(
                            name.to_string(),
                            expected_params.len(),
                            args.len(),
                        ));
                    }
                    for (i, arg) in args.iter().enumerate() {
                        let at = self.infer_expr(arg)?;
                        self.unify(&at, &expected_params[i])?;
                    }
                    Ok((*return_type).clone())
                }
                _ => Err(ZylError::E_TYPE_MISMATCH(
                    Span::default(),
                    "function type".to_string(),
                    format!("{}", ty),
                )),
            }
        } else {
            let arg_types: Vec<Type> = args
                .iter()
                .map(|a| self.infer_expr(a))
                .collect::<std::result::Result<Vec<_>, _>>()?;
            Ok(Type::Fun(arg_types, Box::new(Type::Var(self.fresh_var()))))
        }
    }

    fn handle_call(
        &mut self,
        expr: &Expr,
        op: &Box<Expr>,
        args: &[Expr],
    ) -> std::result::Result<Type, ZylError> {
        let op_name = match &op.inner {
            ExprInner::Atom(Atom::Ident(name)) => name.clone(),
            _ => {
                return Err(ZylError::E_TYPE_MISMATCH(
                    expr.span.clone(),
                    "identifier".to_string(),
                    format!("{:?}", op),
                ))
            }
        };

        if matches!(op_name.as_str(), "+" | "-" | "*" | "/") {
            for arg in args {
                let t = self.infer_expr(arg)?;
                let inner = match &t {
                    Type::Cap(_, inner) => inner.as_ref(),
                    _ => &t,
                };
                match inner {
                    Type::Prim(PrimType::Int | PrimType::Float) => {}
                    _ => {
                        return Err(ZylError::E_TYPE_MISMATCH(
                            expr.span.clone(),
                            "numeric type".to_string(),
                            format!("{}", t),
                        ))
                    }
                }
            }
            Ok(Type::Var(self.fresh_var())) // Int or Float for now.
        } else if matches!(op_name.as_str(), "==" | "!=" | "<" | ">" | "<=" | ">=") {
            for arg in args {
                drop(self.infer_expr(arg)?);
            }
            Ok(Type::Prim(PrimType::Bool))
        } else if op_name == "not" || op_name == "and" || op_name == "or" {
            for arg in args {
                let t = self.infer_expr(arg)?;
                self.unify(&t, &Type::Prim(PrimType::Bool))?;
            }
            Ok(Type::Prim(PrimType::Bool))
        } else if matches!(op_name.as_str(), "str" | "int" | "float") {
            for arg in args {
                drop(self.infer_expr(arg)?);
            }
            match op_name.as_str() {
                "int" => Ok(Type::Prim(PrimType::Int)),
                "float" => Ok(Type::Prim(PrimType::Float)),
                _ => Ok(Type::Prim(PrimType::String)),
            }
        } else if matches!(op_name.as_str(), "is-some" | "is-none" | "is-ok" | "is-err") {
            for arg in args {
                drop(self.infer_expr(arg)?);
            }
            Ok(Type::Prim(PrimType::Bool))
        } else {
            self.handle_apply(&op_name, args)
        }
    }

    fn parse_type_str(&self, typ: &Option<String>) -> Type {
        match typ {
            Some(t) => self.resolve_type_name(t).unwrap_or_else(|| {
                if is_generic_param(t) {
                    Type::Var(self.fresh_var())
                } else {
                    Type::Nominal(t.clone())
                }
            }),
            None => Type::Var(self.fresh_var()),
        }
    }

    fn resolve_type_name(&self, name: &str) -> Option<Type> {
        if let Some(ty) = self.known_types.get(name).cloned() {
            return Some(ty);
        }
        if let Some(inner_name) = parse_cap_type(name) {
            if let Some(it) = self.resolve_type_name(&inner_name) {
                return Some(Type::Cap(CapKind::TCap, Box::new(it)));
            } else if is_generic_param(&inner_name) {
                return Some(Type::Cap(
                    CapKind::TCap,
                    Box::new(Type::Var(self.fresh_var())),
                ));
            }
        }
        if let Some(en) = parse_collection_type(name) {
            if let Some(et) = self.resolve_type_name(&en) {
                return Some(Type::Collection(CollectionKind::Vec, Box::new(et)));
            } else if is_generic_param(&en) {
                return Some(Type::Collection(
                    CollectionKind::Vec,
                    Box::new(Type::Var(self.fresh_var())),
                ));
            }
        }
        if let Some((ps, rs)) = parse_fun_type(name) {
            let params: Vec<Type> = ps
                .split(',')
                .map(|s| {
                    self.resolve_type_name(s.trim())
                        .unwrap_or_else(|| Type::Var(self.fresh_var()))
                })
                .collect();
            return Some(Type::Fun(
                params,
                Box::new(
                    self.resolve_type_name(rs.trim())
                        .unwrap_or_else(|| Type::Var(self.fresh_var())),
                ),
            ));
        }
        if let Some((kn, vn)) = parse_map_type(name) {
            let kt = self
                .resolve_type_name(kn.trim())
                .unwrap_or_else(|| Type::Var(self.fresh_var()));
            let vt = self
                .resolve_type_name(vn.trim())
                .unwrap_or_else(|| Type::Var(self.fresh_var()));
            return Some(Type::Map(Box::new(kt), Box::new(vt)));
        }
        if is_generic_param(name) {
            self.generics_in_scope.borrow_mut().insert(name.to_string());
            return Some(Type::Var(self.fresh_var()));
        }
        None
    }

    fn unify(&mut self, t1: &Type, t2: &Type) -> std::result::Result<(), ZylError> {
        match (t1, t2) {
            (a, b) if a == b => Ok(()),
            (Type::Var(n), _) => {
                let s = &self.subst;
                if s.contains(*n) {
                    return self.unify(&s.apply(t1), t2);
                }
                if self.type_contains_var(t2, *n) {
                    return Err(ZylError::E_TYPE_MISMATCH(
                        Span::default(),
                        format!("type containing ?{}", n),
                        "occurs".to_string(),
                    ));
                }
                let ns = s.extend(*n, t2).map_err(|e| {
                    ZylError::E_TYPE_MISMATCH(Span::default(), "unification error".into(), e)
                })?;
                self.subst = ns;
                Ok(())
            }
            (_, Type::Var(n)) => {
                let s = &self.subst;
                if s.contains(*n) {
                    return self.unify(t1, &s.apply(t2));
                }
                if self.type_contains_var(t1, *n) {
                    return Err(ZylError::E_TYPE_MISMATCH(
                        Span::default(),
                        format!("type containing ?{}", n),
                        "occurs".to_string(),
                    ));
                }
                let ns = s.extend(*n, t1).map_err(|e| {
                    ZylError::E_TYPE_MISMATCH(Span::default(), "unification error".into(), e)
                })?;
                self.subst = ns;
                Ok(())
            }
            (Type::Fun(a1, r1), Type::Fun(a2, r2)) => {
                if a1.len() != a2.len() {
                    return Err(ZylError::E_TYPE_MISMATCH(
                        Span::default(),
                        format!("TFun({} params)", a1.len()),
                        format!("TFun({} params)", a2.len()),
                    ));
                }
                for (a, b) in a1.iter().zip(a2.iter()) {
                    self.unify(a, b)?;
                }
                self.unify(r1, r2)
            }
            (Type::Cap(k1, i1), Type::Cap(k2, i2)) => {
                if k1 != k2 {
                    return Err(ZylError::E_TYPE_MISMATCH(
                        Span::default(),
                        format!("{}<...>", k1),
                        format!("{}<...>", k2),
                    ));
                };
                self.unify(i1, i2)
            }
            (Type::Collection(k1, i1), Type::Collection(k2, i2)) => {
                if k1 != k2 {
                    return Err(ZylError::E_TYPE_MISMATCH(
                        Span::default(),
                        format!("{:?}<...>", k1),
                        format!("{:?}<...>", k2),
                    ));
                };
                self.unify(i1, i2)
            }
            (Type::Map(k1, v1), Type::Map(k2, v2)) => {
                self.unify(k1, k2)?;
                self.unify(v1, v2)
            }
            (Type::ResultType(t1, e1), Type::ResultType(t2, e2)) => {
                self.unify(t1, t2)?;
                self.unify(e1, e2)
            }
            (Type::Nominal(n1), Type::Nominal(n2)) if n1 == n2 => Ok(()),
            _ => Err(ZylError::E_TYPE_MISMATCH(
                Span::default(),
                format!("{}", t1),
                format!("{}", t2),
            )),
        }
    }

    fn type_contains_var(&self, ty: &Type, n: usize) -> bool {
        match self.subst.apply(ty) {
            Type::Var(m) => m == n,
            Type::Cap(_, inner) => self.type_contains_var(&*inner, n),
            Type::Fun(args, ret) => {
                args.iter().any(|a| self.type_contains_var(a, n))
                    || self.type_contains_var(&*ret, n)
            }
            Type::Collection(_, inner) => self.type_contains_var(&*inner, n),
            Type::Map(k, v) => self.type_contains_var(&*k, n) || self.type_contains_var(&*v, n),
            Type::ResultType(t, e) => {
                self.type_contains_var(&*t, n) || self.type_contains_var(&*e, n)
            }
            _ => false,
        }
    }

    // ── Phase 6: Monomorphization accessors ───────────────────────────────
    /// Expose known function signatures for monomorphization.
    pub fn get_known_functions(&self) -> &IndexMap<String, Vec<(String, Type)>> {
        &self.known_functions
    }

    /// Expose function return types for monomorphization.
    pub fn get_function_returns(&self) -> &IndexMap<String, Type> {
        &self.function_returns
    }

    /// Expose trait context for bound verification in monomorphization.
    pub fn get_trait_context(&self) -> &TraitContext {
        &self.trait_ctx
    }

    /// Expose known types (primitives + user-defined) for ADT monomorphization.
    pub fn get_known_types(&self) -> &IndexMap<String, Type> {
        &self.known_types
    }

    /// Expose struct definitions for field-level monomorphization.
    pub fn get_struct_defs(&self) -> &IndexMap<String, Vec<(String, Option<Type>)>> {
        &self.struct_defs
    }
}

fn parse_params_from_expr(expr: &Expr) -> Vec<Param> {
    match &expr.inner {
        // Call from special forms — all elements are params.
        ExprInner::Call(op, ref items) => {
            let mut params = Vec::new();
            // If the operator is a simple identifier and all args are identifiers/keywords,
            // treat this as a raw S-expression list where every element is a param.
            if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_))) {
                let all_simple = items.iter().all(|i| {
                    matches!(&i.inner, ExprInner::Atom(Atom::Ident(_) | Atom::Keyword(_)))
                });
                if all_simple {
                    // Raw list like (x y) — include operator as first param.
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
        ExprInner::Call(_, ref inner) if !inner.is_empty() => {
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
pub fn is_generic_param(s: &str) -> bool {
    s.len() == 1 && s.chars().next().map(|c| c.is_uppercase()).unwrap_or(false)
        || s.starts_with('T')
            && !matches!(s, "TCap" | "TMut" | "TBox" | "TPin" | "TAtomic" | "TFun")
}
fn parse_cap_type(s: &str) -> Option<String> {
    for cap in ["TCap", "TMut", "TBox", "TPin", "TAtomic"] {
        if let Some(rest) = s.strip_prefix(cap).and_then(|s| s.strip_prefix('<')) {
            if let Some(inner) = rest.strip_suffix('>') {
                return Some(inner.to_string());
            }
        }
    }
    None
}
fn parse_collection_type(s: &str) -> Option<String> {
    if let Some(rest) = s.strip_prefix("Vec<") {
        if let Some(inner) = rest.strip_suffix('>') {
            return Some(inner.to_string());
        }
    }
    None
}

fn parse_fun_type(s: &str) -> Option<(String, String)> {
    if let Some(rest) = s.strip_prefix("TFun(") {
        let mut depth = 1;
        for (j, c) in rest.chars().enumerate() {
            match c {
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if depth == 0 {
                        return Some((rest[..j].to_string(), rest[j + 1..].trim().to_string()));
                    }
                }
                _ => {}
            }
        }
    }
    None
}

fn parse_map_type(s: &str) -> Option<(String, String)> {
    if let Some(rest) = s.strip_prefix("Map<") {
        let mut depth = 1;
        for (j, c) in rest.chars().enumerate() {
            match c {
                '<' => depth += 1,
                '>' => depth -= 1,
                ',' if depth == 1 => {
                    return Some((
                        rest[..j].to_string(),
                        rest[j + 1..].strip_suffix('>')?.to_string(),
                    ));
                }
                _ => {}
            }
        }
    }
    None
}

fn parse_result_type(s: &str) -> Option<(String, String)> {
    if let Some(rest) = s.strip_prefix("Result<") {
        let mut depth = 1;
        for (j, c) in rest.chars().enumerate() {
            match c {
                '<' => depth += 1,
                '>' => depth -= 1,
                ',' if depth == 1 => {
                    return Some((
                        rest[..j].to_string(),
                        rest[j + 1..].strip_suffix('>')?.to_string(),
                    ));
                }
                _ => {}
            }
        }
    }
    None
}
