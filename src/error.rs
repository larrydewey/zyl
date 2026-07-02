use thiserror::Error;

/// Source location in the input stream.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Location {
    pub line: usize,
    pub col: usize,
}

impl std::fmt::Display for Location {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}:{}", self.line, self.col)
    }
}

/// A span covering a range of source text.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Span {
    pub start: Location,
    pub end: Location,
}

impl Default for Span {
    fn default() -> Self {
        Self {
            start: Location { line: 0, col: 0 },
            end: Location { line: 0, col: 0 },
        }
    }
}

impl std::fmt::Display for Span {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}-{}", self.start, self.end)
    }
}

/// All error codes from spec §28.
#[derive(Debug, Error, Clone, PartialEq, Eq)]
pub enum ZylError {
    // --- Lexer errors (E_LEX_*) ---
    #[error("lexer: unterminated string at {}", .0)]
    E_UNTERMINATED_STRING(Span),

    #[error("lexer: invalid character '{}' at {}", .1, .0)]
    E_INVALID_CHAR(Location, char),

    #[error("lexer: integer overflow in literal '{}'", .1)]
    E_INTEGER_OVERFLOW(Span, String),

    #[error("lexer: float overflow in literal '{}'", .1)]
    E_FLOAT_OVERFLOW(Span, String),

    #[error("lexer: unexpected EOF while expecting '{}' at {}", .1, .0)]
    E_UNEXPECTED_EOF(Location, &'static str),

    // --- Parser errors (E_PARSE_*) ---
    #[error("parser: expected ')' but found {} at {}", .1, .0)]
    E_EXPECTED_RPAREN(Span, String),

    #[error("parser: expected ']' but found {} at {}", .1, .0)]
    E_EXPECTED_RBRACKET(Span, String),

    #[error("parser: expected '}}' but found {} at {}", .1, .0)]
    E_EXPECTED_RCURLY(Span, String),

    #[error("parser: unexpected token '{}' in expression context at {}", .1, .0)]
    E_UNEXPECTED_TOKEN_IN_EXPR(Span, String),

    #[error("parser: expected an expression but found {} at {}", .1, .0)]
    E_EXPECTED_EXPRESSION(Span, String),

    #[error("parser: empty list is not a valid expression at {}", .0)]
    E_EMPTY_LIST(Span),

    #[error("parser: atom cannot be used as operator in prefix position at {}", .0)]
    E_ATOM_AS_OPERATOR(Span),

    // --- General errors (E_* from spec §28) ---
    #[error("runtime: user error - {} at {}", .1, .0)]
    E_USER_ERROR(Span, String),

    #[error("aliasing: mutable reference conflict at {}", .0)]
    E_MUT_CONFLICT(Span),

    #[error("assertion: condition failed - {} at {}", .1.as_deref().unwrap_or(""), .0)]
    E_ASSERT_FAIL(Span, Option<String>),

    #[error("ffi: call exceeded timeout of {}ms at {}", .1, .0)]
    E_FFI_TIMEOUT(Span, u64),

    #[error("region: value escapes region constraint at {}", .0)]
    E_REGION_ESCAPE(Span),

    #[error("macro: expansion loop detected (max depth exceeded)")]
    E_MACRO_NON_TERMINATION,

    #[error("match: non-exhaustive pattern match at {} — missing cases: {}", .0, .1)]
    E_MATCH_NONEXHAUSTIVE(Span, String),

    #[error("variable: use of uninitialized variable '{}' at {}", .1, .0)]
    E_UNINITIALIZED_USE(Span, String),

    #[error("capability: TMut leaked across boundary at {}", .0)]
    E_CAPABILITY_LEAK(Span),

    #[error("trait: no implementation found for '{}'", .1)]
    E_TRAIT_NOT_FOUND(Span, String),

    #[error("trait: duplicate impl of '{}' for '{}' at {}", .1, .2, .0)]
    E_DUPLICATE_IMPL(Span, String, String),

    #[error("macro: illegal runtime access in macro expansion")]
    E_MACRO_ILLEGAL_ACCESS,

    #[error("contract: contract violation - {} at {}", .1, .0)]
    E_CONTRACT_VIOLATION(Span, String),

    #[error("numeric: integer overflow at {}", .0)]
    E_OVERFLOW(Span),

    #[error("numeric: division by zero at {}", .0)]
    E_DIVISION_BY_ZERO(Span),

    #[error("test: assertion failed - {}", .0)]
    E_TEST_FAILURE(String),

    #[error("test: runner error - {}", .0)]
    E_TEST_RUNNER_ERROR(String),

    #[error("trait: cannot derive '{}' for type '{}' at {}", .1, .2, .0)]
    E_TRAIT_NOT_DERIVABLE(Span, String, String),

    // --- Reserved keyword errors (Phase 1.5) ---
    #[error("parser: reserved keyword '{}' cannot be used as identifier at {}", .1, .0)]
    E_RESERVED_KEYWORD(Span, String),
}

/// A result carrying a ZylError.
pub type Result<T> = std::result::Result<T, ZylError>;
