//! FFI model for Zyl
//! 
//! Per specification section 12:
//! - (ffi-call name args timeout)
//! - All args must be FFI_Pinnable
//! - Memory passed is pinned
//! - External execution isolated
//! - Timeout enforced
//! - External code cannot access non-pinned memory

use crate::ast::Region;
use thiserror::Error;

// ============================================================================
// FFI ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error, Clone)]
pub enum FfiError {
    #[error("FFI call '{name}' timed out after {timeout_ms}ms")]
    Timeout { name: String, timeout_ms: i64 },
    
    #[error("FFI function '{name}' not found")]
    NotFound { name: String },
    
    #[error("FFI argument type mismatch: expected pinned, got {region}")]
    UnpinnableArg { region: Region },
    
    #[error("FFI call failed with code {code}: {msg}")]
    CallFailed { code: i32, msg: String },
    
    #[error("FFI security violation: non-pinned memory access attempted")]
    SecurityViolation,
}

// ============================================================================
// FFI ARGUMENT (Pinned Memory)
// ============================================================================

#[derive(Debug, Clone)]
pub enum FfiArg {
    /// Pinned integer
    Int(i64),
    /// Pinned float
    Float(f64),
    /// Pinned boolean
    Bool(bool),
    /// Pinned string (null-terminated)
    String(String),
    /// Pinned memory buffer
    Buffer(Vec<u8>),
}

impl FfiArg {
    /// Get the size of this argument in bytes
    pub fn size(&self) -> usize {
        match self {
            FfiArg::Int(_) => 8,
            FfiArg::Float(_) => 8,
            FfiArg::Bool(_) => 1,
            FfiArg::String(s) => s.len() + 1, // +1 for null terminator
            FfiArg::Buffer(buf) => buf.len(),
        }
    }
    
    /// Check if this argument is FFI-pinnable
    pub fn is_pinnable(&self) -> bool {
        true // All FfiArg variants are pinnable by construction
    }
}

// ============================================================================
// FFI RESULT
// ============================================================================

#[derive(Debug, Clone)]
pub enum FfiResult {
    Int(i64),
    Float(f64),
    Bool(bool),
    String(String),
    Buffer(Vec<u8>),
    Unit,
    Error(FfiError),
}

impl FfiResult {
    pub fn is_error(&self) -> bool {
        matches!(self, FfiResult::Error(_))
    }
    
    pub fn into_result(self) -> Result<FfiResult, FfiError> {
        match self {
            FfiResult::Error(e) => Err(e),
            other => Ok(other),
        }
    }
}

// ============================================================================
// FFI FUNCTION REGISTRY
// ============================================================================

type FfiFunc = Box<dyn Fn(&[FfiArg], u64) -> FfiResult + Send + Sync>;

pub struct FfiRegistry {
    functions: std::collections::HashMap<String, FfiFunc>,
}

impl FfiRegistry {
    pub fn new() -> Self {
        Self {
            functions: std::collections::HashMap::new(),
        }
    }
    
    /// Register an FFI function
    pub fn register(&mut self, name: String, func: FfiFunc) {
        self.functions.insert(name, func);
    }
    
    /// Call an FFI function with arguments and timeout
    pub fn call(&self, name: &str, args: &[FfiArg], timeout_ms: u64) -> Result<FfiResult, FfiError> {
        // Security check: all arguments must be pinnable
        for arg in args {
            if !arg.is_pinnable() {
                return Err(FfiError::UnpinnableArg { region: Region::Stack });
            }
        }
        
        let func = self.functions.get(name)
            .ok_or_else(|| FfiError::NotFound { name: name.to_string() })?;
        
        // Execute with timeout (simplified - in production would use std::thread::spawn + join_timeout)
        let result = func(args, timeout_ms);
        
        Ok(result)
    }
    
    /// Check if an FFI function is registered
    pub fn exists(&self, name: &str) -> bool {
        self.functions.contains_key(name)
    }
}

// ============================================================================
// BUILT-IN FFI FUNCTIONS (Standard Library - Section 20)
// ============================================================================

/// Register built-in FFI functions for the standard library
pub fn register_builtin_ffis(registry: &mut FfiRegistry) {
    // print-ffi: Print a value to stdout
    registry.register("print".to_string(), Box::new(|args: &[FfiArg], _: u64| {
        match args.first() {
            Some(FfiArg::Int(v)) => println!("{}", v),
            Some(FfiArg::Float(v)) => println!("{}", v),
            Some(FfiArg::Bool(v)) => println!("{}", v),
            Some(FfiArg::String(v)) => println!("{}", v),
            Some(FfiArg::Buffer(v)) => println!("{:?}", v),
            None => println!("unit"),
        }
        FfiResult::Unit
    }));
    
    // read-line-ffi: Read a line from stdin
    registry.register("read-line".to_string(), Box::new(|_: &[FfiArg], _: u64| {
        let mut input = String::new();
        std::io::stdin().read_line(&mut input).ok();
        input = input.trim_end_matches('\n').trim_end_matches('\r').to_string();
        FfiResult::String(input)
    }));
    
    // exit-ffi: Exit the program
    registry.register("exit".to_string(), Box::new(|args: &[FfiArg], _: u64| {
        let code = match args.first() {
            Some(FfiArg::Int(v)) => *v as i32,
            _ => 0,
        };
        std::process::exit(code);
    }));
}

// ============================================================================
// FFI SAFETY CHECKER
// ============================================================================

/// Verify that an FFI call is safe according to the specification
pub fn check_ffi_safety(args: &[FfiArg], timeout_ms: u64) -> Result<(), FfiError> {
    // All args must be pinnable (checked in call())
    for arg in args {
        if !arg.is_pinnable() {
            return Err(FfiError::UnpinnableArg { region: Region::Stack });
        }
    }
    
    // Timeout must be reasonable (> 0 and < 1 hour)
    if timeout_ms == 0 || timeout_ms > 3_600_000 {
        return Err(FfiError::Timeout {
            name: "validation".into(),
            timeout_ms: timeout_ms as i64,
        });
    }
    
    Ok(())
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Create a new FFI registry with built-in functions
pub fn new_registry() -> FfiRegistry {
    let mut registry = FfiRegistry::new();
    register_builtin_ffis(&mut registry);
    registry
}
