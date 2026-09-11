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

use std::io::{self, Write};
use std::fs;
use std::path::Path;
use rustyline::Editor;
use rustyline::history::DefaultHistory;

/// REPL state: tracks defined variables and their bindings
struct ReplState {
    /// Source code of all definitions entered so far
    definitions: String,
    /// Last evaluated result for implicit printing
    last_result: Option<String>,
}

impl ReplState {
    fn new() -> Self {
        ReplState {
            definitions: String::new(),
            last_result: None,
        }
    }

    /// Add a definition to the state
    fn add_definition(&mut self, def: &str) {
        if !self.definitions.is_empty() {
            self.definitions.push('\n');
        }
        self.definitions.push_str(def);
    }

    /// Get the full source with all definitions prepended
    fn get_full_source(&self, new_expr: &str) -> String {
        if self.definitions.is_empty() {
            new_expr.to_string()
        } else {
            format!("{}\n{}", self.definitions, new_expr)
        }
    }
}

/// Check if an expression is a top-level definition (def, defn, struct, deftype, etc.)
/// let/let-mut are expressions that return values, not top-level definitions.
fn is_definition(expr: &str) -> bool {
    let trimmed = expr.trim();
    trimmed.starts_with("(def ") ||
    trimmed.starts_with("(defn ") ||
    trimmed.starts_with("(struct ") ||
    trimmed.starts_with("(deftype ") ||
    trimmed.starts_with("(use ") ||
    trimmed.starts_with("(impl ") ||
    trimmed.starts_with("(trait ") ||
    trimmed.starts_with("(macro ")
}

/// Check if an expression is a print-like call that already produces output
fn is_print_call(expr: &str) -> bool {
    let trimmed = expr.trim();
    trimmed.starts_with("(print ") ||
    trimmed.starts_with("(io-print ") ||
    trimmed.starts_with("(print-int ") ||
    trimmed.starts_with("(print-string ") ||
    trimmed.starts_with("(print-float ") ||
    trimmed.starts_with("(print-bool ") ||
    trimmed.starts_with("(io-print-int ") ||
    trimmed.starts_with("(io-print-string ") ||
    trimmed.starts_with("(io-print-float ") ||
    trimmed.starts_with("(io-newline")
}

/// Compile and run a Zyl source string, returning (stdout, stderr, exit_code)
fn compile_and_run(source: &str) -> Result<(String, String, i32), String> {
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

    let runtime_c = format!("{}.runtime.c", asm_path);
    fs::write(&runtime_c, runtime::embedded_runtime_source())
        .map_err(|e| format!("Failed to write embedded runtime: {}", e))?;

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

    let mut repl_state = ReplState::new();
    let mut rl: Editor<(), DefaultHistory> = Editor::new().expect("Failed to create line editor");
    
    // Load history from file if it exists
    let history_path = dirs::home_dir()
        .map(|p| p.join(".zyl_history"))
        .unwrap_or_else(|| Path::new("/tmp/.zyl_history").to_path_buf());
    let _ = rl.load_history(&history_path);

    loop {
        let readline = rl.readline("> ");
        match readline {
            Ok(line) => {
                let line = line.trim();
                if line.is_empty() {
                    // Print last result if available
                    if let Some(ref result) = repl_state.last_result {
                        println!("{}", result);
                    }
                    continue;
                }

                // Add to history
                let _ = rl.add_history_entry(line);
                
                // Handle REPL commands
                if line == "quit" || line == "exit" {
                    break;
                }

                if line == "help" {
                    println!("Zyl REPL commands:");
                    println!("  quit, exit   - Exit the REPL");
                    println!("  help         - Show this help");
                    println!("  clear        - Clear screen (not implemented)");
                    println!();
                    println!("Variables defined in the REPL persist across commands:");
                    println!("  (def x 42)   - Define variable x = 42");
                    println!("  x            - Use defined variable");
                    println!("  (+ x 1)      - Use x in expression");
                    println!("  (print x)    - Print a value explicitly");
                    continue;
                }

                if line == "clear" {
                    print!("\x1B[2J\x1B[1;1H");
                    io::stdout().flush().unwrap();
                    continue;
                }

                // Check if this is a single identifier variable lookup
                let is_single_identifier = !line.starts_with('(') && !line.starts_with(')') 
                    && !line.contains(' ') && !line.is_empty();
                if is_single_identifier {
                    println!("; Variable '{}' (use in expressions)", line);
                    continue;
                }

                // Determine if we need to wrap in print for implicit result printing
                let is_def = is_definition(line);
                let is_print = is_print_call(line);
                
                // Build the source to compile
                let source = if is_def || is_print {
                    // Definitions and explicit prints don't need wrapping
                    repl_state.get_full_source(line)
                } else {
                    // Wrap the last expression in print for implicit result printing
                    format!("{}\n(print {})", repl_state.definitions, line)
                };

                // Compile and run
                match compile_and_run(&source) {
                    Ok((stdout, stderr, _exit_code)) => {
                        // Print stdout if there's output
                        if !stdout.is_empty() {
                            print!("{}", stdout);
                            // Store last result for implicit printing on empty line
                            repl_state.last_result = Some(stdout.trim().to_string());
                        }
                        // Print stderr if there's output
                        if !stderr.is_empty() {
                            eprintln!("{}", stderr);
                        }
                        
                        // If this was a definition, add it to our state
                        if is_def {
                            repl_state.add_definition(line);
                        }
                    }
                    Err(e) => {
                        eprintln!("Error: {}", e);
                    }
                }
            }
            Err(rustyline::error::ReadlineError::Interrupted) => {
                println!("^C");
                continue;
            }
            Err(rustyline::error::ReadlineError::Eof) => {
                break;
            }
            Err(err) => {
                eprintln!("Error reading input: {}", err);
                break;
            }
        }
    }

    // Save history
    let _ = rl.save_history(&history_path);
    println!("\nGoodbye!");
}