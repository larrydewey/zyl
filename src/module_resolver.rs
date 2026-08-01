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
}

impl ModuleResolver {
    pub fn new() -> Self {
        Self {
            search_paths: vec![PathBuf::from("stdlib/")],
            resolved: IndexMap::new(),
        }
    }

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

        // Resolve all use dependencies.
        let mut dep_exprs = Vec::new();
        for use_stmt in &use_stmts {
            let (dep_name, symbols, _unsafe_) = use_stmt;

            let dep_path = self.find_dependency(dep_name, main_file)?;
            let dep_source = fs::read_to_string(&dep_path)
                .map_err(|_| ZylModuleError::NotFound(dep_name.clone(), dep_path.display().to_string()))?;

            let mut dep_stack = vec![_module_name.into(), dep_name.clone()];
            let resolved_dep = self.resolve_module_from_source(&dep_source, dep_name, &dep_path, &mut dep_stack)?;

            let filtered = if let Some(syms) = symbols {
                if syms.contains(&"*".into()) {
                    resolved_dep
                } else {
                    let syms_set: std::collections::HashSet<&str> = syms.iter().map(|s| s.as_str()).collect();
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

        // Combine dependency exprs + root body exprs.
        let mut result = dep_exprs;
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

        // Parse source to extract use statements, exports, and body expressions.
        let (use_stmts, _export_stmts, body_exprs) = self.parse_module_contents(source)?;

        // Resolve all use dependencies first.
        let mut dep_exprs = Vec::new();
        for use_stmt in &use_stmts {
            let (dep_name, symbols, _unsafe_) = use_stmt;

            let dep_path = self.find_dependency(dep_name, file_path)?;
            let dep_source = fs::read_to_string(&dep_path)
                .map_err(|_| ZylModuleError::NotFound(dep_name.clone(), dep_path.display().to_string()))?;

            dep_stack.push(dep_name.clone());

            let resolved_dep = self.resolve_module_from_source(&dep_source, dep_name, &dep_path, dep_stack)?;

            dep_stack.pop();

            self.resolved.insert(dep_name.clone(), true);

            let filtered = if let Some(syms) = symbols {
                if syms.contains(&"*".into()) {
                    resolved_dep
                } else {
                    let syms_set: std::collections::HashSet<&str> = syms.iter().map(|s| s.as_str()).collect();
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

        self.resolved.insert(module_name.into(), true);

        let mut result = dep_exprs;
        result.extend(body_exprs);
        Ok(result)
    }

    /// Parse source to extract use statements, exports, and body expressions.
    /// Applies PostProcessor to convert raw Call/Apply into specialized ExprInner variants.
    fn parse_module_contents(&self, source: &str) -> Result<(Vec<(String, Option<Vec<String>>, bool)>, Vec<String>, Vec<Expr>), ZylModuleError> {
        use crate::ast::PostProcessor;
        use crate::lexer;
        use crate::parser;

        let tokens = lexer::tokenize(source)?;
        let mut p = parser::Parser::new(tokens);
        p.no_dispatch = true;
        let exprs = p.parse_exprs(|k| matches!(k, lexer::TokenKind::EOF))?;

        // Apply PostProcessor — this converts raw Call/Apply into Defn, Def, etc.
        let mut processor = PostProcessor::new();
        let exprs = processor.process(exprs);

        let mut use_stmts: Vec<(String, Option<Vec<String>>, bool)> = Vec::new();
        let mut export_stmts: Vec<String> = Vec::new();
        let mut other_exprs: Vec<Expr> = Vec::new();

        for expr in &exprs {
            match &expr.inner {
                ExprInner::ModuleDecl(_) => {
                    // Skip module declaration — already known from context.
                }
                ExprInner::UseModule(parts, syms, unsafe_) => {
                    let name = parts.join("/");
                    use_stmts.push((name, syms.clone(), *unsafe_));
                }
                ExprInner::Export(ident) => {
                    export_stmts.push(ident.clone());
                }
                _ => {
                    other_exprs.push(expr.clone());
                }
            }
        }

        Ok((use_stmts, export_stmts, other_exprs))
    }

    /// Find a dependency file path given a dotted module name.
    fn find_dependency(&self, name: &str, _from_file: &Path) -> Result<PathBuf, ZylModuleError> {
        let zyl_path = format!("{}.zyl", name);

        // Try as-is first.
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

        Err(ZylModuleError::NotFound(name.into(), zyl_path))
    }

    /// Check if an expression matches a symbol name.
    fn matches_symbol(&self, expr: &Expr, syms: &std::collections::HashSet<&str>) -> bool {
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
