use crate::error::{Location, Span, ZylError};

/// Token types produced by the lexer.
#[derive(Debug, Clone)]
pub enum TokenKind {
    Ident(String),
    Integer(i64),
    Float(f64),
    StringLit(String),
    Bool(bool),
    Symbol(String),  // ~ prefixed
    Keyword(String), // : prefixed

    LParen,   // (
    RParen,   // )
    LBrace,   // {
    RBrace,   // }
    Colon,    // :
    LBracket, // [
    RBracket, // ]

    EOF,
}

impl PartialEq for TokenKind {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (TokenKind::Ident(a), TokenKind::Ident(b)) => a == b,
            (TokenKind::Integer(a), TokenKind::Integer(b)) => a == b,
            (TokenKind::Float(a), TokenKind::Float(b)) => a.to_bits() == b.to_bits(),
            (TokenKind::StringLit(a), TokenKind::StringLit(b)) => a == b,
            (TokenKind::Bool(a), TokenKind::Bool(b)) => a == b,
            (TokenKind::Symbol(a), TokenKind::Symbol(b)) => a == b,
            (TokenKind::Keyword(a), TokenKind::Keyword(b)) => a == b,
            (TokenKind::LParen, TokenKind::LParen)
            | (TokenKind::RParen, TokenKind::RParen)
            | (TokenKind::LBrace, TokenKind::LBrace)
            | (TokenKind::RBrace, TokenKind::RBrace)
            | (TokenKind::Colon, TokenKind::Colon)
            | (TokenKind::LBracket, TokenKind::LBracket)
            | (TokenKind::RBracket, TokenKind::RBracket)
            | (TokenKind::EOF, TokenKind::EOF) => true,
            _ => false,
        }
    }
}

impl std::fmt::Display for TokenKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TokenKind::Ident(s) => write!(f, "ident '{}'", s),
            TokenKind::Integer(i) => write!(f, "integer {}", i),
            TokenKind::Float(fl) => write!(f, "float {}", fl),
            TokenKind::StringLit(s) => write!(f, "string \"{}\"", s.replace('\n', "\\n")),
            TokenKind::Bool(b) => f.write_str(if *b { "true" } else { "false" }),
            TokenKind::Symbol(s) => write!(f, "symbol ~{}", s),
            TokenKind::Keyword(kw) => write!(f, "keyword :{}", kw),
            TokenKind::LParen => f.write_str("'('"),
            TokenKind::RParen => f.write_str("')'"),
            TokenKind::LBrace => f.write_str("'{'"),
            TokenKind::RBrace => f.write_str("'}'"),
            TokenKind::Colon => f.write_str("':'"),
            TokenKind::LBracket => f.write_str("'['"),
            TokenKind::RBracket => f.write_str("']'"),
            TokenKind::EOF => f.write_str("EOF"),
        }
    }
}

/// A token with its source location.
#[derive(Debug, Clone)]
pub struct Token {
    pub kind: TokenKind,
    pub span: Span,
}

impl std::fmt::Display for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}@{}", self.kind, self.span.start)
    }
}

/// Strip line comments from source text.
fn strip_comments(src: &str) -> String {
    let mut result = String::with_capacity(src.len());
    for line in src.lines() {
        if let Some(pos) = line.find(';') {
            result.push_str(&line[..pos]);
        } else {
            result.push_str(line);
        }
        result.push('\n');
    }
    result
}

/// The lexer: source text → Vec<Token>.
pub fn tokenize(src: &str) -> Result<Vec<Token>, ZylError> {
    let src = strip_comments(src);
    let chars: Vec<char> = src.chars().collect();
    let mut tokens = Vec::new();
    let mut pos = 0;

    while pos < chars.len() {
        // Skip whitespace
        if chars[pos].is_whitespace() {
            pos += 1;
            continue;
        }

        let start_line = count_lines(&chars, pos);
        let start_col = col_from_pos(&chars, pos);

        match chars[pos] {
            '(' => {
                tokens.push(Token {
                    kind: TokenKind::LParen,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            ')' => {
                tokens.push(Token {
                    kind: TokenKind::RParen,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            '{' => {
                tokens.push(Token {
                    kind: TokenKind::LBrace,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            '}' => {
                tokens.push(Token {
                    kind: TokenKind::RBrace,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            '[' => {
                tokens.push(Token {
                    kind: TokenKind::LBracket,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            ']' => {
                tokens.push(Token {
                    kind: TokenKind::RBracket,
                    span: make_span(&chars, pos, start_line, start_col),
                });
                pos += 1;
            }
            ':' => {
                // Could be a keyword (:foo) or just a colon token.
                // Check if next non-whitespace is an identifier char (not another : or delimiter).
                let mut peek = pos + 1;
                while peek < chars.len() && chars[peek].is_whitespace() {
                    peek += 1;
                }
                if peek < chars.len()
                    && !chars[peek].is_whitespace()
                    && !"(){}[]:~".contains(chars[peek])
                {
                    // It's a keyword — lex the identifier part.
                    let (kw, end) = read_ident(&chars, peek);
                    let line = count_lines(&chars, pos);
                    let col = col_from_pos(&chars, pos);
                    tokens.push(Token {
                        kind: TokenKind::Keyword(kw),
                        span: make_span(&chars, pos, line, col),
                    });
                    pos = end;
                } else {
                    // Standalone colon token.
                    tokens.push(Token {
                        kind: TokenKind::Colon,
                        span: make_span(&chars, pos, start_line, start_col),
                    });
                    pos += 1;
                }
            }
            '~' => {
                let mut peek = pos + 1;
                while peek < chars.len() && chars[peek].is_whitespace() {
                    peek += 1;
                }
                if peek < chars.len()
                    && !chars[peek].is_whitespace()
                    && !"(){}[]:~".contains(chars[peek])
                {
                    let (sym, end) = read_ident(&chars, peek);
                    let line = count_lines(&chars, pos);
                    let col = col_from_pos(&chars, pos);
                    tokens.push(Token {
                        kind: TokenKind::Symbol(sym),
                        span: make_span(&chars, pos, line, col),
                    });
                    pos = end;
                } else {
                    return Err(ZylError::E_INVALID_CHAR(
                        Location {
                            line: start_line,
                            col: start_col,
                        },
                        '~',
                    ));
                }
            }
            '"' => {
                let (s, end_pos) = read_string(&chars, pos + 1)?;
                let line = count_lines(&chars, pos);
                let col = col_from_pos(&chars, pos);
                tokens.push(Token {
                    kind: TokenKind::StringLit(s),
                    span: make_span(&chars, pos, line, col),
                });
                pos = end_pos + 1; // skip closing quote
            }
            c if c.is_ascii_digit() || (c == '-' && is_number_start(&chars, pos)) => {
                let (num_str, end) = read_numeric(&chars, pos);
                let line = count_lines(&chars, pos);
                let col = col_from_pos(&chars, pos);

                if num_str.contains('.') || num_str.to_lowercase().contains('e') {
                    match num_str.parse::<f64>() {
                        Ok(v) => tokens.push(Token {
                            kind: TokenKind::Float(v),
                            span: make_span(&chars, pos, line, col),
                        }),
                        Err(_) => {
                            return Err(ZylError::E_FLOAT_OVERFLOW(
                                make_span(&chars, pos, line, col),
                                num_str,
                            ))
                        }
                    }
                } else {
                    match num_str.parse::<i64>() {
                        Ok(v) => tokens.push(Token {
                            kind: TokenKind::Integer(v),
                            span: make_span(&chars, pos, line, col),
                        }),
                        Err(_) => {
                            return Err(ZylError::E_INTEGER_OVERFLOW(
                                make_span(&chars, pos, line, col),
                                num_str,
                            ))
                        }
                    }
                }
                pos = end;
            }
            c if is_ident_start(c) => {
                let (ident, end) = read_ident(&chars, pos);
                // Check for keyword/boolean literals that look like identifiers.
                let line = count_lines(&chars, pos);
                let col = col_from_pos(&chars, pos);

                if ident == "true" || ident == "false" {
                    tokens.push(Token {
                        kind: TokenKind::Bool(ident == "true"),
                        span: make_span(&chars, pos, line, col),
                    });
                } else {
                    tokens.push(Token {
                        kind: TokenKind::Ident(ident),
                        span: make_span(&chars, pos, line, col),
                    });
                }
                pos = end;
            }
            c => {
                return Err(ZylError::E_INVALID_CHAR(
                    Location {
                        line: start_line,
                        col: start_col,
                    },
                    c,
                ));
            }
        }
    }

    let eof_line = count_lines(&chars, chars.len());
    let eof_col = if !chars.is_empty() && chars[chars.len() - 1] != '\n' {
        // Last char wasn't a newline; col is position in last line.
        let mut last_start = chars.len();
        for i in (0..chars.len()).rev() {
            if chars[i] == '\n' {
                last_start = i + 1;
                break;
            }
        }
        chars.len() - last_start + 1
    } else {
        1
    };
    tokens.push(Token {
        kind: TokenKind::EOF,
        span: make_span(&chars, chars.len(), eof_line, eof_col),
    });

    Ok(tokens)
}

// ─── Lexer helpers ──────────────────────────────────────────────────────

fn is_ident_start(c: char) -> bool {
    c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!' | '+' | '/' | '=' | '<' | '>' | '*')
}

fn is_ident_continue(c: char) -> bool {
    c.is_alphanumeric() || matches!(c, '_' | '-' | '?' | '!' | '/' | '=' | '+')
}

fn read_ident(chars: &[char], start: usize) -> (String, usize) {
    let mut end = start + 1; // consume at least the first char if it's an ident_start
    while end < chars.len() && is_ident_continue(chars[end]) {
        end += 1;
    }
    (chars[start..end].iter().collect(), end)
}

fn read_string(chars: &[char], start: usize) -> Result<(String, usize), ZylError> {
    let mut s = String::new();
    let mut i = start;
    while i < chars.len() {
        if chars[i] == '\\' && i + 1 < chars.len() {
            match chars[i + 1] {
                'n' => {
                    s.push('\n');
                    i += 2;
                }
                't' => {
                    s.push('\t');
                    i += 2;
                }
                '"' => {
                    s.push('"');
                    i += 2;
                }
                '\\' => {
                    s.push('\\');
                    i += 2;
                }
                _ => {
                    return Err(ZylError::E_UNTERMINATED_STRING(make_span(
                        chars,
                        start - 1,
                        count_lines(chars, start),
                        col_from_pos(chars, start),
                    )))
                } // -1 to include opening quote
            }
        } else if chars[i] == '"' {
            return Ok((s, i));
        } else {
            s.push(chars[i]);
            i += 1;
        }
    }
    Err(ZylError::E_UNTERMINATED_STRING(make_span(
        chars,
        start - 1,
        count_lines(chars, start),
        col_from_pos(chars, start),
    )))
}

fn is_number_start(chars: &[char], pos: usize) -> bool {
    if chars[pos] != '-' {
        return false;
    }
    let i = pos + 1;
    i < chars.len() && chars[i].is_ascii_digit()
}

fn read_numeric(chars: &[char], start: usize) -> (String, usize) {
    let mut s = String::new();
    let mut i = start;
    if chars[i] == '-' {
        s.push('-');
        i += 1;
    }
    while i < chars.len() && (chars[i].is_ascii_digit() || chars[i] == '.') {
        s.push(chars[i]);
        i += 1;
    }
    // Exponent notation
    if i < chars.len() && (chars[i] == 'e' || chars[i] == 'E') {
        s.push(chars[i]);
        i += 1;
        if i < chars.len() && (chars[i] == '+' || chars[i] == '-') {
            s.push(chars[i]);
            i += 1;
        }
        while i < chars.len() && chars[i].is_ascii_digit() {
            s.push(chars[i]);
            i += 1;
        }
    }
    (s, i)
}

fn count_lines(chars: &[char], pos: usize) -> usize {
    let mut lines = 1usize;
    for c in &chars[..pos] {
        if *c == '\n' {
            lines += 1;
        }
    }
    lines
}

fn col_from_pos(chars: &[char], pos: usize) -> usize {
    let line_start = chars[..pos]
        .iter()
        .rposition(|&c| c == '\n')
        .map(|i| i + 1)
        .unwrap_or(0);
    (pos - line_start) + 1
}

fn make_span(chars: &[char], pos: usize, line: usize, col: usize) -> crate::error::Span {
    let end_col = if chars.get(pos).map(|c| *c == '\n').unwrap_or(false) || pos >= chars.len() {
        // Newline or EOF at this position — span is zero-width.
        col
    } else {
        col + 1
    };

    crate::error::Span {
        start: Location { line, col },
        end: if end_col > col || pos >= chars.len() {
            // Check for newline at this position to determine end location.
            let mut e_line = line;
            let mut e_col = end_col;
            if pos < chars.len() && chars[pos] == '\n' {
                e_line += 1;
                e_col = 1;
            } else if pos >= chars.len() || (end_col > col) {
                // Single-char span.
            }
            Location {
                line: e_line,
                col: e_col,
            }
        } else {
            Location { line, col: end_col }
        },
    }
}
