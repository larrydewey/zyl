//! Lexical analyzer for Zyl
//! 
//! Per specification section 1:
//! Tokens: IDENTIFIER | INTEGER | FLOAT | STRING | BOOLEAN
//!         "(" | ")" | SYMBOL | KEYWORD
//! Comments: ; line comment
//! Whitespace: token separator only

use crate::ast::Location;
use thiserror::Error;

// ============================================================================
// TOKENS (Section 1)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    /// Left parenthesis with location
    LParen(Location),
    /// Right parenthesis with location
    RParen(Location),
    /// Integer literal with location
    Int(i64, Location),
    /// Float literal with location
    Float(f64, Location),
    /// Boolean literal with location
    Bool(bool, Location),
    /// String literal with location
    StringLit(String, Location),
    /// Identifier / symbol with location
    Ident(String, Location),
    /// Keyword (starts with :) with location
    Keyword(String, Location),
    /// Single quote prefix: '(expr) → (quote expr) with location
    Quote(Location),
    /// Line comment (discarded) with location
    Comment(Location),
    /// End of file with location
    Eof(Location),
}

impl Token {
    pub fn location(&self) -> Location {
        match self {
            Token::LParen(loc) => *loc,
            Token::RParen(loc) => *loc,
            Token::Int(_, loc) => *loc,
            Token::Float(_, loc) => *loc,
            Token::Bool(_, loc) => *loc,
            Token::StringLit(_, loc) => *loc,
            Token::Ident(_, loc) => *loc,
            Token::Keyword(_, loc) => *loc,
            Token::Quote(loc) => *loc,
            Token::Comment(loc) => *loc,
            Token::Eof(loc) => *loc,
        }
    }
}

impl std::fmt::Display for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Token::LParen(_) => write!(f, "("),
            Token::RParen(_) => write!(f, ")"),
            Token::Int(v, _) => write!(f, "{}", v),
            Token::Float(v, _) => write!(f, "{}", v),
            Token::Bool(v, _) => write!(f, "{}", v),
            Token::StringLit(v, _) => write!(f, "\"{}\"", v),
            Token::Ident(v, _) => write!(f, "{}", v),
            Token::Keyword(v, _) => write!(f, ":{}", v),
            Token::Quote(_) => write!(f, "'"),
            Token::Comment(_) => write!(f, ";"),
            Token::Eof(_) => write!(f, "<EOF>"),
        }
    }
}

// ============================================================================
// ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error, Clone)]
pub enum LexError {
    #[error("Unexpected character '{char}' at {loc}")]
    UnexpectedChar { char: char, loc: Location },
    
    #[error("Unterminated string at {loc}")]
    UnterminatedString { loc: Location },
    
    #[error("Invalid numeric literal at {loc}")]
    InvalidNumber { loc: Location },
    
    #[error("Invalid identifier at {loc}")]
    InvalidIdent { loc: Location },
}

// ============================================================================
// LEXER
// ============================================================================

pub struct Lexer<'a> {
    #[allow(dead_code)]
    source: &'a str,
    chars: Vec<char>,
    pos: usize,
    line: usize,
    col: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(source: &'a str) -> Self {
        Self {
            source,
            chars: source.chars().collect(),
            pos: 0,
            line: 1,
            col: 1,
        }
    }
    
    fn current(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }
    
    fn advance(&mut self) -> Option<char> {
        let ch = self.chars.get(self.pos).copied();
        if let Some('\n') = ch {
            self.line += 1;
            self.col = 1;
        } else {
            self.col += 1;
        }
        self.pos += 1;
        ch
    }
    
    #[allow(dead_code)]
    fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }
    
    fn location(&self) -> Location {
        Location::new(self.line, self.col)
    }
    
    /// Skip whitespace and comments
    fn skip_whitespace(&mut self) {
        while let Some(ch) = self.current() {
            match ch {
                ' ' | '\t' | '\r' | '\n' => {
                    self.advance();
                }
                ';' => {
                    // Line comment - skip to end of line
                    while let Some(ch) = self.current() {
                        if ch == '\n' {
                            break;
                        }
                        self.advance();
                    }
                }
                _ => break,
            }
        }
    }
    
    /// Read an identifier or keyword
    fn read_ident(&mut self) -> Result<Token, LexError> {
        let loc = self.location();
        let mut ident = String::new();
        
        // First char: letter, -, +, *, /, <, >, =, !, ?, ~
        if let Some(ch) = self.current() {
            if is_ident_start(ch) {
                ident.push(ch);
                self.advance();
            } else {
                return Err(LexError::InvalidIdent { loc });
            }
        }
        
        // Subsequent chars: letter, digit, -, +, *, /, <, >, =, !, ?, ~, .
        while let Some(ch) = self.current() {
            if is_ident_cont(ch) {
                ident.push(ch);
                self.advance();
            } else {
                break;
            }
        }
        
        // Check for keyword prefix
        if ident.starts_with(':') && ident.len() > 1 {
            return Ok(Token::Keyword(ident[1..].to_string(), loc));
        }
        
        // Check for boolean literals
        match ident.as_str() {
            "true" => Ok(Token::Bool(true, loc)),
            "false" => Ok(Token::Bool(false, loc)),
            _ => Ok(Token::Ident(ident, loc)),
        }
    }
    
    /// Read a number (integer or float)
    fn read_number(&mut self) -> Result<Token, LexError> {
        let loc = self.location();
        let mut num_str = String::new();
        
        // Handle negative sign (only if not preceded by digit or dot)
        if self.current() == Some('-') {
            // Check if next char is a digit (not part of identifier)
            if let Some(next) = self.chars.get(self.pos + 1) {
                if next.is_ascii_digit() || *next == '.' {
                    num_str.push('-');
                    self.advance();
                } else {
                    return Ok(Token::Ident("-".to_string(), loc));
                }
            } else {
                return Ok(Token::Ident("-".to_string(), loc));
            }
        }
        
        // Read integer part
        while let Some(ch) = self.current() {
            if ch.is_ascii_digit() {
                num_str.push(ch);
                self.advance();
            } else {
                break;
            }
        }
        
        // Check for decimal point (float)
        let mut is_float = false;
        if self.current() == Some('.') {
            // Must have digit after dot, or digit before dot
            if num_str.chars().any(|c| c.is_ascii_digit()) 
                || self.chars.get(self.pos + 1).map_or(false, |c| c.is_ascii_digit()) {
                is_float = true;
                num_str.push('.');
                self.advance();
                
                while let Some(ch) = self.current() {
                    if ch.is_ascii_digit() {
                        num_str.push(ch);
                        self.advance();
                    } else {
                        break;
                    }
                }
            }
        }
        
        // Check for exponent (can appear after integer or float)
        if let Some('e') | Some('E') = self.current() {
            is_float = true;
            num_str.push('e');
            self.advance();
            if let Some('+') | Some('-') = self.current() {
                num_str.push(self.current().unwrap());
                self.advance();
            }
            while let Some(ch) = self.current() {
                if ch.is_ascii_digit() {
                    num_str.push(ch);
                    self.advance();
                } else {
                    break;
                }
            }
        }
        
        // Parse as float or integer
        if is_float {
            match num_str.parse::<f64>() {
                Ok(v) => Ok(Token::Float(v, loc)),
                Err(_) => Err(LexError::InvalidNumber { loc }),
            }
        } else {
            match num_str.parse::<i64>() {
                Ok(v) => Ok(Token::Int(v, loc)),
                Err(_) => Err(LexError::InvalidNumber { loc }),
            }
        }
    }
    
    /// Read a string literal
    fn read_string(&mut self) -> Result<Token, LexError> {
        let loc = self.location();
        let mut s = String::new();
        
        // Consume opening quote
        self.advance();
        
        loop {
            match self.current() {
                None => return Err(LexError::UnterminatedString { loc }),
                Some('"') => {
                    self.advance();
                    return Ok(Token::StringLit(s, loc));
                }
                Some('\\') => {
                    self.advance();
                    match self.current() {
                        Some('n') => { s.push('\n'); self.advance(); }
                        Some('t') => { s.push('\t'); self.advance(); }
                        Some('\\') => { s.push('\\'); self.advance(); }
                        Some('"') => { s.push('"'); self.advance(); }
                        Some('r') => { s.push('\r'); self.advance(); }
                        Some('0') => { s.push('\0'); self.advance(); }
                        Some(c) => {
                            // Unknown escape - keep as-is
                            s.push('\\');
                            s.push(c);
                            self.advance();
                        }
                        None => return Err(LexError::UnterminatedString { loc }),
                    }
                }
                Some(ch) => {
                    s.push(ch);
                    self.advance();
                }
            }
        }
    }
    
    /// Read the next token
    pub fn next_token(&mut self) -> Result<Token, LexError> {
        self.skip_whitespace();
        let loc = self.location();
        
        match self.current() {
            None => Ok(Token::Eof(loc)),
            Some('(') => { self.advance(); Ok(Token::LParen(loc)) }
            Some(')') => { self.advance(); Ok(Token::RParen(loc)) }
            Some('"') => self.read_string(),
            Some(':') => {
                // Keyword: read : followed by identifier chars
                let loc = self.location();
                self.advance(); // consume :
                let mut ident = String::new();
                while let Some(ch) = self.current() {
                    if is_ident_cont(ch) || ch.is_alphabetic() {
                        ident.push(ch);
                        self.advance();
                    } else {
                        break;
                    }
                }
                if ident.is_empty() {
                    Err(LexError::InvalidIdent { loc })
                } else {
                    Ok(Token::Keyword(ident, loc))
                }
            }
            Some('\'') => {
                // Single quote: syntactic sugar for (quote ...)
                self.advance();
                Ok(Token::Quote(loc))
            }
            Some(ch) if ch.is_ascii_digit() || (ch == '-' && self.chars.get(self.pos+1).map_or(false, |c| c.is_ascii_digit() || *c == '.')) => {
                self.read_number()
            }
            Some(ch) if is_ident_start(ch) => self.read_ident(),
            Some(_) => {
                let loc = self.location();
                let ch = self.current().unwrap();
                Err(LexError::UnexpectedChar { char: ch, loc })
            }
        }
    }
    
    /// Lex the entire source into tokens
    pub fn lex(&mut self) -> Result<Vec<Token>, LexError> {
        let mut tokens = Vec::new();
        loop {
            match self.next_token() {
                Ok(Token::Eof(_)) => break,
                Ok(tok) => tokens.push(tok),
                Err(e) => return Err(e),
            }
        }
        Ok(tokens)
    }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

fn is_ident_start(ch: char) -> bool {
    ch.is_alphabetic() || ch == '_' || matches!(ch, '-' | '+' | '*' | '/' | '<' | '>' | '=' | '!' | '?' | '~' | '%')
}

fn is_ident_cont(ch: char) -> bool {
    ch.is_alphanumeric() || matches!(ch, '-' | '+' | '*' | '/' | '<' | '>' | '=' | '!' | '?' | '~' | '.' | '%')
}

/// Free function to lex a string into tokens
pub fn lex(source: &str) -> Result<Vec<Token>, LexError> {
    let mut lexer = Lexer::new(source);
    lexer.lex()
}

// ============================================================================
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_simple_tokens() {
        let source = "(+ 1 2)";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens.len(), 5);
        assert!(matches!(tokens[0], Token::LParen(_)));
        assert!(matches!(tokens[1], Token::Ident(ref s, _) if s == "+"));
        assert!(matches!(tokens[2], Token::Int(1, _)));
        assert!(matches!(tokens[3], Token::Int(2, _)));
        assert!(matches!(tokens[4], Token::RParen(_)));
    }
    
    #[test]
    fn test_comments() {
        let source = "(+ 1 ; comment\n 2)";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        // Comment is discarded, so we get: ( + 1 2 )
        assert_eq!(tokens.len(), 5);
    }
    
    #[test]
    fn test_floats() {
        let source = "3.14 1e10 2.5E-3";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens.len(), 3);
        assert!(matches!(tokens[0], Token::Float(v, _) if (v - 3.14).abs() < f64::EPSILON));
        assert!(matches!(tokens[1], Token::Float(v, _) if (v - 1e10).abs() < f64::EPSILON));
        assert!(matches!(tokens[2], Token::Float(v, _) if (v - 2.5e-3).abs() < f64::EPSILON));
    }
    
    #[test]
    fn test_booleans() {
        let source = "true false";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens.len(), 2);
        assert!(matches!(tokens[0], Token::Bool(true, _)));
        assert!(matches!(tokens[1], Token::Bool(false, _)));
    }
    
    #[test]
    fn test_strings() {
        let source = r#""hello world""#;
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens.len(), 1);
        assert!(matches!(tokens[0], Token::StringLit(ref s, _) if s == "hello world"));
    }
    
    #[test]
    fn test_keywords() {
        let source = ":foo :bar-baz";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens.len(), 2);
        assert!(matches!(tokens[0], Token::Keyword(ref s, _) if s == "foo"));
        assert!(matches!(tokens[1], Token::Keyword(ref s, _) if s == "bar-baz"));
    }
    
    #[test]
    fn test_nested_parens() {
        let source = "((a b) (c d))";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        // ( ( a b )   ( c d ) )
        assert_eq!(tokens.len(), 10);
    }
    
    #[test]
    fn test_location_single_line() {
        // Verify column positions on a single line
        let source = "(+ 1 2)";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens[0].location(), Location::new(1, 1)); // (
        assert_eq!(tokens[1].location(), Location::new(1, 2)); // +
        assert_eq!(tokens[2].location(), Location::new(1, 4)); // 1
        assert_eq!(tokens[3].location(), Location::new(1, 6)); // 2
        assert_eq!(tokens[4].location(), Location::new(1, 7)); // )
    }
    
    #[test]
    fn test_location_multiline() {
        let source = "(+\n 1\n 2)";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens[0].location(), Location::new(1, 1)); // ( on line 1
        assert_eq!(tokens[1].location(), Location::new(1, 2)); // + on line 1
        assert_eq!(tokens[2].location(), Location::new(2, 2)); // 1 on line 2
        assert_eq!(tokens[3].location(), Location::new(3, 2)); // 2 on line 3
        assert_eq!(tokens[4].location(), Location::new(3, 3)); // ) on line 3
    }
    
    #[test]
    fn test_location_with_comments() {
        let source = "(+ ; comment\n 1)";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens[0].location(), Location::new(1, 1)); // (
        assert_eq!(tokens[1].location(), Location::new(1, 2)); // +
        assert_eq!(tokens[2].location(), Location::new(2, 2)); // 1 (after comment line)
        assert_eq!(tokens[3].location(), Location::new(2, 3)); // )
    }
    
    #[test]
    fn test_location_string_literal() {
        let source = r#""hello" world"#;
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens[0].location(), Location::new(1, 1)); // "hello"
        assert_eq!(tokens[1].location(), Location::new(1, 9)); // world
    }
    
    #[test]
    fn test_location_keyword() {
        let source = ":foo :bar";
        let mut lexer = Lexer::new(source);
        let tokens = lexer.lex().unwrap();
        
        assert_eq!(tokens[0].location(), Location::new(1, 1)); // :foo
        assert_eq!(tokens[1].location(), Location::new(1, 6)); // :bar
    }
}
