mod ast;
mod error;
mod lexer;
mod macro_expander;
mod parser;

use std::env;
use std::fs;
use std::process;

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 || args[1] == "--help" || args[1] == "-h" {
        println!("Zyl compiler v0.1.0");
        println!();
        println!("Usage: zyl <source.zyl> [output.bin]");
        println!();
        println!("Phases (spec §22):");
        println!("  1. Parsing — Tokenize and parse to AST");
        println!("  2. Macro Expansion — Expand macros (innermost-first, hygiene)");
        println!("  3. Type Inference + Trait Resolution");
        println!("  4. Region Inference + Capture Analysis");
        println!("  5. Monomorphization");
        println!("  6. ICNF Generation (SSA IR)");
        println!("  7. Optimization (Safe only)");
        println!("  8. Code Generation → x86_64");
        println!("  9. Linking");
        println!("10. Contract Injection (Optional overlay, §23)");
        println!("11. Hash Finalization");
        println!();
        println!("Options:");
        println!("  --help, -h    Show this help message");
        process::exit(0);
    }

    let source_path = &args[1];
    let output_path = args.get(2).map(|s| s.as_str()).unwrap_or("a.out");

    // Phase 1: Parsing — Tokenize + Parse to AST.
    println!("[Phase 1] Parsing {} ...", source_path);

    let src = fs::read_to_string(source_path)
        .map_err(|e| format!("Failed to read '{}': {}", source_path, e))?;

    // Step 1a: Lexical analysis (spec §1).
    println!("  Tokenizing...");
    let tokens = lexer::tokenize(&src)?;
    println!("  Tokens: {} produced.", tokens.len());

    // Step 1b: Parse to AST (no dispatch — all lists become raw Call/Apply).
    println!("  Parsing AST...");
    let mut parser = parser::Parser::new(tokens);
    parser.no_dispatch = true;
    let exprs = parser.parse_exprs(|k| matches!(k, lexer::TokenKind::EOF))?;

    // Phase 2: Macro Expansion — register defmacros then expand innermost-first.
    println!("[Phase 2] Macro expansion ...");
    let mut expander = macro_expander::MacroExpander::new();
    let non_macro_exprs = expander.register(&exprs);
    let exprs = match expander.expand(non_macro_exprs) {
        Ok(e) => e,
        Err(err) => return Err(Box::new(err)),
    };
    println!("  Macro expansion complete: {} expressions.", exprs.len());

    // Output the AST as JSON (for debugging / pipeline handoff).
    for (i, expr) in exprs.iter().enumerate() {
        let json = serde_json::to_string_pretty(expr)?;
        if i == 0 {
            println!("--- AST ---");
        } else {
            println!();
        }
        println!("{}", json);
    }

    println!();
    println!("Phase 1 complete: Parsing succeeded.");
    println!("Output written to stdout. Future phases will produce {}.", output_path);

    Ok(())
}

fn main() {
    if let Err(e) = run() {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}
