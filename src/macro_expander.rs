use std::cell::RefCell;
use std::collections::HashMap;

use indexmap::IndexMap;

use crate::ast::*;
use crate::error::{Span, ZylError};
// Import Atom separately for use in match arms where ExprInner::Atom shadows it.
use crate::ast::Atom as AstAtom;

// ─── Macro definition ──────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct MacroDef {
    pub name: String,
    /// Pattern expressions — each pattern corresponds to an argument position at the call site.
    pub patterns: Vec<Expr>,
    /// Template expression that gets substituted and returned as expanded code.
    pub template: Box<Expr>,
}

// ─── Gensym registry ──────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct GensymRegistry {
    counter: u64,
}

impl GensymRegistry {
    pub fn new() -> Self { Self { counter: 0 } }
    /// Generate a unique symbol for `prefix`. Format: `{prefix}#{counter}`.
    pub fn gensym(&mut self, prefix: &str) -> String {
        let sym = format!("{}#{}", prefix, self.counter);
        self.counter += 1;
        sym
    }
    /// Reset counter for a fresh expansion context (new call site).
    pub fn reset(&mut self) { self.counter = 0; }
}

// Use RefCell for interior mutability in substitution contexts.
type GensymRef = RefCell<GensymRegistry>;

// ─── Pattern matching helpers ──────────────────────────────────────────

fn is_special_form_name(name: &str) -> bool {
    matches!(name, "if" | "let" | "let-mut" | "while" | "for" | "cond" | "try" | "match")
}

/// Extract the operator name from a Call's first element.
fn call_operator_name(expr: &Expr) -> Option<String> {
    match &expr.inner { ExprInner::Atom(Atom::Ident(n)) => Some(n.clone()), _ => None }
}

/// Normalize raw Call/Apply special forms to their specialized ExprInner variants for matching.
/// This allows patterns defined as raw AST (inside defmacro) to match against both raw and
/// dispatched expressions (outside defmacro).
fn normalize_for_match(expr: &Expr) -> Expr {
    // Raw "if" → If(c, t, e).
    if let ExprInner::Call(op, args) = &expr.inner {
        if call_operator_name(op) == Some("if".into()) && !args.is_empty() {
            let cond = Box::new(args[0].clone());
            let then_ = if args.len() > 1 { Box::new(args[1].clone()) } else { Box::new(Expr { span: Span::default(), inner: ExprInner::Atom(AstAtom::Int(0)) }) };
            let els = if args.len() > 2 { Box::new(args[2].clone()) } else { Box::new(Expr { span: Span::default(), inner: ExprInner::Atom(AstAtom::Int(0)) }) };
            return Expr { span: expr.span.clone(), inner: ExprInner::If(cond, then_, els) };
        }
    }
    // Raw "let" → Let(name, val, body).
    if let ExprInner::Call(op, args) = &expr.inner {
        if call_operator_name(op) == Some("let".into()) && args.len() >= 3 {
            let name = match &args[0].inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___let_".to_string() };
            return Expr { span: expr.span.clone(), inner: ExprInner::Let(name, Box::new(args[1].clone()), Box::new(args[2].clone())) };
        }
    }
    // Raw Apply with special form name → normalize.
    if let ExprInner::Apply(name, args) = &expr.inner {
        match name.as_str() {
            "if" if !args.is_empty() => {
                let cond = Box::new(args[0].clone());
                let then_ = if args.len() > 1 { Box::new(args[1].clone()) } else { Box::new(Expr { span: Span::default(), inner: ExprInner::Atom(AstAtom::Int(0)) }) };
                let els = if args.len() > 2 { Box::new(args[2].clone()) } else { Box::new(Expr { span: Span::default(), inner: ExprInner::Atom(AstAtom::Int(0)) }) };
                return Expr { span: expr.span.clone(), inner: ExprInner::If(cond, then_, els) };
            } "let" if args.len() >= 3 => {
                let name = match &args[0].inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___let_".to_string() };
                return Expr { span: expr.span.clone(), inner: ExprInner::Let(name, Box::new(args[1].clone()), Box::new(args[2].clone())) };
            } "while" if args.len() >= 2 => {
                return Expr { span: expr.span.clone(), inner: ExprInner::While(Box::new(args[0].clone()), Box::new(args[1].clone())) };
            } _ => {}
        }
    }
    // Already specialized or not a special form — return as-is.
    expr.clone()
}

fn match_pattern(pattern: &Expr, expr: &Expr) -> Result<IndexMap<String, Expr>, ()> {
    let mut bindings = IndexMap::new();
    do_match(pattern, expr, &mut bindings)?;
    Ok(bindings)
}

fn do_match(pattern: &Expr, expr: &Expr, bindings: &mut IndexMap<String, Expr>) -> Result<(), ()> {
    // Normalize both to handle raw Call/Apply special forms uniformly.
    let pat = normalize_for_match(pattern);
    let exp = normalize_for_match(expr);

    match (&pat.inner, &exp.inner) {
        (ExprInner::Atom(Atom::Ident(name)), _) => {
            bindings.insert(name.clone(), expr.clone());
            Ok(())
        }
        (ExprInner::Atom(atom_a), ExprInner::Atom(atom_b)) => {
            if atom_a == atom_b { Ok(()) } else { Err(()) }
        }
        // Call: structure must match recursively.
        (ExprInner::Call(op, pats), ExprInner::Call(eop, eargs)) => {
            do_match(op, eop, bindings)?;
            if pats.len() != eargs.len() { return Err(()); }
            for (pp, ep) in pats.iter().zip(eargs.iter()) { do_match(pp, ep, bindings)?; }
            Ok(())
        }
        // Apply with same name: match args recursively.
        (ExprInner::Apply(pname, pargs), ExprInner::Apply(ename, eargs)) if pname == ename => {
            if pargs.len() != eargs.len() { return Err(()); }
            for (pp, ep) in pargs.iter().zip(eargs.iter()) { do_match(pp, ep, bindings)?; }
            Ok(())
        }
        // Begin: match each element.
        (ExprInner::Begin(pexprs), ExprInner::Begin(eexprs)) => {
            if pexprs.len() != eexprs.len() { return Err(()); }
            for (pp, ep) in pexprs.iter().zip(eexprs.iter()) { do_match(pp, ep, bindings)?; }
            Ok(())
        }
        // If: match all three branches.
        (ExprInner::If(pc, pt, pe), ExprInner::If(ec, et, ee)) => {
            do_match(pc, ec, bindings)?; do_match(pt, et, bindings)?; do_match(pe, ee, bindings)
        }
        // For other complex types: try structural equality.
        _ => { if expr_matches_structurally(&pat, &exp) { Ok(()) } else { Err(()) } }
    }
}

fn expr_matches_structurally(a: &Expr, b: &Expr) -> bool {
    use ExprInner::*;
    std::mem::discriminant(&a.inner) == std::mem::discriminant(&b.inner) && match (&a.inner, &b.inner) {
        (Atom(aa), Atom(ab)) => aa == ab,
        (Call(aop, aargs), Call(bop, bargs)) => expr_matches_structurally(aop, bop)
            && aargs.len() == bargs.len() && aargs.iter().zip(bargs.iter()).all(|(x,y)| expr_matches_structurally(x,y)),
        (Def(an, av), Def(bn, bv)) => an == bn.as_str() && expr_matches_structurally(av, bv),
        (Let(al, av, ab), Let(bl, bv, bb)) => al == bl && expr_matches_structurally(av, bv) && expr_matches_structurally(ab, bb),
        (If(ac, at, ae), If(bc, bt, be)) => expr_matches_structurally(ac, bc) && expr_matches_structurally(at, bt) && expr_matches_structurally(ae, be),
        (Begin(ax), Begin(bx)) => ax.len() == bx.len() && ax.iter().zip(bx.iter()).all(|(x,y)| expr_matches_structurally(x,y)),
        _ => false,
    }
}

// ─── Template substitution ─────────────────────────────────────────────

fn substitute(template: &Expr, bindings: &IndexMap<String, Expr>, gensyms: &mut GensymRegistry) -> Expr {
    let gensyms_ref = RefCell::new(gensyms.clone());
    let ctx = SubstContext { bindings, gensyms: gensyms_ref };
    sub_expr(&ctx, template)
}

struct SubstContext<'a> {
    bindings: &'a IndexMap<String, Expr>,
    gensyms: GensymRef,
}

fn atom_ref(name: String) -> Expr {
    Expr { span: Span::default(), inner: ExprInner::Atom(Atom::Ident(name)) }
}

/// Substitute in an expression. Returns a full `Expr` with span preserved.
fn sub_expr(ctx: &SubstContext, expr: &Expr) -> Expr {
    let result = match &expr.inner {
        // Identifier: check if bound by a pattern — return early as whole Expr.
        ExprInner::Atom(Atom::Ident(name)) => {
            return if let Some(replacement) = ctx.bindings.get(name.as_str()) {
                replacement.clone()
            } else { expr.clone() };
        }

        // Call: check if it's a raw special form for proper substitution.
        ExprInner::Call(op, args) => {
            let op_name = call_operator_name(op);
            if matches!(op_name.as_deref(), Some("if")) && !args.is_empty() {
                let cond = sub_expr(ctx, &args[0]);
                let then_ = if args.len() > 1 { sub_expr(ctx, &args[1]) } else { atom_ref("___".into()) };
                let els = if args.len() > 2 { sub_expr(ctx, &args[2]) } else { atom_ref("___".into()) };
                ExprInner::If(Box::new(cond), Box::new(then_), Box::new(els))
            } else if matches!(op_name.as_deref(), Some("let")) && args.len() >= 3 {
                // Substitute bindings into all args first (name position may contain pattern vars).
                let arg0 = sub_expr(ctx, &args[0]);
                let new_val = sub_expr(ctx, &args[1]);
                let name = match &arg0.inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___let_".to_string() };
                let mut inner_bindings = ctx.bindings.clone();
                let gensym_name = format!("__let_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(&name) });
                inner_bindings.insert(name.clone(), atom_ref(gensym_name));
                let inner_ctx = SubstContext { bindings: &inner_bindings, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) };
                ExprInner::Let(name, Box::new(new_val), Box::new(sub_expr(&inner_ctx, &args[2])))
            } else if matches!(op_name.as_deref(), Some("while")) && args.len() >= 2 {
                ExprInner::While(Box::new(sub_expr(ctx, &args[0])), Box::new(sub_expr(ctx, &args[1])))
            } else if matches!(op_name.as_deref(), Some("for")) && args.len() >= 3 {
                let arg0 = sub_expr(ctx, &args[0]);
                let name = match &arg0.inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___for_".to_string() };
                ExprInner::For(name, Box::new(sub_expr(ctx, &args[1])), Box::new(sub_expr(ctx, &args[2])))
            } else {
                let new_op = Box::new(sub_expr(ctx, op));
                let new_args: Vec<Expr> = args.iter().map(|a| sub_expr(ctx, a)).collect();
                ExprInner::Call(new_op, new_args)
            }
        }

        // Apply: check if it's a raw special form for proper substitution.
        ExprInner::Apply(name, args) => {
            match name.as_str() {
                "if" if !args.is_empty() => {
                    let cond = sub_expr(ctx, &args[0]);
                    let then_ = if args.len() > 1 { sub_expr(ctx, &args[1]) } else { atom_ref("___".into()) };
                    let els = if args.len() > 2 { sub_expr(ctx, &args[2]) } else { atom_ref("___".into()) };
                    ExprInner::If(Box::new(cond), Box::new(then_), Box::new(els))
                }
                "let" if args.len() >= 3 => {
                    let arg0 = sub_expr(ctx, &args[0]);
                    let new_val = sub_expr(ctx, &args[1]);
                    let name = match &arg0.inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___let_".to_string() };
                    let mut inner_bindings = ctx.bindings.clone();
                    let gensym_name = format!("__let_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(&name) });
                    inner_bindings.insert(name.clone(), atom_ref(gensym_name));
                    let inner_ctx = SubstContext { bindings: &inner_bindings, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) };
                    ExprInner::Let(name, Box::new(new_val), Box::new(sub_expr(&inner_ctx, &args[2])))
                }
                "while" if args.len() >= 2 => {
                    ExprInner::While(Box::new(sub_expr(ctx, &args[0])), Box::new(sub_expr(ctx, &args[1])))
                }
                "for" if args.len() >= 3 => {
                    let arg0 = sub_expr(ctx, &args[0]);
                    let name = match &arg0.inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => "___for_".to_string() };
                    ExprInner::For(name, Box::new(sub_expr(ctx, &args[1])), Box::new(sub_expr(ctx, &args[2])))
                }
                _ => {
                    let new_args: Vec<Expr> = args.iter().map(|a| sub_expr(ctx, a)).collect();
                    ExprInner::Apply(name.clone(), new_args)
                }
            }
        }

        // Def: substitute the value expression only (name is literal).
        ExprInner::Def(name, val) => {
            ExprInner::Def(name.clone(), Box::new(sub_expr(ctx, val)))
        }

        // Let: bind `name` in body to shadow outer bindings.
        ExprInner::Let(name, val, body) => {
            let new_val = sub_expr(ctx, val);
            let mut inner_bindings = ctx.bindings.clone();
            let gensym_name = format!("__let_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(name) });
            inner_bindings.insert(name.clone(), atom_ref(gensym_name));
            let inner_ctx = SubstContext { bindings: &inner_bindings, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) };
            ExprInner::Let(name.clone(), Box::new(new_val), Box::new(sub_expr(&inner_ctx, body)))
        }

        // If: substitute all three branches.
        ExprInner::If(cond, then_, else_) => {
            ExprInner::If(Box::new(sub_expr(ctx, cond)), Box::new(sub_expr(ctx, then_)), Box::new(sub_expr(ctx, else_)))
        }

        // Begin: substitute each expression.
        ExprInner::Begin(exprs) => {
            ExprInner::Begin(exprs.iter().map(|e| sub_expr(ctx, e)).collect())
        }

        // Lambda/Fn: bind params to shadow outer bindings in body.
        ExprInner::Lambda(_, params, body) | ExprInner::Fn(_, params, body) => {
            let mut inner_bindings = ctx.bindings.clone();
            for p in params {
                let gensym_name = format!("__param_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(&p.name) });
                inner_bindings.insert(p.name.clone(), atom_ref(gensym_name));
            }
            let inner_ctx = SubstContext { bindings: &inner_bindings, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) };
            if matches!(&expr.inner, ExprInner::Lambda(..)) {
                ExprInner::Lambda("".into(), params.clone(), Box::new(sub_expr(&inner_ctx, body)))
            } else {
                ExprInner::Fn("".into(), params.clone(), Box::new(sub_expr(&inner_ctx, body)))
            }
        }

        // For other expression types: delegate to sub_complex.
        _ => sub_complex(ctx, expr),
    };
    Expr { span: expr.span.clone(), inner: result }
}

/// Substitute in complex expression types (returns ExprInner).
fn sub_complex(ctx: &SubstContext, expr: &Expr) -> ExprInner {
    use ExprInner::*;
    match &expr.inner {
        Call(op, args) => { let new_op = Box::new(sub_expr(ctx, op)); let new_args: Vec<Expr> = args.iter().map(|a| sub_expr(ctx, a)).collect(); Call(new_op, new_args) }
        Def(name, val) => Def(name.clone(), Box::new(sub_expr(ctx, val))),
        LetMut(name, val, body) => { LetMut(name.clone(), Box::new(sub_expr(ctx, val)), Box::new(sub_expr(ctx, body))) }
        TryCatch(e, name, h) => TryCatch(Box::new(sub_expr(ctx, e)), name.clone(), Box::new(sub_expr(ctx, h))),
        Match(e, arms) => { let new_arms: Vec<_> = arms.iter().map(|arm| MatchArm { variant: arm.variant.clone(), patterns: arm.patterns.iter().map(|p| sub_expr(ctx, p)).collect(), body: Box::new(sub_expr(ctx, &arm.body)) }).collect(); Match(Box::new(sub_expr(ctx, e)), new_arms) }
        Spawn(e) => Spawn(Box::new(sub_expr(ctx, e))),
        Send(a, m) => Send(Box::new(sub_expr(ctx, a)), Box::new(sub_expr(ctx, m))),
        FfiCall(name, args, timeout) => { let new_args: Vec<Expr> = args.iter().map(|a| sub_expr(ctx, a)).collect(); FfiCall(name.clone(), new_args, *timeout) }
        FfiPin(e) => FfiPin(Box::new(sub_expr(ctx, e))),
        FfiUnpin(e) => FfiUnpin(Box::new(sub_expr(ctx, e))),
        Assert(c, _msg) => { Assert(Box::new(sub_expr(ctx, c)), None) } // msg is Option<String> — no sub needed.
        Unwrap(e) => Unwrap(Box::new(sub_expr(ctx, e))),
        While(c, b) => While(Box::new(sub_expr(ctx, c)), Box::new(sub_expr(ctx, b))),
        For(name, iter, body) => For(name.clone(), Box::new(sub_expr(ctx, iter)), Box::new(sub_expr(ctx, body))),
        Cond(clauses) => { let new_clauses: Vec<_> = clauses.iter().map(|(pred, b)| (Box::new(sub_expr(ctx, pred)), Box::new(sub_expr(ctx, b)))).collect(); Cond(new_clauses) }
        StructGet(s, field) => StructGet(Box::new(sub_expr(ctx, s)), field.clone()),
        MakeStruct(name, args) => { let new_args: Vec<Expr> = args.iter().map(|a| sub_expr(ctx, a)).collect(); MakeStruct(name.clone(), new_args) }
        SetBang(name, val) => SetBang(name.clone(), Box::new(sub_expr(ctx, val))),
        UseModule(parts, syms, unsafe_) => { let new_syms = syms.as_ref().map(|s| s.iter().cloned().collect()); UseModule(parts.clone(), new_syms, *unsafe_) }
        Print(exprs) => Print(exprs.iter().map(|e| sub_expr(ctx, e)).collect()),
        Exit(e) => Exit(Box::new(sub_expr(ctx, e))),
        Close(e) => Close(Box::new(sub_expr(ctx, e))),
        WithResource(name, init, body) => { WithResource(name.clone(), Box::new(sub_expr(ctx, init)), Box::new(sub_expr(ctx, body))) }
        Deftype(name, variants, bound) => { let new_variants: Vec<_> = variants.iter().cloned().collect(); Deftype(name.clone(), new_variants, bound.clone()) }
        TraitDecl(name, methods, where_clause) => { let new_methods: Vec<_> = methods.iter().cloned().collect(); TraitDecl(name.clone(), new_methods, where_clause.clone()) }
        ImplBlock(trait_name, type_name, bodies) => { let new_bodies: Vec<_> = bodies.iter().cloned().collect(); ImplBlock(trait_name.clone(), type_name.clone(), new_bodies) }
        StructDef(sd) | StructDefPlus(sd) => { if matches!(&expr.inner, ExprInner::StructDefPlus(_)) { ExprInner::StructDefPlus(sd.clone()) } else { ExprInner::StructDef(sd.clone()) } }
        AliasDecl(name, target) => AliasDecl(name.clone(), Box::new(sub_expr(ctx, target))),
        Derive(type_name, traits) => Derive(type_name.clone(), traits.clone()),
        TestSuite(name, tests, keywords) => { let new_tests: Vec<_> = tests.iter().cloned().collect(); TestSuite(name.clone(), new_tests, keywords.clone()) }
        TestDecl(name, body, keywords) => TestDecl(name.clone(), Box::new(sub_expr(ctx, body)), keywords.clone()),
        AssertEqual(a, b) => AssertEqual(Box::new(sub_expr(ctx, a)), Box::new(sub_expr(ctx, b))),
        AssertFail(e, _msg) => { AssertFail(Box::new(sub_expr(ctx, e)), None) } // msg is Option<String>.
        AssertTrue(e, _msg) => { AssertTrue(Box::new(sub_expr(ctx, e)), None) }
        AssertFalse(e, _msg) => { AssertFalse(Box::new(sub_expr(ctx, e)), None) }
        TestProperty(name, gen, body) => TestProperty(name.clone(), gen.clone(), Box::new(sub_expr(ctx, body))),
        Setup(exprs) | Teardown(exprs) => { if matches!(&expr.inner, ExprInner::Teardown(_)) { Teardown(exprs.iter().map(|e| sub_expr(ctx, e)).collect()) } else { Setup(exprs.iter().map(|e| sub_expr(ctx, e)).collect()) } }
        RunTests(keywords) => RunTests(keywords.clone()),
        TestCompile(e, expect_error) => TestCompile(Box::new(sub_expr(ctx, e)), *expect_error),
        MacroDef(name, patterns, template) => { let new_patterns: Vec<Expr> = patterns.iter().map(|p| sub_expr(ctx, p)).collect(); MacroDef(name.clone(), new_patterns, Box::new(sub_expr(ctx, template))) }

        // These are handled in the main match arm of sub_expr but included here for completeness.
        Defn(_, params, body) => { let mut inner_bindings = ctx.bindings.clone(); for p in params { inner_bindings.insert(p.name.clone(), atom_ref(format!("__param_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(&p.name) }))); } let ic = SubstContext { bindings: &inner_bindings, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) }; Defn("".into(), params.clone(), Box::new(sub_expr(&ic, body))) },
        Let(name, val, body) => { let nv = sub_expr(ctx, val); let mut ib = ctx.bindings.clone(); ib.insert(name.clone(), atom_ref(format!("__let_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(name) }))); let ic = SubstContext { bindings: &ib, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) }; Let(name.clone(), Box::new(nv), Box::new(sub_expr(&ic, body))) },
        If(c, t, e_) => If(Box::new(sub_expr(ctx, c)), Box::new(sub_expr(ctx, t)), Box::new(sub_expr(ctx, e_))),
        Begin(exprs) => Begin(exprs.iter().map(|e| sub_expr(ctx, e)).collect()),
        Lambda(_, params, body) | Fn(_, params, body) => { let mut ib = ctx.bindings.clone(); for p in params { ib.insert(p.name.clone(), atom_ref(format!("__param_{}", { let mut g = ctx.gensyms.borrow_mut(); g.gensym(&p.name) }))); } let ic = SubstContext { bindings: &ib, gensyms: RefCell::new(ctx.gensyms.borrow().clone()) }; if matches!(&expr.inner, ExprInner::Lambda(..)) { Lambda("".into(), params.clone(), Box::new(sub_expr(&ic, body))) } else { Fn("".into(), params.clone(), Box::new(sub_expr(&ic, body))) } },

        ModuleDecl(_) => expr.inner.clone(),
        Export(_) => expr.inner.clone(),
        ReadLine => ExprInner::ReadLine,
        Atom(_) | Error(_) | Apply(_, _) => expr.inner.clone(),
    }
}

// ─── Macro expander ────────────────────────────────────────────────────

/// Try to extract a macro definition from an expression. Handles both:
/// - ExprInner::MacroDef (dispatched form)  
/// - Raw Call/Apply with "defmacro" operator (no-dispatch form).
fn try_extract_macro_def(expr: &Expr) -> Option<MacroDef> {
    match &expr.inner {
        // Dispatched form.
        ExprInner::MacroDef(name, patterns, template) => Some(MacroDef { name: name.clone(), patterns: patterns.clone(), template: template.clone() }),

        // Raw defmacro Call: (defmacro name patterns template...).
        ExprInner::Call(op, args) if call_operator_name(op) == Some("defmacro".into()) && args.len() >= 3 => {
            let name = match &args[0].inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => return None };
            // patterns is args[1] — a Call/Apply whose ALL children are individual pattern expressions.
            let patterns = extract_all_pattern_elements(&args[1]);
            // template is args[2..] — if multiple, wrap in Begin.
            let template = if args.len() == 3 { Box::new(args[2].clone()) } else {
                Box::new(Expr { span: Span::default(), inner: ExprInner::Begin(args[2..].to_vec()) })
            };
            Some(MacroDef { name, patterns, template })
        }

        // Raw defmacro Apply.
        ExprInner::Apply(name, args) if name == "defmacro" && args.len() >= 3 => {
            let name = match &args[0].inner { ExprInner::Atom(Atom::Ident(n)) => n.clone(), _ => return None };
            let patterns = extract_all_pattern_elements(&args[1]);
            let template = if args.len() == 3 { Box::new(args[2].clone()) } else {
                Box::new(Expr { span: Span::default(), inner: ExprInner::Begin(args[2..].to_vec()) })
            };
            Some(MacroDef { name, patterns, template })
        }

        _ => None
    }
}

#[derive(Debug)]
pub struct MacroExpander {
    macros: HashMap<String, MacroDef>,
    gensyms: GensymRegistry,
}

impl MacroExpander {
    pub fn new() -> Self {
        Self { macros: HashMap::new(), gensyms: GensymRegistry::new() }
    }

    /// Register all defmacro forms from the AST. Returns non-macro expressions.
    pub fn register(&mut self, exprs: &[Expr]) -> Vec<Expr> {
        let mut result = Vec::new();
        for expr in exprs {
            if let Some(mac) = try_extract_macro_def(expr) {
                if self.macros.contains_key(&mac.name) { eprintln!("Warning: macro '{}' redefined at {:?}", mac.name, &expr.span); }
                self.macros.insert(mac.name.clone(), mac);
            } else {
                result.push(expr.clone());
            }
        }
        result
    }

    /// Expand all macro calls in the expression list (innermost-first).
    pub fn expand(&mut self, exprs: Vec<Expr>) -> Result<Vec<Expr>, ZylError> {
        let expanded: Vec<Expr> = exprs.into_iter().map(|e| self.expand_expr(e)).collect::<Result<Vec<_>, _>>()?;
        Ok(expanded)
    }

    fn expand_expr(&mut self, mut expr: Expr) -> Result<Expr, ZylError> {
        // First, recursively expand children (innermost-first = post-order).
        match &expr.inner {
            ExprInner::Call(op, args) => {
                let new_op = Box::new(self.expand_expr(*op.clone())?);
                let mut new_args = Vec::with_capacity(args.len());
                for arg in args { new_args.push(self.expand_expr(arg.clone())?); }
                expr.inner = ExprInner::Call(new_op, new_args);
            }
            ExprInner::Apply(name, args) => {
                let mut new_args = Vec::with_capacity(args.len());
                for arg in args { new_args.push(self.expand_expr(arg.clone())?); }
                expr.inner = ExprInner::Apply(name.clone(), new_args);
            }
            ExprInner::Def(_, val) => {
                let name = match &expr.inner { ExprInner::Def(n, _) => n.clone(), _ => unreachable!() };
                expr.inner = ExprInner::Def(name, Box::new(self.expand_expr(*val.clone())?));
            }
            ExprInner::LetMut(_, val, body) => {
                let name = match &expr.inner { ExprInner::LetMut(n, _, _) => n.clone(), _ => unreachable!() };
                expr.inner = ExprInner::LetMut(name, Box::new(self.expand_expr(*val.clone())?), Box::new(self.expand_expr(*body.clone())?));
            }
            ExprInner::TryCatch(e, name, h) => {
                let catch_name = match &expr.inner { ExprInner::TryCatch(_, n, _) => n.clone(), _ => unreachable!() };
                expr.inner = ExprInner::TryCatch(Box::new(self.expand_expr(*e.clone())?), catch_name, Box::new(self.expand_expr(*h.clone())?));
            }
            ExprInner::Match(e, arms) => {
                let new_arms: Vec<MatchArm> = arms.iter().map(|arm| {
                    Ok(MatchArm { variant: arm.variant.clone(), patterns: arm.patterns.iter().map(|p| self.expand_expr(p.clone())).collect::<Result<Vec<_>, _>>()?, body: Box::new(self.expand_expr(*arm.body.clone())?) })
                }).collect::<Result<_, _>>()?;
                expr.inner = ExprInner::Match(Box::new(self.expand_expr(*e.clone())?), new_arms);
            }
            ExprInner::Spawn(e) => { expr.inner = ExprInner::Spawn(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::Send(a, m) => { expr.inner = ExprInner::Send(Box::new(self.expand_expr(*a.clone())?), Box::new(self.expand_expr(*m.clone())?)); }
            ExprInner::FfiCall(name, args, timeout) => {
                let ffi_name = name.clone(); let t = *timeout;
                let new_args: Vec<Expr> = args.iter().map(|a| self.expand_expr(a.clone())).collect::<Result<Vec<_>, _>>()?;
                expr.inner = ExprInner::FfiCall(ffi_name, new_args, t);
            }
            ExprInner::FfiPin(e) => { expr.inner = ExprInner::FfiPin(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::FfiUnpin(e) => { expr.inner = ExprInner::FfiUnpin(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::Assert(c, msg) => {
                let new_msg: Option<Expr> = match msg { Some(m) => Some(self.expand_expr(atom_ref(m.clone()))?), None => None };
                expr.inner = ExprInner::Assert(Box::new(self.expand_expr(*c.clone())?), new_msg.map(|e| match &e.inner { ExprInner::Atom(Atom::Str(s)) => s.clone(), _ => unreachable!() }));
            }
            ExprInner::Unwrap(e) => { expr.inner = ExprInner::Unwrap(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::While(c, b) => { expr.inner = ExprInner::While(Box::new(self.expand_expr(*c.clone())?), Box::new(self.expand_expr(*b.clone())?)); }
            ExprInner::For(name, iter, body) => { let for_name = name.clone(); expr.inner = ExprInner::For(for_name, Box::new(self.expand_expr(*iter.clone())?), Box::new(self.expand_expr(*body.clone())?)); }
            ExprInner::Cond(clauses) => {
                let new_clauses: Vec<(Box<Expr>, Box<Expr>)> = clauses.iter().map(|(pred, b)| Ok((Box::new(self.expand_expr(*pred.clone())?), Box::new(self.expand_expr(*b.clone())?)))).collect::<Result<Vec<_>, _>>()?;
                expr.inner = ExprInner::Cond(new_clauses);
            }
            ExprInner::Begin(exprs) => { let new: Vec<Expr> = exprs.iter().map(|e| self.expand_expr(e.clone())).collect::<Result<Vec<_>, _>>()?; expr.inner = ExprInner::Begin(new); }

            // If and Let need child expansion — sub_expr converts raw "if"/"let" to these during substitution.
            ExprInner::If(cond, then_, else_) => {
                expr.inner = ExprInner::If(Box::new(self.expand_expr(*cond.clone())?), Box::new(self.expand_expr(*then_.clone())?), Box::new(self.expand_expr(*else_.clone())?));
            }
            ExprInner::Let(name, val, body) => {
                expr.inner = ExprInner::Let(name.clone(), Box::new(self.expand_expr(*val.clone())?), Box::new(self.expand_expr(*body.clone())?));
            }

            // TryCatch also needs child expansion (sub_expr may produce these from raw "try").
            ExprInner::TryCatch(e, name, h) => {
                expr.inner = ExprInner::TryCatch(Box::new(self.expand_expr(*e.clone())?), name.clone(), Box::new(self.expand_expr(*h.clone())?));
            }
            ExprInner::Lambda(_, params, body) | ExprInner::Fn(_, params, body) => {
                let new_body = Box::new(self.expand_expr(*body.clone())?);
                if matches!(&expr.inner, ExprInner::Lambda(..)) { expr.inner = ExprInner::Lambda("".into(), params.clone(), new_body); } else { expr.inner = ExprInner::Fn("".into(), params.clone(), new_body); }
            }
            ExprInner::StructGet(s, field) => { let f = field.clone(); expr.inner = ExprInner::StructGet(Box::new(self.expand_expr(*s.clone())?), f); }
            ExprInner::MakeStruct(name, args) => { let mname = name.clone(); let new_args: Vec<Expr> = args.iter().map(|a| self.expand_expr(a.clone())).collect::<Result<Vec<_>, _>>()?; expr.inner = ExprInner::MakeStruct(mname, new_args); }
            ExprInner::SetBang(name, val) => { expr.inner = ExprInner::SetBang(name.clone(), Box::new(self.expand_expr(*val.clone())?)); }
            ExprInner::UseModule(..) | ExprInner::Export(_) => {}
            ExprInner::Print(exprs) => { let new: Vec<Expr> = exprs.iter().map(|e| self.expand_expr(e.clone())).collect::<Result<Vec<_>, _>>()?; expr.inner = ExprInner::Begin(new); } // Print → Begin for expansion.
            ExprInner::Exit(e) => { expr.inner = ExprInner::Exit(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::Close(e) => { expr.inner = ExprInner::Close(Box::new(self.expand_expr(*e.clone())?)); }
            ExprInner::WithResource(name, init, body) => { let rname = name.clone(); expr.inner = ExprInner::WithResource(rname, Box::new(self.expand_expr(*init.clone())?), Box::new(self.expand_expr(*body.clone())?)); }

            // Types and declarations — expand child expressions.
            _ => {
                use ExprInner::*;
                let new_inner = match &expr.inner {
                    Def(_, val) => { let name = match &expr.inner { Def(n, _) => n.clone(), _ => unreachable!() }; Def(name, Box::new(self.expand_expr(*val.clone())?)) },
                    LetMut(_, val, body) => { let name = match &expr.inner { LetMut(n, _, _) => n.clone(), _ => unreachable!() }; LetMut(name, Box::new(self.expand_expr(*val.clone())?), Box::new(self.expand_expr(*body.clone())?)) },
                    TryCatch(e, name, h) => { let cn = match &expr.inner { TryCatch(_, n, _) => n.clone(), _ => unreachable!() }; TryCatch(Box::new(self.expand_expr(*e.clone())?), cn, Box::new(self.expand_expr(*h.clone())?)) },
                    Match(e, arms) => { let new_arms: Vec<MatchArm> = arms.iter().map(|arm| Ok(MatchArm { variant: arm.variant.clone(), patterns: arm.patterns.iter().map(|p| self.expand_expr(p.clone())).collect::<Result<Vec<_>, _>>()?, body: Box::new(self.expand_expr(*arm.body.clone())?) })).collect::<Result<_, _>>()?; Match(Box::new(self.expand_expr(*e.clone())?), new_arms) },
                    Spawn(e) => Spawn(Box::new(self.expand_expr(*e.clone())?)),
                    Send(a, m) => Send(Box::new(self.expand_expr(*a.clone())?), Box::new(self.expand_expr(*m.clone())?)),
                    FfiCall(name, args, timeout) => { let fn_ = name.clone(); let ft = *timeout; let na: Vec<Expr> = args.iter().map(|a| self.expand_expr(a.clone())).collect::<Result<Vec<_>, _>>()?; FfiCall(fn_, na, ft) },
                    FfiPin(e) => FfiPin(Box::new(self.expand_expr(*e.clone())?)),
                    FfiUnpin(e) => FfiUnpin(Box::new(self.expand_expr(*e.clone())?)),
                    Assert(c, msg) => { let nm: Option<String> = match msg { Some(m) => Some(self.expand_expr(atom_ref(m.clone())).map(|e| match &e.inner { ExprInner::Atom(AstAtom::Str(s)) => s.clone(), _ => unreachable!() })?), None => None }; Assert(Box::new(self.expand_expr(*c.clone())?), nm) },
                    Unwrap(e) => Unwrap(Box::new(self.expand_expr(*e.clone())?)),
                    While(c, b) => While(Box::new(self.expand_expr(*c.clone())?), Box::new(self.expand_expr(*b.clone())?)),
                    For(name, iter, body) => { let fn_ = name.clone(); For(fn_, Box::new(self.expand_expr(*iter.clone())?), Box::new(self.expand_expr(*body.clone())?) ) },
                    Cond(clauses) => { let nc: Vec<(Box<Expr>, Box<Expr>)> = clauses.iter().map(|(p, b)| Ok((Box::new(self.expand_expr(*p.clone())?), Box::new(self.expand_expr(*b.clone())?)))).collect::<Result<Vec<_>, _>>()?; Cond(nc) },
                    StructGet(s, field) => { let f = field.clone(); StructGet(Box::new(self.expand_expr(*s.clone())?), f) },
                    MakeStruct(name, args) => { let mn = name.clone(); let na: Vec<Expr> = args.iter().map(|a| self.expand_expr(a.clone())).collect::<Result<Vec<_>, _>>()?; MakeStruct(mn, na) },
                    SetBang(name, val) => SetBang(name.clone(), Box::new(self.expand_expr(*val.clone())?)),
                    Print(exprs) => { let ne: Vec<Expr> = exprs.iter().map(|e| self.expand_expr(e.clone())).collect::<Result<Vec<_>, _>>()?; Begin(ne) },
                    Exit(e) => Exit(Box::new(self.expand_expr(*e.clone())?)),
                    Close(e) => Close(Box::new(self.expand_expr(*e.clone())?)),
                    WithResource(name, init, body) => { let rn = name.clone(); WithResource(rn, Box::new(self.expand_expr(*init.clone())?), Box::new(self.expand_expr(*body.clone())?) ) },
                    AliasDecl(name, target) => AliasDecl(name.clone(), Box::new(self.expand_expr(*target.clone())?)),
                    TestCompile(e, expect_error) => TestCompile(Box::new(self.expand_expr(*e.clone())?), *expect_error),

                    // No child expressions to expand (or handled inline above).
                    Atom(_) | Error(_) | Defn(_, _, _) | Begin(_)
                    | Lambda(_, _, _) | Fn(_, _, _) | ModuleDecl(_) | UseModule(..) | Cond(_)
                    | Deftype(_, _, _) | TraitDecl(_, _, _) | ImplBlock(_, _, _) | StructDef(_)
                    | StructDefPlus(_) | Derive(_, _) | TestSuite(_, _, _) | TestDecl(_, _, _)
                    | AssertEqual(_, _) | AssertFail(_, _) | AssertTrue(_, _) | AssertFalse(_, _)
                    | TestProperty(_, _, _) | Setup(_) | Teardown(_) | RunTests(_)
                    | MacroDef(_, _, _) => expr.inner.clone(),

                    // Remaining: Call, Apply, Export, ReadLine — handle inline.
                    _ => {
                        use ExprInner::*;
                        match &expr.inner {
                            Call(op, args) => { let no = Box::new(self.expand_expr(*op.clone())?); let na: Vec<Expr> = args.iter().map(|a| self.expand_expr(a.clone())).collect::<Result<Vec<_>, _>>()?; ExprInner::Call(no, na) }
                            Apply(name, args) => { let mut na: Vec<Expr> = Vec::with_capacity(args.len()); for a in args { na.push(self.expand_expr(a.clone())?); }; ExprInner::Apply(name.clone(), na) }
                            _ => expr.inner.clone(), // All other variants — no child expressions to expand.
                        }
                    },
                };
                expr.inner = new_inner;
            }
        }

        // Now check if this expression is a macro call (after children are expanded).
        self.try_expand(expr)
    }

    fn try_expand(&mut self, mut expr: Expr) -> Result<Expr, ZylError> {
        let (name, args) = match &expr.inner {
            ExprInner::Call(op, args) => { if let ExprInner::Atom(Atom::Ident(n)) = &op.inner { (n.clone(), args.clone()) } else { return Ok(expr); } }
            ExprInner::Apply(name, args) => { if !self.macros.contains_key(name.as_str()) && !is_macro_candidate(name) { return Ok(expr); } (name.clone(), args.clone()) }
            _ => return Ok(expr),
        };

        let mac = match self.macros.get(&name) { Some(m) => m, None => return Ok(expr) };

        // Match arguments against the macro's patterns.
        if args.len() != mac.patterns.len() && !has_variadic_pattern(&mac.patterns) {
            return Err(ZylError::E_USER_ERROR(
                expr.span.clone(), format!("macro '{}' expects {} argument(s), got {}", name, mac.patterns.len(), args.len())));
        }

        let mut bindings = IndexMap::new();
        for (i, pattern) in mac.patterns.iter().enumerate() {
            if i < args.len() {
                match match_pattern(pattern, &args[i]) {
                    Ok(b) => { for (k, v) in b { bindings.insert(k, v); } }
                    Err(()) => return Ok(expr), // Pattern didn't match — not a macro call at this site.
                }
            }
        }

        self.gensyms.reset();
        let expanded = substitute(&mac.template, &bindings, &mut self.gensyms);
        // Recursively expand the substituted expression to handle nested macros.
        self.expand_expr(expanded)
    }
}

fn has_variadic_pattern(patterns: &[Expr]) -> bool {
    patterns.iter().any(|p| matches!(&p.inner, ExprInner::Atom(Atom::Ident(n)) if n.starts_with("&")))
}

/// Extract ALL elements from a Call/Apply node as individual pattern expressions.
/// Used for defmacro's argument list where each element is one pattern expression.
fn extract_all_pattern_elements(expr: &Expr) -> Vec<Expr> {
    match &expr.inner {
        ExprInner::Call(op, args) => {
            let mut result = vec![*op.clone()];  // Include operator as first pattern
            result.extend(args.iter().cloned());
            result
        }
        ExprInner::Apply(name, args) => {
            let mut result = vec![Expr { span: Span::default(), inner: ExprInner::Atom(Atom::Ident(name.clone())) }];
            result.extend(args.iter().cloned());
            result
        }
        _ => Vec::new()
    }
}

fn is_macro_candidate(name: &str) -> bool {
    let excluded = ["+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">=", "not", "and", "or", "len", "vec", "tuple", "map", "identity", "compose"];
    !excluded.contains(&name) && name.chars().all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!'))
}
