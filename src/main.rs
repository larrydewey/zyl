mod ast;
mod codegen;
mod error;
mod icnf;
mod lexer;
mod macro_expander;
mod monomorphization;
mod optimization;
mod parser;
mod region_inference;
mod type_inference;
mod type_system;

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
        println!("  2. Post-Processing — Convert raw Call/Apply to specialized ExprInner");
        println!("  3. Macro Expansion — Expand macros (innermost-first, hygiene)");
        println!("  4. Region Inference + Capture Analysis");
        println!("  5. Type Inference + Trait Resolution");
        println!("  6. Monomorphization");
        println!("  7. ICNF Generation (SSA IR)");
        println!("  8. Optimization (Safe only)");
        println!("  9. Code Generation → x86_64");
        println!(" 10. Linking");
        println!(" 11. Contract Injection (Optional overlay, §23)");
        println!(" 12. Hash Finalization");
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

    // Step 1c: Post-process — convert raw Call/Apply special forms to specialized ExprInner variants.
    println!("  Post-processing AST...");
    let mut processor = ast::PostProcessor::new();
    let exprs = processor.process(exprs);

    // Phase 3: Macro Expansion — register defmacros then expand innermost-first.
    println!("[Phase 3] Macro expansion ...");
    let mut expander = macro_expander::MacroExpander::new();
    let non_macro_exprs = expander.register(&exprs);
    let exprs = match expander.expand(non_macro_exprs) {
        Ok(e) => e,
        Err(err) => return Err(Box::new(err)),
    };
    println!("  Macro expansion complete: {} expressions.", exprs.len());

    // Phase 4: Region Inference + Capture Analysis.
    println!("[Phase 4] Region inference ...");
    let mut regioner = region_inference::RegionInferer::new();
    let regioned_exprs = match regioner.infer(&exprs) {
        Ok(e) => e,
        Err(err) => return Err(Box::new(err)),
    };
    println!(
        "  Region inference complete: {} expressions.",
        regioned_exprs.len()
    );

    // Phase 5 (part 1): Collect function definitions for monomorphization.
    // Full type inference runs after monomorphization to preserve AST structure.
    println!("[Phase 5] Type inference ...");
    let mut inferer = type_inference::TypeInferer::new();

    // Collect function definitions first (needed by monomorphization).
    inferer.collect(&regioned_exprs);

    // Phase 6: Monomorphization (runs before full type inference for AST preservation).
    println!("[Phase 6] Monomorphization ...");
    let mut mono_ctx = monomorphization::MonoContext::new(&inferer);
    mono_ctx.discover_from_ast(&regioned_exprs);

    let regioned_for_mono = match mono_ctx.process(&regioned_exprs) {
        Ok(e) => e,
        Err(err) => return Err(Box::new(err)),
    };
    println!(
        "  Monomorphization complete: {} expressions.",
        regioned_for_mono.len()
    );

    // Now run full type inference on the monomorphized AST.
    let typed_exprs = match inferer.infer(&regioned_for_mono) {
        Ok(e) => e,
        Err(err) => return Err(Box::new(err)),
    };
    println!(
        "  Type inference complete: {} expressions.",
        typed_exprs.len()
    );

    // Phase 7: ICNF Generation (SSA IR with region annotations).
    // Uses the monomorphized AST which has full structure intact.
    println!("[Phase 7] ICNF generation ...");
    // Build struct layouts from the AST (struct definitions are in the AST).
    // All fields are 8 bytes (64-bit aligned) in the MVP.
    let mut struct_layouts: codegen::StructLayout = std::collections::HashMap::new();
    for expr in &regioned_for_mono {
        if let ast::ExprInner::StructDef(sd) | ast::ExprInner::StructDefPlus(sd) = &expr.inner {
            let layout: Vec<(String, usize)> = sd.fields.iter().enumerate().map(|(i, (fname, _typ))| {
                (fname.clone(), i * 8)
            }).collect();
            struct_layouts.insert(sd.name.clone(), layout);
        }
    }
    let mut icnf_converter = icnf::IcnfConverter::new().with_struct_layouts(struct_layouts.clone());
    let icnf_program = match icnf_converter.convert(&regioned_for_mono) {
        Ok(p) => p,
        Err(err) => return Err(Box::new(err)),
    };
    // Also pass struct layouts to codegen for potential future use.
    let struct_layouts_for_codegen = struct_layouts.clone();
    println!(
        "  ICNF generation complete: {} functions, {} statements.",
        icnf_program.functions.len(),
        icnf_program.statements.len()
    );

    // Phase 8: Optimization (Safe only).
    println!("[Phase 8] Optimizing ICNF ...");
    let mut optimizer = optimization::Optimizer::new();
    let optimized_icnf = match optimizer.optimize(icnf_program) {
        Ok(p) => p,
        Err(err) => return Err(Box::new(err)),
    };
    println!(
        "  Optimization complete: {} passes applied.",
        optimizer.stats().len()
    );

    // Phase 9: Code Generation → x86_64 assembly.
    println!("[Phase 9] Generating x86_64 assembly ...");
    // Build ADT definitions from AST for codegen.
    let mut adt_defs: std::collections::HashMap<String, Vec<(String, usize)>> = std::collections::HashMap::new();
    for expr in &regioned_for_mono {
        if let ast::ExprInner::Deftype(name, variants, _) = &expr.inner {
            let variant_info: Vec<(String, usize)> = variants
                .iter()
                .map(|v| (v.name.clone(), v.fields.len()))
                .collect();
            adt_defs.insert(name.clone(), variant_info);
        }
    }
    let mut codegen = codegen::CodeGen::new()
        .with_struct_layouts(struct_layouts_for_codegen)
        .with_adt_defs(adt_defs);
    codegen.generate(&optimized_icnf);

    // Write assembly to a temporary file, then assemble and link.
    let asm_path = format!("{}.s", output_path.trim_end_matches(".bin"));
    std::fs::write(&asm_path, &codegen.asm.join("\n"))
        .map_err(|e| format!("Failed to write assembly '{}': {}", asm_path, e))?;
    println!("  Assembly written to: {}", asm_path);

    // Assemble with GNU assembler (as) and link.
    let bin_path = if output_path.ends_with(".bin") {
        output_path.to_string()
    } else {
        format!("{}.bin", output_path.trim_end_matches(".s"))
    };

    println!("  Assembling {} → {}", asm_path, bin_path);

    // Try to assemble and link using cc (which handles as + ld automatically).
    let build_result = std::process::Command::new("cc")
        .arg("-no-pie")
        .arg("-o")
        .arg(&bin_path)
        .arg(&asm_path)
        .output();

    match build_result {
        Ok(output) => {
            if output.status.success() {
                println!("  Linked successfully: {}", bin_path);

                // Keep assembly file for debugging.
                // let _ = std::fs::remove_file(&asm_path);
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                eprintln!("Assembly/linking error:\n{}", stderr);
                return Err(format!("Code generation failed: {}", stderr).into());
            }
        }
        Err(e) => {
            // cc not available — just output the assembly and note that manual linking is needed.
            println!("  Note: 'cc' not found, skipping link step.");
            println!(
                "  To build manually: as {} -o {}.o && ld {}.o -o {}",
                asm_path,
                bin_path.trim_end_matches(".bin"),
                asm_path,
                output_path
            );
        }
    }

    // Output the typed AST (Phase 5 replaces expressions with type annotation atoms).
    for (i, expr) in typed_exprs.iter().enumerate() {
        let json = serde_json::to_string_pretty(expr)?;
        if i == 0 {
            println!("--- Typed AST ---");
        } else {
            println!();
        }
        println!("{}", json);
    }

    // Output the monomorphized AST (full structure, for debugging / pipeline handoff).
    for (i, expr) in regioned_for_mono.iter().enumerate() {
        let json = serde_json::to_string_pretty(expr)?;
        if i == 0 {
            println!("\n--- Monomorphized AST ---");
        } else {
            println!();
        }
        println!("{}", json);
    }

    // Output ICNF as JSON (SSA IR with region annotations, post-optimization).
    let icnf_json = serde_json::to_string_pretty(&optimized_icnf)?;
    println!("\n--- ICNF Program ---");
    println!("Functions: {}", optimized_icnf.functions.len());
    for func in &optimized_icnf.functions {
        let mut sig = format!("  fn {}(", func.name);
        for (i, (param_name, param_type)) in func.params.iter().enumerate() {
            if i > 0 {
                sig.push_str(", ");
            }
            sig.push_str(&format!("{}:{}", param_name, param_type));
        }
        println!("{})", sig);
    }

    // Output ICNF statements as JSON.
    let icnf_stmts_json = serde_json::to_string_pretty(&optimized_icnf.statements)?;
    if !optimized_icnf.statements.is_empty() {
        println!("\n--- ICNF Statements ---");
        println!("{}", icnf_stmts_json);
    }

    // Output region assignments for known types.
    if !regioner.struct_regions.is_empty() || !regioner.func_signatures.is_empty() {
        println!("--- Region Summary ---");
        for (name, fields) in &regioner.struct_regions {
            print!("  struct {}:", name);
            for (fname, region) in fields {
                print!(" {}→{}", fname, region);
            }
            println!();
        }
        for (name, sig) in &regioner.func_signatures {
            print!("  fn {}: params[", name);
            for (i, r) in sig.param_regions.iter().enumerate() {
                if i > 0 {
                    print!(", ");
                }
                print!("{}", r);
            }
            print!("] ret→{}", sig.return_region);
            println!();
        }
    }

    // Output optimization statistics.
    if !optimizer.stats().is_empty() {
        println!("--- Optimization Stats ---");
        for (pass, count) in optimizer.stats() {
            println!("  {}: {} transformations", pass, count);
        }
    }

    println!();
    println!("Phases 1–9 complete: Parsing → Macro Expansion → Region Inference → Monomorphization → Type Inference → ICNF Generation → Optimization → Code Generation succeeded.");

    // Try to run the generated binary.
    if false && std::path::Path::new(&bin_path).exists() {
        println!("Running {} ...", bin_path);
        let run_result = std::process::Command::new(&bin_path).output();

        match run_result {
            Ok(output) => {
                print!("{}", String::from_utf8_lossy(&output.stdout));
                if !output.stderr.is_empty() {
                    eprint!("{}", String::from_utf8_lossy(&output.stderr));
                }
            }
            Err(e) => {
                println!("  Note: Could not run binary: {}", e);
            }
        }
    }

    Ok(())
}

fn main() {
    if let Err(e) = run() {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}
