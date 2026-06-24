//! Zyl - A Deterministic Lisp Systems Language
//! 
//! Entry point: compiles Zyl source to native code

mod ast;
mod lexer;
mod parser;
mod typeck;
mod region;
mod macros;
mod ir;
mod codegen;
mod actor;
mod ffi;
mod eval;
mod compiler;

use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.len() < 2 {
        eprintln!("Zyl Compiler v0.1.0");
        eprintln!("Usage: zyl <source.zyl> [options]");
        eprintln!();
        eprintln!("Options:");
        eprintln!("  -o <file>    Output file (default: a.out)");
        eprintln!("  -e <expr>    Evaluate expression directly");
        eprintln!("  -i           Interpret mode (no compilation)");
        eprintln!("  -O0          No optimization");
        eprintln!("  -O1          Basic optimization (default)");
        eprintln!("  -O2          Medium optimization");
        eprintln!("  -O3          Full optimization");
        eprintln!("  --help       Show this help");
        std::process::exit(1);
    }
    
    let mut output_file = "a.out".to_string();
    let mut interpret_mode = false;
    let mut opt_level = 1;
    let mut eval_expr: Option<String> = None;
    let mut source_file: Option<String> = None;
    
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "-o" => {
                i += 1;
                if i < args.len() {
                    output_file = args[i].clone();
                }
            }
            "-e" => {
                i += 1;
                if i < args.len() {
                    eval_expr = Some(args[i].clone());
                }
            }
            "-i" => {
                interpret_mode = true;
            }
            "-O0" => opt_level = 0,
            "-O1" => opt_level = 1,
            "-O2" => opt_level = 2,
            "-O3" => opt_level = 3,
            "--help" => {
                std::process::exit(0);
            }
            _ => {
                source_file = Some(args[i].clone());
            }
        }
        i += 1;
    }
    
    // Evaluate expression directly if specified
    if let Some(expr) = eval_expr {
        // Try parsing as a full program first (handles defn, let, etc.)
        match parser::parse(&expr) {
            Ok(ref program) => {
                match eval::evaluate_program(&program) {
                    Ok(value) => println!("{}", value),
                    Err(e) => {
                        eprintln!("Error: {}", e);
                        std::process::exit(1);
                    }
                }
            },
            Err(ref parse_err) => {
                // Fall back to single expression parsing
                match parser::parse_expr(&expr) {
                    Ok(parsed_expr) => match eval::evaluate(&parsed_expr) {
                        Ok(value) => println!("{}", value),
                        Err(e) => {
                            eprintln!("Error: {}", e);
                            std::process::exit(1);
                        }
                    },
                    Err(_) => {
                        eprintln!("Parse error: {}", parse_err);
                        std::process::exit(1);
                    }
                }
            }
        }
        return;
    }
    
    // Read source file
    let source = match source_file {
        Some(ref path) => match fs::read_to_string(path) {
            Ok(s) => s,
            Err(e) => {
                eprintln!("Error reading '{}': {}", path, e);
                std::process::exit(1);
            }
        },
        None => {
            eprintln!("Error: no source file or expression provided");
            eprintln!("Usage: zyl <source.zyl> [options]  or  zyl -e <expression>");
            std::process::exit(1);
        }
    };
    
    if interpret_mode {
        // Interpret mode: evaluate directly
        match parser::parse(&source) {
            Ok(program) => match eval::evaluate_program(&program) {
                Ok(value) => println!("{}", value),
                Err(e) => {
                    eprintln!("Runtime error: {}", e);
                    std::process::exit(1);
                }
            },
            Err(e) => {
                eprintln!("Parse error: {}", e);
                std::process::exit(1);
            }
        }
    } else {
        // Compile mode
        match compiler::compile_optimized(&source, opt_level) {
            Ok(result) => {
                println!("{}", result);
                
                // Write output file
                if output_file != "a.out" {
                    match fs::write(&output_file, &result.object_code) {
                        Ok(_) => println!("Output written to {}", output_file),
                        Err(e) => eprintln!("Error writing '{}': {}", output_file, e),
                    }
                }
            }
            Err(e) => {
                eprintln!("Compilation error: {}", e);
                std::process::exit(1);
            }
        }
    }
}
