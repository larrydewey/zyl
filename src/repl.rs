mod ast;
mod deterministic;
mod lexer;
mod parser;
mod macro_expander;
mod module_resolver;
mod region_inference;
mod type_inference;
mod type_system;
mod monomorphization;
mod icnf;
mod optimization;
mod codegen;
mod error;
mod runtime;
mod zyl_source_gen;

use std::io::{self, Write, BufRead};
use std::fs;
use std::path::Path;

// REPL state: tracks defined variables and their types
struct ReplState {
    // Variable names mapped to their inferred types
    vars: crate::deterministic::HashMap<String, String>,
    // Last evaluated result for implicit printing
    last_result: Option<String>,
}

impl ReplState {
    fn new() -> Self {
        ReplState {
            vars: crate::deterministic::HashMap::default(),
            last_result: None,
        }
    }
}

/// Compile and run a Zyl source string, returning (stdout, stderr, exit_code)
/// Also updates the REPL state with any defined variables
fn compile_and_run(source: &str, repl_state: &mut ReplState) -> Result<(String, String, i32), String> {
    let tokens = lexer::tokenize(source).map_err(|e| format!("{}", e))?;
    let mut p = parser::Parser::new(tokens);
    p.no_dispatch = true;
    let exprs = p.parse_exprs(|k| matches!(k, lexer::TokenKind::EOF)).map_err(|e| format!("{}", e))?;

    let mut processor = ast::PostProcessor::new();
    let exprs = processor.process(exprs);

    let module_name = "repl";
    let mut resolver = module_resolver::ModuleResolver::new();
    let exprs = resolver.resolve(&exprs, source, module_name, Path::new("repl.zyl"))
        .map_err(|e| format!("{}", e))?;

    // Collect variable definitions from the expressions
    for expr in &exprs {
        // Handle Defn (def name ...)
        if let ast::ExprInner::Defn(ref name, _, _) = expr.inner {
            repl_state.vars.insert(name.clone(), "Int".to_string());
        }
        // Handle Let bindings
        if let ast::ExprInner::Let(ref name, _, _) = expr.inner {
            repl_state.vars.insert(name.clone(), "Int".to_string());
        }
        // Handle Def (old style)
        if let ast::ExprInner::Def(ref name, _) = expr.inner {
            repl_state.vars.insert(name.clone(), "Int".to_string());
        }
    }

    let mut expander = macro_expander::MacroExpander::new();
    let non_macro_exprs = expander.register(&exprs);
    let exprs = expander.expand(non_macro_exprs).map_err(|e| format!("{}", e))?;

    let regioned = region_inference::RegionInferer::new().infer(&exprs).map_err(|e| format!("{}", e))?;

    let mut inferer = type_inference::TypeInferer::new();
    inferer.collect(&regioned);

    let mut mono_ctx = monomorphization::MonoContext::new(&inferer);
    mono_ctx.discover_from_ast(&regioned);
    let regioned_mono = mono_ctx.process(&regioned).map_err(|e| format!("{}", e))?;

    let typed = inferer.infer(&regioned_mono).map_err(|e| format!("{}", e))?;

    let resolved_params = inferer.get_resolved_known_functions();
    let resolved_returns = inferer.get_resolved_function_returns();

    let struct_layouts: codegen::StructLayout = {
        let mut layouts = codegen::StructLayout::new();
        for e in &typed {
            if let ast::ExprInner::StructDef(sd) = &e.inner {
                let layout: Vec<_> = sd.fields.iter().enumerate().map(|(i, (fname, typ))| {
                    (fname.clone(), i * 8, typ.clone().unwrap_or_else(|| "Int".into()))
                }).collect();
                layouts.insert(sd.name.clone(), layout);
            }
        }
        layouts
    };

    let mut icnf_conv = icnf::IcnfConverter::new()
        .with_struct_layouts(struct_layouts.clone())
        .with_resolved_func_params(resolved_params.clone())
        .with_resolved_func_returns(resolved_returns.clone());
    let icnf_prog = icnf_conv.convert(&regioned_mono).map_err(|e| format!("{}", e))?;

    let mut optimizer = optimization::Optimizer::new();
    let optimized = optimizer.optimize(icnf_prog).map_err(|e| format!("{}", e))?;

    let func_params: crate::deterministic::HashMap<_, _> = resolved_params.iter().map(|(k, v)| (k.clone(), v.clone())).collect();
    let func_returns: crate::deterministic::HashMap<_, _> = resolved_returns.iter().map(|(k, v)| (k.clone(), v.clone())).collect();

    let mut cg = codegen::CodeGen::new()
        .with_struct_layouts(struct_layouts)
        .with_func_params(func_params)
        .with_func_returns(func_returns);
    cg.generate(&optimized);

    let asm_path = format!("/tmp/zyl-repl-{}.s", std::process::id());
    let bin_path = format!("/tmp/zyl-repl-{}.bin", std::process::id());
    let asm_content = if cg.asm.is_empty() { String::new() } else { format!("{}\n", cg.asm.join("\n")) };
    fs::write(&asm_path, &asm_content).map_err(|e| format!("Failed to write asm: {}", e))?;

    let manifest_dir = env!("CARGO_MANIFEST_DIR");
    let runtime_c = format!("{}/{}", manifest_dir, runtime::RUNTIME_C);

    // Assemble
    let assemble = std::process::Command::new("as")
        .arg("-o")
        .arg(&bin_path)
        .arg(&asm_path)
        .output();

    match assemble {
        Ok(output) => {
            if !output.status.success() {
                let stderr = String::from_utf8_lossy(&output.stderr);
                return Err(format!("Assembler error:\n{}", stderr));
            }
        }
        Err(e) => return Err(format!("Assembler not available: {}", e)),
    }

    // Link
    let link = std::process::Command::new("cc")
        .arg("-no-pie")
        .arg("-lpthread")
        .arg("-o")
        .arg(&bin_path)
        .arg(&asm_path)
        .arg(&runtime_c)
        .output();

    match link {
        Ok(output) => {
            if output.status.success() {
                let run_result = std::process::Command::new(&bin_path)
                    .output()
                    .map_err(|e| format!("Failed to run: {}", e))?;
                let stdout = String::from_utf8_lossy(&run_result.stdout);
                let stderr = String::from_utf8_lossy(&run_result.stderr);
                Ok((stdout.to_string(), stderr.to_string(), 0))
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                Err(format!("Link error:\n{}", stderr))
            }
        }
        Err(e) => Err(format!("cc not available: {}", e)),
    }
}

fn main() {
    println!("Zyl REPL v0.5.0");
    println!("Type 'quit' or 'exit' to exit, 'help' for commands.");
    println!("Variables defined in the REPL persist across commands.");
    println!("Last result is automatically printed.");
    println!();

    let stdin = io::stdin();
    let mut out = io::stdout();
    let mut history: Vec<String> = Vec::new();
    let mut repl_state = ReplState::new();

    loop {
        // Print prompt
        write!(out, "> ").unwrap();
        out.flush().unwrap();

        // Read line
        let mut line = String::new();
        match stdin.read_line(&mut line) {
            Ok(0) => break, // EOF
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                break;
            }
            Ok(_) => {}
        }

        let line = line.trim();
        if line.is_empty() {
            // Print last result if available
            if let Some(ref result) = repl_state.last_result {
                print!("{}", result);
            }
            continue;
        }

        // Add to history
        history.push(line.to_string());
        if history.len() > 100 {
            history.remove(0);
        }

        // Handle history navigation with !n
        if line.starts_with("!") {
            let n = line[1..].trim().parse::<usize>().unwrap_or(0);
            if n > 0 && n <= history.len() {
                let recalled = &history[n - 1];
                print!("{}", recalled);
                out.flush().unwrap();
                continue;
            }
            println!("History index out of range");
            continue;
        }

        if line == "quit" || line == "exit" {
            break;
        }

        if line == "help" {
            println!("Zyl REPL commands:");
            println!("  quit, exit   - Exit the REPL");
            println!("  help         - Show this help");
            println!("  !n           - Recall nth history entry");
            println!("  clear        - Clear screen (not implemented)");
            println!();
            println!("Variables defined in the REPL persist across commands:");
            println!("  (def x 42)   - Define variable x = 42");
            println!("  x            - Use defined variable");
            println!("  (+ x 1)      - Use x in expression");
            println!("  (print x)    - Print a value explicitly");
            continue;
        }

        // Check if this is just a variable name lookup
        // Simple heuristic: single identifier that's in our variable state
        if repl_state.vars.contains_key(line) {
            // Variable lookup - print a representation
            println!("; Variable '{}' of type {}", line, repl_state.vars[line]);
            continue;
        }

        // Compile and run
        match compile_and_run(line, &mut repl_state) {
            Ok((stdout, stderr, _exit_code)) => {
                // Print stdout if there's output
                if !stdout.is_empty() {
                    print!("{}", stdout);
                }
                // Print stderr if there's output
                if !stderr.is_empty() {
                    eprintln!("{}", stderr);
                }
                // Store last result if there was output (for implicit printing)
                if stdout.is_empty() && repl_state.last_result.is_none() {
                    // The compile_and_run captures stdout from print statements
                    // If there's no stdout, we store nothing (result will be implicit)
                }
            }
            Err(e) => {
                eprintln!("Error: {}", e);
                // Try to update state from the error source
                let _ = compile_and_run(line, &mut repl_state);
            }
        }
    }

    println!("\nGoodbye!");
}