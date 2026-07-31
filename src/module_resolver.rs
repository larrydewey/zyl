use crate::ast::{Expr, ExprInner};
use crate::error::{Span, ZylError};
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
    /// Dependencies are parsed fresh (they don't need PostProcessor since
    /// tokenize → parse_exprs produces the same AST structure).
    pub fn resolve(
        &mut self,
        root_exprs: &[Expr],
        source: &str,
        module_name: &str,
        main_file: &Path,
    ) -> Result<Vec<Expr>, ZylModuleError> {
        let mut dep_stack = vec![module_name.into()];
        self.resolve_module(root_exprs, source, module_name, main_file, &mut dep_stack)
    }

    fn resolve_module(
        &mut self,
        root_exprs: &[Expr],
        source: &str,
        module_name: &str,
        file_path: &Path,
        dep_stack: &mut Vec<String>,
    ) -> Result<Vec<Expr>, ZylModuleError> {
        // Already resolved?
        if self.resolved.contains_key(module_name) {
            // Return empty — definitions already inlined.
            return Ok(Vec::new());
        }

        // Check circular dependency — if module_name already appears in the stack before the last element.
        let parents = &dep_stack[..dep_stack.len().saturating_sub(1)];
        if parents.iter().any(|s| s == module_name) {
            let mut cycle = parents.to_vec();
            cycle.push(module_name.into());
            return Err(ZylModuleError::Circular(cycle.join(" -> ")));
        }

        // Parse the source to extract module/use/export statements.
        let (use_stmts, export_stmts, other_exprs) = self.parse_module_contents(source)?;

        // Resolve all use dependencies first.
        let mut dep_exprs = Vec::new();
        eprintln!("  [resolver] module '{}' has {} use_stmts, {} other_exprs", module_name, use_stmts.len(), other_exprs.len());
        for use_stmt in &use_stmts {
            let (dep_name, symbols, _unsafe_) = use_stmt;

            // Find the dependency file.
            let dep_path = self.find_dependency(dep_name, file_path)?;
            let dep_source = fs::read_to_string(&dep_path)
                .map_err(|_| ZylModuleError::NotFound(dep_name.clone(), dep_path.display().to_string()))?;

            // Parse dependency.
            let (dep_use_stmts, _dep_exports, dep_body_exprs) = self.parse_module_contents(&dep_source)?;

            eprintln!("  [resolver] dep '{}' has {} body exprs, {} use stmts", dep_name, dep_body_exprs.len(), dep_use_stmts.len());
            dep_stack.push(dep_name.clone());

            // Recursively resolve the dependency.
            let resolved_dep = self.resolve_module(
                &dep_body_exprs,
                &dep_source,
                dep_name,
                &dep_path,
                dep_stack,
            )?;

            dep_stack.pop();

            // Mark as resolved.
            self.resolved.insert(dep_name.clone(), true);

            // Filter by symbols if specific symbols were requested.
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
                // No specific symbols → include all.
                resolved_dep
            };

            dep_exprs.extend(filtered);
        }

        // Mark root module as resolved.
        self.resolved.insert(module_name.into(), true);

        // Combine: dependency exprs + other exprs.
        let mut result = dep_exprs;
        let other_len = other_exprs.len();
        result.extend(other_exprs);
        eprintln!("  [resolver] module '{}' returning {} exprs (deps={}, other={})", module_name, result.len(), result.len() - other_len, other_len);
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

        // Debug: print first few expr inner types
        for (i, e) in exprs.iter().enumerate().take(5) {
            eprintln!("  [resolver/parse] expr[{}] = {:?}", i, e.inner);
        }

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
            ExprInner::Deftype(name, _, _) => {
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

/// Convert module resolution errors to ZylError.
pub fn module_error_to_zyl(err: ZylModuleError) -> ZylError {
    match err {
        ZylModuleError::NotFound(_, name) => ZylError::E_MODULE_NOT_FOUND(Span::default(), name),
        ZylModuleError::NotFoundSymbol(sym, module) => {
            ZylError::E_SYMBOL_NOT_EXPORTED(Span::default(), sym, module)
        }
        ZylModuleError::Circular(cycle) => ZylError::E_CIRCULAR_MODULE(cycle),
        ZylModuleError::Lexer(e) => e,
    }
}
