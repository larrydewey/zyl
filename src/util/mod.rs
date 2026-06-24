//! Utility functions for Zyl

/// Format a value for display
pub fn format_value(value: &str) -> String {
    value.to_string()
}

/// Check if a string is a valid Zyl identifier
pub fn is_valid_identifier(name: &str) -> bool {
    if name.is_empty() {
        return false;
    }
    
    let mut chars = name.chars();
    
    // First character must be a letter, -, +, *, /, <, >, =, !, ?, ~, _, :
    match chars.next() {
        Some(c) if c.is_ascii_alphabetic() || "-+/<>!=?~_:.".contains(c) => {},
        _ => return false,
    }
    
    // Remaining characters can also include digits
    for c in chars {
        if !c.is_ascii_alphanumeric() && !"-+/<>!=?~_.:".contains(c) {
            return false;
        }
    }
    
    true
}

/// Check if a string is a Zyl keyword
pub fn is_keyword(name: &str) -> bool {
    name.starts_with(':')
}

/// Get the base name without keyword prefix
pub fn strip_keyword(name: &str) -> &str {
    if name.starts_with(':') {
        &name[1..]
    } else {
        name
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_valid_identifiers() {
        assert!(is_valid_identifier("foo"));
        assert!(is_valid_identifier("x"));
        assert!(is_valid_identifier("+"));
        assert!(is_valid_identifier("my-var"));
        assert!(is_valid_identifier("a1"));
    }
    
    #[test]
    fn test_invalid_identifiers() {
        assert!(!is_valid_identifier(""));
        assert!(!is_valid_identifier("1abc")); // starts with digit
    }
    
    #[test]
    fn test_keywords() {
        assert!(is_keyword(":foo"));
        assert!(!is_keyword("foo"));
        assert_eq!(strip_keyword(":foo"), "foo");
        assert_eq!(strip_keyword("foo"), "foo");
    }
}
