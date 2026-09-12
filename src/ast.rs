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
    SendClosure(Box<Expr>, Box<Expr>, Vec<CaptureInfo>),
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
    FileOpen(Box<Expr>, Box<Expr>),
    FileRead(Box<Expr>, Box<Expr>),
    FileWrite(Box<Expr>, Box<Expr>),
    FileClose(Box<Expr>),
    BufAppend(Box<Expr>, Box<Expr>),
    WithResource(String, Box<Expr>, Box<Expr>),
    Deftype(String, Vec<ADTVariant>, Vec<String>, Option<String>),
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
    Requires(Box<Expr>),
    Ensures(Box<Expr>),
    Invariant(Box<Expr>),
    Recover(Box<Expr>, Vec<(String, Box<Expr>)>),
    Checkpoint(Box<Expr>),
    ContractsOff(Box<Expr>),
}

/// Capture info for send-closure: tracks captured variable names.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CaptureInfo {
    pub name: String,
    pub ssa_id: usize,
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
#[allow(clippy::enum_variant_names)]
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
            let _ = write_sexpr(f, val);
            Ok(())
        }
        ExprInner::Defn(name, params, body) => {
            write!(f, "(defn {} (", name)?;
            for (i, p) in params.iter().enumerate() {
                if i > 0 {
                    f.write_str(" ")?;
                }
                write!(f, "{}", p)?;
            }
            f.write_str(" )")?;
            let _ = write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Let(name, val, body) => {
            write!(f, "(let ({} ", name)?;
            write_sexpr(f, val)?;
            f.write_str(" ) ")?;
            let _ = write_sexpr(f, body);
            Ok(())
        }
        ExprInner::LetMut(name, val, body) => {
            write!(f, "(let-mut ({} ", name)?;
            write_sexpr(f, val)?;
            f.write_str(" ) ")?;
            let _ = write_sexpr(f, body);
            Ok(())
        }
        ExprInner::If(c, t, e) => {
            f.write_str("(if ")?;
            write_sexpr(f, c)?;
            f.write_str(" ")?;
            write_sexpr(f, t)?;
            f.write_str(" ")?;
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::TryCatch(e, name, h) => {
            f.write_str("(try ")?;
            write_sexpr(f, e)?;
            write!(f, ") (catch {} ", name)?;
            let _ = write_sexpr(f, h);
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
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::Send(a, m) => {
            f.write_str("(send ")?;
            write_sexpr(f, a)?;
            f.write_str(" ")?;
            let _ = write_sexpr(f, m);
            Ok(())
        }
        ExprInner::SendClosure(a, c, caps) => {
            f.write_str("(send-closure ")?;
            write_sexpr(f, a)?;
            f.write_str(" ")?;
            write_sexpr(f, c)?;
            for cap in caps {
                f.write_str(" ")?;
                f.write_str(&cap.name)?;
            }
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
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::FfiUnpin(e) => {
            f.write_str("(ffi-unpin ")?;
            let _ = write_sexpr(f, e);
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
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::While(c, b) => {
            f.write_str("(while ")?;
            write_sexpr(f, c)?;
            f.write_str(" ")?;
            let _ = write_sexpr(f, b);
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
            let _ = write_sexpr(f, body);
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
            for (i, p) in params.iter().enumerate() {
                if i > 0 {
                    f.write_str(" ")?;
                }
                write!(f, "{}", p)?;
            }
            f.write_str(" )")?;
            let _ = write_sexpr(f, body);
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
            let _ = write_sexpr(f, val);
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
        ExprInner::Export(n) => write!(f, "(export {})", escape_ident(n)),
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
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::Close(e) => {
            f.write_str("(close ")?;
            let _ = write_sexpr(f, e);
            Ok(())
        }
        ExprInner::FileOpen(path, mode) => {
            f.write_str("(file-open ")?;
            let _ = write_sexpr(f, path);
            f.write_str(" ")?;
            let _ = write_sexpr(f, mode);
            f.write_str(")")
        }
        ExprInner::FileRead(handle, count) => {
            f.write_str("(file-read ")?;
            let _ = write_sexpr(f, handle);
            f.write_str(" ")?;
            let _ = write_sexpr(f, count);
            f.write_str(")")
        }
        ExprInner::FileWrite(handle, data) => {
            f.write_str("(file-write ")?;
            let _ = write_sexpr(f, handle);
            f.write_str(" ")?;
            let _ = write_sexpr(f, data);
            f.write_str(")")
        }
        ExprInner::FileClose(handle) => {
            f.write_str("(file-close ")?;
            let _ = write_sexpr(f, handle);
            f.write_str(")")
        }
        ExprInner::BufAppend(dst, src) => {
            f.write_str("(buf-append ")?;
            let _ = write_sexpr(f, dst);
            f.write_str(" ")?;
            let _ = write_sexpr(f, src);
            f.write_str(")")
        }
        ExprInner::WithResource(name, init, body) => {
            write!(f, "(with-resource ({} ", name)?;
            write_sexpr(f, init)?;
            f.write_str(" ) ")?;
            let _ = write_sexpr(f, body);
            Ok(())
        }
        ExprInner::Deftype(name, variants, type_params, bound) => {
            write!(f, "(deftype {} ", name)?;
            for tp in type_params {
                f.write_str(" :param ")?;
                write!(f, "{}", escape_ident(tp))?;
            }
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
                for (i, p) in m.params.iter().enumerate() {
                    if i > 0 {
                        f.write_str(" ")?;
                    }
                    write!(f, "{}", p)?;
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
                escape_ident(trait_name),
                escape_ident(type_name)
            )?;
            for body in bodies {
                let DefnNode {
                    name,
                    params,
                    ref body,
                } = &body.defn;
                write!(f, "(defn {} (", escape_ident(name))?;
                for (i, p) in params.iter().enumerate() {
                    if i > 0 {
                        f.write_str(" ")?;
                    }
                    write!(f, "{}", p)?;
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
            let _ = write_sexpr(f, target);
            Ok(())
        }
        ExprInner::Derive(type_name, traits) => {
            write!(f, "(derive {} [", escape_ident(type_name))?;
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
            let _ = write_sexpr(f, body);
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
                let _ = write!(f, " ");
                write_sexpr(f, e)?;
            }
            f.write_str(")")
        }
        ExprInner::RunTests(keywords) => {
            f.write_str("(run-tests")?;
            for (k, v) in keywords {
                let _ = write!(f, " :{} ", k);
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
                let _ = write!(f, " ");
                write_sexpr(f, arg)?;
            }
            f.write_str(")")
        }
        ExprInner::MacroDef(name, patterns, template) => {
            write!(f, "(defmacro {} ", escape_ident(name))?;
            f.write_str("(")?;
            for pat in patterns {
                write_sexpr(f, pat)?;
                f.write_str(" ")?;
            }
            f.write_str(")")?;
            f.write_str(" ")?;
            let _ = write_sexpr(f, template);
            Ok(())
        }
        ExprInner::Requires(e) => {
            f.write_str("(requires ")?;
            write_sexpr(f, e)?;
            f.write_str(")")
        }
        ExprInner::Ensures(e) => {
            f.write_str("(ensures ")?;
            write_sexpr(f, e)?;
            f.write_str(")")
        }
        ExprInner::Invariant(e) => {
            f.write_str("(invariant ")?;
            write_sexpr(f, e)?;
            f.write_str(")")
        }
        ExprInner::Recover(e, arms) => {
            f.write_str("(recover ")?;
            write_sexpr(f, e)?;
            for (err_type, fallback) in arms {
                write!(f, " ({} ", err_type)?;
                write_sexpr(f, fallback)?;
                f.write_str(")")?;
            }
            f.write_str(")")
        }
        ExprInner::Checkpoint(e) => {
            f.write_str("(checkpoint ")?;
            write_sexpr(f, e)?;
            f.write_str(")")
        }
        ExprInner::ContractsOff(e) => {
            f.write_str("(contracts off ")?;
            write_sexpr(f, e)?;
            f.write_str(")")
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
                        let _ = write!(f, " :{} ", k);
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
            let _ = write!(f, " :{} ", k);
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
pub struct PostProcessor {
    /// ADT type params: ADT name → list of type param names.
    adt_type_params: IndexMap<String, Vec<String>>,
    /// ADT variant names: ADT name → list of variant names.
    /// Used to set type_name when creating MakeVariant.
    adt_variants: IndexMap<String, Vec<String>>,
    /// (ADT name, variant name) → head type name of each field, in
    /// declared order (e.g. `EAtom Atom` → ["Atom"]). Used to disambiguate
    /// nested-pattern desugaring when a variant name is shared by more
    /// than one ADT (see `find_adt_for_variant_hinted`).
    variant_field_types: IndexMap<(String, String), Vec<String>>,
    /// Declared struct names, for make-X constructor resolution when X does
    /// not fit the PascalCase heuristic (e.g. test-prefixed `_t_Person`).
    struct_names: std::collections::BTreeSet<String>,
    /// Counter for freshly generated pattern-binding variables (nested
    /// pattern desugaring). Deterministic: same input → same names.
    /// Cell because post_process_expr only has &self.
    pattern_var_counter: std::cell::Cell<usize>,
}

impl PostProcessor {
    pub fn new() -> Self {
        Self {
            adt_type_params: IndexMap::new(),
            adt_variants: IndexMap::new(),
            variant_field_types: IndexMap::new(),
            struct_names: std::collections::BTreeSet::new(),
            pattern_var_counter: std::cell::Cell::new(0),
        }
    }

    /// Generate a deterministic fresh variable name for desugared
    /// nested-pattern bindings.
    fn fresh_pat_var(&self) -> String {
        let n = self.pattern_var_counter.get();
        self.pattern_var_counter.set(n + 1);
        format!("__match_pat_{}", n)
    }

    pub fn process(&mut self, exprs: Vec<Expr>) -> Vec<Expr> {
        // First pass: collect ADT info (type params, variant names).
        for e in &exprs {
            match &e.inner {
                ExprInner::Deftype(name, variants, _, _) => {
                    self.adt_type_params.insert(name.clone(), Vec::new());
                    let vn: Vec<String> = variants.iter().map(|v| v.name.clone()).collect();
                    self.adt_variants.insert(name.clone(), vn);
                    for v in variants {
                        let field_heads: Vec<String> =
                            v.fields.iter().map(|f| Self::type_head_name(f)).collect();
                        self.variant_field_types
                            .insert((name.clone(), v.name.clone()), field_heads);
                    }
                }
                ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                    self.struct_names.insert(sd.name.clone());
                }
                ExprInner::Call(op, args) if Self::is_ident_op(op, "defstruct") && args.len() >= 1 => {
                    if let ExprInner::Atom(Atom::Ident(n)) = &args[0].inner {
                        self.struct_names.insert(n.clone());
                    }
                }
                ExprInner::Call(op, args) if Self::is_ident_op(op, "defstruct+") && args.len() >= 1 => {
                    if let ExprInner::Atom(Atom::Ident(n)) = &args[0].inner {
                        self.struct_names.insert(n.clone());
                    }
                }
                ExprInner::Call(op, args) if Self::is_ident_op(op, "deftype") && args.len() >= 2 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let mut type_params: Vec<String> = Vec::new();
                    let mut variant_names: Vec<String> = Vec::new();
                    let mut variant_fields: Vec<(String, Vec<String>)> = Vec::new();
                    for arg in &args[1..] {
                        match &arg.inner {
                            ExprInner::Call(first, inner_args) => {
                                if let ExprInner::Atom(Atom::Ident(vname)) = &first.inner {
                                    variant_names.push(vname.clone());
                                    let field_heads: Vec<String> = inner_args
                                        .iter()
                                        .map(Self::type_head_name_expr)
                                        .collect();
                                    variant_fields.push((vname.clone(), field_heads));
                                    for item in inner_args.iter() {
                                        if let ExprInner::Atom(Atom::Ident(n)) = &item.inner {
                                            if n.chars().next().map(|c| c.is_uppercase()).unwrap_or(false) {
                                                type_params.push(n.clone());
                                            }
                                        }
                                    }
                                }
                            }
                            ExprInner::Apply(_, inner_args) => {
                                if !inner_args.is_empty() {
                                    if let ExprInner::Atom(Atom::Ident(vname)) = &inner_args[0].inner {
                                        variant_names.push(vname.clone());
                                        let field_heads: Vec<String> = inner_args[1..]
                                            .iter()
                                            .map(Self::type_head_name_expr)
                                            .collect();
                                        variant_fields.push((vname.clone(), field_heads));
                                        for item in inner_args.iter().skip(1) {
                                            if let ExprInner::Atom(Atom::Ident(n)) = &item.inner {
                                                if n.chars().next().map(|c| c.is_uppercase()).unwrap_or(false) {
                                                    type_params.push(n.clone());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            ExprInner::Atom(Atom::Ident(v)) => {
                                variant_names.push(v.clone());
                                variant_fields.push((v.clone(), Vec::new()));
                            }
                            _ => {}
                        }
                    }
                    if !type_params.is_empty() {
                        self.adt_type_params.insert(name.clone(), type_params);
                    }
                    for (vname, field_heads) in variant_fields {
                        self.variant_field_types
                            .insert((name.clone(), vname), field_heads);
                    }
                    if !variant_names.is_empty() {
                        self.adt_variants.insert(name, variant_names);
                    }
                }
                _ => {}
            }
        }
        // Second pass: process expressions.
        exprs
            .into_iter()
            .map(|e| self.post_process_expr(e))
            .collect()
    }

    /// Seed the variant map with ADT info from already-resolved dependencies.
    /// This is used by the module resolver to ensure variant constructors
    /// in a module's body get the correct adt_name.
    pub fn seed_adt_variants(&mut self, adts: &IndexMap<String, Vec<String>>) {
        for (name, variants) in adts {
            self.adt_variants.entry(name.clone()).or_insert_with(|| variants.clone());
        }
    }

    fn is_type_param(&self, name: &str) -> bool {
        self.adt_type_params.values().any(|params| params.contains(&name.to_string()))
    }

    /// Look up which ADT a variant name belongs to.
    fn find_adt_for_variant(&self, variant_name: &str) -> Option<String> {
        self.find_adt_for_variant_hinted(variant_name, None)
    }

    /// Resolve which ADT declares `variant_name`, preferring `expected_adt`
    /// when given and it's one of the declaring ADTs.
    ///
    /// Variant names are not globally unique — `Atom` and `Ast` both declare
    /// `AIdent`/`AInt`/`AFloat`/`ABool` with DIFFERENT discriminants. Without
    /// a hint, this returns the first ADT found by iteration order, which
    /// can silently resolve a nested pattern like `(EAtom (AIdent name) ...)`
    /// against the wrong type (e.g. `Ast` instead of `Atom`) — the generated
    /// match then compares a real `Atom` discriminant against `Ast`'s arm
    /// set, mismatches, and falls through to the default arm every time.
    fn find_adt_for_variant_hinted(
        &self,
        variant_name: &str,
        expected_adt: Option<&str>,
    ) -> Option<String> {
        let mut fallback = None;
        for (adt_name, variants) in &self.adt_variants {
            if variants.iter().any(|v| v == variant_name) {
                if Some(adt_name.as_str()) == expected_adt {
                    return Some(adt_name.clone());
                }
                if fallback.is_none() {
                    fallback = Some(adt_name.clone());
                }
            }
        }
        fallback
    }

    /// Head type name of a field-type expression, e.g. `Atom` → "Atom",
    /// `(List Expr)` → "List". Used only as a disambiguation hint, so a
    /// wrapper type's own name (not its inner element type) is fine.
    fn type_head_name_expr(e: &Expr) -> String {
        match &e.inner {
            ExprInner::Atom(Atom::Ident(n)) | ExprInner::Atom(Atom::Keyword(n)) => n.clone(),
            ExprInner::Call(head, _) => match &head.inner {
                ExprInner::Atom(Atom::Ident(n)) | ExprInner::Atom(Atom::Keyword(n)) => n.clone(),
                _ => String::new(),
            },
            ExprInner::Apply(n, _) => n.clone(),
            _ => String::new(),
        }
    }

    /// Head type name of a field-type string (from an already-parsed
    /// `ADTVariant.fields` entry), e.g. "(List Ast)" → "List".
    fn type_head_name(field_type_str: &str) -> String {
        let s = field_type_str.trim();
        let s = s.strip_prefix('(').unwrap_or(s);
        s.split_whitespace().next().unwrap_or(s).to_string()
    }

    /// Desugar nested variant patterns in a match arm into inner matches.
    ///
    /// `(match e (A-Ident (A-Int n) BODY) ...)` binds the whole nested field
    /// to a fresh variable and re-matches it:
    ///   patterns: (A-Ident __match_pat_N)
    ///   body:     (match __match_pat_N (A-Int n BODY) (Other1 (error ...)) ...)
    ///
    /// The inner match is made exhaustive by listing every other variant of
    /// the pattern's ADT with an `(error ...)` body — those arms are
    /// unreachable at runtime because the outer arm already fixed the tag,
    /// but they keep exhaustiveness checking satisfied without needing a
    /// wildcard mechanism. Desugars recursively, innermost levels first.
    /// Decompose one raw match-arm s-expression into (variant, field-patterns, body).
    ///
    /// Two surface forms are accepted, since the reader gives them different
    /// shapes depending on whether the field list is empty:
    ///   - combined:  (Variant field1 field2 ... body)
    ///       parses as Call(head=Variant-ident, args=[field1, field2, ..., body])
    ///   - wrapped:   ((Variant field1 field2 ...) body...)
    ///       parses as Call(head=(Variant field1 field2 ...)-expr, args=[body...])
    ///     because the reader treats a non-atom first element of a list as an
    ///     ordinary Call head. Here `head` is itself the field-pattern list, and
    ///     the remaining args are the body (wrapped in Begin if there's more
    ///     than one, e.g. from a `(... args)` reader that kept the trailing
    ///     forms separate).
    fn decompose_match_arm(arm_arg: &Expr) -> Option<(String, Vec<Expr>, Expr)> {
        let ExprInner::Call(head, inner) = &arm_arg.inner else {
            return None;
        };
        if inner.is_empty() {
            return None;
        }
        match &head.inner {
            ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => Some((
                v.clone(),
                inner[..inner.len() - 1].to_vec(),
                inner[inner.len() - 1].clone(),
            )),
            ExprInner::Call(..) | ExprInner::Apply(..) if inner.len() > 1 => {
                // ((Variant field*) tail-binding body) — sugar for matching
                // a list's Cons cell with the head destructured by a nested
                // variant pattern (`head` as-is) and the tail bound by the
                // extra token(s) before body, e.g.
                // `((RB n r esc) rest body)` desugars to
                // `(Cons (RB n r esc) rest body)`, letting desugar_arm_raw's
                // nested-pattern pass expand the inner RB pattern.
                let mut pats = vec![(**head).clone()];
                pats.extend(inner[..inner.len() - 1].iter().cloned());
                Some(("Cons".to_string(), pats, inner[inner.len() - 1].clone()))
            }
            ExprInner::Call(inner_head, inner_fields) => {
                let v = match &inner_head.inner {
                    ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                        v.clone()
                    }
                    _ => return None,
                };
                Some((v, inner_fields.clone(), inner[0].clone()))
            }
            ExprInner::Apply(name, inner_fields) => {
                Some((name.clone(), inner_fields.clone(), inner[0].clone()))
            }
            _ => None,
        }
    }

    fn desugar_arm_raw(&self, outer_variant: &str, pats: Vec<Expr>, body: Expr, span: &Span) -> (Vec<Expr>, Expr) {
        let mut pats = pats;
        let mut body = body;
        // Field-type hints for this variant's own fields (by position), used
        // to disambiguate a nested pattern whose head variant name is shared
        // by more than one ADT — see `find_adt_for_variant_hinted`.
        let outer_adt = self.find_adt_for_variant(outer_variant);
        let field_hints: Option<&Vec<String>> = outer_adt
            .as_ref()
            .and_then(|adt| self.variant_field_types.get(&(adt.clone(), outer_variant.to_string())));
        for i in 0..pats.len() {
            // Is pattern[i] a variant-shaped pattern? Raw form: Call/Apply
            // headed by a known variant identifier.
            let (pat_variant, pat_inner) = match &pats[i].inner {
                ExprInner::Call(head, inner) if !inner.is_empty() => {
                    match &head.inner {
                        ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                            (v.clone(), inner.clone())
                        }
                        _ => continue,
                    }
                }
                ExprInner::Apply(name, inner) if !inner.is_empty() => (name.clone(), inner.clone()),
                _ => continue,
            };
            // Only desugar when the head is a KNOWN variant (not a function call).
            let expected = field_hints.and_then(|v| v.get(i)).map(|s| s.as_str());
            let Some(pat_adt) = self.find_adt_for_variant_hinted(&pat_variant, expected) else {
                continue;
            };

            // A nested PATTERN is (Variant sub-pattern*) — every element after
            // the variant head is itself a pattern; there is no trailing body.
            let sub_pats: Vec<Expr> = pat_inner.clone();

            // Bind the field to a fresh variable.
            let fresh = self.fresh_pat_var();
            pats[i] = Expr {
                span: pats[i].span.clone(),
                inner: ExprInner::Atom(Atom::Ident(fresh.clone())),
            };
            let scrutinee = Expr {
                span: span.clone(),
                inner: ExprInner::Atom(Atom::Ident(fresh)),
            };

            // Recursively desugar deeper levels, carrying the current body
            // through as the innermost arm body.
            let (sub_pats, sub_body) =
                self.desugar_arm_raw(&pat_variant, sub_pats, body, span);
            body = sub_body;

            // Build exhaustive arms over the pattern's ADT.
            let mut arm_exprs: Vec<Expr> = Vec::new();
            if let Some((_, variants)) = self.adt_variants.iter().find(|(n, _)| n.as_str() == pat_adt) {
                for v2 in variants.clone() {
                    if v2 == pat_variant {
                        let mut inner_elems = sub_pats.clone();
                        inner_elems.push(body.clone());
                        arm_exprs.push(Expr {
                            span: span.clone(),
                            inner: ExprInner::Call(
                                Box::new(Expr {
                                    span: span.clone(),
                                    inner: ExprInner::Atom(Atom::Ident(v2)),
                                }),
                                inner_elems,
                            ),
                        });
                    } else {
                        // Unreachable alternative — error keeps types general.
                        arm_exprs.push(Expr {
                            span: span.clone(),
                            inner: ExprInner::Call(
                                Box::new(Expr {
                                    span: span.clone(),
                                    inner: ExprInner::Atom(Atom::Ident(v2)),
                                }),
                                vec![Expr {
                                    span: span.clone(),
                                    inner: ExprInner::Call(
                                        Box::new(Expr {
                                            span: span.clone(),
                                            inner: ExprInner::Atom(Atom::Ident("error".to_string())),
                                        }),
                                        vec![Expr {
                                            span: span.clone(),
                                            inner: ExprInner::Atom(Atom::Str(
                                                "match: unreachable case".to_string(),
                                            )),
                                        }],
                                    ),
                                }],
                            ),
                        });
                    }
                }
            }

            // Wrap the body: (match <fresh> <arm>...).
            let mut elems = vec![scrutinee];
            elems.extend(arm_exprs);
            body = Expr {
                span: span.clone(),
                inner: ExprInner::Call(
                    Box::new(Expr {
                        span: span.clone(),
                        inner: ExprInner::Atom(Atom::Ident("match".to_string())),
                    }),
                    elems,
                ),
            };
        }
        (pats, body)
    }

    fn post_process_expr(&self, mut expr: Expr) -> Expr {
        match &expr.inner {
            // Already-structured forms built by the parser's no-dispatch path
            // still need their children post-processed.
            ExprInner::Spawn(inner) => {
                expr.inner = ExprInner::Spawn(Box::new(self.post_process_expr((**inner).clone())));
                return expr;
            }
            ExprInner::Send(a, m) => {
                expr.inner = ExprInner::Send(
                    Box::new(self.post_process_expr((**a).clone())),
                    Box::new(self.post_process_expr((**m).clone())),
                );
                return expr;
            }
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

            // module → Unit (declaration, no-op at runtime).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "module") && args.len() == 1 => {
                expr.inner = ExprInner::Atom(Atom::Ident("Unit".into()));
            }

            // export → Unit (declaration, no-op at runtime).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "export") && args.len() == 1 => {
                expr.inner = ExprInner::Atom(Atom::Ident("Unit".into()));
            }

            // read-line → ReadLine (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "read-line") && args.is_empty() => {
                expr.inner = ExprInner::ReadLine;
            }

            // begin → Begin (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "begin") && !args.is_empty() => {
                expr.inner = ExprInner::Begin(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // defn → Defn (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "defn") && args.len() >= 3 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let params = Self::parse_params_list_inner(args.get(1));
                let body = if args.len() == 3 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::Defn(name, params, body);
            }

            // defun → Defn (Call form, alias for defn).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "defun") && args.len() >= 3 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let params = Self::parse_params_list_inner(args.get(1));
                let body = if args.len() == 3 {
                    Box::new(self.post_process_expr(args[2].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[3..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::Defn(name, params, body);
            }

            // trait → TraitDecl (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "trait") && args.len() >= 1 => {
                let trait_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let mut methods = Vec::new();
                let mut where_clause: Option<(String, String)> = None;
                for arg in &args[1..] {
                    if let ExprInner::Call(_, ref inner) = &arg.inner {
                        if inner.is_empty() {
                            continue;
                        }
                        if let ExprInner::Atom(Atom::Keyword(kw)) = &inner[0].inner {
                            if kw == "where" && inner.len() >= 3 {
                                if let (ExprInner::Atom(Atom::Ident(p)), ExprInner::Atom(Atom::Ident(t))) =
                                    (&inner[1].inner, &inner[2].inner)
                                {
                                    where_clause = Some((p.clone(), t.clone()));
                                }
                                continue;
                            }
                        }
                        let mname = match &inner[0].inner {
                            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                            _ => continue,
                        };
                        let mut mparams = Vec::new();
                        if inner.len() >= 2 {
                            if let ExprInner::Call(_, ref pexprs) = &inner[1].inner {
                                for pe in pexprs {
                                    if let ExprInner::Atom(Atom::Ident(n)) = &pe.inner {
                                        mparams.push(Param {
                                            span: Span::default(),
                                            name: n.clone(),
                                            typ: None,
                                        });
                                    }
                                }
                            }
                        }
                        let ret = inner
                            .get(2)
                            .and_then(|e| match &e.inner {
                                ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                                    Some(t.clone())
                                }
                                _ => None,
                            })
                            .unwrap_or_else(|| "Unit".into());
                        methods.push(TraitMethod {
                            name: mname,
                            params: mparams,
                            return_type: ret,
                        });
                    }
                }
                expr.inner = ExprInner::TraitDecl(trait_name, methods, where_clause);
            }

            // impl → ImplBlock (Call form). Type names are captured raw so the
            // uppercase MakeVariant heuristic cannot mangle them.
            ExprInner::Call(op, args) if Self::is_ident_op(op, "impl") && args.len() >= 3 => {
                let trait_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let type_name = match &args[1].inner {
                    ExprInner::Atom(Atom::Ident(n)) | ExprInner::Atom(Atom::Keyword(n)) => n.clone(),
                    _ => return expr,
                };
                let mut bodies = Vec::new();
                for body_expr in &args[2..] {
                    match &body_expr.inner {
                        ExprInner::Call(bop, barg) if Self::is_ident_op(bop, "defn") && barg.len() >= 2 => {
                            let bname = match &barg[0].inner {
                                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                                _ => continue,
                            };
                            let bparams = Self::parse_params_list_inner(barg.get(1));
                            let bbody = if barg.len() == 3 {
                                Box::new(self.post_process_expr(barg[2].clone()))
                            } else {
                                Box::new(Expr {
                                    span: Span::default(),
                                    inner: ExprInner::Begin(
                                        barg[2..].iter().map(|e| self.post_process_expr(e.clone())).collect(),
                                    ),
                                })
                            };
                            bodies.push(ImplBody {
                                defn: DefnNode {
                                    name: bname,
                                    params: bparams,
                                    body: bbody,
                                },
                            });
                        }
                        ExprInner::Defn(bname, bparams, bbody) => {
                            bodies.push(ImplBody {
                                defn: DefnNode {
                                    name: bname.clone(),
                                    params: bparams.clone(),
                                    body: Box::new(self.post_process_expr((**bbody).clone())),
                                },
                            });
                        }
                        _ => {}
                    }
                }
                expr.inner = ExprInner::ImplBlock(trait_name, type_name, bodies);
            }

            // deftype → Deftype (Call form with raw variant Call/Apply children).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "deftype") && args.len() >= 2 => {
                let type_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let mut variants: Vec<ADTVariant> = Vec::new();
                let mut has_bound = false;
                for arg in &args[1..] {
                    match &arg.inner {
                        ExprInner::Call(first, inner_args) => {
                            if let ExprInner::Atom(Atom::Keyword(kw)) = &first.inner {
                                if kw == "bound" && inner_args.len() >= 2 {
                                    has_bound = true;
                                }
                            } else if let ExprInner::Atom(Atom::Ident(vname)) = &first.inner {
                                let fields: Vec<String> = inner_args
                                    .iter()
                                    .filter_map(|e| match &e.inner {
                                        ExprInner::Atom(Atom::Ident(f)) => Some(f.clone()),
                                        _ => None,
                                    })
                                    .collect();
                                variants.push(ADTVariant { name: vname.clone(), fields });
                            }
                        }
                        ExprInner::Apply(name, inner_args) => {
                            let fields: Vec<String> = inner_args
                                .iter()
                                .filter_map(|e| match &e.inner {
                                    ExprInner::Atom(Atom::Ident(f)) => Some(f.clone()),
                                    _ => None,
                                })
                                .collect();
                            variants.push(ADTVariant { name: name.clone(), fields });
                        }
                        ExprInner::Atom(Atom::Ident(v)) => {
                            variants.push(ADTVariant { name: v.clone(), fields: Vec::new() });
                        }
                        _ => {}
                    }
                }
                if !has_bound {
                    expr.inner = ExprInner::Deftype(type_name, variants, Vec::new(), None);
                }
            }

            // fn → Fn (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "fn") && args.len() >= 2 => {
                let params = Self::parse_params_list_inner(args.first());
                let body = if args.len() == 2 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::Fn(String::new(), params, body);
            }

            // lambda → Lambda (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "lambda") && args.len() >= 2 => {
                let params = Self::parse_params_list_inner(args.first());
                let body = if args.len() == 2 {
                    Box::new(self.post_process_expr(args[1].clone()))
                } else {
                    Box::new(Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(args[2..].iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    })
                };
                expr.inner = ExprInner::Lambda(String::new(), params, body);
            }

            ExprInner::Apply(name, args) if name == "begin" && !args.is_empty() => {
                expr.inner = ExprInner::Begin(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // print → Print (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "print") && !args.is_empty() => {
                expr.inner = ExprInner::Print(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // print → Print (Apply form).
            ExprInner::Apply(name, args) if name == "print" && !args.is_empty() => {
                expr.inner = ExprInner::Print(
                    args.iter().map(|e| self.post_process_expr(e.clone())).collect(),
                );
            }

            // spawn → Spawn (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "spawn") && args.len() == 1 => {
                expr.inner = ExprInner::Spawn(Box::new(self.post_process_expr(args[0].clone())));
            }

            // spawn → Spawn (Apply form).
            ExprInner::Apply(name, args) if name == "spawn" && args.len() == 1 => {
                expr.inner = ExprInner::Spawn(Box::new(self.post_process_expr(args[0].clone())));
            }

            // send → Send (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "send") && args.len() == 2 => {
                expr.inner = ExprInner::Send(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // send → Send (Apply form).
            ExprInner::Apply(name, args) if name == "send" && args.len() == 2 => {
                expr.inner = ExprInner::Send(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // send-closure → SendClosure (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "send-closure") && args.len() >= 3 => {
                let actor = self.post_process_expr(args[0].clone());
                let closure = self.post_process_expr(args[1].clone());
                let caps: Vec<CaptureInfo> = args[2..]
                    .iter()
                    .map(|e| {
                        let processed = self.post_process_expr(e.clone());
                        if let ExprInner::Atom(Atom::Ident(n)) = &processed.inner {
                            CaptureInfo { name: n.clone(), ssa_id: 0 }
                        } else {
                            CaptureInfo { name: "___unnamed".to_string(), ssa_id: 0 }
                        }
                    })
                    .collect();
                expr.inner = ExprInner::SendClosure(Box::new(actor), Box::new(closure), caps);
            }

            // send-closure → SendClosure (Apply form).
            ExprInner::Apply(name, args) if name == "send-closure" && args.len() >= 3 => {
                let actor = self.post_process_expr(args[0].clone());
                let closure = self.post_process_expr(args[1].clone());
                let caps: Vec<CaptureInfo> = args[2..]
                    .iter()
                    .map(|e| {
                        let processed = self.post_process_expr(e.clone());
                        if let ExprInner::Atom(Atom::Ident(n)) = &processed.inner {
                            CaptureInfo { name: n.clone(), ssa_id: 0 }
                        } else {
                            CaptureInfo { name: "___unnamed".to_string(), ssa_id: 0 }
                        }
                    })
                    .collect();
                expr.inner = ExprInner::SendClosure(Box::new(actor), Box::new(closure), caps);
            }

            // let-mut → LetMut (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "let-mut") && args.len() >= 2 => {
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
                expr.inner = ExprInner::LetMut(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(body),
                );
            }

            // let-mut → LetMut (Apply form).
            ExprInner::Apply(name, args) if name == "let-mut" && args.len() >= 2 => {
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
                expr.inner = ExprInner::LetMut(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                    Box::new(body),
                );
            }

            // def → Def (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "def") && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::Def(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // def → Def (Apply form).
            ExprInner::Apply(name, args) if name == "def" && args.len() >= 2 => {
                let name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::Def(
                    name,
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // exit → Exit (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "exit") && args.len() == 1 => {
                expr.inner = ExprInner::Exit(Box::new(self.post_process_expr(args[0].clone())));
            }

            // exit → Exit (Apply form).
            ExprInner::Apply(name, args) if name == "exit" && args.len() == 1 => {
                expr.inner = ExprInner::Exit(Box::new(self.post_process_expr(args[0].clone())));
            }

            // close → Close (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "close") && args.len() == 1 => {
                expr.inner = ExprInner::Close(Box::new(self.post_process_expr(args[0].clone())));
            }

            // close → Close (Apply form).
            ExprInner::Apply(name, args) if name == "close" && args.len() == 1 => {
                expr.inner = ExprInner::Close(Box::new(self.post_process_expr(args[0].clone())));
            }

            // file-open → FileOpen (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "file-open") && args.len() == 2 => {
                expr.inner = ExprInner::FileOpen(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-open → FileOpen (Apply form).
            ExprInner::Apply(name, args) if name == "file-open" && args.len() == 2 => {
                expr.inner = ExprInner::FileOpen(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-read → FileRead (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "file-read") && args.len() == 2 => {
                expr.inner = ExprInner::FileRead(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-read → FileRead (Apply form).
            ExprInner::Apply(name, args) if name == "file-read" && args.len() == 2 => {
                expr.inner = ExprInner::FileRead(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-write → FileWrite (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "file-write") && args.len() == 2 => {
                expr.inner = ExprInner::FileWrite(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-write → FileWrite (Apply form).
            ExprInner::Apply(name, args) if name == "file-write" && args.len() == 2 => {
                expr.inner = ExprInner::FileWrite(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // file-close → FileClose (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "file-close") && args.len() == 1 => {
                expr.inner = ExprInner::FileClose(Box::new(self.post_process_expr(args[0].clone())));
            }

            // file-close → FileClose (Apply form).
            ExprInner::Apply(name, args) if name == "file-close" && args.len() == 1 => {
                expr.inner = ExprInner::FileClose(Box::new(self.post_process_expr(args[0].clone())));
            }

            // buf-append → BufAppend (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "buf-append") && args.len() == 2 => {
                expr.inner = ExprInner::BufAppend(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // buf-append → BufAppend (Apply form).
            ExprInner::Apply(name, args) if name == "buf-append" && args.len() == 2 => {
                expr.inner = ExprInner::BufAppend(
                    Box::new(self.post_process_expr(args[0].clone())),
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // with-resource → WithResource (Call form): (with-resource (name init) body)
            ExprInner::Call(op, args) if Self::is_ident_op(op, "with-resource") && !args.is_empty() => {
                // Binding pair (name init) — first arg is itself a Call from no-dispatch.
                if args.len() >= 2 {
                    if let ExprInner::Call(bop, bargs) = &args[0].inner {
                        if let ExprInner::Atom(Atom::Ident(n)) = &bop.inner {
                            if !bargs.is_empty() {
                                expr.inner = ExprInner::WithResource(
                                    n.clone(),
                                    Box::new(self.post_process_expr(bargs[0].clone())),
                                    Box::new(self.post_process_expr(args[1].clone())),
                                );
                                return expr;
                            }
                        }
                    }
                    // Plain (name init body) spread form.
                    if let ExprInner::Atom(Atom::Ident(n)) = &args[0].inner {
                        expr.inner = ExprInner::WithResource(
                            n.clone(),
                            Box::new(self.post_process_expr(args[1].clone())),
                            Box::new(self.post_process_expr(args[2].clone())),
                        );
                    }
                } else if let ExprInner::Atom(Atom::Ident(n)) = &args[0].inner {
                    expr.inner = ExprInner::WithResource(
                        n.clone(),
                        Box::new(self.post_process_expr(args[1].clone())),
                        Box::new(self.post_process_expr(args[2].clone())),
                    );
                }
            }

            // with-resource → WithResource (Apply form): (with-resource (name init) body)
            ExprInner::Apply(name, args) if name == "with-resource" && !args.is_empty() => {
                if args.len() >= 2 {
                    if let ExprInner::Call(bop, bargs) = &args[0].inner {
                        if let ExprInner::Atom(Atom::Ident(n)) = &bop.inner {
                            if !bargs.is_empty() {
                                expr.inner = ExprInner::WithResource(
                                    n.clone(),
                                    Box::new(self.post_process_expr(bargs[0].clone())),
                                    Box::new(self.post_process_expr(args[1].clone())),
                                );
                                return expr;
                            }
                        }
                    }
                    if let ExprInner::Atom(Atom::Ident(n)) = &args[0].inner {
                        expr.inner = ExprInner::WithResource(
                            n.clone(),
                            Box::new(self.post_process_expr(args[1].clone())),
                            Box::new(self.post_process_expr(args[2].clone())),
                        );
                    }
                }
            }

            // alias → AliasDecl (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "alias") && args.len() >= 2 => {
                let alias_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::AliasDecl(
                    alias_name,
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // alias → AliasDecl (Apply form).
            ExprInner::Apply(name, args) if name == "alias" && args.len() >= 2 => {
                let alias_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                expr.inner = ExprInner::AliasDecl(
                    alias_name,
                    Box::new(self.post_process_expr(args[1].clone())),
                );
            }

            // derive → Derive (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "derive") && args.len() >= 2 => {
                let type_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let traits: Vec<String> = args[1..]
                    .iter()
                    .filter_map(|e| match &e.inner {
                        ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                            Some(t.clone())
                        }
                        _ => None,
                    })
                    .collect();
                expr.inner = ExprInner::Derive(type_name, traits);
            }

            // derive → Derive (Apply form).
            ExprInner::Apply(name, args) if name == "derive" && args.len() >= 2 => {
                let type_name = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return expr,
                };
                let traits: Vec<String> = args[1..]
                    .iter()
                    .filter_map(|e| match &e.inner {
                        ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                            Some(t.clone())
                        }
                        _ => None,
                    })
                    .collect();
                expr.inner = ExprInner::Derive(type_name, traits);
            }

            // requires → Requires (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "requires") && !args.is_empty() => {
                expr.inner = ExprInner::Requires(Box::new(self.post_process_expr(args[0].clone())));
            }

            // requires → Requires (Apply form).
            ExprInner::Apply(name, args) if name == "requires" && !args.is_empty() => {
                expr.inner = ExprInner::Requires(Box::new(self.post_process_expr(args[0].clone())));
            }

            // ensures → Ensures (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "ensures") && !args.is_empty() => {
                expr.inner = ExprInner::Ensures(Box::new(self.post_process_expr(args[0].clone())));
            }

            // ensures → Ensures (Apply form).
            ExprInner::Apply(name, args) if name == "ensures" && !args.is_empty() => {
                expr.inner = ExprInner::Ensures(Box::new(self.post_process_expr(args[0].clone())));
            }

            // invariant → Invariant (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "invariant") && !args.is_empty() => {
                expr.inner = ExprInner::Invariant(Box::new(self.post_process_expr(args[0].clone())));
            }

            // invariant → Invariant (Apply form).
            ExprInner::Apply(name, args) if name == "invariant" && !args.is_empty() => {
                expr.inner = ExprInner::Invariant(Box::new(self.post_process_expr(args[0].clone())));
            }

            // checkpoint → Checkpoint (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "checkpoint") && !args.is_empty() => {
                expr.inner = ExprInner::Checkpoint(Box::new(self.post_process_expr(args[0].clone())));
            }

            // checkpoint → Checkpoint (Apply form).
            ExprInner::Apply(name, args) if name == "checkpoint" && !args.is_empty() => {
                expr.inner = ExprInner::Checkpoint(Box::new(self.post_process_expr(args[0].clone())));
            }

            // recover → Recover (Call form): (recover (ErrType fallback) body)
            ExprInner::Call(op, args) if Self::is_ident_op(op, "recover") && !args.is_empty() => {
                let body = Box::new(self.post_process_expr(args[0].clone()));
                let arms: Vec<(String, Box<Expr>)> = args[1..]
                    .iter()
                    .filter_map(|arm| match &arm.inner {
                        ExprInner::Call(arm_op, arm_args) if arm_args.len() == 1 => {
                            if let ExprInner::Atom(Atom::Ident(err_type)) = &arm_op.inner {
                                Some((
                                    err_type.clone(),
                                    Box::new(self.post_process_expr(arm_args[0].clone())),
                                ))
                            } else {
                                None
                            }
                        }
                        _ => None,
                    })
                    .collect();
                expr.inner = ExprInner::Recover(body, arms);
            }

            // recover → Recover (Apply form).
            ExprInner::Apply(name, args) if name == "recover" && !args.is_empty() => {
                let body = Box::new(self.post_process_expr(args[0].clone()));
                let arms: Vec<(String, Box<Expr>)> = args[1..]
                    .iter()
                    .filter_map(|arm| match &arm.inner {
                        ExprInner::Call(arm_op, arm_args) if arm_args.len() == 1 => {
                            if let ExprInner::Atom(Atom::Ident(err_type)) = &arm_op.inner {
                                Some((
                                    err_type.clone(),
                                    Box::new(self.post_process_expr(arm_args[0].clone())),
                                ))
                            } else {
                                None
                            }
                        }
                        _ => None,
                    })
                    .collect();
                expr.inner = ExprInner::Recover(body, arms);
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
                let (name, val, body_args) = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => {
                        let n = n.clone();
                        let v = if args.len() >= 2 { args[1].clone() } else { atom(Span::default(), Atom::Int(0)) };
                        (n, v, &args[2..])
                    }
                    // (let (name value) body ...) - binding tuple
                    ExprInner::Call(first, ref fields) => {
                        let n = match &first.inner {
                            ExprInner::Atom(Atom::Ident(s)) => s.clone(),
                            _ => "___let_".to_string(),
                        };
                        let v = fields.first().cloned().unwrap_or_else(|| atom(Span::default(), Atom::Int(0)));
                        (n, v, &args[1..])
                    }
                    ExprInner::Apply(first, ref fields) if !fields.is_empty() => {
                        let n = first.clone();
                        let v = fields.first().cloned().unwrap_or_else(|| atom(Span::default(), Atom::Int(0)));
                        (n, v, &args[1..])
                    }
                    _ => ("___let_".to_string(), atom(Span::default(), Atom::Int(0)), &args[1..]),
                };
                let body = if body_args.is_empty() {
                    atom(Span::default(), Atom::Keyword("___skip_".into()))
                } else if body_args.len() == 1 {
                    self.post_process_expr(body_args[0].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(body_args.iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::Let(
                    name.clone(),
                    Box::new(self.post_process_expr(val)),
                    Box::new(body),
                );
            }

            // let → Let (Apply form).
            ExprInner::Apply(name, args) if name == "let" && args.len() >= 2 => {
                // Handle both (let name value body) and (let (name value) body) forms.
                let (name, val, body_args) = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => {
                        let n = n.clone();
                        let v = if args.len() >= 2 { args[1].clone() } else { atom(Span::default(), Atom::Int(0)) };
                        (n, v, &args[2..])
                    }
                    ExprInner::Call(first, ref fields) if !fields.is_empty() => {
                        let n = match &first.inner {
                            ExprInner::Atom(Atom::Ident(s)) => s.clone(),
                            _ => "___let_".to_string(),
                        };
                        let v = fields.first().cloned().unwrap_or_else(|| atom(Span::default(), Atom::Int(0)));
                        (n, v, &args[1..])
                    }
                    ExprInner::Apply(first, ref fields) if !fields.is_empty() => {
                        // Apply("name", [value]) — first is the name string directly.
                        let n = first.clone();
                        let v = fields.first().cloned().unwrap_or_else(|| atom(Span::default(), Atom::Int(0)));
                        (n, v, &args[1..])
                    }
                    _ => ("___let_".to_string(), atom(Span::default(), Atom::Int(0)), &args[1..]),
                };
                let body = if body_args.is_empty() {
                    atom(Span::default(), Atom::Keyword("___skip_".into()))
                } else if body_args.len() == 1 {
                    self.post_process_expr(body_args[0].clone())
                } else {
                    Expr {
                        span: Span::default(),
                        inner: ExprInner::Begin(body_args.iter().map(|e| self.post_process_expr(e.clone())).collect()),
                    }
                };
                expr.inner = ExprInner::Let(
                    name,
                    Box::new(self.post_process_expr(val)),
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
                // Parse init-bindings: args[0] should be a list of (name [value]) pairs.
                // With no_dispatch, (i 0) becomes Call(Ident("i"), [0]).
                // Multiple bindings ((i 0) (j 10)) becomes Call(Call(Ident("i"), [0]), [Call(Ident("j"), [10])]).
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
                                vec![(n.clone(), None)]
                            } else if inner_args.len() == 1 {
                                vec![(n.clone(), Some(Box::new(self.post_process_expr(inner_args[0].clone()))))]
                            } else {
                                Vec::new()
                            }
                        } else {
                            Vec::new()
                        }
                    }
                    ExprInner::Call(first_pair, rest_pairs) => {
                        // Multiple bindings: ((i 0) (j 10) ...) - first_pair is (i 0), rest_pairs is [(j 10), ...]
                        let mut result = Vec::new();
                        // Process first pair
                        if let ExprInner::Call(op2, args2) = &first_pair.inner {
                            if let ExprInner::Atom(Atom::Ident(n)) = &op2.inner {
                                if args2.len() == 1 {
                                    result.push((n.clone(), Some(Box::new(self.post_process_expr(args2[0].clone())))));
                                } else if args2.is_empty() {
                                    result.push((n.clone(), None));
                                }
                            }
                        }
                        // Process remaining pairs
                        for pair in rest_pairs {
                            if let ExprInner::Call(op3, args3) = &pair.inner {
                                if let ExprInner::Atom(Atom::Ident(n)) = &op3.inner {
                                    if args3.len() == 1 {
                                        result.push((n.clone(), Some(Box::new(self.post_process_expr(args3[0].clone())))));
                                    } else if args3.is_empty() {
                                        result.push((n.clone(), None));
                                    }
                                }
                            }
                        }
                        result
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
                    ExprInner::Call(first_pair, rest_pairs) => {
                        let mut result = Vec::new();
                        if let ExprInner::Call(op2, args2) = &first_pair.inner {
                            if let ExprInner::Atom(Atom::Ident(n)) = &op2.inner {
                                if args2.len() == 1 {
                                    result.push((n.clone(), Some(Box::new(self.post_process_expr(args2[0].clone())))));
                                } else if args2.is_empty() {
                                    result.push((n.clone(), None));
                                }
                            }
                        }
                        for pair in rest_pairs {
                            if let ExprInner::Call(op3, args3) = &pair.inner {
                                if let ExprInner::Atom(Atom::Ident(n)) = &op3.inner {
                                    if args3.len() == 1 {
                                        result.push((n.clone(), Some(Box::new(self.post_process_expr(args3[0].clone())))));
                                    } else if args3.is_empty() {
                                        result.push((n.clone(), None));
                                    }
                                }
                            }
                        }
                        result
                    }
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
                                Box::new(Self::cond_test_expr((**first).clone())),
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
                                Box::new(Self::cond_test_expr(inner[0].clone())),
                                Box::new(Expr {
                                    span: Span::default(),
                                    inner: ExprInner::Begin(inner[1..].to_vec()),
                                })
                            )
                        } else {
                            // Fallback: entire arm is the condition, empty body.
                            (Box::new(Self::cond_test_expr(a.clone())), Box::new(atom(Span::default(), Atom::Int(0))))
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
                                Box::new(Self::cond_test_expr((**first).clone())),
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
                                Box::new(Self::cond_test_expr(inner[0].clone())),
                                Box::new(Expr {
                                    span: Span::default(),
                                    inner: ExprInner::Begin(inner[1..].to_vec()),
                                })
                            )
                        } else {
                            (Box::new(Self::cond_test_expr(a.clone())), Box::new(atom(Span::default(), Atom::Int(0))))
                        }
                    })
                    .collect();
                expr.inner = ExprInner::Cond(clauses);
            }

            // try → TryCatch (Call form, 3+ args: try expr catch_name body).
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

            // try → TryCatch (Call form, 2 args: try expr (catch name body)).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "try") && args.len() == 2 => {
                let (catch_name, catch_body) = match &args[1].inner {
                    ExprInner::Call(target, inner) if Self::is_ident_op(target, "catch") && inner.len() >= 2 => {
                        let name = match &target.inner {
                            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                            _ => "___catch_".to_string(),
                        };
                        (name, inner[1].clone())
                    }
                    ExprInner::Apply(_name, inner) if _name == "catch" && inner.len() >= 2 => {
                        let name = match &inner[0].inner {
                            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                            _ => "___catch_".to_string(),
                        };
                        (name, inner[1].clone())
                    }
                    _ => return expr,
                };
                expr.inner = ExprInner::TryCatch(
                    Box::new(self.post_process_expr(args[0].clone())),
                    catch_name,
                    Box::new(self.post_process_expr(catch_body)),
                );
            }

            // try → TryCatch (Apply form, 3+ args: try expr catch_name body).
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

            // try → TryCatch (Apply form, 2 args: try expr (catch name body)).
            ExprInner::Apply(name, args) if name == "try" && args.len() == 2 => {
                let (catch_name, catch_body) = match &args[1].inner {
                    ExprInner::Call(target, inner) if Self::is_ident_op(target, "catch") && inner.len() >= 2 => {
                        let name = match &target.inner {
                            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                            _ => "___catch_".to_string(),
                        };
                        (name, inner[1].clone())
                    }
                    ExprInner::Apply(_n, inner) if _n == "catch" && inner.len() >= 2 => {
                        let name = match &inner[0].inner {
                            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                            _ => "___catch_".to_string(),
                        };
                        (name, inner[1].clone())
                    }
                    _ => return expr,
                };
                expr.inner = ExprInner::TryCatch(
                    Box::new(self.post_process_expr(args[0].clone())),
                    catch_name,
                    Box::new(self.post_process_expr(catch_body)),
                );
            }

            // match → Match (Call form).
            // Spec §8.3: (match Expr (VariantName pattern* body) ...) — each arm
            // is ONE self-contained s-expression: the head names the variant,
            // middle elements are field patterns, and the last element is the
            // arm body. Arms are decomposed from the RAW form BEFORE recursive
            // post-processing, because constructor conversion would otherwise
            // collapse patterns and body into a single argument list.
            ExprInner::Call(op, args) if Self::is_ident_op(op, "match") && !args.is_empty() => {
                let e = Box::new(self.post_process_expr(args[0].clone()));
                let mut arms = Vec::new();
                for arm_arg in &args[1..] {
                    let Some((variant, pats, raw_body)) = Self::decompose_match_arm(arm_arg)
                    else {
                        return expr;
                    };
                    // Desugar nested variant patterns BEFORE post-processing.
                    let (pats, raw_body) =
                        self.desugar_arm_raw(&variant, pats, raw_body, &arm_arg.span);
                    let patterns: Vec<Expr> = pats
                        .into_iter()
                        .map(|p| self.post_process_expr(p))
                        .collect();
                    let body = self.post_process_expr(raw_body);
                    arms.push(MatchArm { variant, patterns, body: Box::new(body) });
                }
                expr.inner = ExprInner::Match(e, arms);
            }

            // match → Match (Apply form). Same self-contained arm grammar as above.
            ExprInner::Apply(name, args) if name == "match" && !args.is_empty() => {
                let e = Box::new(self.post_process_expr(args[0].clone()));
                let mut arms = Vec::new();
                for arm_arg in &args[1..] {
                    // Decompose the RAW arm before post-processing.
                    let Some((variant, pats, raw_body)) = Self::decompose_match_arm(arm_arg)
                    else {
                        return expr;
                    };
                    // Desugar nested variant patterns BEFORE post-processing.
                    let (pats, raw_body) =
                        self.desugar_arm_raw(&variant, pats, raw_body, &arm_arg.span);
                    let patterns: Vec<Expr> = pats
                        .into_iter()
                        .map(|p| self.post_process_expr(p))
                        .collect();
                    let body = self.post_process_expr(raw_body);
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
                        let is_pascal =
                            s.chars().next().map(|c| c.is_uppercase()).unwrap_or(false);
                        if is_pascal || self.struct_names.contains(s) {
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
                let is_pascal = s.chars().next().map(|c| c.is_uppercase()).unwrap_or(false);
                if is_pascal || self.struct_names.contains(s) {
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
            // Priority 1: if operator is a known ADT variant name, convert to MakeVariant
            // regardless of builtin exclusion (enables variants named Int, Bool, etc.).
            // Priority 2: uppercase heuristic for unknown names, excluding builtins.
            // Dotted names (Trait.method) are trait-method calls, never constructors.
            ExprInner::Call(first, ref args)
                if matches!(&first.inner, ExprInner::Atom(Atom::Ident(n)) if (is_uppercase_ident(n) || self.find_adt_for_variant(n).is_some()) && !n.contains('.')) =>
            {
                let variant_name = match &first.inner {
                    ExprInner::Atom(Atom::Ident(v)) => v.clone(),
                    _ => return expr,
                };
                // Check if this is a known ADT variant (priority over builtin exclusion)
                if self.find_adt_for_variant(&variant_name).is_some() {
                    let adt_name = self.find_adt_for_variant(&variant_name).unwrap_or_default();
                    let new_args: Vec<Expr> = args
                        .iter()
                        .map(|a| self.post_process_expr(a.clone()))
                        .filter(|a| !matches!(&a.inner, ExprInner::Atom(Atom::Ident(n)) if self.is_type_param(n)))
                        .collect();
                    expr.inner = ExprInner::MakeVariant(adt_name, variant_name, new_args);
                } else if !is_known_builtin_or_op(first) {
                    // Not a known variant, but passes uppercase heuristic — treat as MakeVariant
                    let adt_name = self.find_adt_for_variant(&variant_name).unwrap_or_default();
                    let new_args: Vec<Expr> = args
                        .iter()
                        .map(|a| self.post_process_expr(a.clone()))
                        .filter(|a| !matches!(&a.inner, ExprInner::Atom(Atom::Ident(n)) if self.is_type_param(n)))
                        .collect();
                    expr.inner = ExprInner::MakeVariant(adt_name, variant_name, new_args);
                }
                // else: known builtin name that's not an ADT variant — fall through to Call processing
            }

            // contracts off expr → ContractsOff (Call form).
            ExprInner::Call(op, args) if Self::is_ident_op(op, "contracts") && args.len() == 2 => {
                let mode = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(m)) => m.clone(),
                    _ => return expr,
                };
                if mode == "off" {
                    expr.inner = ExprInner::ContractsOff(Box::new(self.post_process_expr(args[1].clone())));
                }
            }

            // contracts off expr → ContractsOff (Apply form).
            ExprInner::Apply(name, args) if name == "contracts" && args.len() == 2 => {
                let mode = match &args[0].inner {
                    ExprInner::Atom(Atom::Ident(m)) => m.clone(),
                    _ => return expr,
                };
                if mode == "off" {
                    expr.inner = ExprInner::ContractsOff(Box::new(self.post_process_expr(args[1].clone())));
                }
            }

            // Recognize bare identifier variant constructors (unit variants like None).
            // Priority: if known ADT variant, convert regardless of builtin exclusion.
            // Otherwise: uppercase heuristic, excluding builtins and type parameters.
            ExprInner::Atom(Atom::Ident(ref n)) if (is_uppercase_ident(n) || self.find_adt_for_variant(n).is_some()) && !n.contains('.') => {
                if !self.is_type_param(n) {
                    if self.find_adt_for_variant(n).is_some() {
                        // Known ADT variant — convert regardless of builtin status
                        let adt_name = self.find_adt_for_variant(n).unwrap_or_default();
                        expr.inner = ExprInner::MakeVariant(adt_name, n.clone(), Vec::new());
                    } else if !is_known_builtin_or_apply(n) {
                        // Not a known variant, but passes uppercase heuristic
                        let adt_name = self.find_adt_for_variant(n).unwrap_or_default();
                        expr.inner = ExprInner::MakeVariant(adt_name, n.clone(), Vec::new());
                    }
                }
            }

            ExprInner::Apply(ref name, ref args) if (is_uppercase_ident(name) || self.find_adt_for_variant(name).is_some()) && !name.contains('.') => {
                // Skip if this name is a type parameter of any known ADT.
                if self.is_type_param(name) {
                    return expr;
                }
                if self.find_adt_for_variant(name).is_some() {
                    // Known ADT variant — convert regardless of builtin status
                    let adt_name = self.find_adt_for_variant(name).unwrap_or_default();
                    let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                    expr.inner = ExprInner::MakeVariant(adt_name, name.clone(), new_args);
                } else if !is_known_builtin_or_apply(name) {
                    // Not a known variant, but passes uppercase heuristic
                    let adt_name = self.find_adt_for_variant(name).unwrap_or_default();
                    let new_args: Vec<Expr> = args.iter().map(|a| self.post_process_expr(a.clone())).collect();
                    expr.inner = ExprInner::MakeVariant(adt_name, name.clone(), new_args);
                }
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
            ExprInner::Defn(name, params, body) => {
                let new_body = Box::new(self.post_process_expr(*body.clone()));
                expr.inner = ExprInner::Defn(name.clone(), params.clone(), new_body);
            }
            ExprInner::Lambda(_, params, body) => {
                let new_body = Box::new(self.post_process_expr(*body.clone()));
                expr.inner = ExprInner::Lambda(String::new(), params.clone(), new_body);
            }
            ExprInner::Fn(_, params, body) => {
                let new_body = Box::new(self.post_process_expr(*body.clone()));
                expr.inner = ExprInner::Fn(String::new(), params.clone(), new_body);
            }

            _ => {} // No children to process.
        }
        expr
    }

    fn is_ident_op(op: &Expr, name: &str) -> bool {
        matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
    }

    /// `else` as a `cond` clause's test is never specially recognized —
    /// it's just an ordinary (unbound) identifier, which evaluates to
    /// false at runtime, so every `(else BODY)` fallback clause in every
    /// `cond` silently never fires. Rewrite the bare identifier `else`
    /// into the literal `true`, matching standard Lisp/Scheme semantics.
    fn cond_test_expr(test: Expr) -> Expr {
        if matches!(&test.inner, ExprInner::Atom(Atom::Ident(n)) if n == "else") {
            atom(test.span.clone(), Atom::Bool(true))
        } else {
            test
        }
    }

    fn parse_params_list_inner(arg: Option<&Expr>) -> Vec<Param> {
        match arg {
            Some(e) => match &e.inner {
                ExprInner::Call(op, ref pexprs) => {
                    let mut params = Vec::new();
                    // Top-level params are spread/untyped: (a b c). Typed params use the
                    // nested form ((a Int) (b Int)) — the operator is itself a Call, which
                    // falls into the else branch and is parsed as a typed param.
                    if let ExprInner::Atom(Atom::Ident(name)) = &op.inner {
                        params.push(Param {
                            span: Span::default(),
                            name: name.clone(),
                            typ: None,
                        });
                    } else {
                        // Nested typed-pair form: ((a Int) (b Int)) — the operator is
                        // itself a (name Type) Call; treat it as the first param.
                        params.push(Self::parse_param(op));
                    }
                    for pe in pexprs {
                        params.push(Self::parse_param(pe));
                    }
                    params
                }
                ExprInner::Apply(ref name, ref args)
                    if !name.starts_with("make-")
                        && name.chars().all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!')) =>
                {
                    let mut params = Vec::new();
                    if !args.is_empty()
                        && name.chars().all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!'))
                    {
                        params.push(Param {
                            span: Span::default(),
                            name: name.clone(),
                            typ: None,
                        });
                    }
                    for pe in args {
                        params.push(Self::parse_param(pe));
                    }
                    params
                }
                ExprInner::Atom(Atom::Ident(name)) if name == "Unit" || name.is_empty() => {
                    Vec::new()
                }
                ExprInner::Atom(Atom::Ident(name)) => {
                    vec![Param {
                        span: Span::default(),
                        name: name.clone(),
                        typ: None,
                    }]
                }
                _ => Vec::new(),
            },
            None => Vec::new(),
        }
    }

    fn parse_param(e: &Expr) -> Param {
        match &e.inner {
            ExprInner::Atom(Atom::Ident(name)) => Param {
                span: e.span.clone(),
                name: name.clone(),
                typ: None,
            },
            ExprInner::Call(op, args) => {
                if let ExprInner::Atom(Atom::Ident(name)) = &op.inner {
                    let typ = if args.len() == 1 {
                        Some(Self::parse_type_expr(&args[0]))
                    } else {
                        None
                    };
                    Param {
                        span: e.span.clone(),
                        name: name.clone(),
                        typ,
                    }
                } else {
                    Param {
                        span: e.span.clone(),
                        name: String::new(),
                        typ: None,
                    }
                }
            }
            _ => Param {
                span: e.span.clone(),
                name: String::new(),
                typ: None,
            },
        }
    }

    fn parse_type_expr(e: &Expr) -> String {
        match &e.inner {
            ExprInner::Atom(Atom::Ident(name)) => name.clone(),
            _ => String::new(),
        }
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
            | "file-open" | "file-read" | "file-write" | "file-close"
            | "str" | "int" | "float" | "is-some" | "is-none" | "is-ok" | "is-err"
            // Builtin trait/primitive names that shouldn't become MakeVariant.
            | "Int" | "Float" | "Bool" | "String" | "Unit" | "Vec" | "Option" | "Result"
    )
}
