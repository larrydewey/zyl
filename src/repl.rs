mod ast;
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

fn compile_and_run(source: &str) -> Result<Option<String>, String> {


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
                let layout: Vec<_> = sd.fields.iter().map(|(fname, _)| (fname.clone(), 8usize)).collect();
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

    let func_params: std::collections::HashMap<_, _> = resolved_params.iter().map(|(k, v)| (k.clone(), v.clone())).collect();
    let func_returns: std::collections::HashMap<_, _> = resolved_returns.iter().map(|(k, v)| (k.clone(), v.clone())).collect();

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

    let build_result = std::process::Command::new("cc")
        .arg("-no-pie")
        .arg("-lpthread")
        .arg("-o")
        .arg(&bin_path)
        .arg(&asm_path)
        .arg(&runtime_c)
        .output();

    match build_result {
        Ok(output) => {
            if output.status.success() {
                let run_result = std::process::Command::new(&bin_path)
                    .output()
                    .map_err(|e| format!("Failed to run: {}", e))?;
                let stdout = String::from_utf8_lossy(&run_result.stdout);
                let stderr = String::from_utf8_lossy(&run_result.stderr);
                if !stdout.is_empty() || !stderr.is_empty() {
                    let mut result = stdout.to_string();
                    result.push_str(&stderr);
                    return Ok(Some(result));
                }
                Ok(None)
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                Err(format!("Link error:\n{}", stderr))
            }
        }
        Err(e) => Err(format!("cc not available: {}", e)),
    }
}

fn main() {
    println!("Zyl REPL v0.1.0 (type 'quit' to exit)");
    println!();

    let stdin = io::stdin();
    let mut out = io::stdout();
    let mut history = Vec::new();

    loop {
        print!("> ");
        out.flush().unwrap();

        let mut line = String::new();
        match stdin.lock().read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {},
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                break;
            }
        }

        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if line == "quit" || line == "exit" {
            break;
        }

        history.push(line.to_string());

        match compile_and_run(line) {
            Ok(Some(output)) => {
                print!("{}", output);
            }
            Ok(None) => {}
            Err(e) => {
                eprintln!("Error: {}", e);
            }
        }
    }
}
