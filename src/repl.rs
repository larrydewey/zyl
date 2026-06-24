//! Zyl REPL - Read-Eval-Print Loop
//! 
//! Interactive interpreter for Zyl
//! Maintains persistent environment across evaluations.

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

use std::io::{self, Write};
use eval::{EvalState, Evaluator};

fn main() {
    println!("Zyl REPL v0.1.0");
    println!("Type 'quit' or 'exit' to exit.");
    println!("Type 'help' for available commands.");
    println!();
    
    let stdin = io::stdin();
    let mut stdout = io::stdout();
    
    // Persistent evaluation state — definitions accumulate across lines
    let mut state = EvalState::new();
    
    // Buffer for multi-line input (unclosed parens)
    let mut buffer = String::new();
    
    loop {
        print!("zyl> ");
        stdout.flush().unwrap();
        
        let mut line = String::new();
        match stdin.read_line(&mut line) {
            Ok(0) => break, // EOF
            Ok(_) => {}
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                break;
            }
        }
        
        let line = line.trim();
        
        if line.is_empty() && buffer.is_empty() {
            continue;
        }
        
        // Accumulate into buffer (for multi-line input)
        if !line.is_empty() {
            if !buffer.is_empty() {
                buffer.push(' ');
            }
            buffer.push_str(line);
        }
        
        // Check if we have balanced parens
        let balanced = is_balanced(&buffer);
        
        if !balanced {
            print!("... ");
            continue;
        }
        
        let input = std::mem::take(&mut buffer);
        
        // Handle commands
        match input.as_str() {
            "quit" | "exit" => {
                println!("Goodbye!");
                break;
            }
            "help" => {
                println!("Commands:");
                println!("  quit, exit    - Exit the REPL");
                println!("  help          - Show this help");
                println!("  defs          - List defined functions");
                println!("  clear         - Clear all definitions");
                println!();
                println!("Examples:");
                println!("  (defn double (x) (+ x x))");
                println!("  (double 21)");
                println!("  (let (x 10) (+ x 5))");
                println!("  (if (> 3 2) \"yes\" \"no\")");
            }
            "defs" => {
                // List defined functions from the environment
                let mut defs: Vec<String> = Vec::new();
                collect_defs(&state.env, &mut defs);
                if defs.is_empty() {
                    println!("No definitions yet.");
                } else {
                    for def in &defs {
                        println!("  {}", def);
                    }
                }
            }
            "clear" => {
                state.env = eval::Env::new();
                println!("Cleared all definitions.");
            }
            _ => {
                // Try to parse as a full program first (handles defn, let, etc.)
                match parser::parse(&input) {
                    Ok(program) => {
                        let mut evaluator = Evaluator::new(&mut state);
                        match evaluator.eval_program(&program) {
                            Ok(value) => println!("{}", value),
                            Err(e) => eprintln!("Error: {}", e),
                        }
                    }
                    Err(_) => {
                        // Fall back to single expression parsing
                        match parser::parse_expr(&input) {
                            Ok(expr) => {
                                let mut evaluator = Evaluator::new(&mut state);
                                match evaluator.eval(&expr) {
                                    Ok(value) => println!("{}", value),
                                    Err(e) => eprintln!("Error: {}", e),
                                }
                            }
                            Err(e) => eprintln!("Parse error: {}", e),
                        }
                    }
                }
            }
        }
    }
}

/// Check if parentheses are balanced in a string
fn is_balanced(s: &str) -> bool {
    let mut depth = 0i32;
    let mut in_string = false;
    let mut escape = false;
    
    for ch in s.chars() {
        if escape {
            escape = false;
            continue;
        }
        match ch {
            '\\' if in_string => escape = true,
            '"' => in_string = !in_string,
            '(' if !in_string => depth += 1,
            ')' if !in_string => {
                depth -= 1;
                if depth < 0 {
                    return false; // Unmatched closing paren
                }
            }
            _ => {}
        }
    }
    
    depth == 0
}

/// Collect all function definitions from the environment (recursively through parent envs)
fn collect_defs(env: &eval::Env, defs: &mut Vec<String>) {
    // First check parent environments
    if let Some(parent) = env.get_parent() {
        collect_defs(parent, defs);
    }
    
    // Then check current environment
    for (name, value) in env.get_bindings() {
        match value {
            eval::Value::Closure { params, .. } => {
                defs.push(format!("{} ({})", name, params.join(", ")));
            }
            _ => {
                defs.push(name.clone());
            }
        }
    }
}
