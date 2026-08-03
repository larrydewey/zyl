use crate::ast::Atom;
use crate::icnf::*;
use crate::type_system::{CapKind, CollectionKind, PrimType, Type};
use indexmap::IndexMap;

/// Zyl source code emitter — converts optimized ICNF back to Zyl S-expression source.
/// This is the first step toward self-hosting: generating Zyl source from Zyl programs.
pub struct ZylSourceGen {
    pub source: Vec<String>,
    /// Maps SSA IDs to variable names for output.
    ssa_to_name: IndexMap<usize, String>,
    /// Next variable name for fresh bindings.
    name_counter: usize,
    /// Current function name (for context in error messages).
    current_func: String,
    /// Track which SSA IDs have been emitted as standalone statements.
    emitted: std::collections::HashSet<usize>,
}

impl ZylSourceGen {
    pub fn new() -> Self {
        Self {
            source: Vec::new(),
            ssa_to_name: IndexMap::new(),
            name_counter: 0,
            current_func: "main".to_string(),
            emitted: std::collections::HashSet::new(),
        }
    }

    fn fresh_name(&mut self) -> String {
        let n = self.name_counter;
        self.name_counter += 1;
        format!("t{}", n)
    }

    fn ensure_name(&mut self, id: usize) -> String {
        self.ssa_to_name.get(&id).cloned().unwrap_or_else(|| "?".to_string())
    }

    /// Emit a complete Zyl source program from an ICNFProgram.
    pub fn generate(&mut self, program: &ICNFProgram) {
        for func in &program.functions {
            self.emit_function(func);
        }
        for stmt in &program.statements {
            self.emit_top_stmt(stmt);
        }
    }

    fn emit_function(&mut self, func: &ICNFFuncSig) {
        self.current_func = func.name.clone();
        self.ssa_to_name.clear();
        self.name_counter = 0;
        self.emitted.clear();

        let param_strs: Vec<String> = func
            .params
            .iter()
            .map(|(_name, typ)| self.type_to_str(typ))
            .collect();
        let param_list = if param_strs.is_empty() {
            "()".to_string()
        } else {
            format!("({})", param_strs.join(" "))
        };

        // Emit defn opening with params
        self.source.push(format!("(defn {} {}", func.name, param_list));

        // Emit function body statements inline
        self.emit_func_body(&func.body);

        // Close defn
        self.source.push(")".to_string());
        self.source.push("".to_string());
    }

    /// Emit function body as a sequence of let bindings and expressions,
    /// wrapped in a begin.
    fn emit_func_body(&mut self, stmts: &[ICNFNode]) {
        let mut buf: Vec<String> = Vec::new();

        for stmt in stmts {
            // Skip ___skip_ markers
            if let ICNFInner::Const(Atom::Keyword(s)) = &stmt.node {
                if s == "___skip_" {
                    continue;
                }
            }

            let name = self.fresh_name();
            self.ssa_to_name.insert(stmt.id, name.clone());

            match &stmt.node {
                ICNFInner::Const(atom) => {
                    buf.push(format!("(let {} {})", name, self.atom_to_str(atom)));
                }
                ICNFInner::Load(var_name) => {
                    buf.push(format!("(let {} {})", name, var_name));
                }
                ICNFInner::Assign(_var, ssa_id) => {
                    let val = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} {})", _var, val));
                }
                ICNFInner::BinOp(kind, left_id, right_id) => {
                    let l = self.ensure_name(*left_id);
                    let r = self.ensure_name(*right_id);
                    let op = binop_to_str(*kind);
                    buf.push(format!("(let {} ({} {} {}))", name, op, l, r));
                }
                ICNFInner::UnOp(kind, arg_id) => {
                    let a = self.ensure_name(*arg_id);
                    let op = unop_to_str(*kind);
                    buf.push(format!("(let {} ({} {}))", name, op, a));
                }
                ICNFInner::Call(fname, args) => {
                    let arg_names: Vec<String> = args
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    if arg_names.is_empty() {
                        buf.push(format!("(let {} ({}))", name, fname));
                    } else {
                        buf.push(format!("(let {} ({} {}))", name, fname, arg_names.join(" ")));
                    }
                }
                ICNFInner::If { cond_ssa, then_body, else_body, result_var } => {
                    let cond = self.ensure_name(*cond_ssa);
                    let then_expr = self.embed_stmts(then_body);
                    let else_expr = self.embed_stmts(else_body);
                    buf.push(format!("(let {} (if {} {} {}))", result_var, cond, then_expr, else_expr));
                }
                ICNFInner::While { cond_body, body, result_var } => {
                    let cond_expr = self.embed_stmts(cond_body);
                    let body_expr = self.embed_stmts(body);
                    buf.push(format!("(let {} (while {} {}))", result_var, cond_expr, body_expr));
                }
                ICNFInner::For { init_bindings, cond_nodes, body, result_var } => {
                    let mut parts = Vec::new();
                    // Init bindings
                    for (bind_name, val_opt) in init_bindings {
                        let val = val_opt.map(|ssa_id| self.ensure_name(ssa_id)).unwrap_or_else(|| "nil".to_string());
                        parts.push(format!("{} {}", bind_name, val));
                    }
                    let init_str = parts.join(" ");
                    let cond_expr = self.embed_stmts(cond_nodes);
                    let body_expr = self.embed_stmts(body);
                    buf.push(format!("(let {} (for ({}) {} {}))", result_var, init_str, cond_expr, body_expr));
                }
                ICNFInner::Closure { name, captures } => {
                    if captures.is_empty() {
                        buf.push(format!("(let {} (fn {} ()))", name, name));
                    } else {
                        let cap_names: Vec<String> = captures
                            .iter()
                            .filter_map(|c| self.ssa_to_name.get(&c.ssa_id).cloned())
                            .collect();
                        let caps_str = if cap_names.is_empty() {
                            "none".to_string()
                        } else {
                            cap_names.join(" ")
                        };
                        buf.push(format!("(let {} (closure {} {}))", name, name, caps_str));
                    }
                }
                ICNFInner::MakeVariant { type_name, variant_name, discriminant: _, field_ids } => {
                    let arg_names: Vec<String> = field_ids
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    if arg_names.is_empty() {
                        buf.push(format!("(let {} (make-variant {} {}))", name, type_name, variant_name));
                    } else {
                        buf.push(format!("(let {} (make-variant {} {} {}))", name, type_name, variant_name, arg_names.join(" ")));
                    }
                }
                ICNFInner::Match { scrutinee_ssa, type_name, arms, result_var } => {
                    let scrutinee = self.ensure_name(*scrutinee_ssa);
                    let mut arm_strs = Vec::new();
                    for arm in arms {
                        let body_expr = self.embed_stmts(&arm.body);
                        let mut pattern_parts = Vec::new();
                        for field in &arm.field_names {
                            pattern_parts.push(field.clone());
                        }
                        let pat_str = if pattern_parts.is_empty() {
                            "()".to_string()
                        } else {
                            format!("({})", pattern_parts.join(" "))
                        };
                        arm_strs.push(format!("({} {} {})", arm.variant_name, pat_str, body_expr));
                    }
                    buf.push(format!(
                        "(let {} (match {} {} {}))",
                        result_var,
                        type_name,
                        scrutinee,
                        arm_strs.join(" ")
                    ));
                }
                ICNFInner::TryCatch { try_body, catch_var, catch_body } => {
                    let try_expr = self.embed_stmts(try_body);
                    let catch_expr = self.embed_stmts(catch_body);
                    buf.push(format!(
                        "(let {} (try {} (catch {} {})))",
                        name, try_expr, catch_var, catch_expr
                    ));
                }
                ICNFInner::Begin(nodes) => {
                    // Emit begin body statements normally
                    for n in nodes {
                        self.emit_top_stmt(n);
                    }
                    continue; // Don't add to buf
                }
                ICNFInner::MakeStruct(sname, field_ids) => {
                    let arg_names: Vec<String> = field_ids
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    if arg_names.is_empty() {
                        buf.push(format!("(let {} (make-struct {}))", name, sname));
                    } else {
                        buf.push(format!("(let {} (make-struct {} {}))", name, sname, arg_names.join(" ")));
                    }
                }
                ICNFInner::StructGet(struct_id, offset) => {
                    let s = self.ensure_name(*struct_id);
                    buf.push(format!("(let {} (struct-get {} {}))", name, s, offset));
                }
                ICNFInner::FfiCall { name: fname, args, timeout } => {
                    let arg_names: Vec<String> = args
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    let timeout_str = timeout.to_string();
                    if arg_names.is_empty() {
                        buf.push(format!("(let {} (ffi-call {} {}))", name, fname, timeout_str));
                    } else {
                        buf.push(format!("(let {} (ffi-call {} {} {}))", name, fname, arg_names.join(" "), timeout_str));
                    }
                }
                ICNFInner::Spawn(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (spawn {}))", name, a));
                }
                ICNFInner::Send(target_id, msg_id) => {
                    let t = self.ensure_name(*target_id);
                    let m = self.ensure_name(*msg_id);
                    buf.push(format!("(let {} (send {} {}))", name, t, m));
                }
                ICNFInner::SendClosure(target_id, closure_name, _handler, captured_ids) => {
                    let t = self.ensure_name(*target_id);
                    let cap_names: Vec<String> = captured_ids
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    if cap_names.is_empty() {
                        buf.push(format!("(let {} (send-closure {} {}))", name, t, closure_name));
                    } else {
                        buf.push(format!("(let {} (send-closure {} {} {}))", name, t, closure_name, cap_names.join(" ")));
                    }
                }
                ICNFInner::ErrValue(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (err {}))", name, a));
                }
                ICNFInner::OkValue(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (ok {}))", name, a));
                }
                ICNFInner::Unit => {
                    buf.push(format!("(let {} unit)", name));
                }
                ICNFInner::Print(ssa_ids) => {
                    let arg_names: Vec<String> = ssa_ids
                        .iter()
                        .map(|id| self.ensure_name(*id))
                        .collect();
                    if arg_names.is_empty() {
                        buf.push("(print)".to_string());
                    } else {
                        buf.push(format!("(print {})", arg_names.join(" ")));
                    }
                }
                ICNFInner::ReadLine => {
                    buf.push(format!("(let {} read-line)", name));
                }
                ICNFInner::Exit(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (exit {}))", name, a));
                }
                ICNFInner::Close(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (close {}))", name, a));
                }
                ICNFInner::FileOpen { path, mode } => {
                    let p = self.ensure_name(*path);
                    let m = self.ensure_name(*mode);
                    buf.push(format!("(let {} (file-open {} {}))", name, p, m));
                }
                ICNFInner::FileRead { handle, count } => {
                    let h = self.ensure_name(*handle);
                    let c = self.ensure_name(*count);
                    buf.push(format!("(let {} (file-read {} {}))", name, h, c));
                }
                ICNFInner::FileWrite { handle, data } => {
                    let h = self.ensure_name(*handle);
                    let d = self.ensure_name(*data);
                    buf.push(format!("(let {} (file-write {} {}))", name, h, d));
                }
                ICNFInner::BufAppend { dst, src } => {
                    let a = self.ensure_name(*dst);
                    let b = self.ensure_name(*src);
                    buf.push(format!("(let {} (buf-append {} {}))", name, a, b));
                }
                ICNFInner::FileClose(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (file-close {}))", name, a));
                }
                ICNFInner::WithResource { var_name, init_ssa } => {
                    let i = self.ensure_name(*init_ssa);
                    buf.push(format!("(let {} (with-resource {} {}))", name, var_name, i));
                }
                ICNFInner::SetBang(var, ssa_id) => {
                    let v = self.ensure_name(*ssa_id);
                    buf.push(format!("(set! {} {})", var, v));
                }
                ICNFInner::Unwrap(ssa_id) => {
                    let a = self.ensure_name(*ssa_id);
                    buf.push(format!("(let {} (unwrap {}))", name, a));
                }
                ICNFInner::Assert { cond_ssa, msg } => {
                    let c = self.ensure_name(*cond_ssa);
                    if let Some(msg_str) = msg {
                        buf.push(format!("(assert {} \"{}\")", c, msg_str));
                    } else {
                        buf.push(format!("(assert {})", c));
                    }
                }
            }
        }

        // Wrap all in a begin expression
        if buf.is_empty() {
            self.source.push("(begin)".to_string());
        } else {
            self.source.push(format!("(begin {})", buf.join(" ")));
        }
    }

    /// Embed a sequence of stmts as a single Zyl expression (for if/match/for branches).
    /// Does NOT push to source buffer; returns the expression string.
    /// Embed a sequence of stmts as a single Zyl expression (for if/match/for branches).
    /// Builds an inline map of SSA ID -> expression for intra-branch references.
    fn embed_stmts(&mut self, stmts: &[ICNFNode]) -> String {
        let mut id_to_expr: indexmap::IndexMap<usize, String> = indexmap::IndexMap::new();

        for stmt in stmts {
            if let ICNFInner::Const(Atom::Keyword(s)) = &stmt.node {
                if s == "___skip_" {
                    continue;
                }
            }

            let expr = self.node_to_expr_inline(stmt, &id_to_expr);
            id_to_expr.insert(stmt.id, expr);
        }

        id_to_expr.values().next_back().cloned().unwrap_or_else(|| "unit".to_string())
    }

    /// Convert a single ICNF node to an inline expression using local branch map.
    fn node_to_expr_inline<'a>(&mut self, node: &ICNFNode, id_to_expr: &'a indexmap::IndexMap<usize, String>) -> String {
        match &node.node {
            ICNFInner::Const(atom) => self.atom_to_str(atom),
            ICNFInner::Load(var_name) => var_name.clone(),
            ICNFInner::Assign(_var, ssa_id) => {
                id_to_expr.get(ssa_id).cloned().unwrap_or_else(|| "nil".to_string())
            }
            ICNFInner::BinOp(kind, left_id, right_id) => {
                let l = id_to_expr.get(left_id).cloned().unwrap_or_else(|| "?".to_string());
                let r = id_to_expr.get(right_id).cloned().unwrap_or_else(|| "?".to_string());
                let op = binop_to_str(*kind);
                format!("({} {} {})", op, l, r)
            }
            ICNFInner::UnOp(kind, arg_id) => {
                let a = id_to_expr.get(arg_id).cloned().unwrap_or_else(|| "?".to_string());
                let op = unop_to_str(*kind);
                format!("({} {})", op, a)
            }
            ICNFInner::Call(fname, args) => {
                let arg_names: Vec<String> = args.iter().map(|id| id_to_expr.get(id).cloned().unwrap_or("?".to_string())).collect();
                if arg_names.is_empty() {
                    format!("({})", fname)
                } else {
                    format!("({} {})", fname, arg_names.join(" "))
                }
            }
            ICNFInner::If { cond_ssa, then_body, else_body, result_var: _ } => {
                let cond = id_to_expr.get(cond_ssa).cloned().unwrap_or("?".to_string());
                let then_expr = self.embed_stmts(then_body);
                let else_expr = self.embed_stmts(else_body);
                format!("(if {} {} {})", cond, then_expr, else_expr)
            }
            ICNFInner::Match { scrutinee_ssa, type_name, arms, result_var: _ } => {
                let scrutinee = id_to_expr.get(scrutinee_ssa).cloned().unwrap_or("?".to_string());
                let mut arm_strs = Vec::new();
                for arm in arms {
                    let body_expr = self.embed_stmts(&arm.body);
                    let pat_str = if arm.field_names.is_empty() {
                        "()".to_string()
                    } else {
                        format!("({})", arm.field_names.join(" "))
                    };
                    arm_strs.push(format!("({} {} {})", arm.variant_name, pat_str, body_expr));
                }
                format!("(match {} {} {})", type_name, scrutinee, arm_strs.join(" "))
            }
            _ => "unit".to_string(),
        }
    }

    fn emit_top_stmt(&mut self, stmt: &ICNFNode) {
        // Skip ___skip_ markers
        if let ICNFInner::Const(Atom::Keyword(s)) = &stmt.node {
            if s == "___skip_" {
                return;
            }
        }

        let result_name = self.fresh_name();
        self.ssa_to_name.insert(stmt.id, result_name.clone());

        match &stmt.node {
            ICNFInner::Const(atom) => {
                self.source.push(format!("(let {} {})", result_name, self.atom_to_str(atom)));
            }
            ICNFInner::Load(var_name) => {
                self.source.push(format!("(let {} {})", result_name, var_name));
            }
            ICNFInner::Assign(var, ssa_id) => {
                let val = self.ensure_name(*ssa_id);
                self.source.push(format!("(let {} {})", var, val));
            }
            ICNFInner::BinOp(kind, left_id, right_id) => {
                let l = self.ensure_name(*left_id);
                let r = self.ensure_name(*right_id);
                let op = binop_to_str(*kind);
                self.source.push(format!("(let {} ({} {} {}))", result_name, op, l, r));
            }
            ICNFInner::UnOp(kind, arg_id) => {
                let a = self.ensure_name(*arg_id);
                let op = unop_to_str(*kind);
                self.source.push(format!("(let {} ({} {}))", result_name, op, a));
            }
            ICNFInner::Call(fname, args) => {
                let arg_names: Vec<String> = args.iter().map(|id| self.ensure_name(*id)).collect();
                if arg_names.is_empty() {
                    self.source.push(format!("(let {} ({}))", result_name, fname));
                } else {
                    self.source.push(format!("(let {} ({} {}))", result_name, fname, arg_names.join(" ")));
                }
            }
            ICNFInner::Print(ssa_ids) => {
                let arg_names: Vec<String> = ssa_ids.iter().map(|id| self.ensure_name(*id)).collect();
                if arg_names.is_empty() {
                    self.source.push("(print)".to_string());
                } else {
                    self.source.push(format!("(print {})", arg_names.join(" ")));
                }
            }
            _ => {
                self.source.push(format!("(let {} unit)", result_name));
            }
        }
    }

    fn atom_to_str(&self, atom: &Atom) -> String {
        match atom {
            Atom::Int(v) => v.to_string(),
            Atom::Float(v) => {
                let s = format!("{}", v);
                if !s.contains('.') && !s.contains('e') {
                    format!("{}.0", s)
                } else {
                    s
                }
            }
            Atom::Bool(v) => v.to_string(),
            Atom::Str(v) => format!("\"{}\"", v.replace('\\', "\\\\").replace('"', "\\\"")),
            Atom::Ident(v) => v.clone(),
            Atom::Keyword(v) => format!(":{}", v),
            Atom::Symbol(v) => format!("'{}", v),
        }
    }

    fn type_to_str(&self, typ: &Type) -> String {
        match typ {
            Type::Prim(p) => match p {
                PrimType::Int => "Int".to_string(),
                PrimType::Float => "Float".to_string(),
                PrimType::Bool => "Bool".to_string(),
                PrimType::Unit => "Unit".to_string(),
                PrimType::String => "String".to_string(),
            },
            Type::Cap(kind, inner) => {
                let inner_str = self.type_to_str(inner);
                match kind {
                    CapKind::TCap => format!("TCap<{}>", inner_str),
                    CapKind::TMut => format!("TMut<{}>", inner_str),
                    CapKind::TAtomic => format!("TAtomic<{}>", inner_str),
                    CapKind::TBox => format!("TBox<{}>", inner_str),
                    CapKind::TPin => format!("TPin<{}>", inner_str),
                }
            }
            Type::Fun(params, ret) => {
                let ps: Vec<String> = params.iter().map(|t| self.type_to_str(t)).collect();
                let ret_str = self.type_to_str(ret);
                format!("TFun({}) {}", ps.join(", "), ret_str)
            }
            Type::Var(n) => format!("?{}", n),
            Type::Nominal(name) => name.clone(),
            Type::Collection(kind, inner) => {
                match kind {
                    CollectionKind::Vec => format!("[{}]", self.type_to_str(inner)),
                }
            }
            Type::Map(k, v) => format!("Map<{}, {}>", self.type_to_str(k), self.type_to_str(v)),
            Type::ResultType(ok, err) => format!("Result<{}, {}>", self.type_to_str(ok), self.type_to_str(err)),
        }
    }

    pub fn to_string(&self) -> String {
        self.source.join("\n")
    }
}

fn binop_to_str(op: BinOpKind) -> &'static str {
    match op {
        BinOpKind::Add => "+",
        BinOpKind::Sub => "-",
        BinOpKind::Mul => "*",
        BinOpKind::Div => "/",
        BinOpKind::Rem => "%",
        BinOpKind::Eq => "==",
        BinOpKind::Neq => "!=",
        BinOpKind::Lt => "<",
        BinOpKind::Gt => ">",
        BinOpKind::Le => "<=",
        BinOpKind::Ge => ">=",
        BinOpKind::And => "and",
        BinOpKind::Or => "or",
    }
}

fn unop_to_str(op: UnOpKind) -> &'static str {
    match op {
        UnOpKind::Not => "not",
        UnOpKind::Negate => "-u",
    }
}
