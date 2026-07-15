use indexmap::IndexMap;
use serde::{Deserialize, Serialize};

use crate::ast::*;
use crate::error::{Span, ZylError};
use crate::region_inference::Region;
use crate::type_system::Type;

// ─── ICNF Data Structures (spec §18) ──────────────────────────────────────

/// SSA-based intermediate representation with region annotations.
/// All values: (SSA_ID, Region). Explicit Result types for error handling.

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ICNFFuncSig {
    pub name: String,
    pub params: Vec<(String, Type)>, // param_name -> type
    pub return_type: Option<Type>,   // None = Unit
    pub body: Vec<ICNFNode>,         // converted function body statements
}

/// A single statement in the SSA IR. Each has a unique SSA ID and region annotation.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ICNFNode {
    /// Unique SSA identifier for this node (deterministic counter).
    pub id: usize,
    /// Memory region where this value lives.
    #[serde(skip_serializing_if = "is_default_region")]
    pub region: Region,
    /// Inferred type of the result (if available).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub typ: Option<Type>,
    /// If true, this node is part of a control flow branch body and should not be emitted at global level.
    #[serde(default)]
    pub is_branch_body: bool,
    /// The actual IR operation.
    #[serde(flatten)]
    pub node: ICNFInner,
}

fn is_default_region(r: &Region) -> bool {
    *r == Region::Stack
}

/// Internal discriminant for an SSA IR node.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ICNFInner {
    /// A constant value (int, float, bool, string).
    Const(Atom),
    /// Variable reference: loads the current SSA binding for a name.
    Load(String),
    /// Assignment: binds an SSA ID to a value expression's result.
    Assign(String, usize), // variable_name -> ssa_id_of_value
    /// Binary arithmetic/comparison operation.
    BinOp(BinOpKind, usize, usize),
    /// Unary operation.
    UnOp(UnOpKind, usize),
    /// Function call: name(args...) → result_ssa.
    Call(String, Vec<usize>),
    /// If-then-else with phi node at join point. Branch bodies embedded directly (like While).
    If {
        cond_ssa: usize,
        then_body: Vec<ICNFNode>,
        else_body: Vec<ICNFNode>,
        result_var: String,
    },
    /// While loop: condition body + loop body. Condition re-evaluated each iteration.
    While {
        cond_body: Vec<ICNFNode>,
        body: Vec<ICNFNode>,
        result_var: String,
    },
    /// For loop: for init_bindings condition body. Body is a begin that ends with update.
    For {
        init_bindings: Vec<(String, Option<usize>)>,
        cond_nodes: Vec<ICNFNode>,
        body: Vec<ICNFNode>,
    },
    /// Lambda/closure value (not yet invoked).
    Closure(String),
    /// Tagged union variant construction: (type_name, variant_name, discriminant, field_ids...).
    MakeVariant {
        type_name: String,
        variant_name: String,
        discriminant: usize,
        field_ids: Vec<usize>,
    },
    /// Match on ADT: compute discriminant of scrutinee, select arm by discriminant.
    /// Arms are embedded with their bodies, discriminant compare, and phi at join.
    Match {
        scrutinee_ssa: usize,
        type_name: String,
        arms: Vec<MatchArmICNF>,
        result_var: String,
    },
    TryCatch {
        try_body: Vec<ICNFNode>,
        catch_var: String,
        catch_body: Vec<ICNFNode>,
    },
    /// Begin block (sequence of statements).
    Begin(Vec<ICNFNode>),
    /// Struct construction.
    MakeStruct(String, Vec<usize>),
    /// Field access on a struct value. (struct_value_ssa_id, field_byte_offset)
    StructGet(usize, usize),
    /// FFI call (always Pin region).
    FfiCall {
        name: String,
        args: Vec<usize>,
        timeout: u64,
    },
    /// Actor spawn.
    Spawn(usize),
    /// Send message to actor.
    Send(usize, usize),
    /// Error value (Result::Err).
    ErrValue(usize),
    /// Ok wrapper (Result::Ok).
    OkValue(usize),
    /// Unit / void value.
    Unit,
    /// Print side-effect statement.
    Print(Vec<usize>),
    /// Read line from stdin.
    ReadLine,
    /// Exit with status code.
    Exit(usize),
    /// Close a resource handle.
    Close(usize),
    /// With-resource: acquire and release pattern.
    WithResource { var_name: String, init_ssa: usize },
    /// Set! mutation (for mutable bindings).
    SetBang(String, usize),
    /// Unwrap an alias value.
    Unwrap(usize),
    /// Assert check.
    Assert {
        cond_ssa: usize,
        msg: Option<String>,
    },
}

/// A single match arm: variant name, field bindings, and body statements.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MatchArmICNF {
    pub variant_name: String,
    pub field_names: Vec<String>,
    pub body: Vec<ICNFNode>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum BinOpKind {
    Add,
    Sub,
    Mul,
    Div,
    Rem,
    Eq,
    Neq,
    Lt,
    Gt,
    Le,
    Ge,
    And,
    Or,
}

impl std::fmt::Display for BinOpKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            BinOpKind::Add => write!(f, "+"),
            BinOpKind::Sub => write!(f, "-"),
            BinOpKind::Mul => write!(f, "*"),
            BinOpKind::Div => write!(f, "/"),
            BinOpKind::Rem => write!(f, "%"),
            BinOpKind::Eq => write!(f, "=="),
            BinOpKind::Neq => write!(f, "!="),
            BinOpKind::Lt => write!(f, "<"),
            BinOpKind::Gt => write!(f, ">"),
            BinOpKind::Le => write!(f, "<="),
            BinOpKind::Ge => write!(f, ">="),
            BinOpKind::And => write!(f, "and"),
            BinOpKind::Or => write!(f, "or"),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum UnOpKind {
    Not,
    Negate,
}

impl std::fmt::Display for UnOpKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            UnOpKind::Not => write!(f, "not"),
            UnOpKind::Negate => write!(f, "-u"),
        }
    }
}

/// The complete ICNF output.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ICNFProgram {
    /// Top-level functions (defn/lambda at module level).
    pub functions: Vec<ICNFFuncSig>,
    /// Global/top-level statements.
    pub statements: Vec<ICNFNode>,
    /// IDs of nodes that are part of control flow branch bodies (for deduplication in codegen).
    #[serde(default)]
    pub emitted_branch_ids: std::collections::HashSet<usize>,
}

// ─── ICNF Converter ──────────────────────────────────────────────────────

pub struct IcnfConverter {
    ssa_id_counter: std::cell::Cell<usize>,
    functions: Vec<ICNFFuncSig>,
    global_stmts: Vec<ICNFNode>,
    current_scope: IndexMap<String, usize>,
    /// IDs of nodes that are part of control flow branch bodies (to avoid duplicate emission).
    emitted_branch_ids: std::collections::HashSet<usize>,
    /// When false, convert_expr does not push results to global_stmts. Used for branch body conversion.
    push_to_globals: bool,
    /// Temporary buffer for intermediate nodes during function body conversion.
    body_intermediates: Vec<ICNFNode>,
    /// Struct field layouts for offset computation (struct_name → [(field_name, byte_offset)]).
    struct_layouts: crate::codegen::StructLayout,
    /// Maps SSA IDs to struct names for tracking which bindings hold struct values.
    struct_bindings: std::collections::HashMap<usize, String>,
    /// ADT definitions: type_name → list of (variant_name, field_type_names).
    adt_defs: IndexMap<String, Vec<(String, Vec<String>)>>,
}

impl IcnfConverter {
    pub fn new() -> Self {
        Self {
            ssa_id_counter: std::cell::Cell::new(0),
            functions: Vec::new(),
            global_stmts: Vec::new(),
            current_scope: IndexMap::new(),
            emitted_branch_ids: std::collections::HashSet::new(),
            push_to_globals: true,
            body_intermediates: Vec::new(),
            struct_layouts: crate::codegen::StructLayout::new(),
            struct_bindings: std::collections::HashMap::new(),
            adt_defs: IndexMap::new(),
        }
    }

    /// Set struct field layouts for codegen (built from AST struct definitions).
    pub fn with_struct_layouts(mut self, layouts: crate::codegen::StructLayout) -> Self {
        self.struct_layouts = layouts;
        self
    }

    /// Resolve the SSA ID of a struct expression.
    /// For Ident: returns scope binding. For MakeStruct: returns the expression's ID (caller sets). For StructGet: recursively resolves.
    fn resolve_struct_get_id(&self, struct_expr: &Expr) -> Option<usize> {
        match &struct_expr.inner {
            ExprInner::Atom(Atom::Ident(name)) => self.current_scope.get(name).copied(),
            ExprInner::StructGet(parent, _) => self.resolve_struct_get_id(parent),
            _ => None,
        }
    }

    /// Resolve struct name for a StructGet expression.
    /// Returns (struct_name, field_byte_offset) if resolvable.
    fn resolve_struct_get(
        &self,
        struct_expr: &Expr,
        field_name: &str,
    ) -> Option<(String, usize)> {
        match &struct_expr.inner {
            // Inline construction: (make-Point 1 2)
            ExprInner::MakeStruct(name, _fields) => {
                self.struct_layouts
                    .get(name)
                    .and_then(|fields| {
                        fields
                            .iter()
                            .position(|(fname, _)| fname == field_name)
                            .map(|pos| pos * 8)
                    })
                    .map(|offset| (name.clone(), offset))
            }
            // Variable reference: look up in struct_bindings
            ExprInner::Atom(Atom::Ident(name)) => {
                let ssa_id = self.current_scope.get(name).copied()?;
                let struct_name = self.struct_bindings.get(&ssa_id)?;
                self.struct_layouts
                    .get(struct_name)
                    .and_then(|fields| {
                        fields
                            .iter()
                            .position(|(fname, _)| fname == field_name)
                            .map(|pos| pos * 8)
                    })
                    .map(|offset| (struct_name.clone(), offset))
            }
            // Nested struct-get: look up parent struct type from struct_bindings.
            ExprInner::StructGet(parent, parent_field) => {
                let parent_id = self.resolve_struct_get_id(parent)?;
                let struct_name = self.struct_bindings.get(&parent_id)?.clone();
                self.struct_layouts
                    .get(&struct_name)
                    .and_then(|fields| {
                        fields
                            .iter()
                            .position(|(fname, _)| fname == field_name)
                            .map(|pos| (struct_name, pos * 8))
                    })
            }
            _ => None,
        }
    }

    /// Set whether expression conversion should push results to globals.
    fn set_push_mode(&mut self, push: bool) {
        self.push_to_globals = push;
    }

    /// Convert a list of monomorphized AST expressions into ICNF.
    pub fn convert(&mut self, exprs: &[Expr]) -> Result<ICNFProgram, ZylError> {
        for expr in exprs {
            match &expr.inner {
                // Specialized Defn (from parser when no_dispatch=false, or from monomorphization).
                ExprInner::Defn(name, params, body) => {
                    let param_types: Vec<Type> =
                        params.iter().map(|p| self.resolve_type(p)).collect();
                    let saved_scope = std::mem::take(&mut self.current_scope);
                    for param in params.iter() {
                        let ssa_id = self.next_ssa_id();
                        self.current_scope.insert(param.name.clone(), ssa_id);
                    }
                    // Save current globals, use a temp buffer for function body.
                    let saved_globals = std::mem::replace(&mut self.global_stmts, Vec::new());
                    let saved_push = self.push_to_globals;
                    self.push_to_globals = true;
                    let body_stmts = self.convert_expr_to_stmts(body)?;
                    // Push top-level body statements to temp buffer.
                    for stmt in body_stmts {
                        if self.global_stmts.iter().all(|n| n.id != stmt.id) {
                            self.global_stmts.push(stmt);
                        }
                    }
                    let func_body = std::mem::replace(&mut self.global_stmts, saved_globals);
                    self.push_to_globals = saved_push;
                    let func_sig = ICNFFuncSig {
                        name: name.clone(),
                        params: params
                            .iter()
                            .zip(param_types)
                            .map(|(p, t)| (p.name.clone(), t))
                            .collect(),
                        return_type: Some(Type::Prim(crate::type_system::PrimType::Unit)),
                        body: func_body,
                    };
                    self.functions.push(func_sig);
                    self.current_scope = saved_scope;
                }
                // Raw Call form for defn (from no-dispatch parsing).
                ExprInner::Call(op, args) if is_ident_op(op, "defn") && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    // Parse params: args[1] should be a Call/Apply list of param names.
                    let params = parse_params_from_expr(&args[1]);

                    let param_types: Vec<Type> =
                        params.iter().map(|p| self.resolve_type(p)).collect();
                    let saved_scope = std::mem::take(&mut self.current_scope);
                    for param in &params {
                        let ssa_id = self.next_ssa_id();
                        self.current_scope.insert(param.name.clone(), ssa_id);
                    }

                    // Body is args[2] (or Begin of args[2..]).
                    let body_expr = if args.len() == 3 {
                        &args[2]
                    } else {
                        &Expr {
                            span: crate::error::Span::default(),
                            inner: ExprInner::Begin(args[2..].to_vec()),
                        }
                    };
                    // Save globals, use temp buffer for function body.
                    let saved_globals = std::mem::replace(&mut self.global_stmts, Vec::new());
                    let saved_push = self.push_to_globals;
                    self.push_to_globals = true;
                    let body_stmts = self.convert_expr_to_stmts(body_expr)?;
                    for stmt in body_stmts {
                        if self.global_stmts.iter().all(|n| n.id != stmt.id) {
                            self.global_stmts.push(stmt);
                        }
                    }
                    let func_body = std::mem::replace(&mut self.global_stmts, saved_globals);
                    self.push_to_globals = saved_push;

                    let func_sig = ICNFFuncSig {
                        name,
                        params: params
                            .iter()
                            .zip(param_types)
                            .map(|(p, t)| (p.name.clone(), t))
                            .collect(),
                        return_type: Some(Type::Prim(crate::type_system::PrimType::Unit)),
                        body: func_body,
                    };
                    self.functions.push(func_sig);
                    self.current_scope = saved_scope;
                }
                // Apply form for defn.
                ExprInner::Apply(fname, args) if fname == "defn" && args.len() >= 3 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let params = parse_params_from_expr(&args[1]);

                    let param_types: Vec<Type> =
                        params.iter().map(|p| self.resolve_type(p)).collect();
                    let saved_scope = std::mem::take(&mut self.current_scope);
                    for param in &params {
                        let ssa_id = self.next_ssa_id();
                        self.current_scope.insert(param.name.clone(), ssa_id);
                    }

                    let body_expr = if args.len() == 3 {
                        &args[2]
                    } else {
                        &Expr {
                            span: crate::error::Span::default(),
                            inner: ExprInner::Begin(args[2..].to_vec()),
                        }
                    };
                    // Save globals, use temp buffer for function body.
                    let saved_globals = std::mem::replace(&mut self.global_stmts, Vec::new());
                    let saved_push = self.push_to_globals;
                    self.push_to_globals = true;
                    let body_stmts = self.convert_expr_to_stmts(body_expr)?;
                    for stmt in body_stmts {
                        if self.global_stmts.iter().all(|n| n.id != stmt.id) {
                            self.global_stmts.push(stmt);
                        }
                    }
                    let func_body = std::mem::replace(&mut self.global_stmts, saved_globals);
                    self.push_to_globals = saved_push;

                    let func_sig = ICNFFuncSig {
                        name,
                        params: params
                            .iter()
                            .zip(param_types)
                            .map(|(p, t)| (p.name.clone(), t))
                            .collect(),
                        return_type: Some(Type::Prim(crate::type_system::PrimType::Unit)),
                        body: func_body,
                    };
                    self.functions.push(func_sig);
                    self.current_scope = saved_scope;
                }
                ExprInner::Lambda(name, params, _body) => {
                    let ssa_id = self.next_ssa_id();
                    self.global_stmts.push(ICNFNode {
                        id: ssa_id,
                        region: Region::Heap,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Closure(name.clone()),
                    });
                    let saved_scope = std::mem::take(&mut self.current_scope);
                    for param in params {
                        let ssa_id = self.next_ssa_id();
                        self.current_scope.insert(param.name.clone(), ssa_id);
                    }
                    let _body_stmts = self.convert_expr_to_stmts(_body)?;
                    self.current_scope = saved_scope;
                }
                ExprInner::Fn(name, params, body) => {
                    let saved_scope = std::mem::take(&mut self.current_scope);
                    for param in params {
                        let ssa_id = self.next_ssa_id();
                        self.current_scope.insert(param.name.clone(), ssa_id);
                    }
                    let _body_stmts = self.convert_expr_to_stmts(body)?;
                    self.current_scope = saved_scope;
                }
                ExprInner::Deftype(name, variants, _) => {
                    // Store ADT definition for MakeVariant + Match handling.
                    let variant_info: Vec<(String, Vec<String>)> = variants
                        .iter()
                        .enumerate()
                        .map(|(i, v)| {
                            let field_types: Vec<String> = v.fields.iter().cloned().collect();
                            (v.name.clone(), field_types)
                        })
                        .collect();
                    self.adt_defs.insert(name.clone(), variant_info);
                }
                ExprInner::TraitDecl(..)
                | ExprInner::ImplBlock(..)
                | ExprInner::StructDef(..)
                | ExprInner::StructDefPlus(..)
                | ExprInner::AliasDecl(..)
                | ExprInner::Derive(..)
                | ExprInner::ModuleDecl(..)
                | ExprInner::UseModule(..)
                | ExprInner::Export(..) => {}
                ExprInner::MacroDef(..) => {}

                // Raw Call form for deftype: (deftype Name Variant1 Variant2 ...)
                ExprInner::Call(op, args) if is_ident_op(op, "deftype") && args.len() >= 2 => {
                    let name = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let variant_info: Vec<(String, Vec<String>)> = args[1..]
                        .iter()
                        .enumerate()
                        .filter_map(|(_, arg)| {
                            match &arg.inner {
                                ExprInner::MakeVariant(_, vname, fargs) => {
                                    let fields: Vec<String> = fargs.iter().filter_map(|fa| {
                                        if let ExprInner::Atom(Atom::Ident(f)) = &fa.inner {
                                            Some(f.clone())
                                        } else {
                                            None
                                        }
                                    }).collect();
                                    Some((vname.clone(), fields))
                                }
                                ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                                    Some((v.clone(), Vec::new()))
                                }
                                _ => None,
                            }
                        })
                        .collect();
                    self.adt_defs.insert(name, variant_info);
                }

                // Raw Apply form for deftype: (deftype Name Variant1 Variant2 ...)
                ExprInner::Apply(name, args) if name == "deftype" && args.len() >= 2 => {
                    let tname = match &args[0].inner {
                        ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                        _ => continue,
                    };
                    let variant_info: Vec<(String, Vec<String>)> = args[1..]
                        .iter()
                        .enumerate()
                        .filter_map(|(_, arg)| {
                            match &arg.inner {
                                ExprInner::MakeVariant(_, vname, fargs) => {
                                    let fields: Vec<String> = fargs.iter().filter_map(|fa| {
                                        if let ExprInner::Atom(Atom::Ident(f)) = &fa.inner {
                                            Some(f.clone())
                                        } else {
                                            None
                                        }
                                    }).collect();
                                    Some((vname.clone(), fields))
                                }
                                ExprInner::Atom(Atom::Ident(v)) | ExprInner::Atom(Atom::Keyword(v)) => {
                                    Some((v.clone(), Vec::new()))
                                }
                                _ => None,
                            }
                        })
                        .collect();
                    self.adt_defs.insert(tname, variant_info);
                }

                // Raw Call/Apply for trait/impl/struct — skip (type-level constructs from no-dispatch parsing).
                ExprInner::Call(op, _) if is_ident_op(op, "trait") || is_ident_op(op, "impl") || is_ident_op(op, "defstruct") || is_ident_op(op, "defstruct+") => {}
                ExprInner::Apply(name, _) if name == "trait" || name == "impl" || name == "defstruct" || name == "defstruct+" => {}
                _ => {
                    let stmts = self.convert_expr_to_stmts(expr)?;
                    for s in stmts {
                        // Dedup: don't push if a node with this ID already exists.
                        if !self.global_stmts.iter().any(|n| n.id == s.id) {
                            self.global_stmts.push(s);
                        }
                    }
                }
            }
        }

        Ok(ICNFProgram {
            functions: std::mem::take(&mut self.functions),
            statements: std::mem::take(&mut self.global_stmts),
            emitted_branch_ids: std::mem::take(&mut self.emitted_branch_ids),
        })
    }

    /// Get the set of branch body IDs for deduplication in codegen.
    pub fn get_emitted_branch_ids(&self) -> &std::collections::HashSet<usize> {
        &self.emitted_branch_ids
    }

    /// Convert a single AST expression into one or more ICNF nodes.
    /// When push_to_globals is true, pushes all nodes to global_stmts.
    fn convert_expr_collect(&mut self, expr: &Expr) -> Result<Vec<ICNFNode>, ZylError> {
        let mut stmts = self.convert_expr_to_stmts(expr)?;
        // Push collected nodes to global_stmts when in pushing mode.
        if self.push_to_globals && !stmts.is_empty() {
            for stmt in &stmts {
                if self.global_stmts.iter().all(|n| n.id != stmt.id) {
                    self.global_stmts.push(stmt.clone());
                }
            }
        }
        Ok(stmts)
    }

    /// Convert an expression and return its SSA ID without pushing to globals.
    fn convert_expr_collect_id(&mut self, expr: &Expr) -> Result<usize, ZylError> {
        let stmts = self.convert_expr_to_stmts(expr)?;
        // Only push last node to target storage for operand lookup when in pushing mode.
        if !stmts.is_empty() && self.push_to_globals {
            let last = stmts.last().unwrap().clone();
            // Check if already in target storage to avoid duplicates.
            if self.global_stmts.iter().all(|n| n.id != last.id) {
                self.global_stmts.push(last);
            }
        }
        if !stmts.is_empty() {
            Ok(stmts.last().unwrap().id)
        } else {
            Ok(0)
        }
    }

    /// Convert a single AST expression into one or more ICNF nodes.
    fn convert_expr_to_stmts(&mut self, expr: &Expr) -> Result<Vec<ICNFNode>, ZylError> {
        match &expr.inner {
            ExprInner::Atom(Atom::Ident(name)) => {
                // Variable reference: look up in current scope for SSA ID.
                // Load nodes get a fresh SSA ID (distinct from the variable's binding),
                // so codegen can distinguish between the definition and its use.
                // The operand is the variable name (for local_vars lookup in codegen).
                if let Some(&ssa_id) = self.current_scope.get(name) {
                    let load_id = self.next_ssa_id();
                    // Always add Load to global_stmts so codegen can find it.
                    // The Ident handler always pushes to self.global_stmts regardless
                    // of push_to_globals. During body conversion (push_to_globals=false),
                    // self.global_stmts is a temp buffer; the Let handler collects these
                    // Load nodes from self.global_stmts after the swap.
                    if self.global_stmts.iter().all(|n| n.id != load_id) {
                        self.global_stmts.push(ICNFNode {
                            id: load_id,
                            region: Region::Stack,
                            typ: None,
                            is_branch_body: false,
                            node: ICNFInner::Load(name.clone()),
                        });
                    }
                    Ok(vec![ICNFNode {
                        id: load_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Load(name.clone()),
                    }])
                } else {
                    // Not in scope — treat as a constant (for literals, type metadata, etc.).
                    Ok(vec![self.emit(ICNFInner::Const(Atom::Ident(name.clone())))])
                }
            }
            ExprInner::Atom(atom) => {
                let result = vec![self.emit(ICNFInner::Const(atom.clone()))];
                Ok(result)
            }

            // Print from raw Call form: (print e1 ... en).
            ExprInner::Call(op, args)
                if matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == "print")
                    && !args.is_empty() =>
            {
                let mut all_nodes: Vec<ICNFNode> = Vec::new();
                let mut arg_ids = Vec::with_capacity(args.len());
                for e in args.iter() {
                    let mut stmts = self.convert_expr_collect(e)?;
                    arg_ids.push(stmts.last().map(|n| n.id).unwrap_or(self.next_ssa_id()));
                    all_nodes.append(&mut stmts);
                }
                all_nodes.push(self.emit(ICNFInner::Print(arg_ids)));
                Ok(all_nodes)
            }

            // Print from raw Apply form: (print e1 ... en).
            ExprInner::Apply(name, args) if name == "print" && !args.is_empty() => {
                let mut all_nodes: Vec<ICNFNode> = Vec::new();
                let mut arg_ids = Vec::with_capacity(args.len());
                for e in args.iter() {
                    let mut stmts = self.convert_expr_collect(e)?;
                    arg_ids.push(stmts.last().map(|n| n.id).unwrap_or(self.next_ssa_id()));
                    all_nodes.append(&mut stmts);
                }
                all_nodes.push(self.emit(ICNFInner::Print(arg_ids)));
                Ok(all_nodes)
            }

            // Variable reference (bare identifier as expression — no arguments).
            ExprInner::Call(op, args)
                if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_)))
                    && !is_arithmetic_or_cmp_expr(op)
                    && args.is_empty() =>
            {
                let name = match &op.inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return Ok(Vec::new()),
                };
                if let Some(&ssa_id) = self.current_scope.get(&name) {
                    // Load gets a fresh SSA ID (distinct from scope binding).
                    let load_id = self.next_ssa_id();
                    Ok(vec![ICNFNode {
                        id: load_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Load(name),
                    }])
                } else {
                    let id = self.next_ssa_id();
                    Ok(vec![ICNFNode {
                        id,
                        region: Region::Heap,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Load(id.to_string()),
                    }])
                }
            }

            // Binary operations from Call form (+ a b).
            ExprInner::Call(op, args)
                if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_)))
                    && is_arithmetic_or_cmp_expr(op) =>
            {
                let name = match &op.inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return Ok(Vec::new()),
                };
                self.convert_bin_op(&name, args)
            }

            // Binary operations from Apply form (+ a b).
            ExprInner::Apply(name, args) if is_arithmetic_or_cmp_name(name) => {
                self.convert_bin_op(name, args)
            }

            // Unary not.
            ExprInner::Call(op, args)
                if matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == "not")
                    && !args.is_empty() =>
            {
                let arg_id = self.convert_expr(&args[0])?;
                Ok(vec![self.emit(ICNFInner::UnOp(UnOpKind::Not, arg_id))])
            }

            // If-then-else.
            ExprInner::If(cond, then_, else_) => {
                let cond_id = self.convert_expr_collect_id(cond)?;

                // Convert branch bodies - push to globals so intermediate nodes are visible for operand lookup.
                let mut then_stmts = self.convert_branch_body(then_)?;
                let mut else_stmts = self.convert_branch_body(else_)?;

                // Mark all branch body nodes as is_branch_body=true for codegen dedup.
                for stmt in &mut then_stmts {
                    stmt.is_branch_body = true;
                }
                for stmt in &mut else_stmts {
                    stmt.is_branch_body = true;
                }

                let result_var = format!("___if_result_{}", self.ssa_id_counter.get());
                // Use fresh IDs - don't reuse cond_id which may collide with existing nodes.
                let if_node_id = self.next_ssa_id();
                let phi_id = self.next_ssa_id();

                let result_var_clone = result_var.clone();
                Ok(vec![
                    ICNFNode {
                        id: if_node_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::If {
                            cond_ssa: cond_id,
                            then_body: then_stmts,
                            else_body: else_stmts,
                            result_var,
                        },
                    },
                    ICNFNode {
                        id: phi_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Assign(result_var_clone, cond_id),
                    },
                ])
            }

            // Let binding.
            ExprInner::Let(name, val, body) => {
                // Defer all global pushes to ensure correct ordering:
                // value intermediates → Assign → body statements.
                let saved_scope = std::mem::take(&mut self.current_scope);
                let mut saved_globals = std::mem::replace(&mut self.global_stmts, Vec::new());
                let saved_push = self.push_to_globals;
                self.push_to_globals = false;
                // 1. Restore outer scope before converting value (value may reference
                //    outer bindings — e.g., `make-Pair p p` needs `p` in scope).
                self.current_scope = saved_scope.clone();
                // 2. Convert value expression (collecting intermediates, NOT pushing).
                let val_stmts = self.convert_expr_to_stmts(val)?;
                let val_id = val_stmts.last().map(|n| n.id).unwrap_or(self.next_ssa_id());
                // 3. Create Assign node.
                let ssa_id = self.next_ssa_id();
                let assign_node = ICNFNode {
                    id: ssa_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assign(name.clone(), val_id),
                };
                // Propagate struct type from value to binding: if val_id is a struct,
                // register the binding's SSA ID so resolve_struct_get can find it.
                if let Some(struct_name) = self.struct_bindings.get(&val_id).cloned() {
                    self.struct_bindings.insert(ssa_id, struct_name);
                }
                // 4. Update scope BEFORE converting body (so body can find the binding).
                self.current_scope.insert(name.clone(), ssa_id);
                // 5. Convert body (collecting intermediates, NOT pushing).
                let body_stmts = self.convert_expr_to_stmts(body)?;
                self.current_scope = saved_scope;
                // 5. Restore globals and push all in correct order (with dedup).
                // The Ident handler always pushes Load nodes to self.global_stmts.
                // During body conversion, self.global_stmts was a temp buffer (replaced
                // by the Let handler's mem::replace). After swap: self.global_stmts
                // = old_globals, saved_globals = temp buffer (with Load nodes).
                std::mem::swap(&mut self.global_stmts, &mut saved_globals);
                // Collect Load nodes from saved_globals (the temp buffer).
                let load_stmts: Vec<ICNFNode> = saved_globals
                    .into_iter()
                    .filter(|n| matches!(n.node, ICNFInner::Load(_)))
                    .collect();
                let mut all_stmts = val_stmts;
                all_stmts.push(assign_node);
                all_stmts.extend(body_stmts);
                all_stmts.extend(load_stmts);
                for stmt in &all_stmts {
                    if !self.global_stmts.iter().any(|n| n.id == stmt.id) {
                        self.global_stmts.push(stmt.clone());
                    }
                }
                self.push_to_globals = saved_push;
                // 6. Return all statements for caller (used by convert()'s default arm).
                Ok(all_stmts)
            }

            // Let-mut binding.
            ExprInner::LetMut(name, val, body) => {
                // Defer all global pushes to ensure correct ordering:
                // value intermediates → Assign → body statements.
                let saved_scope = std::mem::take(&mut self.current_scope);
                let mut saved_globals = std::mem::replace(&mut self.global_stmts, Vec::new());
                let saved_push = self.push_to_globals;
                self.push_to_globals = false;
                // Restore outer scope before converting value.
                self.current_scope = saved_scope.clone();
                // Convert value expression (collecting intermediates, NOT pushing to globals).
                let val_stmts = self.convert_expr_to_stmts(val)?;
                let val_id = val_stmts.last().map(|n| n.id).unwrap_or(self.next_ssa_id());
                // Create Assign node.
                let ssa_id = self.next_ssa_id();
                let assign_node = ICNFNode {
                    id: ssa_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assign(name.clone(), val_id),
                };
                // Update scope BEFORE converting body.
                self.current_scope.insert(name.clone(), ssa_id);
                // Convert body (collecting intermediates, NOT pushing to globals).
                let body_stmts = self.convert_expr_to_stmts(body)?;
                self.current_scope = saved_scope;
                // Restore globals and push all in correct order (with dedup).
                std::mem::swap(&mut self.global_stmts, &mut saved_globals);
                // Collect Load nodes from saved_globals (the temp buffer).
                let load_stmts: Vec<ICNFNode> = saved_globals
                    .into_iter()
                    .filter(|n| matches!(n.node, ICNFInner::Load(_)))
                    .collect();
                let mut all_stmts = val_stmts;
                all_stmts.push(assign_node);
                all_stmts.extend(body_stmts);
                all_stmts.extend(load_stmts);
                for stmt in &all_stmts {
                    if !self.global_stmts.iter().any(|n| n.id == stmt.id) {
                        self.global_stmts.push(stmt.clone());
                    }
                }
                self.push_to_globals = saved_push;
                Ok(all_stmts)
            }

            // While loop.
            ExprInner::While(cond, body) => {
                // Convert condition to inline body nodes (re-evaluated each iteration).
                let mut cond_nodes = self.convert_branch_body(cond)?;
                // Mark condition nodes as branch body for codegen dedup.
                for stmt in &mut cond_nodes {
                    stmt.is_branch_body = true;
                }

                // Convert body without pushing to globals (like cond_body).
                let mut body_stmts = self.convert_branch_body(body)?;
                // Mark body nodes as branch body for codegen dedup.
                for stmt in &mut body_stmts {
                    stmt.is_branch_body = true;
                }

                let result_var = format!("___while_result_{}", self.ssa_id_counter.get());
                let while_node_id = self.next_ssa_id();

                Ok(vec![ICNFNode {
                    id: while_node_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::While {
                        cond_body: cond_nodes,
                        body: body_stmts,
                        result_var,
                    },
                }])
            }

            // For loop.
            ExprInner::For(ref bindings, cond_expr, body) => {
                // Process init bindings: for each (name [value]), either use existing var or create new one.
                let mut init_ssa: Vec<(String, Option<usize>)> = Vec::new();
                for binding in bindings {
                    let (name, val_opt) = binding;
                    if let Some(val_expr) = val_opt {
                        // Create new binding with initial value
                        let saved_scope = std::mem::take(&mut self.current_scope);
                        let id = self.next_ssa_id();
                        self.current_scope.insert(name.clone(), id);
                        let val_stmts = self.convert_expr_to_stmts(val_expr)?;
                        let init_ssa_id = self.next_ssa_id();
                        self.global_stmts.push(ICNFNode {
                            id: init_ssa_id,
                            region: Region::Stack,
                            typ: None,
                            is_branch_body: false,
                            node: ICNFInner::Load(name.clone()),
                        });
                        init_ssa.push((name.clone(), Some(init_ssa_id)));
                        self.global_stmts.extend(val_stmts);
                        self.current_scope = saved_scope;
                    } else {
                        // Use existing variable
                        if let Some(&id) = self.current_scope.get(name) {
                            init_ssa.push((name.clone(), Some(id)));
                        } else {
                            return Err(ZylError::E_UNBOUND_VARIABLE(Span::default(), name.clone()));
                        }
                    }
                }
                // Bind all loop vars in scope before converting cond/body.
                let saved_scope = std::mem::take(&mut self.current_scope);
                for binding in bindings {
                    let (name, _) = binding;
                    if let Some(&id) = self.current_scope.get(name) {
                        // already bound
                    }
                }
                let cond_nodes = self.convert_expr_to_stmts(cond_expr)?;
                let mut body_stmts = self.convert_expr_to_stmts(body)?;
                self.current_scope = saved_scope;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::For {
                        init_bindings: init_ssa,
                        cond_nodes,
                        body: body_stmts,
                    },
                }])
            }

            // Cond → desugar to nested If.
            ExprInner::Cond(clauses) => {
                if clauses.is_empty() {
                    return Ok(vec![self.emit(ICNFInner::Unit)]);
                }
                self.convert_cond_recursive(&clauses, 0)
            }

            // Try-catch.
            ExprInner::TryCatch(try_expr, catch_var, catch_body) => {
                let mut try_stmts = self.convert_expr_to_stmts(try_expr)?;
                if self.push_to_globals {
                    for s in &try_stmts {
                        if !self.global_stmts.iter().any(|n| n.id == s.id) {
                            self.global_stmts.push(s.clone());
                        }
                    }
                }
                let saved_scope = std::mem::take(&mut self.current_scope);
                let err_id = self.next_ssa_id();
                self.current_scope.insert(catch_var.clone(), err_id);
                let mut catch_stmts = self.convert_expr_to_stmts(catch_body)?;
                if self.push_to_globals {
                    for s in &catch_stmts {
                        if !self.global_stmts.iter().any(|n| n.id == s.id) {
                            self.global_stmts.push(s.clone());
                        }
                    }
                }
                self.current_scope = saved_scope;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::TryCatch {
                        try_body: try_stmts,
                        catch_var: catch_var.clone(),
                        catch_body: catch_stmts,
                    },
                }])
            }

            // Lambda (nested).
            ExprInner::Lambda(name, params, _body) => {
                let ssa_id = self.next_ssa_id();
                Ok(vec![ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Closure(name.clone()),
                }])
            }

            ExprInner::Fn(name, params, _body) => {
                let ssa_id = self.next_ssa_id();
                Ok(vec![ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Closure(format!("fn_{}", name)),
                }])
            }

            // Function call (Apply form).
            ExprInner::Apply(name, args) => self.convert_apply_call(name, args),

            // Function call (Call form with operator as first element — non-arithmetic).
            ExprInner::Call(op, args)
                if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_)))
                    && !is_arithmetic_or_cmp_expr(op) =>
            {
                let func_name = match &op.inner {
                    ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                    _ => return Ok(Vec::new()),
                };

                // Convert all arguments, collecting ALL intermediate nodes (not just the last ID).
                let mut result = Vec::new();
                let mut arg_ids = Vec::with_capacity(args.len());
                for a in args.iter() {
                    let mut stmts = self.convert_expr_collect(a)?;
                    let id = if !stmts.is_empty() {
                        stmts.last().unwrap().id
                    } else {
                        self.next_ssa_id()
                    };
                    arg_ids.push(id);
                    result.append(&mut stmts);
                }

                result.push(self.emit(ICNFInner::Call(func_name, arg_ids)));
                Ok(result)
            }

            // Begin block.
            ExprInner::Begin(exprs) => {
                if exprs.is_empty() {
                    return Ok(vec![self.emit(ICNFInner::Unit)]);
                }
                let mut all_stmts = Vec::new();
                for e in exprs.iter() {
                    let stmts = self.convert_expr_to_stmts(e)?;
                    all_stmts.extend(stmts);
                }
                Ok(all_stmts)
            }

            // Struct construction.
            ExprInner::MakeStruct(name, fields) => {
                let mut all_nodes: Vec<ICNFNode> = Vec::new();
                let mut field_ids = Vec::with_capacity(fields.len());
                for f in fields.iter() {
                    let stmts = self.convert_expr_to_stmts(f)?;
                    for s in stmts {
                        all_nodes.push(s.clone());
                        if self.push_to_globals {
                            if !self.global_stmts.iter().any(|n| n.id == s.id) {
                                self.global_stmts.push(s);
                            }
                        }
                    }
                    if !all_nodes.is_empty() {
                        field_ids.push(all_nodes.last().unwrap().id);
                    } else {
                        let id = self.next_ssa_id();
                        field_ids.push(id);
                    }
                }

                let ssa_id = self.next_ssa_id();
                // Register this SSA ID as a struct-typed binding.
                self.struct_bindings.insert(ssa_id, name.clone());
                all_nodes.push(ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::MakeStruct(name.clone(), field_ids),
                });
                Ok(all_nodes)
            }

            // Struct field access.
            ExprInner::StructGet(struct_expr, field_name) => {
                // Collect ALL nodes from the struct expression (including nested StructGet).
                let mut stmts = self.convert_expr_collect(struct_expr)?;
                let struct_id = stmts.last().map(|n| n.id).unwrap_or(0);
                let (struct_name, field_offset) =
                    self.resolve_struct_get(struct_expr, field_name)
                        .unwrap_or_else(|| {
                            // Fallback: can't resolve struct name — try to get it from
                            // struct_bindings via the struct expression's SSA ID.
                            if let Some(name) = self.struct_bindings.get(&struct_id).cloned() {
                                self.struct_layouts
                                    .get(&name)
                                    .and_then(|fields| {
                                        fields
                                            .iter()
                                            .position(|(fname, _)| fname == field_name)
                                            .map(|pos| (name, pos * 8))
                                    })
                                    .unwrap_or_else(|| (String::new(), 0))
                            } else {
                                (String::new(), 0)
                            }
                        });
                if !struct_name.is_empty() {
                    self.struct_bindings.insert(struct_id, struct_name);
                }
                stmts.push(ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::StructGet(struct_id, field_offset),
                });
                Ok(stmts)
            }

            // Tagged union variant construction: MakeVariant(type_name, variant_name, args).
            ExprInner::MakeVariant(ref type_name, ref variant_name, args) => {
                // Compute discriminant for this variant from the ADT definition.
                // If type_name is empty, resolve it from the variant name.
                let (resolved_type, discriminant) = if !type_name.is_empty() {
                    (type_name.clone(), self.adt_defs.get(type_name).and_then(|variants| {
                        variants.iter().position(|(vname, _)| vname == variant_name)
                    }).unwrap_or(0))
                } else {
                    // Look up variant in all ADTs to find the type name.
                    let (resolved_type, idx) = self.adt_defs.iter().find_map(|(tname, variants)| {
                        variants.iter().position(|(vname, _)| vname == variant_name)
                            .map(|i| (tname.clone(), i))
                    }).unwrap_or_else(|| (String::new(), 0));
                    (resolved_type, idx)
                };
                let discriminant = discriminant;

                // Convert all field expressions and collect their SSA IDs.
                let mut all_nodes: Vec<ICNFNode> = Vec::new();
                let mut field_ids = Vec::with_capacity(args.len());
                for arg in args.iter() {
                    let stmts = self.convert_expr_to_stmts(arg)?;
                    for s in &stmts {
                        all_nodes.push(s.clone());
                        if self.push_to_globals {
                            if !self.global_stmts.iter().any(|n| n.id == s.id) {
                                self.global_stmts.push(s.clone());
                            }
                        }
                    }
                    if !stmts.is_empty() {
                        field_ids.push(stmts.last().unwrap().id);
                    } else {
                        let id = self.next_ssa_id();
                        field_ids.push(id);
                    }
                }

                // Allocate memory for the tagged union: discriminant + field pointers.
                let total_size = (field_ids.len() + 1) * 8; // discriminant + fields.
                let ssa_id = self.next_ssa_id();
                let mut result = all_nodes;
                result.push(ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::MakeVariant {
                        type_name: resolved_type.clone(),
                        variant_name: variant_name.clone(),
                        discriminant,
                        field_ids: field_ids.clone(),
                    },
                });
                self.struct_bindings.insert(ssa_id, format!("{}-{}", resolved_type, variant_name));
                Ok(result)
            }

            // Match on ADT: discriminant compare + branch selection.
            ExprInner::Match(scrutinee, arms) => {
                // Resolve the type name from scrutinee expression (or use first arm's type).
                let type_name = self.resolve_match_type(scrutinee, &arms);

                let scrut_id = self.convert_expr(scrutinee)?;

                // Convert each arm body and collect statements.
                let mut all_stmts: Vec<ICNFNode> = Vec::new();
                let mut icnf_arms: Vec<MatchArmICNF> = Vec::new();

                for arm in arms {
                    // Bind pattern variables (field names) in scope for the arm body.
                    let saved_scope = std::mem::take(&mut self.current_scope);

                    // Extract pattern variable names from arm.patterns and bind them.
                    let mut field_names: Vec<String> = Vec::new();
                    for p in &arm.patterns {
                        if let ExprInner::Atom(Atom::Ident(name)) = &p.inner {
                            let ssa_id = self.next_ssa_id();
                            self.current_scope.insert(name.clone(), ssa_id);
                            field_names.push(name.clone());
                        }
                    }

                    // Convert the arm body.
                    let body_stmts = self.convert_expr_to_stmts(&arm.body)?;
                    self.current_scope = saved_scope;

                    // Add arm body statements to all_stmts (they'll be embedded).
                    for s in &body_stmts {
                        if !all_stmts.iter().any(|n| n.id == s.id) {
                            all_stmts.push(s.clone());
                        }
                    }

                    icnf_arms.push(MatchArmICNF {
                        variant_name: arm.variant.clone(),
                        field_names,
                        body: body_stmts,
                    });
                }

                let result_var = format!("___match_result_{}", self.ssa_id_counter.get());

                let ssa_id = self.next_ssa_id();
                all_stmts.insert(0, ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Match {
                        scrutinee_ssa: scrut_id,
                        type_name: type_name.clone(),
                        arms: icnf_arms,
                        result_var,
                    },
                });

                Ok(all_stmts)
            }

            // FFI call.
            ExprInner::FfiCall(name, args, timeout) => {
                let mut arg_ids = Vec::with_capacity(args.len());
                for a in args.iter() {
                    let stmts = self.convert_expr_to_stmts(a)?;
                    if !stmts.is_empty() {
                        arg_ids.push(stmts.last().unwrap().id);
                    } else {
                        let id = self.next_ssa_id();
                        arg_ids.push(id);
                    }
                }

                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Pin,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::FfiCall {
                        name: name.clone(),
                        args: arg_ids,
                        timeout: *timeout,
                    },
                }])
            }

            ExprInner::FfiPin(expr) => {
                let inner_id = self.convert_expr(expr)?;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Pin,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::FfiCall {
                        name: "ffi_pin".to_string(),
                        args: vec![inner_id],
                        timeout: 0,
                    },
                }])
            }

            ExprInner::FfiUnpin(expr) => {
                let inner_id = self.convert_expr(expr)?;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::FfiCall {
                        name: "ffi_unpin".to_string(),
                        args: vec![inner_id],
                        timeout: 0,
                    },
                }])
            }

            // Spawn actor.
            ExprInner::Spawn(closure) => {
                let closure_id = self.convert_expr(closure)?;
                Ok(vec![self.emit(ICNFInner::Spawn(closure_id))])
            }

            // Send to actor.
            ExprInner::Send(actor, msg) => {
                let actor_id = self.convert_expr(actor)?;
                let msg_id = self.convert_expr(msg)?;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Send(actor_id, msg_id),
                }])
            }

            // Print.
            ExprInner::Print(exprs) => {
                let mut all_nodes: Vec<ICNFNode> = Vec::new();
                let mut arg_ids = Vec::with_capacity(exprs.len());
                for e in exprs.iter() {
                    let mut stmts = self.convert_expr_collect(e)?;
                    arg_ids.push(stmts.last().map(|n| n.id).unwrap_or(self.next_ssa_id()));
                    all_nodes.append(&mut stmts);
                }
                all_nodes.push(self.emit(ICNFInner::Print(arg_ids)));
                Ok(all_nodes)
            }

            ExprInner::ReadLine => Ok(vec![ICNFNode {
                id: self.next_ssa_id(),
                region: Region::Heap,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::ReadLine,
            }]),

            // Exit.
            ExprInner::Exit(code) => {
                let code_id = self.convert_expr(code)?;
                Ok(vec![self.emit(ICNFInner::Exit(code_id))])
            }

            // Close resource.
            ExprInner::Close(handle) => {
                let handle_id = self.convert_expr(handle)?;
                Ok(vec![self.emit(ICNFInner::Close(handle_id))])
            }

            // With-resource binding.
            ExprInner::WithResource(name, init, body) => {
                let saved_scope = std::mem::take(&mut self.current_scope);
                // Restore scope before converting init so outer bindings are visible.
                self.current_scope = saved_scope.clone();
                let init_id = self.convert_expr(init)?;
                let ssa_id = self.next_ssa_id();
                let acquire_node = ICNFNode {
                    id: ssa_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assign(name.clone(), init_id),
                };
                self.current_scope.insert(name.clone(), ssa_id);
                // Convert body but don't emit close — resource cleanup is implicit.
                let _body_stmts = self.convert_expr_to_stmts(body)?;
                self.current_scope = saved_scope;
                Ok(vec![acquire_node])
            }

            // Set! mutation.
            ExprInner::SetBang(target, val) => {
                let val_nodes = self.convert_expr_collect(val)?;
                let val_id = val_nodes.last().map(|n| n.id).unwrap_or(0);
                if let Some(&existing_ssa) = self.current_scope.get(target) {
                    let setbang_id = self.next_ssa_id();
                    let new_ssa = self.next_ssa_id();
                    // Update scope to point to new SSA.
                    self.current_scope.insert(target.clone(), new_ssa);
                    let mut result = val_nodes;
                    result.push(ICNFNode {
                        id: setbang_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::SetBang(target.clone(), val_id),
                    });
                    result.push(ICNFNode {
                        id: new_ssa,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::Assign(target.clone(), val_id),
                    });
                    Ok(result)
                } else {
                    Ok(vec![ICNFNode {
                        id: self.next_ssa_id(),
                        region: Region::Heap,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::SetBang(target.clone(), val_id),
                    }])
                }
            }

            // Unwrap alias.
            ExprInner::Unwrap(expr) => {
                let inner_id = self.convert_expr(expr)?;
                Ok(vec![self.emit(ICNFInner::Unwrap(inner_id))])
            }

            // Assert (from AST).
            ExprInner::Assert(cond, msg_opt) => {
                let cond_id = self.convert_expr(cond)?;
                let msg: Option<String> = msg_opt.clone();
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assert {
                        cond_ssa: cond_id,
                        msg,
                    },
                }])
            }

            // Error value.
            ExprInner::Error(_msg) => {
                let ssa_id = self.next_ssa_id();
                Ok(vec![ICNFNode {
                    id: ssa_id,
                    region: Region::Heap,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::ErrValue(0 /* error payload placeholder */),
                }])
            }

            // Def (top-level variable binding).
            ExprInner::Def(name, val) => {
                let saved_scope = std::mem::take(&mut self.current_scope);
                let val_id = self.convert_expr(val)?;
                let ssa_id = self.next_ssa_id();
                let assign_node = ICNFNode {
                    id: ssa_id,
                    region: Region::Global,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assign(name.clone(), val_id),
                };
                self.current_scope.insert(name.clone(), ssa_id);
                // Also emit as global statement.
                self.global_stmts.push(assign_node.clone());
                let result = vec![assign_node];
                self.current_scope = saved_scope;
                Ok(result)
            }

            // Test-related expressions.
            ExprInner::AssertEqual(a, b) => {
                let a_id = self.convert_expr(a)?;
                drop(self.convert_expr(b)); // TODO: compare SSA IDs for assert-equal semantics.
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assert {
                        cond_ssa: a_id,
                        msg: Some("assert-equal failed".to_string()),
                    },
                }])
            }

            ExprInner::AssertFail(expr, _msg) => {
                let _ = self.convert_expr(expr)?;
                Ok(vec![self.emit(ICNFInner::Begin(Vec::new()))])
            }

            // AssertTrue.
            ExprInner::AssertTrue(expr, msg_opt) => {
                let expr_id = self.convert_expr(expr)?;
                let msg: Option<String> = msg_opt.clone();
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assert {
                        cond_ssa: expr_id,
                        msg,
                    },
                }])
            }

            ExprInner::AssertFalse(expr, _msg) => {
                let expr_id = self.convert_expr(expr)?;
                Ok(vec![ICNFNode {
                    id: self.next_ssa_id(),
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::Assert {
                        cond_ssa: expr_id,
                        msg: Some("assert-false failed".to_string()),
                    },
                }])
            }

            ExprInner::TestSuite(..)
            | ExprInner::TestDecl(..)
            | ExprInner::TestProperty(..)
            | ExprInner::Setup(..)
            | ExprInner::Teardown(..)
            | ExprInner::RunTests(..)
            | ExprInner::TestCompile(..) => Ok(vec![self.emit(ICNFInner::Begin(Vec::new()))]),

            _ => {
                // Fallback: emit as Begin with empty body.
                Ok(vec![self.emit(ICNFInner::Begin(Vec::new()))])
            }
        }
    }

    /// Recursively convert Cond clauses into nested If nodes (right-to-left).
    fn convert_cond_recursive(
        &mut self,
        clauses: &[(Box<Expr>, Box<Expr>)],
        idx: usize,
    ) -> Result<Vec<ICNFNode>, ZylError> {
        if idx >= clauses.len() {
            return Ok(vec![self.emit(ICNFInner::Unit)]);
        }

        let (pred, body) = &clauses[idx];
        let cond_id = self.convert_expr(pred)?;

        // Convert body and push to globals so intermediate nodes are visible for operand lookup.
        let mut body_stmts = self.convert_expr_to_stmts(body)?;
        if self.push_to_globals {
            for s in &body_stmts {
                if !self.global_stmts.iter().any(|n| n.id == s.id) {
                    self.global_stmts.push(s.clone());
                }
            }
        }

        let then_id = if !body_stmts.is_empty() {
            body_stmts.last().unwrap().id
        } else {
            0
        };

        // Else branch: next clause or Unit.
        let else_id = if idx + 1 < clauses.len() {
            let rest = self.convert_cond_recursive(clauses, idx + 1)?;
            if !rest.is_empty() {
                rest.last().unwrap().id
            } else {
                0
            }
        } else {
            0 // last clause — no explicit else (returns Unit).
        };

        let result_var = format!("___cond_result_{}", self.ssa_id_counter.get());
        let phi_id = self.next_ssa_id();

        let result_var_clone = result_var.clone();
        let mut nodes = vec![ICNFNode {
            id: cond_id,
            region: Region::Stack,
            typ: None,
            is_branch_body: false,
            node: ICNFInner::If {
                cond_ssa: cond_id,
                then_body: body_stmts.clone(),
                else_body: Vec::new(),
                result_var,
            },
        }];
        for s in body_stmts {
            nodes.push(s);
        }
        // Phi merge node.
        nodes.push(ICNFNode {
            id: phi_id,
            region: Region::Stack,
            typ: None,
            is_branch_body: false,
            node: ICNFInner::Assign(result_var_clone, cond_id),
        });

        Ok(nodes)
    }

    /// Convert an expression to its SSA ID. Pushes to globals only if push_to_globals is true.
    fn convert_expr(&mut self, expr: &Expr) -> Result<usize, ZylError> {
        let stmts = self.convert_expr_to_stmts(expr)?;
        if self.push_to_globals {
            for s in stmts.clone() {
                if !self.global_stmts.iter().any(|n| n.id == s.id) {
                    self.global_stmts.push(s);
                }
            }
        }
        if !stmts.is_empty() {
            Ok(stmts.last().unwrap().id)
        } else {
            Ok(0)
        }
    }

    /// Convert an expression and push results to globals (top-level only). Returns SSA ID.
    fn convert_and_push(&mut self, expr: &Expr) -> Result<usize, ZylError> {
        let stmts = self.convert_expr_to_stmts(expr)?;
        for s in stmts.clone() {
            if !self.global_stmts.iter().any(|n| n.id == s.id) {
                self.global_stmts.push(s);
            }
        }
        if !stmts.is_empty() {
            Ok(stmts.last().unwrap().id)
        } else {
            Ok(0)
        }
    }

    /// Convert a branch body expression: collect statements WITHOUT pushing to globals.
    /// Branch body nodes stay embedded in the ICNF If/While/For node, not interleaved in func.body.
    fn convert_branch_body(&mut self, expr: &Expr) -> Result<Vec<ICNFNode>, ZylError> {
        // Use non-pushing mode — branch body nodes stay embedded in control flow nodes.
        let saved = std::mem::replace(&mut self.push_to_globals, false);
        let stmts = self.convert_expr_to_stmts(expr)?;
        self.push_to_globals = saved;
        Ok(stmts)
    }

    /// Convert binary operations (+ a b).
    fn convert_bin_op(&mut self, name: &str, args: &[Expr]) -> Result<Vec<ICNFNode>, ZylError> {
        match name {
            "+" => self.convert_nary_fold(BinOpKind::Add, args),
            "-" => self.convert_sub(args),
            "*" => self.convert_nary_fold(BinOpKind::Mul, args),
            "/" => self.convert_binary_only("/", BinOpKind::Div, args),
            "%" => self.convert_binary_only("%", BinOpKind::Rem, args),
            "==" => self.convert_binary_only("==", BinOpKind::Eq, args),
            "!=" => self.convert_binary_only("!=", BinOpKind::Neq, args),
            "<" => self.convert_binary_only("<", BinOpKind::Lt, args),
            ">" => self.convert_binary_only(">", BinOpKind::Gt, args),
            "<=" => self.convert_binary_only("<=", BinOpKind::Le, args),
            ">=" => self.convert_binary_only(">=", BinOpKind::Ge, args),

            "and" | "or" => {
                if args.is_empty() {
                    return Ok(vec![self.emit(ICNFInner::Const(Atom::Bool(false)))]);
                }
                let mut result = Vec::new();
                for arg in args.iter() {
                    let arg_id = self.convert_expr(arg)?;
                    let ssa_id = self.next_ssa_id();
                    result.push(ICNFNode {
                        id: arg_id,
                        region: Region::Stack,
                        typ: None,
                        is_branch_body: false,
                        node: ICNFInner::If {
                            cond_ssa: arg_id,
                            then_body: Vec::new(),
                            else_body: Vec::new(),
                            result_var: format!("___{}_result", name),
                        },
                    });
                }
                Ok(result)
            }

            _ => {
                // Unknown binary op — treat as function call.
                let mut arg_ids = Vec::with_capacity(args.len());
                for a in args.iter() {
                    let stmts = self.convert_expr_to_stmts(a)?;
                    if !stmts.is_empty() {
                        arg_ids.push(stmts.last().unwrap().id);
                    } else {
                        let id = self.next_ssa_id();
                        arg_ids.push(id);
                    }
                }

                Ok(vec![self.emit(ICNFInner::Call(name.to_string(), arg_ids))])
            }
        }
    }

    /// Convert subtraction: handles unary minus and binary n-ary fold.
    fn convert_sub(&mut self, args: &[Expr]) -> Result<Vec<ICNFNode>, ZylError> {
        let mut result = Vec::new();

        if args.is_empty() || (args.len() == 1 && !is_expr_value(args)) {
            return Ok(result);
        }

        // Unary - (negation): single non-value argument.
        if args.len() == 1 && is_unary_minus_candidate(&args[0]) {
            let arg_id = self.convert_expr_collect_id(&args[0])?;
            let ssa_id = self.next_ssa_id();
            result.push(ICNFNode {
                id: ssa_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::UnOp(UnOpKind::Negate, arg_id),
            });
        } else if args.len() == 2 {
            let mut left_stmts = self.convert_expr_collect(&args[0])?;
            let left_id = if !left_stmts.is_empty() {
                left_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut left_stmts);
            let mut right_stmts = self.convert_expr_collect(&args[1])?;
            let right_id = if !right_stmts.is_empty() {
                right_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut right_stmts);
            let ssa_id = self.next_ssa_id();
            result.push(ICNFNode {
                id: ssa_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::BinOp(BinOpKind::Sub, left_id, right_id),
            });
        } else if args.len() > 2 {
            let mut acc_stmts = self.convert_expr_collect(&args[0])?;
            let mut acc_id = if !acc_stmts.is_empty() {
                acc_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut acc_stmts);
            for arg in &args[1..] {
                let mut arg_stmts = self.convert_expr_collect(arg)?;
                let arg_id = if !arg_stmts.is_empty() {
                    arg_stmts.last().unwrap().id
                } else {
                    self.next_ssa_id()
                };
                result.append(&mut arg_stmts);
                let ssa_id = self.next_ssa_id();
                result.push(ICNFNode {
                    id: ssa_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::BinOp(BinOpKind::Sub, acc_id, arg_id),
                });
                acc_id = ssa_id;
            }
        }

        Ok(result)
    }

    /// Convert an Apply form function call (e.g., (add x y)).
    fn convert_apply_call(&mut self, name: &str, args: &[Expr]) -> Result<Vec<ICNFNode>, ZylError> {
        // Skip type annotation atoms like T_INT, ?0 etc. — these are from Phase 5's output replacement.
        if is_type_annotation_atom(name) {
            return Ok(Vec::new());
        }

        let mut result = Vec::new();
        let mut arg_ids = Vec::with_capacity(args.len());
        for a in args.iter() {
            let mut stmts = self.convert_expr_collect(a)?;
            let id = if !stmts.is_empty() {
                stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            arg_ids.push(id);
            result.append(&mut stmts);
        }

        result.push(self.emit(ICNFInner::Call(name.to_string(), arg_ids)));
        Ok(result)
    }

    /// Helper: convert N-ary fold operations (*, +).
    fn convert_nary_fold(
        &mut self,
        op: BinOpKind,
        args: &[Expr],
    ) -> Result<Vec<ICNFNode>, ZylError> {
        let mut result = Vec::new();

        if args.is_empty() {
            return Ok(result);
        }

        // Unary case for + (returns operand). For * returns 1.
        if args.len() == 1 && is_unary_fold_candidate(&args[0]) {
            match op {
                BinOpKind::Add => {}
                /* just use the operand */,
                BinOpKind::Mul => return Ok(vec![self.emit(ICNFInner::Const(Atom::Int(1)))]),
                _ => {}
            }

            let arg_id = self.convert_expr_collect_id(&args[0])?;
            // For unary +, identity — emit a load of the same value.
            result.push(ICNFNode {
                id: arg_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::Load(format!("___fold_{}", arg_id)),
            });
        } else if args.len() == 2 {
            let mut left_stmts = self.convert_expr_collect(&args[0])?;
            let left_id = if !left_stmts.is_empty() {
                left_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut left_stmts);

            let mut right_stmts = self.convert_expr_collect(&args[1])?;
            let right_id = if !right_stmts.is_empty() {
                right_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut right_stmts);

            let ssa_id = self.next_ssa_id();
            result.push(ICNFNode {
                id: ssa_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::BinOp(op, left_id, right_id),
            });
        } else if args.len() > 2 {
            let mut acc_stmts = self.convert_expr_collect(&args[0])?;
            let mut acc_id = if !acc_stmts.is_empty() {
                acc_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut acc_stmts);

            for arg in &args[1..] {
                let mut arg_stmts = self.convert_expr_collect(arg)?;
                let arg_id = if !arg_stmts.is_empty() {
                    arg_stmts.last().unwrap().id
                } else {
                    self.next_ssa_id()
                };
                result.append(&mut arg_stmts);
                let ssa_id = self.next_ssa_id();
                result.push(ICNFNode {
                    id: ssa_id,
                    region: Region::Stack,
                    typ: None,
                    is_branch_body: false,
                    node: ICNFInner::BinOp(op, acc_id, arg_id),
                });
                acc_id = ssa_id;
            }
        }

        Ok(result)
    }

    /// Helper: convert binary-only operations (/, ==, !=, <, >, <=, >=).
    fn convert_binary_only(
        &mut self,
        _name: &str,
        op: BinOpKind,
        args: &[Expr],
    ) -> Result<Vec<ICNFNode>, ZylError> {
        let mut result = Vec::new();

        if args.len() == 2 {
            let mut left_stmts = self.convert_expr_collect(&args[0])?;
            let left_id = if !left_stmts.is_empty() {
                left_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut left_stmts);
            let mut right_stmts = self.convert_expr_collect(&args[1])?;
            let right_id = if !right_stmts.is_empty() {
                right_stmts.last().unwrap().id
            } else {
                self.next_ssa_id()
            };
            result.append(&mut right_stmts);
            let ssa_id = self.next_ssa_id();
            result.push(ICNFNode {
                id: ssa_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::BinOp(op, left_id, right_id),
            });
        } else if args.len() == 1 && is_unary_fold_candidate(&args[0]) {
            let arg_id = self.convert_expr(&args[0])?;
            let ssa_id = self.next_ssa_id();
            result.push(ICNFNode {
                id: ssa_id,
                region: Region::Stack,
                typ: None,
                is_branch_body: false,
                node: ICNFInner::UnOp(UnOpKind::Negate, arg_id),
            });
        }

        Ok(result)
    }

    /// Emit an ICNF node with a new SSA ID (auto-generated).
    fn emit(&mut self, inner: ICNFInner) -> ICNFNode {
        let id = self.next_ssa_id();

        // Determine region based on the operation type.
        let region = match &inner {
            ICNFInner::Const(_) => Region::Global, // constants are global.
            ICNFInner::Load(_) | ICNFInner::Assign(_, _) => Region::Stack, // local bindings.
            ICNFInner::BinOp(..) | ICNFInner::UnOp(..) => Region::Stack, // arithmetic on stack.
            ICNFInner::Call(..) => Region::Heap,   // function results may escape.
            ICNFInner::If { .. } => Region::Stack,
            ICNFInner::While { .. } | ICNFInner::For { .. } => Region::Stack,
            ICNFInner::Closure(_) => Region::Heap,
            ICNFInner::Match { .. } => Region::Heap,
            ICNFInner::TryCatch { .. } => Region::Stack,
            ICNFInner::Begin(..) => Region::Stack,
            ICNFInner::MakeStruct(_, _) => Region::Heap, // structs are heap-allocated.
            ICNFInner::MakeVariant { .. } => Region::Heap, // tagged unions are heap-allocated.
            ICNFInner::StructGet(_, _) => Region::Stack, // field access result is stack-bound.
            ICNFInner::Match { .. } => Region::Heap, // match result may escape.
            ICNFInner::FfiCall { .. } => Region::Pin,
            ICNFInner::Spawn(_) | ICNFInner::Send(..) => Region::Heap,
            ICNFInner::ErrValue(_) | ICNFInner::OkValue(_) => Region::Heap, // Result values.
            ICNFInner::Unit => Region::Stack,
            ICNFInner::Print(..) => Region::Stack,
            ICNFInner::ReadLine => Region::Heap,
            ICNFInner::Exit(_) | ICNFInner::Close(_) => Region::Stack,
            ICNFInner::WithResource { .. } => Region::Stack,
            ICNFInner::SetBang(_, _) => Region::Stack,
            ICNFInner::Unwrap(_) => Region::Heap, // alias values are heap.
            ICNFInner::Assert { .. } => Region::Stack,
        };

        ICNFNode {
            id,
            region,
            typ: None,
            is_branch_body: false,
            node: inner,
        }
    }

    /// Resolve the type of a parameter (for function signatures).
    fn resolve_type(&self, param: &Param) -> Type {
        if let Some(ref typ_str) = param.typ {
            match typ_str.as_str() {
                "Int" => Type::Prim(crate::type_system::PrimType::Int),
                "Float" => Type::Prim(crate::type_system::PrimType::Float),
                "Bool" => Type::Prim(crate::type_system::PrimType::Bool),
                "String" => Type::Prim(crate::type_system::PrimType::String),
                "Unit" => Type::Prim(crate::type_system::PrimType::Unit),
                _ => Type::Nominal(typ_str.clone()), // user-defined type.
            }
        } else {
            Type::Var(0) // untyped parameter → fresh variable (will be inferred).
        }
    }

    /// Generate the next deterministic SSA ID.
    fn next_ssa_id(&self) -> usize {
        let id = self.ssa_id_counter.get();
        self.ssa_id_counter.set(id + 1);
        id
    }

    /// Resolve the type name for a match expression.
    /// Tries to infer from the scrutinee expression by looking for struct/ADT bindings.
    fn resolve_match_type(&self, scrutinee: &Expr, arms: &[MatchArm]) -> String {
        // Try to find type from the first arm's variant lookup.
        if let Some(first_arm) = arms.first() {
            // Look up the type that has this variant.
            for (type_name, variants) in &self.adt_defs {
                if variants.iter().any(|(v, _)| v == &first_arm.variant) {
                    return type_name.clone();
                }
            }
        }
        // Fallback: try to get type name from the scrutinee's binding.
        if let ExprInner::Atom(Atom::Ident(name)) = &scrutinee.inner {
            if let Some(&ssa_id) = self.current_scope.get(name) {
                if let Some(binding_name) = self.struct_bindings.get(&ssa_id) {
                    // Extract ADT type from "TypeName-VariantName" format.
                    if let Some(pos) = binding_name.find('-') {
                        return binding_name[..pos].to_string();
                    }
                }
            }
        }
        // Ultimate fallback — use empty string (codegen will handle generically).
        String::new()
    }
}

// ─── Helpers ──────────────────────────────────────────────────────────────

fn is_special_form_ident(op: &Expr) -> bool {
    matches!(&op.inner, ExprInner::Atom(Atom::Ident(n))
        if matches!(n.as_str(), "if" | "let" | "while" | "for" | "cond" | "try" | "match"))
}

fn is_arithmetic_or_cmp_expr(op: &Expr) -> bool {
    matches!(&op.inner, ExprInner::Atom(Atom::Ident(n))
        if is_arithmetic_or_cmp_name(n))
}

fn is_arithmetic_or_cmp_name(name: &str) -> bool {
    matches!(
        name,
        "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "and" | "or"
    )
}

/// Check if an expression looks like a value (not another Call/Apply).
fn is_expr_value(args: &[Expr]) -> bool {
    !matches!(
        &args[0].inner,
        ExprInner::Call(_, _) | ExprInner::Apply(_, _)
    )
}

/// Check if this is a unary minus candidate.
fn is_unary_minus_candidate(expr: &Expr) -> bool {
    matches!(&expr.inner, ExprInner::Atom(_)) || !is_expr_value_single(expr)
}

fn is_expr_value_single(expr: &Expr) -> bool {
    !matches!(&expr.inner, ExprInner::Call(_, _) | ExprInner::Apply(_, _))
}

/// Check if an expression can be used as a fold operand.
fn is_unary_fold_candidate(expr: &Expr) -> bool {
    matches!(&expr.inner, ExprInner::Atom(_)) || !is_expr_value_single(expr)
}

/// Check if a name looks like a type annotation atom from Phase 5.
fn is_type_annotation_atom(name: &str) -> bool {
    name.starts_with("T_") || (name.len() > 0 && matches!(name.chars().next(), Some('?')))
}

// ─── Helpers for parsing defn/def parameters from raw Call/Apply forms ──

fn is_ident_op(op: &Expr, name: &str) -> bool {
    matches!(&op.inner, ExprInner::Atom(Atom::Ident(n)) if n == name)
}

/// Parse parameter names and types from an expression (Call or Apply form).
fn parse_params_from_expr(expr: &Expr) -> Vec<Param> {
    match &expr.inner {
        // Call/Apply list of params like (x y z) or ((a Int) (b Float)).
        ExprInner::Call(op, ref items) => {
            let mut params = Vec::new();
            // If the operator is a simple identifier and all args are identifiers/keywords,
            // treat this as a raw S-expression list where every element is a param.
            if matches!(&op.inner, ExprInner::Atom(Atom::Ident(_))) {
                let all_simple = items.iter().all(|i| {
                    matches!(&i.inner, ExprInner::Atom(Atom::Ident(_) | Atom::Keyword(_)))
                });
                if all_simple {
                    // Raw list like (x y) — include operator as first param.
                    if let ExprInner::Atom(Atom::Ident(n)) = &op.inner {
                        params.push(Param {
                            span: crate::error::Span::default(),
                            name: n.clone(),
                            typ: None,
                        });
                    }
                }
            }
            for i in items.iter() {
                params.push(parse_single_param(i));
            }
            params
        }
        ExprInner::Apply(ref name, ref args)
            if !name.starts_with("make-")
                && name
                    .chars()
                    .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!')) =>
        {
            let mut params = Vec::new();
            if name
                .chars()
                .all(|c| c.is_alphabetic() || matches!(c, '_' | '-' | '?' | '!'))
            {
                params.push(Param {
                    span: crate::error::Span::default(),
                    name: name.clone(),
                    typ: None,
                });
            }
            for pe in args.iter() {
                params.push(parse_single_param(pe));
            }
            params
        }
        _ => Vec::new(),
    }
}

fn parse_single_param(expr: &Expr) -> Param {
    match &expr.inner {
        ExprInner::Call(_, ref inner) if !inner.is_empty() => {
            let name = match &inner[0].inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            let typ = if inner.len() > 1 {
                match &inner[1].inner {
                    ExprInner::Atom(Atom::Ident(s)) => Some(s.clone()),
                    _ => None,
                }
            } else {
                None
            };
            Param {
                span: crate::error::Span::default(),
                name,
                typ,
            }
        }
        _ => {
            let name = match &expr.inner {
                ExprInner::Atom(Atom::Ident(n)) => n.clone(),
                _ => "___".to_string(),
            };
            Param {
                span: crate::error::Span::default(),
                name,
                typ: None,
            }
        }
    }
}
