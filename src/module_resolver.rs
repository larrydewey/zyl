use crate::ast::{Atom, Expr, ExprInner};
use crate::error::ZylError;
use indexmap::IndexMap;
use std::fs;
use std::path::{Path, PathBuf};

/// Resolves module declarations and use statements into a flat AST.
///
/// Strategy:
///  - The main source file is already parsed + post-processed by the caller.
///  - `use core/core` resolves to `stdlib/core/core.zyl`.
///  - The resolver reads and parses dependency files, then inlines their
///    definitions into the output AST.
///  - `use` with specific symbols: only those symbols are kept.
///  - `use` with `*`: all definitions from the module are inlined.
pub struct ModuleResolver {
    /// Search paths for modules.
    search_paths: Vec<PathBuf>,
    /// Track resolved modules to avoid re-processing.
    resolved: IndexMap<String, bool>,
    /// ADT info collected from all resolved modules (ADT name → variant names).
    /// Used to seed the PostProcessor so variant constructors get correct adt_name.
    adt_info: IndexMap<String, Vec<String>>,
}

const EMBEDDED_PREFIX: &str = "embedded://";

fn embedded_module_source(name: &str) -> Option<&'static str> {
    Some(match name {
        "actor/actor" => include_str!("../stdlib/actor/actor.zyl"),
        "allocator/allocator" => include_str!("../stdlib/allocator/allocator.zyl"),
        "atomic/atomic" => include_str!("../stdlib/atomic/atomic.zyl"),
        "collections/collections" => include_str!("../stdlib/collections/collections.zyl"),
        "collections/map" => include_str!("../stdlib/collections/map.zyl"),
        "collections/set" => include_str!("../stdlib/collections/set.zyl"),
        "collections/vec" => include_str!("../stdlib/collections/vec.zyl"),
        "compiler/assert_lowering" => include_str!("../stdlib/compiler/assert_lowering.zyl"),
        "compiler/ast" => include_str!("../stdlib/compiler/ast.zyl"),
        "compiler/closure_inline" => include_str!("../stdlib/compiler/closure_inline.zyl"),
        "compiler/codegen" => include_str!("../stdlib/compiler/codegen.zyl"),
        "compiler/contract_injection" => include_str!("../stdlib/compiler/contract_injection.zyl"),
        "compiler/expr_inner" => include_str!("../stdlib/compiler/expr_inner.zyl"),
        "compiler/icnf" => include_str!("../stdlib/compiler/icnf.zyl"),
        "compiler/lexer" => include_str!("../stdlib/compiler/lexer.zyl"),
        "compiler/macro_expand" => include_str!("../stdlib/compiler/macro_expand.zyl"),
        "compiler/module_resolver" => include_str!("../stdlib/compiler/module_resolver.zyl"),
        "compiler/monomorphization" => include_str!("../stdlib/compiler/monomorphization.zyl"),
        "compiler/parser" => include_str!("../stdlib/compiler/parser.zyl"),
        "compiler/region_inference" => include_str!("../stdlib/compiler/region_inference.zyl"),
        "compiler/resolver" => include_str!("../stdlib/compiler/resolver.zyl"),
        "compiler/trait_dispatch" => include_str!("../stdlib/compiler/trait_dispatch.zyl"),
        "compiler/type_inference" => include_str!("../stdlib/compiler/type_inference.zyl"),
        "compiler/type_system" => include_str!("../stdlib/compiler/type_system.zyl"),
        "core/core" => include_str!("../stdlib/core/core.zyl"),
        "core/list" => include_str!("../stdlib/core/list.zyl"),
        "core/option" => include_str!("../stdlib/core/option.zyl"),
        "core/result" => include_str!("../stdlib/core/result.zyl"),
        "ffi/ffi" => include_str!("../stdlib/ffi/ffi.zyl"),
        "io/io" => include_str!("../stdlib/io/io.zyl"),
        "mlib/deep" => include_str!("../stdlib/mlib/deep.zyl"),
        "testing/test_test_harness" => include_str!("../stdlib/testing/test_test_harness.zyl"),
        "testing/testing" => include_str!("../stdlib/testing/testing.zyl"),
        _ => return None,
    })
}

impl ModuleResolver {
    pub fn new() -> Self {
        Self {
            search_paths: vec![PathBuf::from("stdlib/")],
            resolved: IndexMap::new(),
            adt_info: IndexMap::new(),
        }
    }

    #[allow(dead_code)]
    pub fn with_search_path(mut self, path: impl Into<PathBuf>) -> Self {
        self.search_paths.push(path.into());
        self
    }

    /// Resolve module declarations in the top-level AST.
    /// The root AST is already parsed + post-processed.
    /// Extracts use statements from root_exprs, resolves dependencies,
    /// and returns combined AST (deps + root body exprs).
    pub fn resolve(
        &mut self,
        root_exprs: &[Expr],
        _source: &str,
        _module_name: &str,
        main_file: &Path,
    ) -> Result<Vec<Expr>, ZylModuleError> {
        // Extract use statements and body expressions from already-parsed root_exprs.
        // The parser runs with no_dispatch=true, so use statements appear as raw
        // Call(Ident("use"), [Ident("module/name")]) rather than UseModule.
        let mut use_stmts: Vec<(String, Option<Vec<String>>, bool)> = Vec::new();
        let mut body_exprs: Vec<Expr> = Vec::new();
        for expr in root_exprs {
            match &expr.inner {
                ExprInner::UseModule(parts, syms, unsafe_) => {
                    use_stmts.push((parts.join("/"), syms.clone(), *unsafe_));
                }
                ExprInner::Call(op, args) if Self::is_ident_op(op, "use") => {
                    if !args.is_empty() {
                        let module_name = match &args[0].inner {
                            ExprInner::Atom(Atom::Ident(m)) => m.clone(),
                            _ => continue,
                        };
                        let mut syms: Option<Vec<String>> = None;
                        let mut unsafe_ = false;
                        for arg in &args[1..] {
                            if let ExprInner::Atom(Atom::Keyword(kw)) = &arg.inner {
                                if kw == "unsafe" {
                                    unsafe_ = true;
                                    continue;
                                }
                            }
                            if let ExprInner::Atom(Atom::Ident(s)) = &arg.inner {
                                syms.get_or_insert_with(Vec::new);
                                syms.as_mut().unwrap().push(s.clone());
                            }
                        }
                        use_stmts.push((module_name, syms, unsafe_));
                    }
                }
                ExprInner::ModuleDecl(_) | ExprInner::Export(_) => {
                    // Skip module declarations and exports — handled by resolver.
                }
                _ => {
                    body_exprs.push(expr.clone());
                }
            }
        }

        // Core is the language prelude: make it available even when a program
        // has no explicit imports. Explicit core/core imports are still
        // honored, while the resolver's resolved-module set prevents repeats.
        let core_loaded = use_stmts.iter().any(|(name, _, _)| name == "core/core");
        let mut core_dep_exprs: Vec<Expr> = Vec::new();
        if !core_loaded {
            let core_path = self.find_dependency("core/core", main_file)?;
            let core_source = self.read_module_source("core/core", &core_path)?;
            let mut dep_stack = vec![_module_name.into(), "core/core".into()];
            core_dep_exprs = self.resolve_module_from_source(
                &core_source,
                "core/core",
                &core_path,
                &mut dep_stack,
            )?;
        }

        // Resolve all use dependencies.
        let mut dep_exprs = Vec::new();
        for use_stmt in &use_stmts {
            let (dep_name, symbols, _unsafe_) = use_stmt;

            let dep_path = self.find_dependency(dep_name, main_file)?;
            let dep_source = self.read_module_source(dep_name, &dep_path)?;

            let mut dep_stack = vec![_module_name.into(), dep_name.clone()];
            let resolved_dep = self.resolve_module_from_source(&dep_source, dep_name, &dep_path, &mut dep_stack)?;

            let filtered = if let Some(syms) = symbols {
                if syms.contains(&"*".into()) {
                    resolved_dep
                } else {
                    let syms_set: crate::deterministic::HashSet<&str> = syms.iter().map(|s| s.as_str()).collect();
                    let filtered: Vec<Expr> = resolved_dep
                        .into_iter()
                        .filter(|e| self.matches_symbol(e, &syms_set))
                        .collect();
                    if filtered.is_empty() && !syms.is_empty() {
                        let first_sym = &syms[0];
                        return Err(ZylModuleError::NotFoundSymbol(first_sym.clone(), dep_name.clone()));
                    }
                    filtered
                }
            } else {
                resolved_dep
            };

            dep_exprs.extend(filtered);
        }

        // Combine core deps + explicit deps + root body exprs.
        // Auto-linked core definitions that the root program re-defines are
        // dropped — user definitions shadow stdlib defaults (otherwise the
        // same function would be emitted twice and fail linking).
        let root_defined: crate::deterministic::HashSet<String> = body_exprs
            .iter()
            .filter_map(|e| match &e.inner {
                ExprInner::Defn(name, _, _) | ExprInner::Def(name, _) => Some(name.clone()),
                _ => None,
            })
            .collect();
        let mut result: Vec<Expr> = core_dep_exprs
            .into_iter()
            .filter(|e| match &e.inner {
                ExprInner::Defn(name, _, _) | ExprInner::Def(name, _) => {
                    !root_defined.contains(name)
                }
                _ => true,
            })
            .collect();
        result.extend(dep_exprs.into_iter().filter(|e| match &e.inner {
            ExprInner::Defn(name, _, _) | ExprInner::Def(name, _) => !root_defined.contains(name),
            _ => true,
        }));
        result.extend(body_exprs);
        Ok(result)
    }

    fn resolve_module_from_source(
        &mut self,
        source: &str,
        module_name: &str,
        file_path: &Path,
        dep_stack: &mut Vec<String>,
    ) -> Result<Vec<Expr>, ZylModuleError> {
        // Already resolved?
        if self.resolved.contains_key(module_name) {
            return Ok(Vec::new());
        }

        // Check circular dependency.
        let parents = &dep_stack[..dep_stack.len().saturating_sub(1)];
        if parents.iter().any(|s| s == module_name) {
            let mut cycle = parents.to_vec();
            cycle.push(module_name.into());
            return Err(ZylModuleError::Circular(cycle.join(" -> ")));
        }

        // Parse source to extract use statements (without post-processing body yet).
        // We defer post-processing until after dependencies are resolved so that
        // the PostProcessor has access to all ADT definitions from imported modules.
        let (use_stmts, _export_stmts) = self.extract_use_stmts(source)?;

        // Resolve all use dependencies first.
        let mut dep_exprs = Vec::new();
        for use_stmt in &use_stmts {
            let (dep_name, symbols, _unsafe_) = use_stmt;

            let dep_path = self.find_dependency(dep_name, file_path)?;
            let dep_source = self.read_module_source(dep_name, &dep_path)?;

            dep_stack.push(dep_name.clone());

            let resolved_dep = self.resolve_module_from_source(&dep_source, dep_name, &dep_path, dep_stack)?;

            dep_stack.pop();

            self.resolved.insert(dep_name.clone(), true);

            let filtered = if let Some(syms) = symbols {
                if syms.contains(&"*".into()) {
                    resolved_dep
                } else {
                    let syms_set: crate::deterministic::HashSet<&str> = syms.iter().map(|s| s.as_str()).collect();
                    let filtered: Vec<Expr> = resolved_dep
                        .into_iter()
                        .filter(|e| self.matches_symbol(e, &syms_set))
                        .collect();
                    if filtered.is_empty() && !syms.is_empty() {
                        let first_sym = &syms[0];
                        return Err(ZylModuleError::NotFoundSymbol(first_sym.clone(), dep_name.clone()));
                    }
                    filtered
                }
            } else {
                resolved_dep
            };

            dep_exprs.extend(filtered);
        }

        // Collect ADT info from resolved dependencies so the PostProcessor
        // can correctly resolve variant constructors (Some, None, Ok, Err)
        // in this module's body expressions.
        let mut dep_adts = IndexMap::new();
        for dep_expr in &dep_exprs {
            if let ExprInner::Deftype(name, variants, _, _) = &dep_expr.inner {
                let vn: Vec<String> = variants.iter().map(|v| v.name.clone()).collect();
                dep_adts.insert(name.clone(), vn);
            }
        }
        // Also merge ADT info from previously resolved modules.
        for (name, variants) in &self.adt_info {
            dep_adts.entry(name.clone()).or_insert_with(|| variants.clone());
        }

        // Post-process the source body with seeded ADT info.
        let body_exprs = self.post_process_body(source, &dep_adts)?;

        // Update the resolver's ADT info with this module's ADTs.
        for expr in &body_exprs {
            if let ExprInner::Deftype(name, variants, _, _) = &expr.inner {
                let vn: Vec<String> = variants.iter().map(|v| v.name.clone()).collect();
                self.adt_info.insert(name.clone(), vn);
            }
        }

        self.resolved.insert(module_name.into(), true);

        let mut result = dep_exprs;
        result.extend(body_exprs);
        Ok(result)
    }

    /// Parse source and extract use statements (without post-processing body).
    /// Use statements are extracted from raw parsed expressions before
    /// dependency resolution, so post-processing isn't needed for this step.
    fn extract_use_stmts(&self, source: &str) -> Result<(Vec<(String, Option<Vec<String>>, bool)>, Vec<String>), ZylModuleError> {
        use crate::lexer;
        use crate::parser;

        let tokens = lexer::tokenize(source)?;
        let mut p = parser::Parser::new(tokens);
        p.no_dispatch = true;
        let exprs = p.parse_exprs(|k| matches!(k, lexer::TokenKind::EOF))?;

        let mut use_stmts: Vec<(String, Option<Vec<String>>, bool)> = Vec::new();
        let mut export_stmts: Vec<String> = Vec::new();

        for expr in &exprs {
            match &expr.inner {
                ExprInner::ModuleDecl(_) => {}
                ExprInner::UseModule(parts, syms, unsafe_) => {
                    use_stmts.push((parts.join("/"), syms.clone(), *unsafe_));
                }
                ExprInner::Call(op, args) if Self::is_ident_op(op, "use") => {
                    if !args.is_empty() {
                        let module_name = match &args[0].inner {
                            ExprInner::Atom(Atom::Ident(m)) => m.clone(),
                            _ => continue,
                        };
                        let mut syms: Option<Vec<String>> = None;
                        let mut unsafe_ = false;
                        for arg in &args[1..] {
                            if let ExprInner::Atom(Atom::Keyword(kw)) = &arg.inner {
                                if kw == "unsafe" {
                                    unsafe_ = true;
                                    continue;
                                }
                            }
                            if let ExprInner::Atom(Atom::Ident(s)) = &arg.inner {
                                syms.get_or_insert_with(Vec::new);
                                syms.as_mut().unwrap().push(s.clone());
                            }
                        }
                        use_stmts.push((module_name, syms, unsafe_));
                    }
                }
                ExprInner::Export(ident) => {
                    export_stmts.push(ident.clone());
                }
                _ => {}
            }
        }

        Ok((use_stmts, export_stmts))
    }

    /// Post-process the source body with seeded ADT info from resolved dependencies.
    fn post_process_body(
        &self,
        source: &str,
        precollected_adts: &IndexMap<String, Vec<String>>,
    ) -> Result<Vec<Expr>, ZylModuleError> {
        use crate::ast::PostProcessor;
        use crate::lexer;
        use crate::parser;

        let tokens = lexer::tokenize(source)?;
        let mut p = parser::Parser::new(tokens);
        p.no_dispatch = true;
        let exprs = p.parse_exprs(|k| matches!(k, lexer::TokenKind::EOF))?;

        let mut processor = PostProcessor::new();
        processor.seed_adt_variants(precollected_adts);
        let exprs = processor.process(exprs);

        let mut body_exprs: Vec<Expr> = Vec::new();
        for expr in &exprs {
            match &expr.inner {
                ExprInner::ModuleDecl(_) | ExprInner::UseModule(_, _, _) | ExprInner::Export(_) => {}
                ExprInner::Call(op, args) if Self::is_ident_op(op, "use") => {}
                _ => {
                    body_exprs.push(expr.clone());
                }
            }
        }

        Ok(body_exprs)
    }

    /// Find a dependency file path given a dotted module name.
    fn find_dependency(&self, name: &str, _from_file: &Path) -> Result<PathBuf, ZylModuleError> {
        let zyl_path = format!("{}.zyl", name);

        // A source-local module takes precedence over the installed prelude.
        if let Some(parent) = _from_file.parent() {
            let candidate = parent.join(&zyl_path);
            if candidate.exists() {
                return Ok(candidate);
            }
        }

        // Try as-is for callers running from a project root.
        if PathBuf::from(&zyl_path).exists() {
            return Ok(PathBuf::from(&zyl_path));
        }

        // Search in stdlib paths.
        for search_path in &self.search_paths {
            let candidate = search_path.join(&zyl_path);
            if candidate.exists() {
                return Ok(candidate);
            }
        }

        if embedded_module_source(name).is_some() {
            return Ok(PathBuf::from(format!("{}{}", EMBEDDED_PREFIX, zyl_path)));
        }

        Err(ZylModuleError::NotFound(name.into(), zyl_path))
    }

    fn read_module_source(&self, name: &str, path: &Path) -> Result<String, ZylModuleError> {
        if path.to_string_lossy().starts_with(EMBEDDED_PREFIX) {
            return embedded_module_source(name)
                .map(str::to_owned)
                .ok_or_else(|| ZylModuleError::NotFound(name.into(), path.display().to_string()));
        }
        fs::read_to_string(path)
            .map_err(|_| ZylModuleError::NotFound(name.into(), path.display().to_string()))
    }

    /// Check if an expression matches a symbol name.
    fn matches_symbol(&self, expr: &Expr, syms: &crate::deterministic::HashSet<&str>) -> bool {
        match &expr.inner {
            ExprInner::Defn(name, _, _) | ExprInner::Def(name, _) => {
                syms.contains(name.as_str())
            }
            ExprInner::StructDef(sd) | ExprInner::StructDefPlus(sd) => {
                syms.contains(sd.name.as_str())
            }
            ExprInner::Deftype(name, _, _, _) => {
                syms.contains(name.as_str())
            }
            ExprInner::AliasDecl(name, _) => {
                syms.contains(name.as_str())
            }
            _ => false,
        }
    }
}

/// Errors from module resolution.
#[derive(Debug, thiserror::Error)]
pub enum ZylModuleError {
    #[error("module: module '{}' not found at '{}'", .0, .1)]
    NotFound(String, String),

    #[error("module: symbol '{}' not exported by '{}'", .0, .1)]
    NotFoundSymbol(String, String),

    #[error("module: circular dependency: {}", .0)]
    Circular(String),

    #[error("lexer: {0}")]
    Lexer(#[from] ZylError),
}

impl ModuleResolver {
    fn is_ident_op(op: &Expr, name: &str) -> bool {
        matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
    }
}

/// Convert module resolution errors to ZylError.
pub fn module_error_to_zyl(err: ZylModuleError) -> ZylError {
    match err {
        ZylModuleError::NotFound(name, _path) => ZylError::E_MODULE_NOT_FOUND(name, _path),
        ZylModuleError::NotFoundSymbol(sym, module) => {
            ZylError::E_SYMBOL_NOT_EXPORTED(sym, module)
        }
        ZylModuleError::Circular(cycle) => ZylError::E_CIRCULAR_MODULE(cycle),
        ZylModuleError::Lexer(e) => e,
    }
}
