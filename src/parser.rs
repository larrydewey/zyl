use indexmap::IndexMap;

use crate::ast::*;
use crate::error::{Location, Span, ZylError};
use crate::lexer::{Token, TokenKind};

/// Reserved keywords that MUST NOT be used as identifiers in definition forms.
/// §1.3.1 — prevents shadowing core language constructs and breaking dispatch.
const RESERVED_KEYWORDS: &[&str] = &[
    // Definitions & bindings
    "def",
    "defn",
    "defun",
    "let",
    "let-mut",
    // Control flow
    "if",
    "try",
    "catch",
    "while",
    "for",
    "cond",
    "begin",
    // Closures
    "fn",
    "lambda",
    // Traits & types
    "trait",
    "impl",
    "deftype",
    "alias",
    "derive",
    // Structs
    "defstruct",
    "defstruct+",
    "struct-get",
    // FFI & concurrency
    "ffi-call",
    "ffi-pin",
    "ffi-unpin",
    "spawn",
    "send",
    // Assertions & errors
    "assert",
    "error",
    "unwrap",
    // Testing framework
    "test-suite",
    "test",
    "assert-equal",
    "assert-fail",
    "assert-true",
    "assert-false",
    "test-property",
    "setup",
    "teardown",
    "run-tests",
    "test-compile",
    // Module system
    "module",
    "use",
    "export",
    // Contracts & recovery
    "pub",
    "requires",
    "ensures",
    "invariant",
    "recover",
    "checkpoint",
    "contracts",
    // Macros
    "defmacro",
];

/// Check if an identifier is a reserved keyword. Returns error if it is.
fn check_reserved_keyword(name: &str, span: &Span) -> Result<(), ZylError> {
    if RESERVED_KEYWORDS.contains(&name) {
        return Err(ZylError::E_RESERVED_KEYWORD(span.clone(), name.to_string()));
    }
    Ok(())
}

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
    pub no_dispatch: bool,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self {
            tokens,
            pos: 0,
            no_dispatch: false,
        }
    }

    /// Parse expressions without dispatching special forms — returns raw Call/Apply nodes.
    /// Used inside defmacro argument lists so pattern variables named after special forms
    /// (e.g., `(cond body)`) don't trigger p_cond/p_if etc during initial parsing.
    pub fn parse_exprs_no_dispatch(
        &mut self,
        stop: impl FnMut(&TokenKind) -> bool,
    ) -> Result<Vec<Expr>, ZylError> {
        let mut exprs = Vec::new();
        let mut stop = stop;
        while !self.at_end() && !stop(self.peek_kind()) {
            exprs.push(self.parse_expr_no_dispatch()?);
        }
        Ok(exprs)
    }

    fn parse_expr_no_dispatch(&mut self) -> Result<Expr, ZylError> {
        let token = self.next_token()?;
        match &token.kind {
            TokenKind::RParen | TokenKind::RBrace | TokenKind::RBracket => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    token.span.clone(),
                    format!("{}", token.kind),
                ));
            }
            _ => {}
        }

        Ok(match &token.kind {
            TokenKind::LParen => self.parse_list_no_dispatch(&token)?,
            TokenKind::Ident(s) => atom_expr(token.span.clone(), Atom::Ident(s.clone())),
            TokenKind::Integer(i) => atom_expr(token.span.clone(), Atom::Int(*i)),
            TokenKind::Float(f) => atom_expr(token.span.clone(), Atom::Float(*f)),
            TokenKind::StringLit(s) => atom_expr(token.span.clone(), Atom::Str(s.clone())),
            TokenKind::Bool(b) => atom_expr(token.span.clone(), Atom::Bool(*b)),
            TokenKind::Symbol(s) => atom_expr(token.span.clone(), Atom::Symbol(s.clone())),
            TokenKind::Keyword(kw) => atom_expr(token.span.clone(), Atom::Keyword(kw.clone())),
            _ => {
                return Err(ZylError::E_UNEXPECTED_TOKEN_IN_EXPR(
                    token.span,
                    format!("{}", token.kind),
                ))
            }
        })
    }

    fn parse_list_no_dispatch(&mut self, open: &Token) -> Result<Expr, ZylError> {
        let elements = self.parse_exprs_no_dispatch(|k| matches!(k, TokenKind::RParen))?;
        self.expect_token_kind(TokenKind::RParen)?;

        if elements.is_empty() {
            return Ok(Expr {
                span: open.span.clone(),
                inner: ExprInner::Atom(Atom::Ident("Unit".into())),
            });
        }

        // No dispatch — build a raw Call node with all elements as children.
        let first = Box::new(elements[0].clone());
        let rest: Vec<Expr> = if elements.len() > 1 {
            elements.into_iter().skip(1).collect()
        } else {
            Vec::new()
        };

        Ok(Expr {
            span: open.span.clone(),
            inner: ExprInner::Call(first, rest),
        })
    }

    /// Parse expressions with normal special form dispatch.
    pub fn parse_exprs_dispatch(
        &mut self,
        stop: impl FnMut(&TokenKind) -> bool,
    ) -> Result<Vec<Expr>, ZylError> {
        let mut exprs = Vec::new();
        let mut stop = stop;
        while !self.at_end() && !stop(self.peek_kind()) {
            exprs.push(self.parse_expr()?);
        }
        Ok(exprs)
    }

    /// Parse one or more expressions until `stop` returns true.
    pub fn parse_exprs(
        &mut self,
        stop: impl FnMut(&TokenKind) -> bool,
    ) -> Result<Vec<Expr>, ZylError> {
        let mut exprs = Vec::new();
        let mut stop = stop;
        while !self.at_end() && !stop(self.peek_kind()) {
            exprs.push(self.parse_expr()?);
        }
        Ok(exprs)
    }

    pub fn parse_expr(&mut self) -> Result<Expr, ZylError> {
        let token = self.next_token()?;
        match &token.kind {
            TokenKind::RParen | TokenKind::RBrace | TokenKind::RBracket => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    token.span.clone(),
                    format!("{}", token.kind),
                ));
            }
            _ => {}
        }

        Ok(match &token.kind {
            TokenKind::LParen => self.parse_list(&token)?,
            TokenKind::Ident(s) => atom_expr(token.span.clone(), Atom::Ident(s.clone())),
            TokenKind::Integer(i) => atom_expr(token.span.clone(), Atom::Int(*i)),
            TokenKind::Float(f) => atom_expr(token.span.clone(), Atom::Float(*f)),
            TokenKind::StringLit(s) => atom_expr(token.span.clone(), Atom::Str(s.clone())),
            TokenKind::Bool(b) => atom_expr(token.span.clone(), Atom::Bool(*b)),
            TokenKind::Symbol(s) => atom_expr(token.span.clone(), Atom::Symbol(s.clone())),
            TokenKind::Keyword(kw) => atom_expr(token.span.clone(), Atom::Keyword(kw.clone())),
            _ => {
                return Err(ZylError::E_UNEXPECTED_TOKEN_IN_EXPR(
                    token.span,
                    format!("{}", token.kind),
                ))
            }
        })
    }

    fn parse_list(&mut self, open: &Token) -> Result<Expr, ZylError> {
        let elements = self.parse_exprs(|k| matches!(k, TokenKind::RParen))?;
        self.expect_token_kind(TokenKind::RParen)?;

        if elements.is_empty() {
            return Ok(Expr {
                span: open.span.clone(),
                inner: ExprInner::Atom(Atom::Ident("Unit".into())),
            });
        }

        match &elements[0].inner {
            ExprInner::Atom(Atom::Ident(name)) => self.dispatch(&open.span, name, &elements[1..]),
            _ => {
                let first = Box::new(elements[0].clone());
                let rest: Vec<Expr> = if elements.len() > 1 {
                    elements.into_iter().skip(1).collect()
                } else {
                    Vec::new()
                };
                Ok(Expr {
                    span: open.span.clone(),
                    inner: ExprInner::Call(first, rest),
                })
            }
        }
    }

    fn dispatch(&self, span: &Span, op: &str, args: &[Expr]) -> Result<Expr, ZylError> {
        eprintln!("DEBUG dispatch: op_len={}, op_bytes={:?}", op.len(), op.as_bytes());
        // Use sequential if-else to avoid type mismatch in match arms.
        macro_rules! check_arity {
            ($name:expr, $min:expr, $max:expr, $args:expr) => {{
                if !($args.len() >= $min && $args.len() <= $max) {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        Span::default(),
                        format!(
                            "{} expects {}-{} arguments, got {}",
                            $name,
                            $min,
                            $max,
                            $args.len()
                        ),
                    ));
                }
            }};
        }

        // When no_dispatch is set (inside defmacro args), return raw Call/Apply instead of dispatching.
        eprintln!("DEBUG: no_dispatch={}, op_len={}", self.no_dispatch, op.len());
        if self.no_dispatch {
            let first = Box::new(Expr {
                span: Span::default(),
                inner: ExprInner::Atom(Atom::Ident(op.to_string())),
            });
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Call(first, args.to_vec()),
            });
        }

        if op == "def" {
            eprintln!("DEBUG: def branch");
            return self.p_def(span, args);
        } else if op == "defn" || op == "defun" {
            return self.p_defn(span, args);
        } else if op == "let" {
            return self.p_let(span, false, args);
        } else if op == "let-mut" {
            return self.p_let(span, true, args);
        } else if op == "if" {
            return Ok(self.p_if(args));
        } else if op == "try" {
            return self.p_try(args);
        } else if op == "match" {
            return self.p_match(args);
        } else if op == "while" {
            return Ok(self.p_while(args));
        } else if op == "for" {
            eprintln!("DEBUG: for branch - PANICING");
            std::process::exit(42);
        } else if op == "cond" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Cond(self.p_cond(args)?),
            });
        } else if op == "begin" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Begin(args.to_vec()),
            });
        } else if op == "fn" || op == "lambda" {
            return self.p_lambda(span, op, args);
        } else if op == "defmacro" {
            return self.p_defmacro(span, args);
        }
        // Assertions & errors.
        else if op == "assert" {
            check_arity!("assert", 1, 2, args);
            let msg = if args.len() == 2 {
                Some(args[1].clone().try_string()?)
            } else {
                None
            };
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Assert(Box::new(args[0].clone()), msg),
            });
        } else if op == "error" {
            check_arity!("error", 1, 1, args);
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Error(args[0].try_string()?),
            });
        } else if op == "unwrap" {
            check_arity!("unwrap", 1, 1, args);
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Unwrap(Box::new(args[0].clone())),
            });
        }
        // Concurrency & FFI.
        else if op == "spawn" {
            check_arity!("spawn", 1, 1, args);
            return Ok(Expr {
                span: Span::default(),
                inner: ExprInner::Spawn(Box::new(args[0].clone())),
            });
        } else if op == "send" {
            check_arity!("send", 2, 2, args);
            return Ok(Expr {
                span: Span::default(),
                inner: ExprInner::Send(Box::new(args[0].clone()), Box::new(args[1].clone())),
            });
        } else if op == "ffi-call" {
            return self.p_ffi_call(span, args);
        } else if op == "ffi-pin" {
            check_arity!("ffi-pin", 1, 1, args);
            return Ok(Expr {
                span: Span::default(),
                inner: ExprInner::FfiPin(Box::new(args[0].clone())),
            });
        } else if op == "ffi-unpin" {
            check_arity!("ffi-unpin", 1, 1, args);
            return Ok(Expr {
                span: Span::default(),
                inner: ExprInner::FfiUnpin(Box::new(args[0].clone())),
            });
        }
        // Mutation & sequencing.
        else if op == "set!" {
            check_arity!("set!", 2, 2, args);
            let name = args[0].try_ident()?;
            check_reserved_keyword(&name, &args[0].span)?;
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::SetBang(name, Box::new(args[1].clone())),
            });
        } else if op == "struct-get" {
            return self.p_struct_get(span, args);
        }
        // I/O.
        else if op == "print" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Print(args.to_vec()),
            });
        } else if op == "read-line" {
            check_arity!("read-line", 0, 0, args);
            return Ok(Expr {
                span: Span::default(),
                inner: ExprInner::ReadLine,
            });
        } else if op == "exit" {
            check_arity!("exit", 1, 1, args);
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Exit(Box::new(args[0].clone())),
            });
        } else if op == "close" {
            return self.p_close(span, args);
        }
        // Resource management.
        else if op == "with-resource" {
            return self.p_with_resource(span, args);
        }
        // Type system.
        else if op == "deftype" {
            return self.p_deftype(span, args);
        } else if op == "trait" {
            return self.p_trait_decl(span, args);
        } else if op == "impl" {
            return self.p_impl_block(args);
        }
        // Structs & aliases.
        else if op == "defstruct" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::StructDef(self.p_struct_def(args)?),
            });
        } else if op == "defstruct+" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::StructDefPlus(self.p_struct_def(args)?),
            });
        } else if op == "alias" {
            return self.p_alias(span, args);
        } else if op == "derive" {
            return self.p_derive(args);
        }
        // Testing framework.
        else if op == "test-suite" {
            check_arity!("test-suite", 1, 256, args);
            let (name, tests, keywords) = self.p_test_suite(args)?;
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::TestSuite(name, tests, keywords),
            });
        } else if op == "test" {
            check_arity!("test", 2, 256, args);
            let (name, body, keywords) = self.p_test_decl(args)?;
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::TestDecl(name, body, keywords),
            });
        } else if op == "assert-equal" {
            return self.p_assert_equal(span, args);
        } else if op == "assert-fail" {
            return self.p_assert_fail(span, args);
        } else if op == "assert-true" {
            return self.p_assert_true(span, args);
        } else if op == "assert-false" {
            return self.p_assert_false(span, args);
        } else if op == "test-property" {
            return self.p_test_property(args);
        } else if op == "setup" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Setup(args.to_vec()),
            });
        } else if op == "teardown" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Teardown(args.to_vec()),
            });
        } else if op == "run-tests" {
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::RunTests(self.p_run_tests(args)?),
            });
        } else if op == "test-compile" {
            return self.p_test_compile(span, args);
        }
        // Module system.
        else if op == "module" {
            check_arity!("module", 1, 1, args);
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::ModuleDecl(args[0].try_string()?),
            });
        } else if op == "use" {
            return self.p_use(span, args);
        } else if op == "export" {
            check_arity!("export", 1, 1, args);
            let ident = args[0].try_ident()?;
            check_reserved_keyword(&ident, &args[0].span)?;
            return Ok(Expr {
                span: span.clone(),
                inner: ExprInner::Export(ident),
            });
        }
        // Built-in operations.
        else {
            return self.p_builtin(span, op, args);
        }
    }

    // ── Special form parsers (all return Result<Expr>) ────────────────

    fn p_def(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&name, &args[0].span)?;
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::Def(name, Box::new(args[1].clone())),
        })
    }

    fn p_defn(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&name, &args[0].span)?;
        let params = self.parse_params_list(args.get(1));
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::Defn(name, params, Box::new(args[2].clone())),
        })
    }

    fn p_let(&self, span: &Span, mutable: bool, args: &[Expr]) -> Result<Expr, ZylError> {
        // Handle (let name value body) format where all three are separate elements.
        if args.len() >= 3 {
            let name = match &args[0].inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        args[0].span.clone(),
                        "identifier".into(),
                    ))
                }
            };
            check_reserved_keyword(&name, &args[0].span)?;
            let val = args[1].clone();
            let body = if args.len() == 3 {
                args[2].clone()
            } else {
                // Multiple body expressions → wrap in Begin
                Expr {
                    span: span.clone(),
                    inner: ExprInner::Begin(args[2..].to_vec()),
                }
            };
            let inner = if mutable {
                ExprInner::LetMut(name, Box::new(val), Box::new(body))
            } else {
                ExprInner::Let(name, Box::new(val), Box::new(body))
            };
            return Ok(Expr {
                span: span.clone(),
                inner,
            });
        }

        // Handle (let ((name value) ...) body) format.
        if args.len() >= 2 {
            let bindings = match &args[0].inner {
                ExprInner::Call(_, ref fields) | ExprInner::Apply(_, ref fields) => fields,
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        args[0].span.clone(),
                        "binding list".into(),
                    ))
                }
            };
            if !bindings.is_empty() {
                let name = match &bindings[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_EXPECTED_EXPRESSION(
                            args[0].span.clone(),
                            "(name value)".into(),
                        ))
                    }
                };
                check_reserved_keyword(&name, &args[0].span)?;
                let val = bindings
                    .get(1)
                    .cloned()
                    .unwrap_or_else(|| atom_expr(Span::default(), Atom::Int(0)));
                // Use args[1] as body when first arg is binding list.
                let body = args[1].clone();
                let inner = if mutable {
                    ExprInner::LetMut(name, Box::new(val), Box::new(body))
                } else {
                    ExprInner::Let(name, Box::new(val), Box::new(body))
                };
                return Ok(Expr {
                    span: span.clone(),
                    inner,
                });
            }
        }

        Err(ZylError::E_EXPECTED_EXPRESSION(
            args[0].span.clone(),
            "(name value)".into(),
        ))
    }

    fn p_if(&self, args: &[Expr]) -> Expr {
        Expr {
            span: Span::default(),
            inner: ExprInner::If(
                Box::new(args[0].clone()),
                Box::new(args[1].clone()),
                Box::new(args[2].clone()),
            ),
        }
    }

    fn p_while(&self, args: &[Expr]) -> Expr {
        let body = if args.len() == 2 {
            args[1].clone()
        } else {
            Expr {
                span: Span::default(),
                inner: ExprInner::Begin(args[1..].to_vec()),
            }
        };
        Expr {
            span: Span::default(),
            inner: ExprInner::While(Box::new(args[0].clone()), Box::new(body)),
        }
    }

    fn p_try(&self, args: &[Expr]) -> Result<Expr, ZylError> {
        let catch_clause = match &args[1].inner {
            ExprInner::Call(_, ref inner) => inner,
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "(catch name expr)".into(),
                ))
            }
        };

        if !matches!(&catch_clause.first().map(|e| &e.inner), Some(ExprInner::Atom(Atom::Ident(n))) if n == "catch")
        {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                args[1].span.clone(),
                "(catch name expr)".into(),
            ));
        }

        let catch_name = match &catch_clause.get(0).map(|e| &e.inner) {
            Some(ExprInner::Atom(Atom::Ident(n))) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&catch_name, &args[1].span)?;
        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::TryCatch(
                Box::new(args[0].clone()),
                catch_name,
                Box::new(catch_clause[1].clone()),
            ),
        })
    }

    fn p_match(&self, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "match needs expr + arms".into(),
            ));
        }
        let mut arms = Vec::new();
        let mut i = 1;
        while i < args.len() {
            let pattern_arg = &args[i];
            let (variant, patterns) = match &pattern_arg.inner {
                ExprInner::Call(_, ref inner) if !inner.is_empty() => {
                    let v = match &inner[0].inner {
                        ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                            v.clone()
                        }
                        _ => {
                            return Err(ZylError::E_EXPECTED_EXPRESSION(
                                pattern_arg.span.clone(),
                                "variant".into(),
                            ))
                        }
                    };
                    let pats = match inner.len() {
                        1 => Vec::new(),
                        2 => vec![inner[1].clone()],
                        _ => inner[1..inner.len() - 1].to_vec(),
                    };
                    (v, pats)
                }
                ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                    (v.clone(), Vec::new())
                }
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        pattern_arg.span.clone(),
                        "match arm".into(),
                    ))
                }
            };
            i += 1;
            if i >= args.len() {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    pattern_arg.span.clone(),
                    "match body".into(),
                ));
            }
            let body = args[i].clone();
            i += 1;
            arms.push(MatchArm { variant, patterns, body: Box::new(body) });
        }
        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::Match(Box::new(args[0].clone()), arms),
        })
    }

    fn p_for(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        eprintln!("DEBUG p_for: args.len()={}", args.len());
        // Parse init bindings: list of (name [value]) pairs
        let bindings = match &args[0].inner {
            ExprInner::Begin(items) => {
                eprintln!("DEBUG p_for: Begin with {} items", items.len());
                items.iter().map(|item| {
                    match &item.inner {
                        ExprInner::Atom(Atom::Ident(n)) => {
                            eprintln!("DEBUG p_for: Ident {}", n);
                            (n.clone(), None)
                        }
                        ExprInner::Begin(sub) => {
                            eprintln!("DEBUG p_for: sub Begin with {} items", sub.len());
                            if sub.len() >= 2 {
                                if let ExprInner::Atom(Atom::Ident(n)) = &sub[0].inner {
                                    let name = n.clone();
                                    let val = Some(Box::new(sub[1].clone()));
                                    eprintln!("DEBUG p_for: binding {} {:?}", name, val.is_some());
                                    (name, val)
                                } else {
                                    (String::new(), None)
                                }
                            } else {
                                (String::new(), None)
                            }
                        }
                        _ => {
                            eprintln!("DEBUG p_for: other");
                            (String::new(), None)
                        }
                    }
                }).collect::<Vec<_>>()
            }
            other => {
                eprintln!("DEBUG p_for: not Begin, other discriminant");
                Vec::new()
            }
        };
        eprintln!("DEBUG p_for: final bindings count={}", bindings.len());

        if args.len() >= 3 {
            Ok(Expr {
                span: span.clone(),
                inner: ExprInner::For(
                    bindings,
                    Box::new(args[1].clone()),
                    Box::new(args[2].clone()),
                ),
            })
        } else {
            Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "for needs (init-bindings) condition body".into(),
            ))
        }
    }

    fn p_cond(&self, args: &[Expr]) -> Result<Vec<(Box<Expr>, Box<Expr>)>, ZylError> {
        let mut clauses = Vec::new();
        for arg in args {
            match &arg.inner {
                ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                    if !inner.is_empty() =>
                {
                    if inner.len() >= 2 {
                        clauses.push((
                            Box::new(inner[0].clone()),
                            Box::new(Expr {
                                span: Span::default(),
                                inner: ExprInner::Begin(inner[1..].to_vec()),
                            }),
                        ));
                    } else {
                        clauses.push((
                            Box::new(inner[0].clone()),
                            Box::new(atom_expr(Span::default(), Atom::Int(0))),
                        ));
                    }
                }
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        arg.span.clone(),
                        "cond clause".into(),
                    ))
                }
            }
        }
        Ok(clauses)
    }

    fn p_lambda(&self, span: &Span, op: &str, args: &[Expr]) -> Result<Expr, ZylError> {
        let params = self.parse_params_list(args.get(0));
        let inner = if op == "fn" {
            ExprInner::Fn("".into(), params, Box::new(args[1].clone()))
        } else {
            ExprInner::Lambda("".into(), params, Box::new(args[1].clone()))
        };
        Ok(Expr {
            span: span.clone(),
            inner,
        })
    }

    fn p_defmacro(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 3 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "defmacro needs name + patterns + template".into(),
            ));
        }

        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&name, &args[0].span)?;

        // args[1] is the patterns list (Call/Apply).
        let patterns = match &args[1].inner {
            ExprInner::Call(_, ref p) | ExprInner::Apply(_, ref p) => p.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "patterns list".into(),
                ))
            }
        };

        // args[2..] is the template — if multiple expressions, wrap in Begin.
        let template = if args.len() == 3 {
            Box::new(args[2].clone())
        } else {
            Box::new(Expr {
                span: Span::default(),
                inner: ExprInner::Begin(args[2..].to_vec()),
            })
        };

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::MacroDef(name, patterns, template),
        })
    }

    fn p_ffi_call(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "ffi-call needs name + args + timeout".into(),
            ));
        }

        let ffi_name = match &args[0].inner {
            ExprInner::Atom(Atom::Str(s)) => s.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "string (name)".into(),
                ))
            }
        };
        let last = args.last().unwrap();
        let timeout = match &last.inner {
            ExprInner::Atom(Atom::Int(t)) => *t as u64,
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    last.span.clone(),
                    "integer (timeout)".into(),
                ))
            }
        };

        let ffi_args = if args.len() > 2 {
            args[1..args.len() - 1].to_vec()
        } else {
            Vec::new()
        };
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::FfiCall(ffi_name, ffi_args, timeout),
        })
    }

    fn p_struct_get(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "struct-get needs struct + field".into(),
            ));
        }
        let field = match &args[1].inner {
            ExprInner::Atom(Atom::Ident(f)) => f.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "field name".into(),
                ))
            }
        };
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::StructGet(Box::new(args[0].clone()), field),
        })
    }

    fn p_close(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "close needs handle".into(),
            ));
        }
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::Close(Box::new(args[0].clone())),
        })
    }

    fn p_with_resource(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "with-resource needs binding + body".into(),
            ));
        }

        let binding = match &args[0].inner {
            ExprInner::Call(_, ref inner) if inner.len() == 2 => {
                let name = match &inner[0].inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => {
                        return Err(ZylError::E_EXPECTED_EXPRESSION(
                            args[0].span.clone(),
                            "identifier".into(),
                        ))
                    }
                };
                check_reserved_keyword(&name, &args[0].span)?;
                (name, inner[1].clone())
            }
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "(name expr)".into(),
                ))
            }
        };

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::WithResource(
                binding.0,
                Box::new(binding.1),
                Box::new(args[1].clone()),
            ),
        })
    }

    fn p_deftype(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "deftype needs name + variants".into(),
            ));
        }
        let type_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "type name".into(),
                ))
            }
        };
        check_reserved_keyword(&type_name, &args[0].span)?;

        let mut variants = Vec::new();
        let mut bound: Option<String> = None;
        for arg in &args[1..] {
            match &arg.inner {
                ExprInner::Call(_, ref inner) | ExprInner::Apply(_, ref inner)
                    if !inner.is_empty() =>
                {
                    if let ExprInner::Atom(Atom::Keyword(kw)) = &inner[0].inner {
                        if kw == "bound" && inner.len() >= 2 {
                            bound = Some(match &inner[1].inner {
                                ExprInner::Atom(Atom::Ident(t)) => t.clone(),
                                _ => {
                                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                                        arg.span.clone(),
                                        "type".into(),
                                    ))
                                }
                            });
                        } else if kw == "where" && inner.len() >= 3 {
                            bound = Some(match &inner[2].inner {
                                ExprInner::Atom(Atom::Ident(t)) => t.clone(),
                                _ => {
                                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                                        arg.span.clone(),
                                        "trait".into(),
                                    ))
                                }
                            });
                        } else {
                            self.parse_variant(inner, arg, &mut variants)?;
                        }
                    } else {
                        self.parse_variant(inner, arg, &mut variants)?;
                    }
                }
                ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                    // Unit variant like None — no fields.
                    variants.push(ADTVariant {
                        name: v.clone(),
                        fields: Vec::new(),
                    });
                }
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        arg.span.clone(),
                        "variant or option".into(),
                    ))
                }
            }
        }

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::Deftype(type_name, variants, bound),
        })
    }

    fn parse_variant(
        &self,
        inner: &[Expr],
        arg: &Expr,
        out: &mut Vec<ADTVariant>,
    ) -> Result<(), ZylError> {
        let vname = match &inner[0].inner {
            ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => v.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    arg.span.clone(),
                    "variant name".into(),
                ))
            }
        };
        let fields: Vec<String> = inner
            .iter()
            .skip(1)
            .filter_map(|e| match &e.inner {
                ExprInner::Atom(Atom::Ident(t)) => Some(t.clone()),
                _ => None,
            })
            .collect();
        out.push(ADTVariant {
            name: vname,
            fields,
        });
        Ok(())
    }

    fn p_trait_decl(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "trait needs name + methods".into(),
            ));
        }
        let trait_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "trait name".into(),
                ))
            }
        };
        check_reserved_keyword(&trait_name, &args[0].span)?;

        let mut methods = Vec::new();
        let mut where_clause: Option<(String, String)> = None;

        for arg in &args[1..] {
            match &arg.inner {
                ExprInner::Call(_, ref inner) if !inner.is_empty() => {
                    if let ExprInner::Atom(Atom::Keyword(kw)) = &inner[0].inner {
                        if kw == "where" && inner.len() >= 3 {
                            where_clause = Some((
                                match &inner[1].inner {
                                    ExprInner::Atom(Atom::Ident(p)) => p.clone(),
                                    _ => {
                                        return Err(ZylError::E_EXPECTED_EXPRESSION(
                                            arg.span.clone(),
                                            "type param".into(),
                                        ))
                                    }
                                },
                                match &inner[2].inner {
                                    ExprInner::Atom(Atom::Ident(t)) => t.clone(),
                                    _ => {
                                        return Err(ZylError::E_EXPECTED_EXPRESSION(
                                            arg.span.clone(),
                                            "trait name".into(),
                                        ))
                                    }
                                },
                            ));
                            continue;
                        }
                    }

                    let mname = match &inner[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => {
                            return Err(ZylError::E_EXPECTED_EXPRESSION(
                                arg.span.clone(),
                                "method name".into(),
                            ))
                        }
                    };
                    let mut mparams = Vec::new();
                    if inner.len() >= 2 {
                        match &inner[1].inner {
                            ExprInner::Call(_, ref pexprs) => {
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
                            _ => {}
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
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        arg.span.clone(),
                        "method or :where clause".into(),
                    ))
                }
            }
        }

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::TraitDecl(trait_name, methods, where_clause),
        })
    }

    fn p_impl_block(&self, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 3 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "impl needs trait + type + bodies".into(),
            ));
        }
        let trait_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "trait name".into(),
                ))
            }
        };
        check_reserved_keyword(&trait_name, &args[0].span)?;
        let type_name = match &args[1].inner {
            ExprInner::Atom(Atom::Ident(n)) | ExprInner::Atom(Atom::Keyword(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "type name".into(),
                ))
            }
        };

        let bodies: Vec<ImplBody> = args[2..]
            .iter()
            .map(|e| match &e.inner {
                ExprInner::Defn(name, params, body) => ImplBody {
                    defn: DefnNode {
                        name: name.clone(),
                        params: params.clone(),
                        body: body.clone(),
                    },
                },
                _ => ImplBody {
                    defn: DefnNode {
                        name: "??".into(),
                        params: Vec::new(),
                        body: Box::new(e.clone()),
                    },
                },
            })
            .collect();

        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::ImplBlock(trait_name, type_name, bodies),
        })
    }

    fn p_struct_def(&self, args: &[Expr]) -> Result<StructDef, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "struct needs a name".into(),
            ));
        }
        let struct_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&struct_name, &args[0].span)?;

        let mut fields: Vec<(String, Option<String>)> = Vec::new();
        for arg in &args[1..] {
            match &arg.inner {
                ExprInner::Call(_, ref inner) if !inner.is_empty() => {
                    if let ExprInner::Atom(Atom::Keyword(kw)) = &inner[0].inner {
                        if kw == "derive" {
                            continue;
                        } else {
                            return Err(ZylError::E_EXPECTED_EXPRESSION(
                                arg.span.clone(),
                                format!("unknown option :{}", kw),
                            ));
                        }
                    }

                    let fname = match &inner[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => {
                            return Err(ZylError::E_EXPECTED_EXPRESSION(
                                arg.span.clone(),
                                "field name".into(),
                            ))
                        }
                    };
                    let ftype = inner.get(1).and_then(|e| match &e.inner {
                        ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                            Some(t.clone())
                        }
                        _ => None,
                    });
                    fields.push((fname, ftype));
                }
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        arg.span.clone(),
                        "field or option".into(),
                    ))
                }
            }
        }

        Ok(StructDef {
            name: struct_name,
            fields,
        })
    }

    fn p_alias(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "alias needs name + type".into(),
            ));
        }
        let alias_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "identifier".into(),
                ))
            }
        };
        check_reserved_keyword(&alias_name, &args[0].span)?;
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::AliasDecl(alias_name, Box::new(args[1].clone())),
        })
    }

    fn p_derive(&self, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "derive needs type + traits".into(),
            ));
        }
        let type_name = match &args[0].inner {
            ExprInner::Atom(Atom::Ident(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "type name".into(),
                ))
            }
        };
        check_reserved_keyword(&type_name, &args[0].span)?;
        let traits: Vec<String> = args[1..]
            .iter()
            .filter_map(|e| match &e.inner {
                ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                    Some(t.clone())
                }
                _ => None,
            })
            .collect();
        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::Derive(type_name, traits),
        })
    }

    fn p_test_suite(
        &self,
        args: &[Expr],
    ) -> Result<(String, Vec<TestOrSuite>, IndexMap<String, Atom>), ZylError> {
        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Str(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "string (suite name)".into(),
                ))
            }
        };

        let mut tests = Vec::new();
        let mut keywords = IndexMap::new();
        let mut i = 1;
        while i < args.len() {
            match &args[i].inner {
                ExprInner::Atom(Atom::Keyword(kw)) => {
                    if i + 1 >= args.len() {
                        return Err(ZylError::E_EXPECTED_EXPRESSION(
                            args[i].span.clone(),
                            format!("value after :{}", kw),
                        ));
                    }
                    keywords.insert(
                        kw.clone(),
                        match &args[i + 1].inner {
                            ExprInner::Atom(a) => a.clone(),
                            _ => Atom::Int(0),
                        },
                    );
                    i += 2;
                }
                _ => tests.push(TestOrSuite::Test(self.p_test_decl_from_expr(&args[i])?)),
            }
        }

        Ok((name, tests, keywords))
    }

    fn p_test_decl(
        &self,
        args: &[Expr],
    ) -> Result<(String, Box<Expr>, IndexMap<String, Atom>), ZylError> {
        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Str(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "string (test name)".into(),
                ))
            }
        };

        // args[1] is the body. Remaining are keyword arguments — but they're already parsed as expressions, not raw tokens.
        let mut keywords = IndexMap::new();
        Ok((name, Box::new(args[1].clone()), keywords))
    }

    fn p_test_decl_from_expr(&self, arg: &Expr) -> Result<TestDecl, ZylError> {
        match &arg.inner {
            ExprInner::TestDecl(name, body, kw) => Ok(TestDecl {
                name: name.clone(),
                body: body.clone(),
                keywords: kw.clone(),
            }),
            _ => Err(ZylError::E_EXPECTED_EXPRESSION(
                arg.span.clone(),
                "test declaration".into(),
            )),
        }
    }

    fn p_assert_equal(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 2 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "assert-equal needs two expressions".into(),
            ));
        }
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::AssertEqual(Box::new(args[0].clone()), Box::new(args[1].clone())),
        })
    }

    fn p_assert_fail(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        let msg = if args.len() >= 2 {
            Some(args[1].try_string()?)
        } else {
            None
        };
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::AssertFail(Box::new(args[0].clone()), msg),
        })
    }

    fn p_assert_true(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        let msg = if args.len() >= 2 {
            Some(args[1].try_string()?)
        } else {
            None
        };
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::AssertTrue(Box::new(args[0].clone()), msg),
        })
    }

    fn p_assert_false(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        let msg = if args.len() >= 2 {
            Some(args[1].try_string()?)
        } else {
            None
        };
        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::AssertFalse(Box::new(args[0].clone()), msg),
        })
    }

    fn p_test_property(&self, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.len() < 3 {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "test-property needs name + gen + body".into(),
            ));
        }
        let name = match &args[0].inner {
            ExprInner::Atom(Atom::Str(n)) => n.clone(),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "string (name)".into(),
                ))
            }
        };

        let gen = match &args[1].inner {
            ExprInner::Atom(Atom::Ident(g)) if g == "gen-int" => Generator::GenInt,
            ExprInner::Atom(Atom::Ident(g)) if g == "gen-bool" => Generator::GenBool,
            ExprInner::Atom(Atom::Ident(g)) if g == "gen-string" => Generator::GenString,
            ExprInner::Atom(Atom::Ident(g)) if g == "gen-float" => Generator::GenFloat,
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[1].span.clone(),
                    "generator".into(),
                ))
            }
        };

        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::TestProperty(name, gen, Box::new(args[2].clone())),
        })
    }

    fn p_run_tests(&self, args: &[Expr]) -> Result<IndexMap<String, Atom>, ZylError> {
        let mut keywords = IndexMap::new();
        for arg in args {
            match &arg.inner {
                ExprInner::Atom(Atom::Keyword(kw)) => { /* need value — limitation of pre-parsed args */
                }
                _ => {}
            }
        }
        Ok(keywords)
    }

    fn p_test_compile(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "test-compile needs an expression".into(),
            ));
        }
        let mut expect_error: Option<bool> = None;

        for arg in &args[1..] {
            if let ExprInner::Call(_, ref inner) = &arg.inner {
                if !inner.is_empty() {
                    if let ExprInner::Atom(Atom::Keyword(kw)) = &inner[0].inner {
                        if kw == "expect-error" && inner.len() >= 2 {
                            expect_error = Some(match &inner[1].inner {
                                ExprInner::Atom(Atom::Bool(b)) => *b,
                                _ => {
                                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                                        arg.span.clone(),
                                        "boolean".into(),
                                    ))
                                }
                            });
                        }
                    }
                }
            }
        }

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::TestCompile(Box::new(args[0].clone()), expect_error),
        })
    }

    fn p_use(&self, span: &Span, args: &[Expr]) -> Result<Expr, ZylError> {
        if args.is_empty() {
            return Err(ZylError::E_EXPECTED_EXPRESSION(
                Span::default(),
                "use needs a module name".into(),
            ));
        }
        let mut unsafe_ = false;
        let mut parts: Vec<String> = Vec::new();
        let mut syms: Option<Vec<String>> = None;

        match &args[0].inner {
            ExprInner::Atom(Atom::Ident(m)) => parts.push(m.clone()),
            _ => {
                return Err(ZylError::E_EXPECTED_EXPRESSION(
                    args[0].span.clone(),
                    "module name".into(),
                ))
            }
        };

        for arg in &args[1..] {
            if let ExprInner::Atom(Atom::Keyword(kw)) = &arg.inner {
                if kw == "unsafe" {
                    unsafe_ = true;
                    continue;
                }
            }
            syms.get_or_insert_with(Vec::new);
            match &arg.inner {
                ExprInner::Atom(Atom::Ident(s)) => syms.as_mut().unwrap().push(s.clone()),
                _ => {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        arg.span.clone(),
                        "symbol".into(),
                    ))
                }
            };
        }

        Ok(Expr {
            span: Span::default(),
            inner: ExprInner::UseModule(parts, syms, unsafe_),
        })
    }

    fn p_builtin(&self, span: &Span, name: &str, args: &[Expr]) -> Result<Expr, ZylError> {
        // Only convert make-* to MakeStruct if the struct name starts with uppercase
        // (heuristic: user-defined functions use lowercase, struct names use PascalCase).
        if name.starts_with("make-") && !args.is_empty() {
            let struct_name = &name[5..];
            if struct_name.chars().next().map(|c| c.is_uppercase()).unwrap_or(false) {
                return Ok(Expr {
                    span: span.clone(),
                    inner: ExprInner::MakeStruct(struct_name.to_string(), args.to_vec()),
                });
            }
        }

        // Validate known built-ins.
        match name {
            "+" | "-" | "*" | "/" | "%" => {}
            "==" | "!=" | "<" | ">" | "<=" | ">=" if args.len() == 2 => {}
            "not" if args.len() == 1 => {}
            "and" | "or" => {}
            x if x.ends_with('?')
                && (x.starts_with("int")
                    || x.starts_with("float")
                    || x.starts_with("bool")
                    || x.starts_with("string")
                    || x.starts_with("struct")
                    || x.starts_with("alias")) =>
            {
                if args.len() != 1 {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        span.clone(),
                        format!("{} expects 1 argument", name),
                    ));
                }
            }
            "len" | "vec" | "tuple" => {}
            "map" if !name.starts_with("make-") && !args.is_empty() => {}
            "identity" | "compose" => {
                if args.len() != 1 {
                    return Err(ZylError::E_EXPECTED_EXPRESSION(
                        span.clone(),
                        format!("{} expects 1 argument", name),
                    ));
                }
            }
            _ => {}
        }

        Ok(Expr {
            span: span.clone(),
            inner: ExprInner::Apply(name.to_string(), args.to_vec()),
        })
    }

    // ── Helpers ────────────────────────────────────────────────────────

    fn parse_params_list(&self, arg: Option<&Expr>) -> Vec<Param> {
        match arg {
            Some(e) => match &e.inner {
                ExprInner::Call(_, ref pexprs) => {
                    // Call from special forms — all elements are params.
                    pexprs.iter().map(|pe| self.parse_param(pe)).collect()
                }
                ExprInner::Apply(ref name, ref args)
                    if !name.starts_with("make-")
                        && name
                            .chars()
                            .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!')) =>
                {
                    // Apply from generic calls — treat all components as params.
                    let mut params = Vec::new();
                    // Add the operator (name) as a param if it looks like an identifier.
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
                        params.push(self.parse_param(pe));
                    }
                    params
                }
                _ => Vec::new(),
            },
            None => Vec::new(),
        }
    }

    fn parse_param(&self, e: &Expr) -> Param {
        match &e.inner {
            ExprInner::Atom(Atom::Ident(n)) => Param {
                span: Span::default(),
                name: n.clone(),
                typ: None,
            },
            ExprInner::Call(_, ref fields) if fields.len() == 2 => {
                let nm = match &fields[0].inner {
                    ExprInner::Atom(Atom::Ident(nn)) => nn.clone(),
                    _ => "?".into(),
                };
                let tp = match &fields[1].inner {
                    ExprInner::Atom(Atom::Ident(t)) | ExprInner::Atom(Atom::Keyword(t)) => {
                        Some(t.clone())
                    }
                    _ => None,
                };
                Param {
                    span: Span::default(),
                    name: nm,
                    typ: tp,
                }
            }
            _ => Param {
                span: Span::default(),
                name: "?".into(),
                typ: None,
            },
        }
    }

    fn at_end(&self) -> bool {
        self.pos >= self.tokens.len() || matches!(self.tokens[self.pos].kind, TokenKind::EOF)
    }
    fn peek_kind(&self) -> &TokenKind {
        self.tokens
            .get(self.pos)
            .map(|t| &t.kind)
            .unwrap_or(&TokenKind::EOF)
    }

    fn next_token(&mut self) -> Result<Token, ZylError> {
        if self.at_end() {
            return Err(ZylError::E_UNEXPECTED_EOF(
                Location { line: 1, col: 1 },
                "token",
            ));
        }
        Ok(self.tokens.remove(self.pos)) // O(n); acceptable for Phase 1.
    }

    fn expect_token_kind(&mut self, kind: TokenKind) -> Result<(), ZylError> {
        if *self.peek_kind() != kind {
            return Err(ZylError::E_EXPECTED_RPAREN(
                Span::default(),
                format!("expected {:?}", kind),
            ));
        }
        self.pos += 1;
        Ok(())
    }
}

// ── Atom helpers on Expr ───────────────────────────────────────────────

trait ExprExt {
    fn try_ident(&self) -> Result<String, ZylError>;
    fn try_string(&self) -> Result<String, ZylError>;
}

impl ExprExt for Expr {
    fn try_ident(&self) -> Result<String, ZylError> {
        match &self.inner {
            ExprInner::Atom(Atom::Ident(n)) => Ok(n.clone()),
            _ => Err(ZylError::E_EXPECTED_EXPRESSION(
                self.span.clone(),
                "identifier".into(),
            )),
        }
    }
    fn try_string(&self) -> Result<String, ZylError> {
        match &self.inner {
            ExprInner::Atom(Atom::Str(s)) => Ok(s.clone()),
            _ => Err(ZylError::E_EXPECTED_EXPRESSION(
                self.span.clone(),
                "string literal".into(),
            )),
        }
    }
}

fn atom_expr(span: Span, atom: Atom) -> Expr {
    Expr {
        span,
        inner: ExprInner::Atom(atom),
    }
}
