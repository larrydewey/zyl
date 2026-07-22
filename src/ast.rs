use indexmap::IndexMap;
use serde::{Deserialize, Serialize};
use std::hash::Hash;

use crate::error::Span;

/// An S-expression atom.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Atom {
    Ident(String),
    Keyword(String),
    Symbol(String),
    Int(i64),
    Float(f64),
    Bool(bool),
    Str(String),
}

impl Eq for Atom {}

impl Hash for Atom {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        std::mem::discriminant(self).hash(state);
        match self {
            Atom::Ident(s) => s.hash(state),
            Atom::Keyword(kw) => kw.hash(state),
            Atom::Symbol(sym) => sym.hash(state),
            Atom::Int(i) => i.to_ne_bytes().hash(state),
            Atom::Float(f) => f.to_bits().hash(state),
            Atom::Bool(b) => b.hash(state),
            Atom::Str(s) => s.hash(state),
        }
    }
}

/// A Zyl expression.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Expr {
    #[serde(skip)]
    pub span: Span,
    #[serde(flatten)]
    pub inner: ExprInner,
}

impl std::fmt::Display for Expr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write_sexpr(f, self)
    }
}

/// Internal expression discriminant.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ExprInner {
    Atom(Atom),
    Call(Box<Expr>, Vec<Expr>),
    Def(String, Box<Expr>),
    Defn(String, Vec<Param>, Box<Expr>),
    Let(String, Box<Expr>, Box<Expr>),
    LetMut(String, Box<Expr>, Box<Expr>),
    If(Box<Expr>, Box<Expr>, Box<Expr>),
    TryCatch(Box<Expr>, String, Box<Expr>),
    Match(Box<Expr>, Vec<MatchArm>),
    Spawn(Box<Expr>),
    Send(Box<Expr>, Box<Expr>),
    FfiCall(String, Vec<Expr>, u64),
    FfiPin(Box<Expr>),
    FfiUnpin(Box<Expr>),
    Assert(Box<Expr>, Option<String>),
    Error(String),
    Unwrap(Box<Expr>),
    While(Box<Expr>, Box<Expr>),
    For(Vec<(String, Option<Box<Expr>>)>, Box<Expr>, Box<Expr>),
    Cond(Vec<(Box<Expr>, Box<Expr>)>),
    Begin(Vec<Expr>),
    Lambda(String, Vec<Param>, Box<Expr>),
    Fn(String, Vec<Param>, Box<Expr>),
    StructGet(Box<Expr>, String),
    MakeStruct(String, Vec<Expr>),
    MakeVariant(String, String, Vec<Expr>),
    SetBang(String, Box<Expr>),
    ModuleDecl(String),
    UseModule(Vec<String>, Option<Vec<String>>, bool),
    Export(String),
    Print(Vec<Expr>),
    ReadLine,
    Exit(Box<Expr>),
    Close(Box<Expr>),
    WithResource(String, Box<Expr>, Box<Expr>),
    Deftype(String, Vec<ADTVariant>, Option<String>),
    TraitDecl(String, Vec<TraitMethod>, Option<(String, String)>),
    ImplBlock(String, String, Vec<ImplBody>),
    StructDef(StructDef),
    StructDefPlus(StructDef),
    AliasDecl(String, Box<Expr>),
    Derive(String, Vec<String>),
    TestSuite(String, Vec<TestOrSuite>, IndexMap<String, Atom>),
    TestDecl(String, Box<Expr>, IndexMap<String, Atom>),
    AssertEqual(Box<Expr>, Box<Expr>),
    AssertFail(Box<Expr>, Option<String>),
    AssertTrue(Box<Expr>, Option<String>),
    AssertFalse(Box<Expr>, Option<String>),
    TestProperty(String, Generator, Box<Expr>),
    Setup(Vec<Expr>),
    Teardown(Vec<Expr>),
    RunTests(IndexMap<String, Atom>),
    TestCompile(Box<Expr>, Option<bool>),
    Apply(String, Vec<Expr>),
    MacroDef(String, Vec<Expr>, Box<Expr>),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Param {
    #[serde(skip)]
    pub span: Span,
    pub name: String,
    pub typ: Option<String>,
}

impl std::fmt::Display for Param {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if let Some(ref t) = self.typ {
            write!(f, "({} {})", self.name, t)
        } else {
            write!(f, "{}", self.name)
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MatchArm {
    pub variant: String,
    pub patterns: Vec<Expr>,
    pub body: Box<Expr>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ADTVariant {
    pub name: String,
    pub fields: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TraitMethod {
    pub name: String,
    pub params: Vec<Param>,
    pub return_type: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ImplBody {
    pub defn: DefnNode,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DefnNode {
    pub name: String,
    pub params: Vec<Param>,
    pub body: Box<Expr>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct StructDef {
    pub name: String,
    pub fields: Vec<(String, Option<String>)>,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Generator {
    GenInt,
    GenBool,
    GenString,
    GenFloat,
}

/// A test declaration.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TestDecl {
    pub name: String,
    pub body: Box<Expr>,
    pub keywords: IndexMap<String, Atom>,
}

/// A test or nested suite inside a test-suite.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TestOrSuite {
    Test(TestDecl),
    Suite(TestSuiteNode),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TestSuiteNode {
    pub name: String,
    pub tests: Vec<TestOrSuite>,
    pub keywords: IndexMap<String, Atom>,
}

// ─── S-expression pretty printing ──────────────────────────────────────

fn write_sexpr(f: &mut std::fmt::Formatter<'_>, expr: &Expr) -> std::fmt::Result {
    match &expr.inner {
        ExprInner::Atom(atom) => write_atom(f, atom),
        ExprInner::Call(op, args) => {
            f.write_str("(")?;
            write_sexpr(f, op)?;
            for arg in args {
                f.write_str(" ")?;
                write_sexpr(f, arg)?;
            }
            f.write_str(")")
        }
        ExprInner::Def(name, val) => {
            write!(f, "(def {} ", name)?;
            write_sexpr(f, val);
            Ok(())
        }
        ExprInner::Defn(name, params, body) => {
            write!(f, "(defn {} (", name)?;
            for i in 0..params.len() {
                if i > 0 {
                    f.write_str(" ")?;
                }
                write!(f, "{}", &params[i])?;
            }
            f.write_str(" )")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Let(name, val, body) => {
            write!(f, "(let ({} ", name)?;
            write_sexpr(f, val)?;
            f.write_str(" ) ")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::LetMut(name, val, body) => {
            write!(f, "(let-mut ({} ", name)?;
            write_sexpr(f, val)?;
            f.write_str(" ) ")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::If(c, t, e) => {
            f.write_str("(if ")?;
            write_sexpr(f, c)?;
            f.write_str(" ")?;
            write_sexpr(f, t)?;
            f.write_str(" ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::TryCatch(e, name, h) => {
            f.write_str("(try ")?;
            write_sexpr(f, e)?;
            write!(f, ") (catch {} ", name)?;
            write_sexpr(f, h);
            Ok(())
        }
        ExprInner::Match(e, arms) => {
            f.write_str("(match ")?;
            write_sexpr(f, e)?;
            for arm in arms {
                write!(f, " ({})", arm.variant)?;
                for pat in &arm.patterns {
                    f.write_str(" ")?;
                    write_sexpr(f, pat)?;
                }
                f.write_str(" ")?;
                write_sexpr(f, &arm.body)?;
                f.write_str(")")?;
            }
            f.write_str(")")
        }
        ExprInner::Spawn(e) => {
            f.write_str("(spawn ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::Send(a, m) => {
            f.write_str("(send ")?;
            write_sexpr(f, a)?;
            f.write_str(" ")?;
            write_sexpr(f, m);
            Ok(())
        }
        ExprInner::FfiCall(name, args, timeout) => {
            write!(f, "(ffi-call \"{}\" ", name)?;
            for arg in args {
                f.write_str(" ")?;
                write_sexpr(f, arg)?;
            }
            write!(f, " {})", timeout)
        }
        ExprInner::FfiPin(e) => {
            f.write_str("(ffi-pin ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::FfiUnpin(e) => {
            f.write_str("(ffi-unpin ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::Assert(c, msg) => {
            f.write_str("(assert ")?;
            write_sexpr(f, c)?;
            if let Some(ref m) = msg {
                write!(f, " \"{}\"", escape_str(m))?;
            }
            f.write_str(")")
        }
        ExprInner::Error(msg) => write!(f, "(error \"{}\")", escape_str(msg)),
        ExprInner::Unwrap(e) => {
            f.write_str("(unwrap ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::While(c, b) => {
            f.write_str("(while ")?;
            write_sexpr(f, c)?;
            f.write_str(" ")?;
            write_sexpr(f, b);
            Ok(())
        }
        ExprInner::For(bindings, cond, body) => {
            write!(f, "(for (")?;
            for (i, (name, val)) in bindings.iter().enumerate() {
                if i > 0 {
                    write!(f, " ")?;
                }
                write!(f, "{}", name)?;
                if let Some(v) = val {
                    write!(f, " ")?;
                    write_sexpr(f, v)?;
                }
            }
            write!(f, ") ")?;
            write_sexpr(f, cond)?;
            f.write_str(" ")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Cond(clauses) => {
            f.write_str("(cond")?;
            for (pred, body) in clauses {
                f.write_str(" (")?;
                write_sexpr(f, pred)?;
                f.write_str(" ")?;
                write_sexpr(f, body)?;
                f.write_str(")")?;
            }
            f.write_str(")")
        }
        ExprInner::Begin(exprs) => {
            f.write_str("(begin")?;
            for e in exprs {
                f.write_str(" ")?;
                write_sexpr(f, e)?;
            }
            f.write_str(")")
        }
        ExprInner::Lambda(_, params, body) | ExprInner::Fn(_, params, body) => {
            let tag = if matches!(&expr.inner, ExprInner::Lambda(..)) {
                "lambda"
            } else {
                "fn"
            };
            write!(f, "({} (", tag)?;
            for i in 0..params.len() {
                if i > 0 {
                    f.write_str(" ")?;
                }
                write!(f, "{}", &params[i])?;
            }
            f.write_str(" )")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::StructGet(s, field) => {
            f.write_str("(struct-get ")?;
            write_sexpr(f, s)?;
            write!(f, " {})", field)
        }
        ExprInner::MakeStruct(name, args) => {
            write!(f, "(make-{} ", name)?;
            for arg in args {
                f.write_str(" ")?;
                write_sexpr(f, arg)?;
            }
            f.write_str(")")
        }
        ExprInner::MakeVariant(type_name, variant_name, args) => {
            write!(f, "({}", variant_name)?;
            for arg in args {
                f.write_str(" ")?;
                write_sexpr(f, arg)?;
            }
            f.write_str(") /* {} */")?;
            if !type_name.is_empty() {
                write!(f, " :{}", type_name)?;
            }
            f.write_str(")")
        }
        ExprInner::SetBang(name, val) => {
            write!(f, "(set! {} ", name)?;
            write_sexpr(f, val);
            Ok(())
        }
        ExprInner::ModuleDecl(n) => write!(f, "(module {})", n),
        ExprInner::UseModule(parts, syms, unsafe_) => {
            f.write_str("(use ")?;
            for p in parts {
                write!(f, "{}.", escape_ident(p))?;
            }
            if let Some(ref s) = syms {
                f.write_str("{ ")?;
                for (i, sym) in s.iter().enumerate() {
                    if i > 0 {
                        f.write_str(" ")?;
                    }
                    write!(f, "{}", escape_ident(sym))?;
                }
                f.write_str("}")?;
            } else {
                f.write_str("*")?;
            }
            if *unsafe_ {
                f.write_str(" :unsafe")?;
            }
            f.write_str(")")
        }
        ExprInner::Export(n) => write!(f, "(export {})", escape_ident(&n)),
        ExprInner::Print(exprs) => {
            f.write_str("(print")?;
            for e in exprs {
                f.write_str(" ")?;
                write_sexpr(f, e)?;
            }
            f.write_str(")")
        }
        ExprInner::ReadLine => f.write_str("(read-line)"),
        ExprInner::Exit(e) => {
            f.write_str("(exit ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::Close(e) => {
            f.write_str("(close ")?;
            write_sexpr(f, e);
            Ok(())
        }
        ExprInner::WithResource(name, init, body) => {
            write!(f, "(with-resource ({} ", name)?;
            write_sexpr(f, init)?;
            f.write_str(" ) ")?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Deftype(name, variants, bound) => {
            write!(f, "(deftype {} ", name)?;
            for v in variants {
                write!(f, "({}", escape_ident(&v.name))?;
                for fld in &v.fields {
                    f.write_str(" ")?;
                    write!(f, "{}", escape_ident(fld))?;
                }
                f.write_str(")")?;
            }
            if let Some(ref b) = bound {
                f.write_str(" :bound ")?;
                write!(f, "{}", escape_ident(b))?;
            }
            f.write_str(")")
        }
        ExprInner::TraitDecl(name, methods, where_clause) => {
            write!(f, "(trait {} ", name)?;
            for m in methods {
                write!(f, "({} (", escape_ident(&m.name))?;
                for i in 0..m.params.len() {
                    if i > 0 {
                        f.write_str(" ")?;
                    }
                    write!(f, "{}", &m.params[i])?;
                }
                write!(f, ") {})", m.return_type)?;
            }
            if let Some((param, bound)) = where_clause {
                write!(
                    f,
                    " :where ({} :{})",
                    escape_ident(param),
                    escape_ident(bound)
                )?;
            }
            f.write_str(")")
        }
        ExprInner::ImplBlock(trait_name, type_name, bodies) => {
            write!(
                f,
                "(impl {} {} ",
                escape_ident(&trait_name),
                escape_ident(type_name)
            )?;
            for body in bodies {
                let DefnNode {
                    name,
                    params,
                    ref body,
                } = &body.defn;
                write!(f, "(defn {} (", escape_ident(name))?;
                for i in 0..params.len() {
                    if i > 0 {
                        f.write_str(" ")?;
                    }
                    write!(f, "{}", &params[i])?;
                }
                f.write_str(" )")?;
                write_sexpr(f, body.as_ref())?;
                f.write_str(")")?;
            }
            f.write_str(")")
        }
        ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
            let tag = if matches!(&expr.inner, ExprInner::StructDefPlus(..)) {
                "defstruct+"
            } else {
                "defstruct"
            };
            write!(f, "({} {} ", tag, escape_ident(&sd.name))?;
            for (name, typ) in &sd.fields {
                write!(f, "({}", escape_ident(name))?;
                if let Some(ref t) = typ {
                    f.write_str(" ")?;
                    write!(f, "{}", t)?;
                }
                f.write_str(")")?;
            }
            f.write_str(")")
        }
        ExprInner::AliasDecl(name, target) => {
            write!(f, "(alias {} ", escape_ident(name))?;
            write_sexpr(f, target);
            Ok(())
        }
        ExprInner::Derive(type_name, traits) => {
            write!(f, "(derive {} [", escape_ident(&type_name))?;
            for (i, t) in traits.iter().enumerate() {
                if i > 0 {
                    f.write_str(" ")?;
                }
                write!(f, "{}", escape_ident(t))?;
            }
            f.write_str("])")
        }
        ExprInner::TestSuite(name, tests, keywords) => {
            write!(f, "(test-suite \"{}\" ", name)?;
            for test in tests {
                match test {
                    TestOrSuite::Test(t) => {
                        write!(f, "(test \"{}\"", t.name)?;
                        if !t.keywords.is_empty() {
                            for (k, v) in &t.keywords {
                                f.write_str(" :")?;
                                write!(f, "{}", k)?;
                                f.write_str(" ")?;
                                write_atom(f, v)?;
                            }
                        }
                        f.write_str(")")?;
                    }
                    TestOrSuite::Suite(ref s) => {
                        write_sexpr_test_suite(f, s)?;
                    }
                }
            }
            if !keywords.is_empty() {
                for (k, v) in keywords {
                    f.write_str(" :")?;
                    write!(f, "{}", k)?;
                    f.write_str(" ")?;
                    write_atom(f, v)?;
                }
            }
            f.write_str(")")
        }
        ExprInner::TestDecl(name, body, keywords) => {
            write!(f, "(test \"{}\" ", name)?;
            write_sexpr(f, body)?;
            if !keywords.is_empty() {
                for (k, v) in keywords {
                    f.write_str(" :")?;
                    write!(f, "{}", k)?;
                    f.write_str(" ")?;
                    write_atom(f, v)?;
                }
            }
            f.write_str(")")
        }
        ExprInner::AssertEqual(a, b) => {
            f.write_str("(assert-equal ")?;
            write_sexpr(f, a)?;
            f.write_fmt(format_args!(" {}", expr_to_string(b)))
        }
        ExprInner::AssertFail(e, msg) => {
            f.write_str("(assert-fail ")?;
            write_sexpr(f, e)?;
            if let Some(ref m) = msg {
                write!(f, " \"{}\"", escape_str(m))?;
            }
            f.write_str(")")
        }
        ExprInner::AssertTrue(e, msg) => {
            f.write_str("(assert-true ")?;
            write_sexpr(f, e)?;
            if let Some(ref m) = msg {
                write!(f, " \"{}\"", escape_str(m))?;
            }
            f.write_str(")")
        }
        ExprInner::AssertFalse(e, msg) => {
            f.write_str("(assert-false ")?;
            write_sexpr(f, e)?;
            if let Some(ref m) = msg {
                write!(f, " \"{}\"", escape_str(m))?;
            }
            f.write_str(")")
        }
        ExprInner::TestProperty(name, gen, body) => {
            let g = match gen {
                Generator::GenInt => "gen-int",
                Generator::GenBool => "gen-bool",
                Generator::GenString => "gen-string",
                Generator::GenFloat => "gen-float",
            };
            write!(f, "(test-property \"{}\" {} ", name, g)?;
            write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Setup(exprs) | ExprInner::Teardown(exprs) => {
            let tag = if matches!(&expr.inner, ExprInner::Teardown(..)) {
                "teardown"
            } else {
                "setup"
            };
            write!(f, "({}", tag)?;
            for e in exprs {
                write!(f, " ");
                write_sexpr(f, e)?;
            }
            f.write_str(")")
        }
        ExprInner::RunTests(keywords) => {
            f.write_str("(run-tests")?;
            for (k, v) in keywords {
                write!(f, " :{} ", k);
                write_atom(f, v)?;
            }
            f.write_str(")")
        }
        ExprInner::TestCompile(e, expect_error) => {
            f.write_str("(test-compile ").and(write_sexpr(f, e))?;
            if let Some(exp) = expect_error {
                write!(f, " (:expect-error {})", exp)?;
            }
            f.write_str(")")
        }
        ExprInner::Apply(name, args) => {
            write!(f, "({}", name)?;
            for arg in args {
                write!(f, " ");
                write_sexpr(f, arg)?;
            }
            f.write_str(")")
        }
        ExprInner::MacroDef(name, patterns, template) => {
            write!(f, "(defmacro {} ", escape_ident(&name))?;
            f.write_str("(")?;
            for pat in patterns {
                write_sexpr(f, pat)?;
                f.write_str(" ")?;
            }
            f.write_str(")")?;
            f.write_str(" ")?;
            write_sexpr(f, template);
            Ok(())
        }
    }
}

fn expr_to_string(expr: &Expr) -> String {
    format!("{:?}", expr.inner)
}

fn write_atom(f: &mut std::fmt::Formatter<'_>, atom: &Atom) -> std::fmt::Result {
    match atom {
        Atom::Ident(s) => write!(f, "{}", escape_ident(s)),
        Atom::Keyword(s) => write!(f, ":{}", s),
        Atom::Symbol(s) => write!(f, "~{}", s),
        Atom::Int(i) => write!(f, "{}", i),
        Atom::Float(fl) => write!(f, "{}", fl),
        Atom::Bool(b) => f.write_str(if *b { "true" } else { "false" }),
        Atom::Str(s) => write!(f, "\"{}\"", escape_str(s)),
    }
}

fn write_sexpr_test_suite(
    f: &mut std::fmt::Formatter<'_>,
    suite: &TestSuiteNode,
) -> std::fmt::Result {
    write!(f, "(test-suite \"{}\" ", suite.name)?;
    for test in &suite.tests {
        match test {
            TestOrSuite::Test(t) => {
                write!(f, "(test \"{}\"", t.name)?;
                if !t.keywords.is_empty() {
                    for (k, v) in &t.keywords {
                        write!(f, " :{} ", k);
                        write_atom(f, v)?;
                    }
                }
                f.write_str(")")?;
            }
            TestOrSuite::Suite(s) => {
                write_sexpr_test_suite(f, s)?;
            }
        }
    }
    if !suite.keywords.is_empty() {
        for (k, v) in &suite.keywords {
            write!(f, " :{} ", k);
            write_atom(f, v)?;
        }
    }
    f.write_str(")")
}

fn escape_ident(s: &str) -> String {
    if s.chars()
        .all(|c| c.is_alphanumeric() || matches!(c, '_' | '-' | '?' | '!'))
    {
        s.to_string()
    } else {
        format!("\"{}\"", s.replace('\\', "\\\\").replace('"', "\\\""))
    }
}

fn escape_str(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

// ─── Post-processor: convert raw Call/Apply special forms to specialized ExprInner variants ──

/// Convert raw "if"/"let"/etc. Call/Apply nodes into their specialized ExprInner variants
/// for clean AST output and downstream phase compatibility.
pub struct PostProcessor;

impl PostProcessor {
    pub fn new() -> Self {
        Self
    }

    pub fn process(&mut self, exprs: Vec<Expr>) -> Vec<Expr> {
        exprs
            .into_iter()
            .map(|e| self.post_process_expr(e))
            .collect()
    }

    fn post_process_expr(&self, mut expr: Expr) -> Expr {
        match &expr.inner {
            // defmacro → MacroDef.
            ExprInner::Call(op, args) if Self::is_ident_op(op, "defmacro") && args.len() >= 3 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                // The pattern list (args[1]) may be a Call from no-dispatch parsing where
                // the first element is the operator and the rest are additional args.
                // We need ALL elements: the operator + all args.
                let patterns = match &args[1].inner {
                    ExprInner::Call(first, rest) => {
                        let mut p = vec![*first.clone()];
                        p.extend(rest.iter().cloned());
                        p
                    }
                    ExprInner::Apply(name, args) => {
                        let mut p = vec![Expr {
                            span: Span::default(),
                            inner: ExprInner::Atom(Atom::Ident(name.clone())),
                        }];
                        p.extend(args.iter().cloned());
                        p
                    }
                    _ => Vec::new(),
                };
                let template = if args.len() == 3 {
                    Box::new(args[2].clone())
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].to_vec()),
                    })
                };
                expr.inner = ExprInner::MacroDef(name, patterns, template);
            }

            // begin → Begin (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "begin") && !args.is_empty() => {
                expr.inner = ExprInner::Begin(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // begin → Begin (Apply form).
            ExprInner::Apply(name, args) if name == "begin" && !args.is_empty() => {
                expr.inner = ExprInner::Begin(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // if → If (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "if") && !args.is_empty() => {
                let cond = Box::new(self.post_process_expr(args[0].clone()));
                let then_ = if args.len() > 1 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else {
                    Box::new(atom(Span::default(), Atom::Keyword("___skip_".into())))
                };
                let els = if args.len() > 2 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(atom(Span::default(), Atom::Keyword("___skip_".into())))
                };
                expr.inner = ExprInner::If(cond, then_, els);
            }

            // if → If (Apply form).
            ExprInner::Apply(name, args) if name == "if" && !args.is_empty() => {
                let cond = Box::new(self.post_process_expr(args[0].clone()));
                let then_ = if args.len() > 1 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else {
                    Box::new(atom(Span::default(), Atom::Keyword("___skip_".into())))
                };
                let els = if args.len() > 2 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(atom(Span::default(), Atom::Keyword("___skip_".into())))
                };
                expr.inner = ExprInner::If(cond, then_, els);
            }

            // let → Let (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "let") && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___let_".to_string(),
                };
                let body = if args.len() == 2 {
                    self.post_process_expr(args[1].clone())
                } else if args.len() == 3 {
                    self.post_process_expr(args[2].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::Let(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(body),
                );
            }

            // let → Let (Apply form).
            ExprInner::Apply(name, args) if name == "let" && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___let_".to_string(),
                };
                let body = if args.len() == 2 {
                    self.post_process_expr(args[1].clone())
                } else if args.len() == 3 {
                    self.post_process_expr(args[2].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::Let(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(body),
                );
            }

            // while → While (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "while") && args.len() >= 2 => {
                let body = if args.len() == 2 {
                    self.post_process_expr(args[1].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[1..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::While(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(body),
                );
            }

            // while → While (Apply form).
            ExprInner::Apply(name, args) if name == "while" && args.len() >= 2 => {
                let body = if args.len() == 2 {
                    self.post_process_expr(args[1].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[1..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::While(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(body),
                );
            }

            // for → For (Call form): (for (init-bindings) cond body)
            ExprInner::Call(op, args) if Self::is_ident_op(op, "for") && args.len() >= 3 => {
                // Parse init-bindings: args[0] should be a list of (name [value]) pairs
                // With no_dispatch, (i 0) becomes Call(Ident("i"), [0]), so we need to handle both.
                let bindings: Vec<(String, Option<Box<Expr>>)> = match &args[0].inner {
                    ExprInner::Begin(items) => items.iter().map(|item| {
                        match &item.inner {
                            ExprInner::Atom(Atom::Ident(n)) => (n.clone(), None),
                            ExprInner::Begin(sub) => {
                                if sub.len() >= 2 {
                                    if let ExprInner::Atom(Atom::Ident(n)) = &sub[0].inner {
                                        let name = n.clone();
                                        let val = Some(Box::new(self.post_process_expr(sub[1].clone())));
                                        (name, val)
                                    } else {
                                        (String::new(), None)
                                    }
                                } else {
                                    (String::new(), None)
                                }
                            }
                            _ => (String::new(), None),
                        }
                    }).collect::<Vec<_>>(),
                    ExprInner::Call(inner_op, inner_args) if matches!(&inner_op.inner, ExprInner::Atom(Atom::Ident(_))) => {
                        // Single binding pair: (name) or (name value)
                        if let ExprInner::Atom(Atom::Ident(n)) = &inner_op.inner {
                            if inner_args.is_empty() {
                                // Just a variable name
                                vec![(n.clone(), None)]
                            } else if inner_args.len() == 1 {
                                // Variable with initial value
                                vec![(n.clone(), Some(Box::new(self.post_process_expr(inner_args[0].clone()))) )]
                            } else {
                                Vec::new()
                            }
                        } else {
                            Vec::new()
                        }
                    }
                    _ => Vec::new(),
                };
                expr.inner = ExprInner::For(
                    bindings,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(self.post_process_expr(args[2].clone())),
                );
            }

            // for → For (Apply form): (for (init-bindings) cond body)
            ExprInner::Apply(name, args) if name == "for" && args.len() >= 3 => {
                let bindings: Vec<(String, Option<Box<Expr>>)> = match &args[0].inner {
                    ExprInner::Begin(items) => items.iter().map(|item| {
                        match &item.inner {
                            ExprInner::Atom(Atom::Ident(n)) => (n.clone(), None),
                            ExprInner::Begin(sub) => {
                                if sub.len() >= 2 {
                                    if let ExprInner::Atom(Atom::Ident(n)) = &sub[0].inner {
                                        let name = n.clone();
                                        let val = Some(Box::new(self.post_process_expr(sub[1].clone())));
                                        (name, val)
                                    } else {
                                        (String::new(), None)
                                    }
                                } else {
                                    (String::new(), None)
                                }
                            }
                            _ => (String::new(), None),
                        }
                    }).collect::<Vec<_>>(),
                    _ => Vec::new(),
                };
                expr.inner = ExprInner::For(
                    bindings,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(self.post_process_expr(args[2].clone())),
                );
            }

            // let-mut → LetMut (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "let-mut") && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___letmut_".to_string(),
                };
                let body = if args.len() == 2 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else if args.len() == 3 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::LetMut(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    body,
                );
            }

            // let-mut → LetMut (Apply form).
            ExprInner::Apply(name, args) if name == "let-mut" && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___letmut_".to_string(),
                };
                let body = if args.len() == 2 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else if args.len() == 3 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::LetMut(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    body,
                );
            }

            // set! → SetBang (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "set!") && args.len() == 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::SetBang(name, Box::new(self.post_process_expr(args[1].clone())));
            }

            // set! → SetBang (Apply form).
            ExprInner::Apply(name, args) if name == "set!" && args.len() == 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::SetBang(name, Box::new(self.post_process_expr(args[1].clone())));
            }

            // cond → Cond (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "cond") && !args.is_empty() => {
                let clauses: Vec<(Box<Expr>, Box<Expr>)> = args
                    .iter()
                    .map(|a| {
                        let a = self.post_process_expr(a.clone());
                        // Call from parse_list: first element = condition, rest = body.
                        if let ExprInner::Call(first, rest) = &a.inner {
                            (
                                first.clone(),
                                if rest.is_empty() {
                                    Box::new(atom(Span::default(), Atom::Int(0)))
                                } else {
                                    Box::new(Expr {
                                        span: Span::default(),
                                        inner: ExprInner::Begin(rest.clone()),
                                    })
                                }
                            )
                        } else if let ExprInner::Apply(_, ref inner) = &a.inner {
                            (
                                Box::new(inner[0].clone()),
                                Box::new(Expr {
                                    span: Span::default(),
                                    inner: ExprInner::Begin(inner[1..].to_vec()),
                                })
                            )
                        } else {
                            // Fallback: entire arm is the condition, empty body.
                            (a.into(), Box::new(atom(Span::default(), Atom::Int(0))))
                        }
                    })
                    .collect();
                expr.inner = ExprInner::Cond(clauses);
            }

            // cond → Cond (Apply form).
            ExprInner::Apply(name, args) if name == "cond" && !args.is_empty() => {
                let clauses: Vec<(Box<Expr>, Box<Expr>)> = args
                    .iter()
                    .map(|a| {
                        let a = self.post_process_expr(a.clone());
                        if let ExprInner::Call(first, rest) = &a.inner {
                            (
                                first.clone(),
                                if rest.is_empty() {
                                    Box::new(atom(Span::default(), Atom::Int(0)))
                                } else {
                                    Box::new(Expr {
                                        span: Span::default(),
                                        inner: ExprInner::Begin(rest.clone()),
                                    })
                                }
                            )
                        } else if let ExprInner::Apply(_, ref inner) = &a.inner {
                            (
                                Box::new(inner[0].clone()),
                                Box::new(Expr {
                                    span: Span::default(),
                                    inner: ExprInner::Begin(inner[1..].to_vec()),
                                })
                            )
                        } else {
                            (a.into(), Box::new(atom(Span::default(), Atom::Int(0))))
                        }
                    })
                    .collect();
                expr.inner = ExprInner::Cond(clauses);
            }

            // try → TryCatch (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "try") && args.len() >= 3 => {
                let catch_name = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___catch_".to_string(),
                };
                expr.inner = ExprInner::TryCatch(
                    Box::new(self.post_process_expr(args[0].clone())),
                    catch_name,
                    Box::new(self.post_process_expr(args[2].clone())),
                );
            }

            // try → TryCatch (Apply form).
            ExprInner::Apply(name, args) if name == "try" && args.len() >= 3 => {
                let catch_name = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => "___catch_".to_string(),
                };
                expr.inner = ExprInner::TryCatch(
                    Box::new(self.post_process_expr(args[0].clone())),
                    catch_name,
                    Box::new(self.post_process_expr(args[2].clone())),
                );
            }

            // match → Match (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "match") && !args.is_empty() => {
                let e = Box::new(self.post_process_expr(args[0].clone()));
                let mut arms = Vec::new();
                let mut i = 1;
                while i < args.len() {
                    let processed = self.post_process_expr(args[i].clone());
                    let (variant, patterns) = match &processed.inner {
                        ExprInner::Call(_, ref inner) if !inner.is_empty() => {
                            let v = match &inner[0].inner {
                                ExprInner::Atom(Atom::Ident(v))
                                | ExprInner::Atom(Atom::Keyword(v)) => v.clone(),
                                _ => "___".to_string(),
                            };
                            let pats = match inner.len() {
                                1 => Vec::new(),
                                2 => vec![inner[1].clone()],
                                _ => inner[1..inner.len() - 1].to_vec(),
                            };
                            (v, pats)
                        }
                        ExprInner::MakeVariant(_, vname, ref fargs) => {
                            (vname.clone(), fargs.clone())
                        }
                        ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                            (v.clone(), Vec::new())
                        }
                        _ => ("___".to_string(), Vec::new()),
                    };
                    i += 1;
                    let body = if i < args.len() {
                        self.post_process_expr(args[i].clone())
                    } else {
                        return expr;
                    };
                    i += 1;
                    arms.push(MatchArm { variant, patterns, body: Box::new(body) });
                }
                expr.inner = ExprInner::Match(e, arms);
            }

            // match → Match (Apply form).
            ExprInner::Apply(name, args) if name == "match" && !args.is_empty() => {
                let e = Box::new(self.post_process_expr(args[0].clone()));
                let mut arms = Vec::new();
                let mut i = 1;
                while i < args.len() {
                    let processed = self.post_process_expr(args[i].clone());
                    let (variant, patterns) = match &processed.inner {
                        ExprInner::Call(_, ref inner) if !inner.is_empty() => {
                            let v = match &inner[0].inner {
                                ExprInner::Atom(Atom::Ident(v))
                                | ExprInner::Atom(Atom::Keyword(v)) => v.clone(),
                                _ => "___".to_string(),
                            };
                            let pats = match inner.len() {
                                1 => Vec::new(),
                                2 => vec![inner[1].clone()],
                                _ => inner[1..inner.len() - 1].to_vec(),
                            };
                            (v, pats)
                        }
                        ExprInner::MakeVariant(_, vname, ref fargs) => {
                            (vname.clone(), fargs.clone())
                        }
                        ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                            (v.clone(), Vec::new())
                        }
                        _ => ("___".to_string(), Vec::new()),
                    };
                    i += 1;
                    let body = if i < args.len() {
                        self.post_process_expr(args[i].clone())
                    } else {
                        return expr;
                    };
                    i += 1;
                    arms.push(MatchArm { variant, patterns, body: Box::new(body) });
                }
                expr.inner = ExprInner::Match(e, arms);
            }

            // make-StructName → MakeStruct (Call form from no-dispatch parsing).
            // Only convert if struct name starts with uppercase (PascalCase heuristic).
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if n.starts_with("make-"))
                    && !args.is_empty() =>
            {
                let struct_name = match &first.inner {
                    ExprInner::Atom(Atom::Ident(n)) => {
                        let s = &n[5..];
                        if s.chars().next().map(|c| c.is_uppercase()).unwrap_or(false) {
                            s.to_string()
                        } else {
                            return expr;
                        }
                    }
                    _ => return expr,
                };
                let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                expr.inner = ExprInner::MakeStruct(struct_name, new_args);
            }

            // make-StructName → MakeStruct (Apply form).
            // Only convert if struct name starts with uppercase.
            ExprInner::Apply(name, args) if name.starts_with("make-") && !args.is_empty() => {
                let s = &name[5..];
                if s.chars().next().map(|c| c.is_uppercase()).unwrap_or(false) {
                    let struct_name = s.to_string();
                    let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                    expr.inner = ExprInner::MakeStruct(struct_name, new_args);
                }
            }

            // struct-get → StructGet (Call form).
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if n == "struct-get")
                    && args.len() >= 2 =>
            {
                let struct_expr = Box::new(self.post_process_expr(args[0].clone()));
                let field = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(f)) | ExprInner::Atom(Atom::Str(f)) => f.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::StructGet(struct_expr, field);
            }

            // struct-get → StructGet (Apply form).
            ExprInner::Apply(name, args) if name == "struct-get" && args.len() >= 2 => {
                let struct_expr = Box::new(self.post_process_expr(args[0].clone()));
                let field = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(f)) | ExprInner::Atom(Atom::Str(f)) => f.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::StructGet(struct_expr, field);
            }

            // defstruct → StructDef (Call form from no-dispatch parsing).
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if n == "defstruct")
                    && args.len() >= 2 =>
            {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(nm)) => nm.clone(),
                    _ => return expr,
                };
                let fields: Vec<(String, Option<String>)> = args[1..]
                    .iter()
                    .map(|f| {
                        let fname = match &f.inner {
                            ExprInner::Call(op, _) => {
                                if let ExprInner::Atom(Atom::Ident(fn_)) = &op.inner {
                                    fn_.clone()
                                } else {
                                    "___".to_string()
                                }
                            }
                            ExprInner::Atom(Atom::Ident(fn_)) => fn_.clone(),
                            _ => "___".to_string(),
                        };
                        (fname, None)
                    })
                    .collect();
                expr.inner = ExprInner::StructDef(StructDef { name, fields });
            }

            // defstruct+ → StructDefPlus (Call form).
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if n == "defstruct+")
                    && args.len() >= 2 =>
            {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(nm)) => nm.clone(),
                    _ => return expr,
                };
                let fields: Vec<(String, Option<String>)> = args[1..]
                    .iter()
                    .map(|f| {
                        let fname = match &f.inner {
                            ExprInner::Call(op, _) => {
                                if let ExprInner::Atom(Atom::Ident(fn_)) = &op.inner {
                                    fn_.clone()
                                } else {
                                    "___".to_string()
                                }
                            }
                            ExprInner::Atom(Atom::Ident(fn_)) => fn_.clone(),
                            _ => "___".to_string(),
                        };
                        (fname, None)
                    })
                    .collect();
                expr.inner = ExprInner::StructDefPlus(StructDef { name, fields });
            }

            // defstruct → StructDef (Apply form).
            ExprInner::Apply(name, args) if name == "defstruct" && args.len() >= 2 => {
                let sname = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(nm)) => nm.clone(),
                    _ => return expr,
                };
                let fields: Vec<(String, Option<String>)> = args[1..]
                    .iter()
                    .map(|f| {
                        let fname = match &f.inner {
                            ExprInner::Call(op, _) => {
                                if let ExprInner::Atom(Atom::Ident(fn_)) = &op.inner {
                                    fn_.clone()
                                } else {
                                    "___".to_string()
                                }
                            }
                            ExprInner::Atom(Atom::Ident(fn_)) => fn_.clone(),
                            _ => "___".to_string(),
                        };
                        (fname, None)
                    })
                    .collect();
                expr.inner = ExprInner::StructDef(StructDef { name: sname, fields });
            }

            // defstruct+ → StructDefPlus (Apply form).
            ExprInner::Apply(name, args) if name == "defstruct+" && args.len() >= 2 => {
                let sname = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(nm)) => nm.clone(),
                    _ => return expr,
                };
                let fields: Vec<(String, Option<String>)> = args[1..]
                    .iter()
                    .map(|f| {
                        let fname = match &f.inner {
                            ExprInner::Call(op, _) => {
                                if let ExprInner::Atom(Atom::Ident(fn_)) = &op.inner {
                                    fn_.clone()
                                } else {
                                    "___".to_string()
                                }
                            }
                            ExprInner::Atom(Atom::Ident(fn_)) => fn_.clone(),
                            _ => "___".to_string(),
                        };
                        (fname, None)
                    })
                    .collect();
                expr.inner = ExprInner::StructDefPlus(StructDef { name: sname, fields });
            }

            // Recognize variant constructor calls: (Some x y ...) or unit variants like None.
            // Heuristic: operator starts with uppercase letter AND is not a known builtin/op.
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if is_uppercase_ident(n))
                    && !is_known_builtin_or_op(first) =>
            {
                let variant_name = match &first.inner {
                    ExprInner::Atom(Atom::Ident(v)) => v.clone(),
                    _ => return expr,
                };
                let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                expr.inner = ExprInner::MakeVariant(String::new(), variant_name, new_args);
            }

            // Recognize bare identifier variant constructors (unit variants like None).
            ExprInner::Atom(Atom::Ident(n)) if is_uppercase_ident(n) && !is_known_builtin_or_apply(n) => {
                expr.inner = ExprInner::MakeVariant(String::new(), n.clone(), Vec::new());
            }

            ExprInner::Apply(name, ref args) if is_uppercase_ident(&name) && !is_known_builtin_or_apply(&name) => {
                let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                expr.inner = ExprInner::MakeVariant(String::new(), name.clone(), new_args);
            }

            // Recursively process children of Call/Apply nodes.
            ExprInner::Call(op, args) => {
                let new_op = Box::new(self.post_process_expr(*op.clone()));
                let new_args: Vec<Expr> = args
                    .iter()
                    .map(|a| self.post_process_expr(a.clone()))
                    .collect();
                expr.inner = ExprInner::Call(new_op, new_args);
            }
            ExprInner::Apply(name, args) => {
                let new_args: Vec<Expr> = args
                    .iter()
                    .map(|a| self.post_process_expr(a.clone()))
                    .collect();
                expr.inner = ExprInner::Apply(name.clone(), new_args);
            }

            // Other specialized forms — process children.
            ExprInner::Def(_, val) => {
                expr.inner = ExprInner::Def(
                    match &expr.inner {
                        ExprInner::Def(n, _) => n.clone(),
                        _ => unreachable!(),
                    },
                    Box::new(self.post_process_expr(*val.clone())),
                );
            }
            ExprInner::LetMut(name, val, body) => {
                expr.inner = ExprInner::LetMut(
                    name.clone(),
                    Box::new(self.post_process_expr(*val.clone())),
                    Box::new(self.post_process_expr(*body.clone())),
                );
            }
            ExprInner::MakeVariant(type_name, variant_name, args) => {
                let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                expr.inner = ExprInner::MakeVariant(type_name.clone(), variant_name.clone(), new_args);
            }
            ExprInner::TryCatch(e, name, h) => {
                expr.inner = ExprInner::TryCatch(
                    Box::new(self.post_process_expr(*e.clone())),
                    name.clone(),
                    Box::new(self.post_process_expr(*h.clone())),
                );
            }
            ExprInner::If(cond, then_, else_) => {
                expr.inner = ExprInner::If(
                    Box::new(self.post_process_expr(*cond.clone())),
                    Box::new(self.post_process_expr(*then_.clone())),
                    Box::new(self.post_process_expr(*else_.clone())),
                );
            }
            ExprInner::Let(name, val, body) => {
                expr.inner = ExprInner::Let(
                    name.clone(),
                    Box::new(self.post_process_expr(*val.clone())),
                    Box::new(self.post_process_expr(*body.clone())),
                );
            }
            ExprInner::While(c, b) => {
                expr.inner = ExprInner::While(
                    Box::new(self.post_process_expr(*c.clone())),
                    Box::new(self.post_process_expr(*b.clone())),
                );
            }
            ExprInner::For(bindings, cond, body) => {
                let new_bindings: Vec<(String, Option<Box<Expr>>)> = bindings
                    .iter()
                    .map(|(name, val)| {
                        let new_val = val.as_ref().map(|v| Box::new(self.post_process_expr(*v.clone())));
                        (name.clone(), new_val)
                    })
                    .collect();
                expr.inner = ExprInner::For(
                    new_bindings,
                    Box::new(self.post_process_expr(*cond.clone())),
                    Box::new(self.post_process_expr(*body.clone())),
                );
            }
            ExprInner::Cond(clauses) => {
                let nc: Vec<(Box<Expr>, Box<Expr>)> = clauses
                    .iter()
                    .map(|(p, b)| {
                        (
                            Box::new(self.post_process_expr(*p.clone())),
                            Box::new(self.post_process_expr(*b.clone())),
                        )
                    })
                    .collect();
                expr.inner = ExprInner::Cond(nc);
            }
            ExprInner::Begin(exprs) => {
                let ne: Vec<Expr> = exprs
                    .iter()
                    .map(|e| self.post_process_expr(e.clone()))
                    .collect();
                expr.inner = ExprInner::Begin(ne);
            }

            _ => {} // No children to process.
        }
        expr
    }

    fn is_ident_op(op: &Expr, name: &str) -> bool {
        matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
    }
}

fn atom(span: Span, a: Atom) -> Expr {
    Expr {
        span,
        inner: ExprInner::Atom(a),
    }
}

/// Check if a name starts with an uppercase letter (PascalCase heuristic for variants/types).
fn is_uppercase_ident(name: &str) -> bool {
    name.chars().next().map(|c| c.is_uppercase()).unwrap_or(false)
}

/// Check if name is a known builtin or operator that should NOT become a MakeVariant.
fn is_known_builtin_or_op(op: &Expr) -> bool {
    if let ExprInner::Atom(Atom::Ident(n)) = &op.inner {
        is_known_builtin_or_apply(n)
    } else {
        false
    }
}

fn is_known_builtin_or_apply(name: &str) -> bool {
    matches!(
        name,
        "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "not"
            | "and" | "or" | "print" | "read-line" | "exit" | "close" | "unwrap"
            | "str" | "int" | "float" | "is-some" | "is-none" | "is-ok" | "is-err"
            // Builtin trait/primitive names that shouldn't become MakeVariant.
            | "Int" | "Float" | "Bool" | "String" | "Unit" | "Vec" | "Option" | "Result"
    )
}
