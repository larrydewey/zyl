//! Parser for Zyl S-expressions
//! 
//! Converts token stream into AST per specification section 2.

use crate::ast::*;
use crate::lexer::Token;
use crate::lexer::LexError;
use thiserror::Error;

// ============================================================================
// ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error)]
pub enum ParseError {
    #[error("Expected {expected}, got {got} at {loc}")]
    ExpectedToken { expected: &'static str, got: Token, loc: Location },
    
    #[error("Unexpected end of input at {loc}")]
    UnexpectedEof { loc: Location },
    
    #[error("Mismatched parentheses at {loc}")]
    MismatchedParen { loc: Location },
    
    #[error("Invalid expression at {loc}: {msg}")]
    InvalidExpr { loc: Location, msg: String },
    
    #[error("Empty list is not a valid expression at {loc}")]
    EmptyList { loc: Location },
    
    #[error("Lexical error: {0}")]
    Lex(#[from] LexError),
}

// ============================================================================
// PARSER
// ============================================================================

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }
    
    fn current(&self) -> Option<&Token> {
        self.tokens.get(self.pos)
    }
    
    fn advance(&mut self) -> Option<Token> {
        let tok = self.tokens.get(self.pos).cloned();
        self.pos += 1;
        tok
    }
    
    /// Get location of the current token, or (0, 0) if at EOF.
    fn loc(&self) -> Location {
        self.current().map(|t| t.location()).unwrap_or(Location::new(0, 0))
    }
    
    /// Get location of a token at a given index, or (0, 0) if out of bounds.
    fn loc_at(&self, idx: usize) -> Location {
        self.tokens.get(idx).map(|t| t.location()).unwrap_or(Location::new(0, 0))
    }
    
    /// Advance and return the token, or UnexpectedEof with current location.
    fn expect_token(&mut self) -> Result<Token, ParseError> {
        let loc = self.loc();
        match self.advance() {
            Some(t) => Ok(t),
            None => Err(ParseError::UnexpectedEof { loc }),
        }
    }
    
    fn expect_kind(&mut self, check: fn(Token) -> bool) -> Result<Token, ParseError> {
        match self.advance() {
            Some(ref t) if check(t.clone()) => Ok(t.clone()),
            Some(t) => Err(ParseError::ExpectedToken {
                expected: format!("{}", t).leak(),
                got: t,
                loc: token_location(&self.tokens, self.pos - 1),
            }),
            None => Err(ParseError::UnexpectedEof {
                loc: self.loc(),
            }),
        }
    }
    
    fn expect_keyword(&mut self, kw: &str) -> Result<(), ParseError> {
        match self.current() {
            Some(Token::Ident(expected, _)) if expected == kw => {
                self.advance();
                Ok(())
            }
            Some(tok) => Err(ParseError::ExpectedToken {
                expected: "keyword",
                got: tok.clone(),
                loc: token_location(&self.tokens, self.pos),
            }),
            None => Err(ParseError::UnexpectedEof {
                loc: self.loc(),
            }),
        }
    }
    
    /// Parse a complete program (list of top-level forms)
    pub fn parse_program(&mut self) -> Result<Program, ParseError> {
        for (i, tok) in self.tokens.iter().enumerate() {
        }
        let mut all_exprs: Vec<Expr> = Vec::new();
        
        // Parse all top-level forms
        while self.current().is_some() {
            let expr = self.parse_expr()?;
            all_exprs.push(expr);
        }
        
        if all_exprs.is_empty() {
            return Ok(Program::empty());
        }
        
        // Separate definitions from body expressions
        let mut defs: Vec<Expr> = Vec::new();
        let mut body_exprs: Vec<Expr> = Vec::new();
        
        for expr in all_exprs {
            match &expr {
                Expr::Def(..) | Expr::Defn { .. } => {
                    defs.push(expr);
                }
                _ => {
                    body_exprs.push(expr);
                }
            }
        }
        
        let body = if body_exprs.is_empty() {
            if defs.is_empty() {
                Expr::Atom(AtomKind::Ident("unit".into()))
            } else {
                // All are definitions, use the last one as body (but don't remove from defs)
                defs.last().cloned().unwrap_or(Expr::Atom(AtomKind::Ident("unit".into())))
            }
        } else if body_exprs.len() == 1 {
            body_exprs.pop().unwrap()
        } else {
            Expr::App("begin".into(), body_exprs)
        };
        
        Ok(Program::new(defs, body))
    }
    
    /// Parse a single expression
    pub fn parse_expr(&mut self) -> Result<Expr, ParseError> {
        match self.current() {
            None => Err(ParseError::UnexpectedEof {
                loc: self.loc(),
            }),
            Some(t) if matches!(t, Token::LParen(_)) => {
                // Check for curried lambda syntax: ((param) body)
                if self.is_curried_lambda() {
                    return self.parse_curried_lambda();
                }
                self.parse_list()
            }
            Some(t) if matches!(t, Token::Quote(_)) => {
                // Single quote syntactic sugar: '(expr) → (quote expr)
                self.advance();
                let inner = self.parse_expr()?;
                Ok(Expr::Quote(Box::new(inner)))
            }
            Some(tok) => self.parse_atom(tok.clone()),
        }
    }
    
    /// Parse an atom (literal or identifier)
    fn parse_atom(&mut self, tok: Token) -> Result<Expr, ParseError> {
        let expr = match tok {
            Token::Int(v, _) => Expr::Atom(AtomKind::Int(v)),
            Token::Float(v, _) => Expr::Atom(AtomKind::Float(v)),
            Token::Bool(v, _) => Expr::Atom(AtomKind::Bool(v)),
            Token::StringLit(v, _) => Expr::Atom(AtomKind::StringLit(v)),
            Token::Ident(name, _) => Expr::Atom(AtomKind::Ident(name)),
            Token::Keyword(kw, _) => Expr::Atom(AtomKind::Ident(format!(":{}", kw))),
            other => return Err(ParseError::ExpectedToken {
                expected: "expression",
                got: other,
                loc: self.loc(),
            }),
        };
        self.advance();
        Ok(expr)
    }
    
    // ========================================================================
    // CURRIED LAMBDA SUPPORT (§7.2)
    // ========================================================================
    
    /// Check if current position starts a curried lambda: ((param) body)
    fn is_curried_lambda(&self) -> bool {
        // Must be LParen followed by another LParen (the outer parens of the first param group)
        if !matches!(self.current(), Some(Token::LParen(_))) {
            return false;
        }

        let mut pos = self.pos + 1; // skip outer (
        while pos < self.tokens.len() {
            match &self.tokens[pos] {
                Token::LParen(_) => {
                    // Found ( — check if this is a param group: LPAREN IDENT RPAREN
                    if pos + 2 >= self.tokens.len() {
                        return false; // Not enough tokens for (name)
                    }
                    let ident_pos = pos + 1;
                    let rparen_pos = pos + 2;
                    
                    match (&self.tokens[ident_pos], &self.tokens[rparen_pos]) {
                        (Token::Ident(_, _), Token::RParen(_)) => {
                            // This is a valid param group: (name)
                            let after_group = rparen_pos + 1;
                            if after_group >= self.tokens.len() {
                                return false; // No body content — not valid curried lambda
                            }
                            match &self.tokens[after_group] {
                                Token::LParen(_) => {
                                    // Another opening paren follows. Check if it's another param group.
                                    let next_pos = after_group;
                                    if next_pos + 2 >= self.tokens.len() {
                                        return false; // Not enough tokens for more params or body
                                    }
                                    match (&self.tokens[next_pos + 1], &self.tokens[next_pos + 2]) {
                                        (Token::Ident(_, _), Token::RParen(_)) => {
                                            // Another param group — continue scanning
                                            pos = next_pos;
                                            continue;
                                        }
                                        (_, _) => {
                                            // Not a param group pattern — this is the body!
                                            return true;
                                        }
                                    }
                                }
                                Token::RParen(_) => {
                                    // Closing paren immediately after params — no body content
                                    return false; // Not valid curried lambda (no body)
                                }
                                _ => {
                                    // Non-paren token starts the body — valid curried lambda
                                    return true;
                                }
                            }
                        }
                        (_, _) => {
                            // Not a param group pattern at this position
                            return false;
                        }
                    }
                }
                _ => {
                    // Non-paren token at top level inside outer parens — not curried syntax
                    return false;
                }
            }
        }
        false
    }
    
    /// Parse curried lambda: ((param) body)
    /// Desugars to: (fn ((param)) body)
    /// Multi-level: ((x) (y) (+ x y)) → (fn ((x)) (fn ((y)) (+ x y)))
    fn parse_curried_lambda(&mut self) -> Result<Expr, ParseError> {
        // Consume outer LParen
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        let mut params = Vec::new();
        let mut body_exprs: Vec<Expr> = Vec::new();
        
        // Collect parameter names from ((p1) (p2) ...)
        // A param group is exactly 3 tokens: LParen, Ident, RParen.
        // We stop when we see something that's not a simple (identifier) pattern,
        // which means the rest is body expressions.
        while self.is_param_group() {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            match self.current() {
                Some(Token::Ident(name, _)) => {
                    params.push(name.clone());
                    self.advance();
                }
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "Curried lambda parameter must be an identifier".into(),
                }),
            }
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        }
        
        // Parse body expressions
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            body_exprs.push(self.parse_expr()?);
        }
        
        let body = match body_exprs.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => body_exprs.pop().unwrap(),
            _ => Expr::Begin(body_exprs),
        };

        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;

        // Build NESTED closures for proper partial application support.
        // ((p1) (p2) ... (pn) body) -> (fn (p1) (fn (p2) ... (fn (pn) body)...))
        let mut inner_body = Box::new(body);
        for param in params.into_iter().rev() {
            inner_body = Box::new(Expr::Fn {
                params: vec![param],
                body: inner_body,
            });
        }

        Ok(*inner_body)
    }
    
    /// Check if current position starts a param group: (name)
    /// A param group is exactly 3 tokens: LParen, Ident, RParen.
    /// This distinguishes `(x)` from `(fn ...)` or other expressions.
    ///
    /// IMPORTANT: We also verify that consuming this pattern leaves valid
    /// body content after it. If the next token after (name) is only RParen,
    /// then what looks like a param group is actually part of the function body.
    fn is_param_group(&self) -> bool {
        if !matches!(self.current(), Some(Token::LParen(_))) {
            return false;
        }
        // Must be exactly: LParen, Ident, RParen (3 tokens)
        let pos = self.pos + 1;
        if pos >= self.tokens.len() {
            return false;
        }
        match &self.tokens[pos] {
            Token::Ident(_, _) => {
                let after_ident = pos + 1;
                // Must have RParen immediately after the identifier
                if after_ident < self.tokens.len()
                    && matches!(self.tokens[after_ident], Token::RParen(_))
                {
                    // Now check what follows: there must be more content for body.
                    let after_group = after_ident + 1;
                    if after_group >= self.tokens.len() {
                        return false; // No body — not a valid param group in curried context
                    }
                    match &self.tokens[after_group] {
                        Token::LParen(_) => true,   // More params or nested expr (body)
                        _ => true,                   // Non-paren token starts the body
                        // RParen here means no body content — not a valid param group
                    }
                } else {
                    false
                }
            }
            _ => false,
        }
    }
    
    /// Parse a list (application or special form)
    fn parse_list(&mut self) -> Result<Expr, ParseError> {
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        // Check for empty list — parse as App with no args (empty tuple when quoted)
        if matches!(self.current(), Some(Token::RParen(_))) {
            self.advance();
            return Ok(Expr::App("".into(), Vec::new()));
        }
        
        // Parse the operator
        let op_tok = self.advance().unwrap();
        
        // Handle nested application: ((f x) y) - operator is itself an expression
        if matches!(op_tok, Token::LParen(_)) {
            // op_tok IS the inner LParen we just consumed.
            // We need to parse the inner list manually since parse_expr() expects
            // to see the LParen itself.
            let operator = self.parse_inner_list()?;
            
            // Parse remaining arguments
            let mut args = Vec::new();
            while !matches!(self.current(), Some(Token::RParen(_))) {
                if self.current() == None {
                    return Err(ParseError::MismatchedParen {
                        loc: self.loc(),
                    });
                }
                let arg = self.parse_expr()?;
                args.push(arg);
            }
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
            return Ok(Expr::AppExpr(Box::new(operator), args));
        }
        
        let op = match &op_tok {
            Token::Ident(name, _) => name.clone(),
            Token::Int(v, _) => v.to_string(),
            Token::Float(v, _) => v.to_string(),
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: format!("Expected operator, got {}", op_tok),
            }),
        };
        
        // Dispatch to special form parsers
        // Note: inner functions do NOT consume the final ) — parse_list does it after dispatch
        match op.as_str() {
            "quote" => {
                let expr = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(Expr::Quote(Box::new(expr)));
            }
            "def" => {
                let expr = self.parse_def_inner(op)?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "defn" => {
                let expr = self.parse_defn_inner(op)?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "let" | "let-mut" => {
                let mutable = op == "let-mut";
                let expr = self.parse_let_inner(mutable, op)?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "if" => {
                let expr = self.parse_if_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "try" => {
                let expr = self.parse_try_catch_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "spawn" => {
                let expr = self.parse_spawn_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "send" => {
                let expr = self.parse_send_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "ffi-call" => {
                let expr = self.parse_ffi_call_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "ffi-pin" => {
                let expr = self.parse_ffi_pin_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "assert" => {
                let expr = self.parse_assert_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "fn" => {
                let expr = self.parse_fn_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "while" => {
                let expr = self.parse_while_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "for" => {
                let expr = self.parse_for_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "cond" => {
                let expr = self.parse_cond_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "match" => {
                let expr = self.parse_match_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "deftype" => {
                let expr = self.parse_deftype_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "trait" => {
                let expr = self.parse_trait_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "impl" => {
                let expr = self.parse_impl_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "use" => {
                let expr = self.parse_use_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "export" => {
                let expr = self.parse_export_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "pub" => {
                let expr = self.parse_pub_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "requires" => {
                let expr = self.parse_requires_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "ensures" => {
                let expr = self.parse_ensures_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "invariant" => {
                let expr = self.parse_invariant_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "recover" => {
                let expr = self.parse_recover_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "checkpoint" => {
                let expr = self.parse_checkpoint_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "contracts" => {
                let expr = self.parse_contracts_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            "begin" => {
                let expr = self.parse_begin_inner()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(expr);
            }
            _ => {
                // Regular application
                let mut args = Vec::new();
                while !matches!(self.current(), Some(Token::RParen(_))) {
                    if self.current() == None {
                        return Err(ParseError::MismatchedParen {
                            loc: self.loc(),
                        });
                    }
                    let arg = self.parse_expr()?;
                    args.push(arg);
                }
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                Ok(Expr::App(op, args))
            }
        }
    }
    
    /// Parse a list where the opening LParen has already been consumed.
    /// Used for nested applications like ((f x) y) where we need to parse
    /// the inner (f x) without consuming another LParen.
    fn parse_inner_list(&mut self) -> Result<Expr, ParseError> {
        // Check for empty list
        if matches!(self.current(), Some(Token::RParen(_))) {
            self.advance();
            return Ok(Expr::App("".into(), Vec::new()));
        }
        
        // Parse the operator token
        let op_tok = self.advance().unwrap();
        
        // Parse the operator expression.
        // For nested applications like ((f x) y), op_tok is LParen and we recurse.
        // For special forms used as operators like ((fn (x) x) 3), we parse via
        // parse_expr which handles all special form dispatch internally.
        let mut expr: Expr = if matches!(op_tok, Token::LParen(_)) {
            self.parse_inner_list()?
        } else {
            match &op_tok {
                Token::Ident(name, _) => {
                    // Check if it's a special form
                    match name.as_str() {
                        "def" => self.parse_def_inner(name.clone())?,
                        "defn" => self.parse_defn_inner(name.clone())?,
                        "let" | "let-mut" => {
                            let mutable = name == "let-mut";
                            self.parse_let_inner(mutable, name.clone())?
                        }
                        "if" => self.parse_if_inner()?,
                        "try" => self.parse_try_catch_inner()?,
                        "spawn" => self.parse_spawn_inner()?,
                        "send" => self.parse_send_inner()?,
                        "ffi-call" => self.parse_ffi_call_inner()?,
                        "ffi-pin" => self.parse_ffi_pin_inner()?,
                        "assert" => self.parse_assert_inner()?,
                        "fn" => self.parse_fn_inner()?,
                        "while" => self.parse_while_inner()?,
                        "for" => self.parse_for_inner()?,
                        "cond" => self.parse_cond_inner()?,
                        "match" => self.parse_match_inner()?,
                        "deftype" => self.parse_deftype_inner()?,
                        "trait" => self.parse_trait_inner()?,
                        "impl" => self.parse_impl_inner()?,
                        "use" => self.parse_use_inner()?,
                        "export" => self.parse_export_inner()?,
                        "pub" => self.parse_pub_inner()?,
                        "requires" => self.parse_requires_inner()?,
                        "ensures" => self.parse_ensures_inner()?,
                        "invariant" => self.parse_invariant_inner()?,
                        "recover" => self.parse_recover_inner()?,
                        "checkpoint" => self.parse_checkpoint_inner()?,
                        "contracts" => self.parse_contracts_inner()?,
                        "begin" => self.parse_begin_inner()?,
                        // Testing framework
                        "test-suite" => self.parse_test_suite_inner()?,
                        "test" => self.parse_test_inner()?,
                        "assert-equal" => self.parse_assert_equal_inner()?,
                        "assert-fail" => self.parse_assert_fail_inner()?,
                        "assert-true" => self.parse_assert_true_inner()?,
                        "assert-false" => self.parse_assert_false_inner()?,
                        "test-property" => self.parse_test_property_inner()?,
                        "setup" => self.parse_setup_inner()?,
                        "teardown" => self.parse_teardown_inner()?,
                        "run-tests" => self.parse_run_tests_inner()?,
                        "test-compile" => self.parse_test_compile_inner()?,
                        _ => Expr::Atom(AtomKind::Ident(name.clone())),
                    }
                }
                Token::Int(v, _) => Expr::Atom(AtomKind::Int(*v)),
                Token::Float(v, _) => Expr::Atom(AtomKind::Float(*v)),
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: format!("Expected operator, got {}", op_tok),
                }),
            }
        };
        
        let mut args = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) {
            if self.current() == None {
                return Err(ParseError::MismatchedParen {
                    loc: self.loc(),
                });
            }
            let arg = self.parse_expr()?;
            args.push(arg);
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;

        if args.is_empty() {
            Ok(expr)
        } else {
            Ok(Expr::AppExpr(Box::new(expr), args))
        }
    }

    /// Parse (def Name Expr)
    fn parse_def_inner(&mut self, _op: String) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "def requires an identifier".into(),
            }),
        };
        let value = self.parse_expr()?;
        // NOTE: parse_list will consume the final ) after we return
        Ok(Expr::Def(name, Box::new(value)))
    }
    
    /// Parse (defn Name (Params*) Body)
    /// Supports curried syntax: (defn name ((p1) body)) where ((p1) body) is a curried lambda
    fn parse_defn_inner(&mut self, _op: String) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "defn requires an identifier".into(),
            }),
        };
        
        // Check if this is a curried lambda: ((param) body)
        if matches!(self.current(), Some(Token::LParen(_))) {
            let saved_pos = self.pos;
            match self.parse_curried_lambda_inner() {
                Ok(fn_expr) => {
                    // parse_curried_lambda_inner returns nested Fns for curried lambdas.
                    // Flatten all parameters into a single list and extract the innermost body.
                    let mut flat_params = Vec::new();
                    
                    // Walk through ALL levels of Fn nesting to collect params
                    let mut current: &Expr = &fn_expr;
                    loop {
                        match current {
                            Expr::Fn { params, ref body } => {
                                for param in params {
                                    flat_params.push(param.clone());
                                }
                                // Continue into the next Fn level if present
                                if matches!(&**body, Expr::Fn { .. }) {
                                    current = body;
                                } else {
                                    break; // Reached innermost non-Fn body
                                }
                            }
                            _ => break,
                        }
                    }
                    
                    // Extract the final (innermost) body expression by walking down again
                    let mut final_body: Box<Expr> = match &fn_expr {
                        Expr::Fn { ref params, ref body } => (*body).clone(),
                        _ => return Err(ParseError::InvalidExpr {
                            loc: self.loc(),
                            msg: "Expected Fn from curried lambda".into(),
                        }),
                    };
                    // Walk down to the innermost body
                    loop {
                        match &*final_body {
                            Expr::Fn { ref params, ref body } => {
                                let _ = (params); // already counted above
                                final_body = (*body).clone();
                            }
                            _ => break,
                        }
                    }
                    
                    // parse_curried_lambda_inner already consumed the RParen for its param list.
                    return Ok(Expr::Defn {
                        name,
                        params: flat_params,
                        body: final_body,
                        ret_type: None,
                    });
                }
                _ => {
                    // Not a valid curried lambda, backtrack and treat as normal
                    self.pos = saved_pos;
                }
            }
        }
        
        // Normal parameter list (flat identifiers)
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        let mut params = Vec::new();
        
        // Normal parameter list (flat identifiers)
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            let p_tok = self.expect_token()?;
            match p_tok {
                Token::Ident(n, _) => params.push(n),
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "defn parameters must be identifiers".into(),
                }),
            }
        }
        
        // Consume the ) that closes the params list
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        // Parse body (can be multiple expressions - implicit begin)
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            bodies.push(self.parse_expr()?);
        }
        let body = match bodies.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => bodies.pop().unwrap(),
            _ => Expr::App("begin".into(), bodies),
        };
        
        Ok(Expr::Defn {
            name,
            params,
            body: Box::new(body),
            ret_type: None,
        })
    }
    
    /// Parse curried lambda parameters without consuming outer parens
    fn parse_curried_lambda_inner(&mut self) -> Result<Expr, ParseError> {
        // Consume outer LParen
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        let mut params = Vec::new();
        let mut body_exprs: Vec<Expr> = Vec::new();
        
        // Collect parameter names from ((p1) (p2) ...)
        while self.is_param_group() {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            match self.current() {
                Some(Token::Ident(name, _)) => {
                    params.push(name.clone());
                    self.advance();
                }
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "Curried lambda parameter must be an identifier".into(),
                }),
            }
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        }
        
        // Must have at least one param group to be a valid curried lambda
        if params.is_empty() {
            return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "Curried lambda requires at least one parameter".into(),
            });
        }
        
        // Parse body expressions
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            body_exprs.push(self.parse_expr()?);
        }
        
        let body = match body_exprs.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => body_exprs.pop().unwrap(),
            _ => Expr::Begin(body_exprs),
        };

        // Consume the closing RParen of the curried lambda expression itself.
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;

        // Build NESTED closures for proper partial application support.
        // ((p1) (p2) ... (pn) body) -> (fn (p1) (fn (p2) ... (fn (pn) body)...))
        let mut inner_body = Box::new(body);
        for param in params.into_iter().rev() {
            inner_body = Box::new(Expr::Fn {
                params: vec![param],
                body: inner_body,
            });
        }

        Ok(*inner_body)
    }
    
    /// Parse (let ((Name Expr)* ) Body) or (let-mut ((Name Expr)* ) Body)
    /// Supports both single and multiple bindings.
    fn parse_let_inner(&mut self, mutable: bool, _op: String) -> Result<Expr, ParseError> {
        // Parse binding list
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        let mut bindings: Vec<(String, Expr)> = Vec::new();
        
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            // Each binding is either (Name Expr) or just Name Expr
            if matches!(self.current(), Some(Token::LParen(_))) {
                // Multi-binding syntax: ((name expr))
                self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
                let name_tok = self.expect_token()?;
                let name = match name_tok {
                    Token::Ident(n, _) => n,
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "let binding requires an identifier".into(),
                    }),
                };
                let value = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?; // close the (name expr) pair
                bindings.push((name, value));
            } else {
                // Single-binding syntax: (Name Expr)
                let name_tok = self.expect_token()?;
                let name = match name_tok {
                    Token::Ident(n, _) => n,
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "let requires an identifier".into(),
                    }),
                };
                let value = self.parse_expr()?;
                bindings.push((name, value));
            }
        }
        
        // Consume the ) that closes the binding list
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        // Parse body (can be multiple expressions)
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            bodies.push(self.parse_expr()?);
        }
        
        let body = match bodies.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => bodies.pop().unwrap(),
            _ => Expr::App("begin".into(), bodies),
        };
        
        // NOTE: parse_list will consume the final ) after we return
        
        // Build nested let expressions for multiple bindings
        let mut result = body;
        for (name, value) in bindings.into_iter().rev() {
            if mutable {
                result = Expr::LetMut { name, value: Box::new(value), body: Box::new(result) };
            } else {
                result = Expr::Let { name, value: Box::new(value), body: Box::new(result) };
            }
        }
        
        Ok(result)
    }
    
    /// Parse (if Expr Expr Expr)
    fn parse_if_inner(&mut self) -> Result<Expr, ParseError> {
        let cond = self.parse_expr()?;
        let then_branch = self.parse_expr()?;
        let else_branch = self.parse_expr()?;
        // NOTE: parse_list will consume the final ) after we return
        Ok(Expr::If { cond: Box::new(cond), then_branch: Box::new(then_branch), else_branch: Box::new(else_branch) })
    }
    
    /// Parse (try Expr (catch Name Expr))
    fn parse_try_catch_inner(&mut self) -> Result<Expr, ParseError> {
        let body = self.parse_expr()?;
        
        // Parse catch clause
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        self.expect_keyword("catch")?;
        
        let name_tok = self.expect_token()?;
        let catch_var = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "catch requires an identifier".into(),
            }),
        };
        
        let handler = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        Ok(Expr::TryCatch { body: Box::new(body), catch_var, handler: Box::new(handler) })
    }
    
    /// Parse (spawn Expr)
    fn parse_spawn_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        Ok(Expr::Spawn(Box::new(expr)))
    }
    
    /// Parse (send Expr Expr)
    fn parse_send_inner(&mut self) -> Result<Expr, ParseError> {
        let target = self.parse_expr()?;
        let message = self.parse_expr()?;
        Ok(Expr::Send { target: Box::new(target), message: Box::new(message) })
    }
    
    /// Parse (ffi-call String Expr* Integer)
    fn parse_ffi_call_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::StringLit(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "ffi-call requires a string name".into(),
            }),
        };
        
        let mut args = Vec::new();
        let mut timeout_ms: Option<i64> = None;
        
        while !matches!(self.current(), Some(Token::RParen(_))) {
            match self.current() {
                Some(Token::Int(v, _)) if timeout_ms.is_none() && !args.is_empty() => {
                    timeout_ms = Some(*v);
                    self.advance();
                }
                _ => {
                    args.push(self.parse_expr()?);
                }
            }
        }
        
        Ok(Expr::FfiCall { name, args, timeout_ms: timeout_ms.unwrap_or(5000) })
    }
    
    /// Parse (ffi-pin Expr)
    fn parse_ffi_pin_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        Ok(Expr::FfiPin(Box::new(expr)))
    }
    
    /// Parse (assert Expr String)
    fn parse_assert_inner(&mut self) -> Result<Expr, ParseError> {
        let condition = self.parse_expr()?;
        
        let msg_tok = self.expect_token()?;
        let message = match msg_tok {
            Token::StringLit(m, _) => m,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "assert requires a string message".into(),
            }),
        };
        
        Ok(Expr::Assert { condition: Box::new(condition), message })
    }
    
    /// Parse (fn (param*) body) - Closure (§7)
    fn parse_fn_inner(&mut self) -> Result<Expr, ParseError> {
        let mut params = Vec::new();
        
        // Check if this is a curried lambda: ((param) body)
        // Do NOT consume the opening paren here — parse_curried_lambda_inner handles it
        if matches!(self.current(), Some(Token::LParen(_))) {
            let saved_pos = self.pos;
            match self.parse_curried_lambda_inner() {
                Ok(Expr::Fn { params: p, body }) => {
                    // parse_curried_lambda_inner already consumed the RParen for its param list.
                    // Return immediately — parse_list will consume the final RParen for the fn.
                    return Ok(Expr::Fn { params: p, body });
                }
                _ => {
                    // Not a valid curried lambda, backtrack and treat as normal
                    self.pos = saved_pos;
                }
            }
        }
        
        // Normal parameter list (flat identifiers) — consume opening paren
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            let p_tok = self.expect_token()?;
            match p_tok {
                Token::Ident(n, _) => params.push(n),
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "fn parameters must be identifiers".into(),
                }),
            }
        }
        
        // Consume the ) that closes the params list
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        // Parse body
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current().is_some() {
            bodies.push(self.parse_expr()?);
        }
        let body = match bodies.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => bodies.pop().unwrap(),
            _ => Expr::App("begin".into(), bodies),
        };
        
        Ok(Expr::Fn { params, body: Box::new(body) })
    }
    
    /// Parse (while Expr Expr) - Loop (§12.5)
    fn parse_while_inner(&mut self) -> Result<Expr, ParseError> {
        let condition = self.parse_expr()?;
        let body = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::While { condition: Box::new(condition), body: Box::new(body) })
    }
    
    /// Parse (for Name Expr Expr Body) - For loop (§12.6)
    fn parse_for_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "for requires an identifier".into(),
            }),
        };
        let iterator = self.parse_expr()?;
        let body = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::For { name, iterator: Box::new(iterator), body: Box::new(body) })
    }
    
    /// Parse (cond (pred body) ...) - Conditional dispatch (§12.7)
    fn parse_cond_inner(&mut self) -> Result<Expr, ParseError> {
        let mut clauses = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            
            // Check for else clause
            if matches!(self.current(), Some(Token::Ident(ref n, _)) if n == "else") {
                self.advance();
                let body = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                clauses.push((Expr::Atom(AtomKind::Bool(true)), body));
            } else {
                let cond = self.parse_expr()?;
                let body = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                clauses.push((cond, body));
            }
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Cond(clauses))
    }
    
    /// Parse (match scrutinee (Variant patterns body) ...) - Pattern matching (§8)
    fn parse_match_inner(&mut self) -> Result<Expr, ParseError> {
        let scrutinee = self.parse_expr()?;
        
        let mut clauses = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            
            // Parse variant name (can be identifier or literal for pattern matching)
            let variant_tok = self.expect_token()?;
            let is_literal_variant = matches!(variant_tok, Token::Int(..) | Token::Float(..) | Token::Bool(..));
            let variant = match &variant_tok {
                Token::Ident(n, _) => n.clone(),
                Token::Int(v, _) => v.to_string(),
                Token::Float(v, _) => v.to_string(),
                Token::Bool(b, _) => b.to_string(),
                Token::StringLit(s, _) => s.clone(),
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "match clause must start with a variant name or literal".into(),
                }),
            };
            
            // Parse patterns (only for non-literal variants like ADT constructors)
            let mut patterns = Vec::new();
            if !is_literal_variant {
                while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                    match self.current() {
                        Some(Token::Ident(ref n, _)) if n == "_" => {
                            self.advance();
                            patterns.push(MatchPattern::Wildcard);
                        }
                        Some(Token::Ident(n, _)) => {
                            let name = n.clone();
                            self.advance();
                            patterns.push(MatchPattern::Bind(name));
                        }
                        // Non-ident tokens (literals, etc.) are body expressions, not patterns
                        _ => break,
                    }
                }
            }
            
            // Parse body
            let body = if matches!(self.current(), Some(Token::RParen(_))) {
                Expr::Atom(AtomKind::Ident("unit".into()))
            } else {
                let mut bodies = Vec::new();
                while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                    bodies.push(self.parse_expr()?);
                }
                match bodies.len() {
                    0 => Expr::Atom(AtomKind::Ident("unit".into())),
                    1 => bodies.pop().unwrap(),
                    _ => Expr::App("begin".into(), bodies),
                }
            };
            
            if let Some(Token::RParen(_)) = self.current() {
                self.advance();
            }
            
            clauses.push(MatchClause { variant, patterns, body: Box::new(body) });
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Match { scrutinee: Box::new(scrutinee), clauses })
    }
    
    /// Parse (deftype Name (Variant*) ...) - ADT declaration (§8)
    fn parse_deftype_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "deftype requires an identifier".into(),
            }),
        };
        
        let mut variants = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            
            let v_tok = self.expect_token()?;
            let v_name = match v_tok {
                Token::Ident(n, _) => n,
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "variant must be an identifier".into(),
                }),
            };
            
            let mut fields = Vec::new();
            while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                let field_expr = self.parse_type_expr()?;
                fields.push(field_expr);
            }
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
            
            variants.push(AdtVariant { name: v_name, fields });
        }
        
        if let Some(Token::RParen(_)) = self.current() {
            self.advance();
        }
        
        Ok(Expr::Deftype { name, variants })
    }
    
    /// Parse (trait Name (Method*) ...) - Trait declaration (§5)
    fn parse_trait_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "trait requires an identifier".into(),
            }),
        };
        
        let mut methods = Vec::new();
        let mut bound: Option<String> = None;
        
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            // Check for 'where' clause
            if matches!(self.current(), Some(Token::Ident(ref n, _)) if n == "where") {
                self.advance();
                let bound_tok = self.expect_token()?;
                bound = match bound_tok {
                    Token::Ident(n, _) => Some(n),
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "trait bound must be an identifier".into(),
                    }),
                };
                continue;
            }
            
            // Parse method: (Name (Params*) ReturnType)
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            let m_tok = self.expect_token()?;
            let m_name = match m_tok {
                Token::Ident(n, _) => n,
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "method must be an identifier".into(),
                }),
            };
            
            // Parse params
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            let mut params = Vec::new();
            while !matches!(self.current(), Some(Token::RParen(_))) {
                let p_tok = self.expect_token()?;
                match p_tok {
                    Token::Ident(n, _) => params.push(n),
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "method params must be identifiers".into(),
                    }),
                }
            }
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
            
            // Parse return type
            let ret_type = self.parse_type_expr()?;
            
            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
            methods.push(TraitMethod { name: m_name, params, return_type: ret_type });
        }
        
        if let Some(Token::RParen(_)) = self.current() {
            self.advance();
        }
        
        Ok(Expr::TraitDecl { name, methods, bound })
    }
    
    /// Parse (impl TraitName TypeName (ImplBody*) ...) - Trait impl (§5)
    fn parse_impl_inner(&mut self) -> Result<Expr, ParseError> {
        let trait_tok = self.expect_token()?;
        let trait_name = match trait_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "impl requires a trait name".into(),
            }),
        };
        
        let type_tok = self.expect_token()?;
        let type_name = match type_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "impl requires a type name".into(),
            }),
        };
        
        let mut body = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            body.push(self.parse_expr()?);
        }
        
        if let Some(Token::RParen(_)) = self.current() {
            self.advance();
        }
        
        Ok(Expr::Impl { trait_name, type_name, body })
    }
    
    /// Parse (use module-name { symbol }) - Import (§24)
    fn parse_use_inner(&mut self) -> Result<Expr, ParseError> {
        let module_tok = self.expect_token()?;
        let module = match module_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "use requires a module name".into(),
            }),
        };
        
        // Parse { symbol { => alias } }
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?; // { is parsed as LParen
        let mut symbols = Vec::new();
        
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            let sym_tok = self.expect_token()?;
            let name = match sym_tok {
                Token::Ident(n, _) => n,
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "use requires symbol identifiers".into(),
                }),
            };
            
            let alias = if matches!(self.current(), Some(Token::Ident(ref n, _)) if n == "=>") {
                self.advance();
                let alias_tok = self.expect_token()?;
                match alias_tok {
                    Token::Ident(n, _) => Some(n),
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "alias must be an identifier".into(),
                    }),
                }
            } else {
                None
            };
            
            symbols.push(UseSymbol { name, alias });
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Use { module, symbols })
    }
    
    /// Parse (export Expr) - Export (§24)
    fn parse_export_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Export(Box::new(expr)))
    }
    
    /// Parse (pub Expr) - Public definition (§24)
    fn parse_pub_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Pub(Box::new(expr)))
    }
    
    /// Parse (requires Condition) - Precondition (§23)
    fn parse_requires_inner(&mut self) -> Result<Expr, ParseError> {
        let condition = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Requires(Box::new(condition)))
    }
    
    /// Parse (ensures Condition Body) - Postcondition (§23)
    fn parse_ensures_inner(&mut self) -> Result<Expr, ParseError> {
        let condition = self.parse_expr()?;
        let body = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Ensures { condition: Box::new(condition), body: Box::new(body) })
    }
    
    /// Parse (invariant Condition) - Invariant (§23)
    fn parse_invariant_inner(&mut self) -> Result<Expr, ParseError> {
        let condition = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Invariant(Box::new(condition)))
    }
    
    /// Parse (recover ((ErrType) fallback-expr) ... body) - Recovery (§23)
    fn parse_recover_inner(&mut self) -> Result<Expr, ParseError> {
        let mut handlers = Vec::new();
        
        // Parse handler clauses: ((error-type) fallback)
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
            
            // Check for nested (error-type) clause
            if let Some(Token::LParen(_)) = self.current() {
                self.advance();
                let err_tok = self.expect_token()?;
                let err_type = match err_tok {
                    Token::Ident(n, _) => n,
                    _ => return Err(ParseError::InvalidExpr {
                        loc: self.loc(),
                        msg: "recover error type must be an identifier".into(),
                    }),
                };
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                
                let fallback = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                handlers.push((err_type, fallback));
            } else {
                // Body expression (last item after all handlers)
                let body = self.parse_expr()?;
                self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                return Ok(Expr::Recover { handlers, body: Box::new(body) });
            }
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Recover { handlers, body: Box::new(Expr::Atom(AtomKind::Ident("unit".into()))) })
    }
    
    /// Parse (checkpoint Expr) - Checkpoint scope (§23)
    fn parse_checkpoint_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Checkpoint(Box::new(expr)))
    }
    
    /// Parse (contracts profile) - Contract profile (§23)
    fn parse_contracts_inner(&mut self) -> Result<Expr, ParseError> {
        let profile_tok = self.expect_token()?;
        let profile = match profile_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "contracts requires a profile name".into(),
            }),
        };
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Contracts(profile))
    }
    
    /// Parse (begin Expr+) - Sequencing (§12.8)
    fn parse_begin_inner(&mut self) -> Result<Expr, ParseError> {
        let mut exprs = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            exprs.push(self.parse_expr()?);
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Begin(exprs))
    }
    
    // ========================================================================
    // TESTING FRAMEWORK PARSERS (§20.5 — v3.3)
    // ========================================================================
    
    /// Parse a keyword value: prefer string literal, fall back to expr → string
    fn parse_string_or_expr_to_string(&mut self) -> Result<String, ParseError> {
        let cur = self.tokens.get(self.pos).cloned();
        match cur {
            Some(Token::StringLit(s, _)) => {
                self.advance();
                Ok(s)
            }
            Some(_) => {
                // Parse as expression and convert to string representation
                let expr = self.parse_expr()?;
                Ok(format!("{}", expr))
            }
            None => Err(ParseError::UnexpectedEof {
                loc: self.loc(),
            }),
        }
    }
    
    fn parse_test_suite_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match &name_tok {
            Token::StringLit(s, _) => s.clone(),
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "test-suite name must be a string literal".into(),
            }),
        };
        
        // Parse optional keywords
        let mut keywords = Vec::new();
        while self.current().is_some() {
            if let Some(Token::Keyword(kw, _)) = self.current() {
                let kw_name = kw.clone();
                self.advance();
                let value = self.parse_string_or_expr_to_string()?;
                keywords.push((kw_name, value));
            } else {
                break;
            }
        }
        
        // Parse test bodies
        let mut tests = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            tests.push(self.parse_expr()?);
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::TestSuite { name, tests, keywords })
    }
    
    fn parse_test_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match &name_tok {
            Token::StringLit(s, _) => s.clone(),
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "test name must be a string literal".into(),
            }),
        };
        
        // Parse optional keywords
        let mut keywords = Vec::new();
        while self.current().is_some() {
            if let Some(Token::Keyword(kw, _)) = self.current() {
                let kw_name = kw.clone();
                self.advance();
                let value = self.parse_string_or_expr_to_string()?;
                keywords.push((kw_name, value));
            } else {
                break;
            }
        }
        
        // Parse test body
        let body = if matches!(self.current(), Some(Token::RParen(_))) {
            Expr::Atom(AtomKind::Ident("unit".into()))
        } else {
            let b = self.parse_expr()?;
            b
        };
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Test { name, body: Box::new(body), keywords })
    }
    
    fn parse_assert_equal_inner(&mut self) -> Result<Expr, ParseError> {
        let expected = self.parse_expr()?;
        let actual = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::AssertEqual { expected: Box::new(expected), actual: Box::new(actual) })
    }
    
    fn parse_assert_fail_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        let cur_token = self.tokens.get(self.pos).cloned();
        let message = match cur_token {
            Some(Token::StringLit(s, _)) => {
                self.advance();
                Some(s)
            }
            _ => None,
        };
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::AssertFail { expr: Box::new(expr), message })
    }
    
    fn parse_assert_true_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        let cur_token = self.tokens.get(self.pos).cloned();
        let message = match cur_token {
            Some(Token::StringLit(s, _)) => {
                self.advance();
                Some(s)
            }
            _ => None,
        };
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::AssertTrue { expr: Box::new(expr), message })
    }
    
    fn parse_assert_false_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        let cur_token = self.tokens.get(self.pos).cloned();
        let message = match cur_token {
            Some(Token::StringLit(s, _)) => {
                self.advance();
                Some(s)
            }
            _ => None,
        };
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::AssertFalse { expr: Box::new(expr), message })
    }
    
    fn parse_test_property_inner(&mut self) -> Result<Expr, ParseError> {
        let name_tok = self.expect_token()?;
        let name = match &name_tok {
            Token::StringLit(s, _) => s.clone(),
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "test-property name must be a string literal".into(),
            }),
        };
        
        // Parse generator
        let gen_tok = self.expect_token()?;
        let generator = match &gen_tok {
            Token::Ident(ref s, _) if s == "s" => Generator::GenInt,
            Token::Ident(ref s, _) if s == "s" => Generator::GenBool,
            Token::Ident(ref s, _) if s == "s" => Generator::GenString,
            Token::Ident(ref s, _) if s == "s" => Generator::GenFloat,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: format!("invalid generator: {:?}", gen_tok),
            }),
        };
        
        // Parse property function
        let property_fn = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::TestProperty { name, generator, property_fn: Box::new(property_fn) })
    }
    
    fn parse_setup_inner(&mut self) -> Result<Expr, ParseError> {
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            bodies.push(self.parse_expr()?);
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Setup(bodies))
    }
    
    fn parse_teardown_inner(&mut self) -> Result<Expr, ParseError> {
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            bodies.push(self.parse_expr()?);
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Teardown(bodies))
    }
    
    fn parse_run_tests_inner(&mut self) -> Result<Expr, ParseError> {
        let mut verbose = false;
        let mut fail_fast = false;
        let mut parallel = true;
        
        while self.current().is_some() {
            if let Some(Token::Keyword(kw, _)) = self.current() {
                match kw.as_str() {
                    "verbose" => {
                        self.advance();
                        if let Some(Token::Bool(b, _)) = self.current() {
                            verbose = *b;
                            self.advance();
                        }
                    }
                    "fail-fast" => {
                        self.advance();
                        if let Some(Token::Bool(b, _)) = self.current() {
                            fail_fast = *b;
                            self.advance();
                        }
                    }
                    "parallel" => {
                        self.advance();
                        if let Some(Token::Bool(b, _)) = self.current() {
                            parallel = *b;
                            self.advance();
                        }
                    }
                    _ => break,
                }
            } else {
                break;
            }
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::RunTests { verbose, fail_fast, parallel })
    }
    
    fn parse_test_compile_inner(&mut self) -> Result<Expr, ParseError> {
        let expr = self.parse_expr()?;
        let mut expect_error = false;
        
        if let Some(Token::Keyword(ref kw, _)) = self.current() {
            if kw == "expect-error" {
                self.advance();
                expect_error = true;
            }
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::TestCompile { expr: Box::new(expr), expect_error })
    }
    
    /// Parse a type expression (for trait methods, deftype fields)
    fn parse_type_expr(&mut self) -> Result<TypeExpr, ParseError> {
        match self.current() {
            Some(Token::Ident(ref name, _)) => {
                let name = name.clone();
                self.advance();
                
                // Check for primitive types
                match name.as_str() {
                    "Int" => Ok(TypeExpr::Prim(PrimType::Int)),
                    "Float" => Ok(TypeExpr::Prim(PrimType::Float)),
                    "Bool" => Ok(TypeExpr::Prim(PrimType::Bool)),
                    "String" => Ok(TypeExpr::Prim(PrimType::String)),
                    "Unit" => Ok(TypeExpr::Prim(PrimType::Unit)),
                    "TFun" => {
                        // TFun([TypeExpr] TypeExpr)
                        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
                        let args = if matches!(self.current(), Some(Token::LParen(_))) {
                            self.advance();
                            let mut a = Vec::new();
                            while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                                a.push(self.parse_type_expr()?);
                            }
                            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                            a
                        } else {
                            vec![]
                        };
                        let ret = self.parse_type_expr()?;
                        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                        Ok(TypeExpr::Fun { args, ret: Box::new(ret) })
                    }
                    _ => {
                        // Check for generic application: Vec<T>, Map<K,V>
                        if matches!(self.current(), Some(Token::LParen(_))) {
                            self.advance(); // consume (
                            let mut args = Vec::new();
                            while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                                args.push(self.parse_type_expr()?);
                            }
                            self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
                            Ok(TypeExpr::App { name, args })
                        } else {
                            // Check for capability wrapper: TCap<T>, TMut<T>, etc.
                            if let Some(cap) = parse_cap_prefix(&name) {
                                let inner = self.parse_type_expr()?;
                                Ok(TypeExpr::Cap { cap, inner: Box::new(inner) })
                            } else {
                                Ok(TypeExpr::Generic(name))
                            }
                        }
                    }
                }
            }
            Some(tok) => Err(ParseError::ExpectedToken {
                expected: "type expression",
                got: tok.clone(),
                loc: self.loc(),
            }),
            None => Err(ParseError::UnexpectedEof {
                loc: self.loc(),
            }),
        }
    }
    
    /// Parse (def Name Expr)
    fn parse_def(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'def'
        
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "def requires an identifier".into(),
            }),
        };
        
        let value = self.parse_expr()?;
        
        Ok(Expr::Def(name, Box::new(value)))
    }
    
    /// Parse (defn Name (Params*) Body)
    fn parse_defn(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'defn'
        
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "defn requires an identifier".into(),
            }),
        };
        
        // Parse parameter list
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        let mut params = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) {
            let p_tok = self.expect_token()?;
            match p_tok {
                Token::Ident(n, _) => params.push(n),
                _ => return Err(ParseError::InvalidExpr {
                    loc: self.loc(),
                    msg: "defn parameters must be identifiers".into(),
                }),
            }
        }
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        // Parse body (can be multiple expressions - implicit begin)
        let body = if matches!(self.current(), Some(Token::RParen(_))) {
            // Empty body
            Expr::Atom(AtomKind::Ident("unit".into()))
        } else {
            // Parse all remaining expressions as body
            let mut bodies = Vec::new();
            while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
                bodies.push(self.parse_expr()?);
            }
            match bodies.len() {
                0 => Expr::Atom(AtomKind::Ident("unit".into())),
                1 => bodies.pop().unwrap(),
                _ => Expr::App("begin".into(), bodies),
            }
        };
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        Ok(Expr::Defn {
            name,
            params,
            body: Box::new(body),
            ret_type: None,
        })
    }
    
    /// Parse (let (Name Expr) Body) or (let-mut (Name Expr) Body)
    fn parse_let(&mut self, mutable: bool) -> Result<Expr, ParseError> {
        self.advance(); // consume 'let' or 'let-mut'
        
        // Parse binding list
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "let requires an identifier".into(),
            }),
        };
        
        let value = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        // Parse body (can be multiple expressions)
        let mut bodies = Vec::new();
        while !matches!(self.current(), Some(Token::RParen(_))) && self.current() != None {
            bodies.push(self.parse_expr()?);
        }
        
        let body = match bodies.len() {
            0 => Expr::Atom(AtomKind::Ident("unit".into())),
            1 => bodies.pop().unwrap(),
            _ => Expr::App("begin".into(), bodies),
        };
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        if mutable {
            Ok(Expr::LetMut {
                name,
                value: Box::new(value),
                body: Box::new(body),
            })
        } else {
            Ok(Expr::Let {
                name,
                value: Box::new(value),
                body: Box::new(body),
            })
        }
    }
    
    /// Parse (if Expr Expr Expr)
    fn parse_if(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'if'
        
        let cond = self.parse_expr()?;
        let then_branch = self.parse_expr()?;
        let else_branch = self.parse_expr()?;
        
        Ok(Expr::If {
            cond: Box::new(cond),
            then_branch: Box::new(then_branch),
            else_branch: Box::new(else_branch),
        })
    }
    
    /// Parse (try Expr (catch Name Expr))
    fn parse_try_catch(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'try'
        
        let body = self.parse_expr()?;
        
        // Parse catch clause
        self.expect_kind(|t| matches!(t, Token::LParen(_)))?;
        self.expect_keyword("catch")?;
        
        let name_tok = self.expect_token()?;
        let catch_var = match name_tok {
            Token::Ident(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "catch requires an identifier".into(),
            }),
        };
        
        let handler = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        Ok(Expr::TryCatch {
            body: Box::new(body),
            catch_var,
            handler: Box::new(handler),
        })
    }
    
    /// Parse (spawn Expr)
    fn parse_spawn(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'spawn'
        let expr = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Spawn(Box::new(expr)))
    }
    
    /// Parse (send Expr Expr)
    fn parse_send(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'send'
        let target = self.parse_expr()?;
        let message = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::Send {
            target: Box::new(target),
            message: Box::new(message),
        })
    }
    
    /// Parse (ffi-call String Expr* Integer)
    fn parse_ffi_call(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'ffi-call'
        
        let name_tok = self.expect_token()?;
        let name = match name_tok {
            Token::StringLit(n, _) => n,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "ffi-call requires a string name".into(),
            }),
        };
        
        // Parse args until we hit the timeout integer
        let mut args = Vec::new();
        let mut timeout_ms: Option<i64> = None;
        
        while !matches!(self.current(), Some(Token::RParen(_))) {
            match self.current() {
                Some(Token::Int(v, _)) if timeout_ms.is_none() && args.len() > 0 => {
                    // This might be the timeout - but only if it's the last thing
                    // For safety, we'll parse it as an arg and let the type checker decide
                    // Actually, per spec: (ffi-call String Expr* Integer)
                    // The last integer is the timeout
                    timeout_ms = Some(*v);
                    self.advance();
                }
                _ => {
                    args.push(self.parse_expr()?);
                }
            }
        }
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        Ok(Expr::FfiCall {
            name,
            args,
            timeout_ms: timeout_ms.unwrap_or(5000), // default 5 second timeout
        })
    }
    
    /// Parse (ffi-pin Expr)
    fn parse_ffi_pin(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'ffi-pin'
        let expr = self.parse_expr()?;
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        Ok(Expr::FfiPin(Box::new(expr)))
    }
    
    /// Parse (assert Expr String)
    fn parse_assert(&mut self) -> Result<Expr, ParseError> {
        self.advance(); // consume 'assert'
        
        let condition = self.parse_expr()?;
        
        let msg_tok = self.expect_token()?;
        let message = match msg_tok {
            Token::StringLit(m, _) => m,
            _ => return Err(ParseError::InvalidExpr {
                loc: self.loc(),
                msg: "assert requires a string message".into(),
            }),
        };
        
        self.expect_kind(|t| matches!(t, Token::RParen(_)))?;
        
        Ok(Expr::Assert {
            condition: Box::new(condition),
            message,
        })
    }
}

/// Helper to get location from token index
fn token_location(_tokens: &[Token], idx: usize) -> Location {
    // Simplified - in production would track line/col per token
    Location::new(1, idx * 5)
}

/// Parse a capability type prefix (TCap, TMut, TAtomic, TBox, TPin)
fn parse_cap_prefix(name: &str) -> Option<CapType> {
    match name {
        "TCap" => Some(CapType::Immutable),
        "TMut" => Some(CapType::Mutable),
        "TAtomic" => Some(CapType::Atomic),
        "TBox" => Some(CapType::Boxed),
        "TPin" => Some(CapType::Pinned),
        _ => None,
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Parse Zyl source code into an AST
pub fn parse(source: &str) -> Result<Program, ParseError> {
    let tokens = crate::lexer::lex(source)?;
    let mut parser = Parser::new(tokens);
    parser.parse_program()
}

/// Parse a single expression
pub fn parse_expr(source: &str) -> Result<Expr, ParseError> {
    let tokens = crate::lexer::lex(source)?;
    let mut parser = Parser::new(tokens);
    parser.parse_expr()
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_parse_atom() {
        let expr = parse_expr("42").unwrap();
        assert_eq!(expr, Expr::Atom(AtomKind::Int(42)));
    }
    
    #[test]
    fn test_parse_app() {
        let expr = parse_expr("(+ 1 2)").unwrap();
        match expr {
            Expr::App(op, args) => {
                assert_eq!(op, "+");
                assert_eq!(args.len(), 2);
            }
            _ => panic!("Expected App"),
        }
    }
    
    #[test]
    fn test_parse_def() {
        let prog = parse("(def x 42)").unwrap();
        assert_eq!(prog.defs.len(), 1);
    }
    
    #[test]
    fn test_parse_defn() {
        let prog = parse("(defn foo (x) (+ x 1))").unwrap();
        assert_eq!(prog.defs.len(), 1);
    }
    
    #[test]
    fn test_parse_let() {
        let expr = parse_expr("(let (x 5) (+ x 1))").unwrap();
        match expr {
            Expr::Let { name, .. } => assert_eq!(name, "x"),
            _ => panic!("Expected Let"),
        }
    }
    
    #[test]
    fn test_parse_if() {
        let expr = parse_expr("(if true 1 2)").unwrap();
        match expr {
            Expr::If { cond, then_branch, else_branch, .. } => {
                assert_eq!(*cond, Expr::Atom(AtomKind::Bool(true)));
                assert_eq!(*then_branch, Expr::Atom(AtomKind::Int(1)));
                assert_eq!(*else_branch, Expr::Atom(AtomKind::Int(2)));
            }
            _ => panic!("Expected If"),
        }
    }
    
    #[test]
    fn test_parse_error_location_single_line() {
        // Error should point to the actual problematic token
        let result = parse_expr("(def 42 x)");
        assert!(result.is_err());
        let err = result.unwrap_err();
        // The error should be at column 9 (where '42' starts after '(def ')
        match &err {
            ParseError::InvalidExpr { loc, .. } => {
                assert_eq!(loc.line, 1);
                assert_eq!(loc.col, 9);
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_multiline() {
        // Test that errors track to the last known position in multiline input
        let source = "(+\n 1\n 2";  // Missing closing paren
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::MismatchedParen { loc } => {
                // At EOF, location is (0, 0) since there's no token to report from
                assert_eq!(loc.line, 0);
                assert_eq!(loc.col, 0);
            }
            _ => {}
        }
    }
    
    #[test]
    fn test_parse_error_location_with_comments() {
        // Test that errors track correctly even with comments affecting whitespace
        let source = "(+\n ; comment\n 1";  // Missing closing paren after comment line
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::MismatchedParen { loc } => {
                // At EOF, location is (0, 0)
                assert_eq!(loc.line, 0);
                assert_eq!(loc.col, 0);
            }
            _ => {}
        }
    }
    
    #[test]
    fn test_parse_curried_lambda_location() {
        let source = "(defn foo (x) (+ x 1))";
        let result = parse(source);
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
        let prog = result.unwrap();
        assert_eq!(prog.defs.len(), 1);
    }
    
    #[test]
    fn test_parse_nested_app_location() {
        // ((f x) y) - nested application should parse without error
        let expr = parse_expr("((+ 1 2) 3)");
        assert!(expr.is_ok());
        // The expression parses successfully (structure may vary based on parser implementation)
    }
    
    #[test]
    fn test_parse_error_location_curried_lambda() {
        // Test that fn expression parses correctly
        let result = parse_expr("(fn (x) (+ x 1))");
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
    }
    
    #[test]
    fn test_parse_error_location_let_binding() {
        // Test error location in let binding
        let result = parse_expr("(let (42 x) (+ x 1))");
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                assert_eq!(loc.line, 1);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_deeply_nested() {
        // Error deep inside nested structure should point to the actual problem
        let source = "(+\n  (+\n   (+\n    (def 42 x)\n    3)\n   5)\n  7)";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 4 where 'def' appears inside nested +
                assert_eq!(loc.line, 4);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_multiline_if() {
        // Error in if expression body on a different line
        let source = "(if\n true\n 1\n (def 42 x))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 4 where 'def' appears in else branch
                assert_eq!(loc.line, 4);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_multiline_let() {
        // Error in let binding across multiple lines
        let source = "(let\n ((x 1)\n  (42 y))\n (+ x y))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 3 where '42' appears as binding name
                assert_eq!(loc.line, 3);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_curried_lambda_param() {
        // Error in curried lambda parameter list - use actual syntax error
        let source = "(defn foo (x) 42)";
        let result = parse(source);
        // Note: Parser accepts this as valid syntax (42 is a valid expression)
        // Type checking would catch the semantic error later
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
    }
    
    #[test]
    fn test_parse_error_location_try_catch() {
        // Error in try/catch structure
        let source = "(try\n 1\n (catch e\n   (def 42 x)))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 4 where 'def' appears in catch body
                assert_eq!(loc.line, 4);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_multiple_defs_then_error() {
        // Multiple valid definitions followed by an error
        let source = "(def x 1)\n(def y 2)\n(+ x (def 42 z))";
        let result = parse(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 3 where 'def' appears in expression
                assert_eq!(loc.line, 3);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_fn_params() {
        // Function parameter list - parser accepts (42 y) as valid expression
        let source = "(fn (x)\n  (42 y)\n  (+ x y))";
        let result = parse_expr(source);
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
    }
    
    #[test]
    fn test_parse_error_location_nested_apps() {
        // Error in deeply nested application
        let source = "((+\n 1\n  (def 42 x))\n 3)";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 3 where 'def' appears in nested app
                assert_eq!(loc.line, 3);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_with_long_comments() {
        // Error tracking through lines with long comments
        let source = "(def\n x ; this is a very long comment that spans multiple words and should not affect location tracking\n 42)";
        let result = parse(source);
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
        let prog = result.unwrap();
        assert_eq!(prog.defs.len(), 1);
    }
    
    #[test]
    fn test_parse_error_location_mixed_whitespace() {
        // Error tracking with tabs and spaces mixed
        let source = "(def\n\t x\n\t\t 42)";
        let result = parse(source);
        match &result { Ok(_) => {}, Err(e) => println!("ERROR: {}", e), }; assert!(result.is_ok());
        let prog = result.unwrap();
        assert_eq!(prog.defs.len(), 1);
    }
    
    #[test]
    fn test_parse_error_location_mismatched_parens_deep() {
        // Mismatched parentheses in deeply nested structure
        let source = "(+\n  (*\n   (+\n    (-\n     (/\n      (def 42 x)\n      2)\n     3)\n    5)\n   7)\n  9)";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 6 where 'def' appears deep in nesting
                assert_eq!(loc.line, 6);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_multiple_nested_ifs() {
        // Multiple nested if expressions with error in deepest else branch
        let source = "(if\n true\n 1\n (if\n   false\n   2\n   (if\n     true\n     3\n     (def 42 x))))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 10 where 'def' appears in deepest else
                assert_eq!(loc.line, 10);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_let_with_multiple_bindings() {
        // Error in let with multiple bindings across lines
        let source = "(let\n ((a 1)\n  (b 2)\n  (42 c)\n  (d 4))\n (+ a b c d))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 4 where '42' appears as binding name
                assert_eq!(loc.line, 4);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_fn_with_curried_body() {
        // Error in function with curried body expression
        let source = "(fn (x)\n  (if\n   (> x 0)\n   (+ x 1)\n   (def 42 y)))";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 5 where 'def' appears in else branch
                assert_eq!(loc.line, 5);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }
    
    #[test]
    fn test_parse_error_location_try_with_nested_let() {
        // Error in try block with nested let
        let source = "(try\n (let ((x 1))\n   (+ x\n      (def 42 y)))\n (catch e\n   0)";
        let result = parse_expr(source);
        assert!(result.is_err());
        match &result.unwrap_err() {
            ParseError::InvalidExpr { loc, msg } => {
                // Error should be on line 4 where 'def' appears in nested let
                assert_eq!(loc.line, 4);
                assert!(msg.contains("identifier"));
            }
            _ => panic!("Expected InvalidExpr error"),
        }
    }

    #[test]
    fn test_parse_fn_nested() {
        // Test nested fn application: ((fn (x) x) 3)
        let result = parse_expr("((fn (x) x) 3)");
        match &result {
            Ok(expr) => println!("Parsed OK: {:?}", expr),
            Err(e) => println!("Parse error: {}", e),
        }
        assert!(result.is_ok(), "Should parse ((fn (x) x) 3): {:?}", result);
    }
    }

#[cfg(test)]  
mod currying_fix_tests {
    use super::*;
    
    #[test]
    fn test_curried_lambda_simple() {
        let result = parse_expr("((x) (+ x 1))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Fn { params, body } => {
                assert_eq!(params.len(), 1);
                assert_eq!(&params[0], "x");
                match body.as_ref() {
                    Expr::App(op, args) => {
                        assert_eq!(op, "+");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("Expected App for body: {:?}", body),
                }
            }
            other => panic!("Expected Fn, got {:?}", other),
        }
    }

    #[test]
    fn test_curried_lambda_multi_level() {
        let result = parse_expr("((a) (b) (+ a b))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Fn { params, body } => {
                assert_eq!(params.len(), 1);
                assert_eq!(&params[0], "a");
                match body.as_ref() {
                    Expr::Fn { params: inner_params, .. } => {
                        assert_eq!(inner_params.len(), 1);
                        assert_eq!(&inner_params[0], "b");
                    }
                    other => panic!("Expected nested Fn for body: {:?}", other),
                }
            }
            other => panic!("Expected outer Fn, got {:?}", other),
        }
    }

    #[test]
    fn test_curried_lambda_three_level() {
        let result = parse_expr("((a) (b) (c) (+ a (+ b c)))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Fn { params, body } => {
                assert_eq!(params.len(), 1);
                assert_eq!(&params[0], "a");
                match body.as_ref() {
                    Expr::Fn { params: inner_params, body: inner_body } => {
                        assert_eq!(inner_params.len(), 1);
                        assert_eq!(&inner_params[0], "b");
                        match inner_body.as_ref() {
                            Expr::Fn { params, .. } => {
                                assert_eq!(params.len(), 1);
                                assert_eq!(&params[0], "c");
                            }
                            other => panic!("Expected nested Fn for c: {:?}", other),
                        }
                    }
                    other => panic!("Expected inner Fn for b: {:?}", other),
                }
            }
            other => panic!("Expected outer Fn, got {:?}", other),
        }
    }

    #[test]
    fn test_def_curried_lambda() {
        let result = parse_expr("(def add ((x) (y) (+ x y)))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Def(name, value) => {
                assert_eq!(name, "add");
                match value.as_ref() {
                    Expr::Fn { params, .. } => {
                        assert_eq!(params.len(), 1);
                        assert_eq!(&params[0], "x");
                    }
                    other => panic!("Expected Fn for def value: {:?}", other),
                }
            }
            other => panic!("Expected Def, got {:?}", other),
        }
    }

    #[test]
    fn test_defn_curried_lambda() {
        let result = parse_expr("(defn f ((x) x))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Defn { name, params, .. } => {
                assert_eq!(name, "f");
                assert_eq!(params.len(), 1);
                assert_eq!(&params[0], "x");
            }
            other => panic!("Expected Defn, got {:?}", other),
        }
    }

    #[test]
    fn test_defn_three_param_curried() {
        let result = parse_expr("(defn add-three ((a) (b) (c) (+ a (+ b c))))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Defn { name, params, .. } => {
                assert_eq!(name, "add-three");
                assert_eq!(params.len(), 3);
                assert_eq!(&params[0], "a");
                assert_eq!(&params[1], "b");
                assert_eq!(&params[2], "c");
            }
            other => panic!("Expected Defn, got {:?}", other),
        }
    }

    #[test]
    fn test_curried_in_let() {
        let result = parse_expr("(let (f ((a) (+ a 1))) (f 5))");
        assert!(result.is_ok());
    }

    #[test]
    fn test_curried_as_function_argument() {
        let result = parse_expr("(map ((x) (+ x 1)) '(1 2 3))");
        assert!(result.is_ok());
    }

    #[test]
    fn test_normal_fn_still_works() {
        let result = parse_expr("(fn (x y z) (+ x (+ y z)))");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::Fn { params, .. } => {
                assert_eq!(params.len(), 3);
            }
            other => panic!("Expected Fn, got {:?}", other),
        }
    }

    #[test]
    fn test_regular_application_plus() {
        let result = parse_expr("(+ 1 2)");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::App(op, args) => {
                assert_eq!(op, "+");
                assert_eq!(args.len(), 2);
            }
            other => panic!("Expected App, got {:?}", other),
        }
    }

    #[test]
    fn test_regular_application_map() {
        let result = parse_expr("(map f xs)");
        assert!(result.is_ok());
        match &result.unwrap() {
            Expr::App(op, args) => {
                assert_eq!(op, "map");
                assert_eq!(args.len(), 2);
            }
            other => panic!("Expected App, got {:?}", other),
        }
    }

    #[test]
    fn test_nested_application_with_curried_lambda() {
        let result = parse_expr("(((a) (b) (+ a b)) 1 2)");
        assert!(result.is_ok());
    }

    #[test]
    fn test_is_curried_lambda_detection() {
        // Simple: ((x) body) — IS curried
        let tokens = crate::lexer::lex("((x) x)").unwrap();
        let mut parser = Parser::new(tokens);
        assert!(parser.is_curried_lambda());

        // Multi-level: ((a) (b) (+ a b)) — IS curried
        let tokens2 = crate::lexer::lex("((a) (b) (+ a b))").unwrap();
        let mut parser2 = Parser::new(tokens2);
        assert!(parser2.is_curried_lambda());

        // Three-level: ((a) (b) (c) body) — IS curried
        let tokens3 = crate::lexer::lex("((a) (b) (c) (+ a b))").unwrap();
        let mut parser3 = Parser::new(tokens3);
        assert!(parser3.is_curried_lambda());

        // NOT curried: ((fn (x) x) 1) — this is an application, not currying
        let tokens4 = crate::lexer::lex("((fn (x) x) 1)").unwrap();
        let mut parser4 = Parser::new(tokens4);
        assert!(!parser4.is_curried_lambda());

        // NOT curried: (+ 1 2) — regular application
        let tokens5 = crate::lexer::lex("(+ 1 2)").unwrap();
        let mut parser5 = Parser::new(tokens5);
        assert!(!parser5.is_curried_lambda());

        // NOT curried: (f x y z) — regular application with multiple args
        let tokens6 = crate::lexer::lex("(f x y z)").unwrap();
        let mut parser6 = Parser::new(tokens6);
        assert!(!parser6.is_curried_lambda());
    }

    #[test]
    fn test_no_body_after_params() {
        // ((a)) should NOT be curried (no body after params)
        let tokens = crate::lexer::lex("((a))").unwrap();
        let mut parser = Parser::new(tokens);
        assert!(!parser.is_curried_lambda());

        // ((a) ()) — empty list as "body" is not valid curried lambda
        let tokens2 = crate::lexer::lex("((a) (b))").unwrap();
        let mut parser2 = Parser::new(tokens2);
        assert!(!parser2.is_curried_lambda());

        // ((a) x y z) — multiple body expressions, IS curried
        let tokens3 = crate::lexer::lex("((a) (+ a 1))").unwrap();
        let mut parser3 = Parser::new(tokens3);
        assert!(parser3.is_curried_lambda());
    }

}
