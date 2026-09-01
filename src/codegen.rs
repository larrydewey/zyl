use crate::ast::Atom;
use crate::icnf::*;
use crate::type_system::{PrimType, Type};
use indexmap::IndexMap;
use crate::deterministic::{HashMap, HashSet};
use std::collections::BTreeMap;

// ─── x86_64 Code Generation (spec §22 — Phase 9) ──────────────────────
/// Generates Linux x86_64 System V ABI assembly from optimized ICNF.
/// Uses a linear-scan register allocator over SSA values within each function body.
/// Struct field layout: struct name → [(field_name, byte_offset)].
/// All fields are 8 bytes (64-bit aligned) in the MVP.
pub type StructLayout = BTreeMap<String, Vec<(String, usize, String)>>;

pub struct CodeGen {
    /// Collected assembly output lines.
    pub asm: Vec<String>,
    /// P1: fatal emission problems (unresolvable values). Never silently
    /// fabricate zeros — record here; main() turns these into E_CODEGEN.
    pub fatal_errors: Vec<String>,
    /// TCO: statement ids of true tail positions (self-calls eligible for
    /// frame-reuse), computed per function including through If/Match nests.
    tail_call_ids: crate::deterministic::HashSet<usize>,
    /// Label counter for unique jump targets and string literals.
    label_counter: usize,
    /// XMM register counter for SSE floating-point register allocation.
    xmm_counter: usize,
    /// Counter for unique spawn wrapper function names.
    spawn_counter: usize,
    /// IDs of nodes already emitted as standalone statements.
    standalone_emitted: crate::deterministic::HashSet<usize>,
    all_nodes: crate::deterministic::HashMap<usize, ICNFNode>,
    sg_slots: crate::deterministic::HashMap<usize, usize>,
    /// Struct field layouts for offset computation.
    struct_layouts: StructLayout,
    /// ADT definitions: type_name → list of (variant_name, field_count).
    adt_defs: std::collections::BTreeMap<String, Vec<(String, usize)>>,
    /// Closure body stmts keyed by closure SSA ID (for inline fn/lambda bodies).
    closure_bodies: crate::deterministic::HashMap<usize, Vec<ICNFNode>>,
    /// Closure metadata: closure_id → (name, captures).
    closures: crate::deterministic::HashMap<usize, (String, Vec<CaptureField>)>,
    /// Buffered wrapper functions for anonymous spawn closures.
    spawn_wrappers: Vec<String>,
    /// Function name → return type (from type inference), for print type detection.
    func_returns: crate::deterministic::HashMap<String, Type>,
    /// Function name → resolved param (name, type) list (from type inference).
    func_params: crate::deterministic::HashMap<String, Vec<(String, Type)>>,
    /// Names of parameters typed as String in the function currently being emitted.
    string_params: crate::deterministic::HashSet<String>,
    /// Names of parameters typed as Float in the function currently being emitted.
    float_params: crate::deterministic::HashSet<String>,
    /// Match-arm pattern variables bound to String fields (from type inference).
    string_locals: crate::deterministic::HashSet<String>,
    /// Match-arm pattern variables bound to Float fields (from deftype decls).
    float_locals: crate::deterministic::HashSet<String>,
    /// Temp stack slot counter for BinOp/UnOp temporaries. Separate from If result_var slots.
    temp_slot_counter: usize,
    /// All known function names (sanitized), used to distinguish direct calls
    /// from indirect calls through function-typed variables, and to materialize
    /// function-pointer values (`lea rax, _ZYL_<name>`).
    function_names: crate::deterministic::HashSet<String>,
    /// Name (sanitized) of the function currently being emitted, for resolving
    /// function-typed parameter references. Empty at top level.
    current_func: String,
    /// Names that hold function-pointer values (inferred structurally, since the
    /// type records leave HOF parameter vars unresolved). Includes local/param
    /// names that are called indirectly and names assigned from a function ref.
    fn_value_names: crate::deterministic::HashSet<String>,
    /// Mapping from original closure name → unique closure name (with SSA ID suffix).
    /// Used to resolve Call instructions that reference the original name.
    closure_name_map: crate::deterministic::HashMap<String, String>,
    /// Always-spill scheme: stack slot index for every value-producing
    /// statement id. After a statement is emitted, its result (rax) is
    /// spilled to [rbp-8*(slot+1)]; operand loads read the slot instead of
    /// trusting registers that intervening calls may have clobbered.
    value_slots: crate::deterministic::HashMap<usize, usize>,
    /// Frame size (bytes) implied by value_slots; used by all prologues.
    spill_frame: usize,
}

#[allow(dead_code)]
impl CodeGen {
    pub fn new() -> Self {
        Self {
            asm: Vec::new(),
            fatal_errors: Vec::new(),
            tail_call_ids: crate::deterministic::HashSet::default(),
            label_counter: 0,
            xmm_counter: 0,
            spawn_counter: 0,
            standalone_emitted: crate::deterministic::HashSet::default(),
            all_nodes: crate::deterministic::HashMap::default(),
            sg_slots: crate::deterministic::HashMap::default(),
            struct_layouts: StructLayout::new(),
            adt_defs: std::collections::BTreeMap::new(),
            closure_bodies: crate::deterministic::HashMap::default(),
            closures: crate::deterministic::HashMap::default(),
            spawn_wrappers: Vec::new(),
            func_returns: crate::deterministic::HashMap::default(),
            func_params: crate::deterministic::HashMap::default(),
            string_params: crate::deterministic::HashSet::default(),
            float_params: crate::deterministic::HashSet::default(),
            string_locals: crate::deterministic::HashSet::default(),
            float_locals: crate::deterministic::HashSet::default(),
            temp_slot_counter: 0,
            function_names: crate::deterministic::HashSet::default(),
            current_func: String::new(),
            fn_value_names: crate::deterministic::HashSet::default(),
            closure_name_map: crate::deterministic::HashMap::default(),
            value_slots: crate::deterministic::HashMap::default(),
            spill_frame: 256,
        }
    }

    /// Set function return types for codegen (from type inference).
    pub fn with_func_returns(mut self, returns: crate::deterministic::HashMap<String, Type>) -> Self {
        self.func_returns = returns;
        self
    }

    /// Set match-arm pattern variables that bind String fields.
    pub fn with_string_locals(mut self, vars: crate::deterministic::HashSet<String>) -> Self {
        self.string_locals = vars;
        self
    }

    /// Set resolved function parameter types for codegen (from type inference).
    pub fn with_func_params(
        mut self,
        params: crate::deterministic::HashMap<String, Vec<(String, Type)>>,
    ) -> Self {
        self.func_params = params;
        self
    }

    /// Set struct field layouts for codegen (built from AST struct definitions).
    pub fn with_struct_layouts(mut self, layouts: StructLayout) -> Self {
        self.struct_layouts = layouts;
        self
    }

    /// Set ADT definitions for codegen (built from AST deftype).
    pub fn with_adt_defs(mut self, defs: std::collections::BTreeMap<String, Vec<(String, usize)>>) -> Self {
        self.adt_defs = defs;
        self
    }

    /// Set closure body stmts for codegen (from ICNF closure conversion).
    pub fn with_closure_bodies(mut self, bodies: crate::deterministic::HashMap<usize, Vec<ICNFNode>>) -> Self {
        self.closure_bodies = bodies;
        self
    }

    /// Set closure metadata for codegen (from ICNF closure conversion).
    pub fn with_closures(mut self, closures: crate::deterministic::HashMap<usize, (String, Vec<CaptureField>)>) -> Self {
        self.closures = closures;
        self
    }

    /// Collect all operand IDs (L/R for BinOp, arg for UnOp, args for Call/Print/FfiCall, val for Assign, cond_ssa for If, embedded stmts for Begin/While/For/Match) from an ICNF node and its children.
    fn collect_operand_ids_in_node(node: &ICNFInner, out: &mut HashSet<usize>) {
        match node {
            ICNFInner::BinOp(_, l, r) => {
                out.insert(*l);
                out.insert(*r);
            }
            ICNFInner::UnOp(_, id) => {
                out.insert(*id);
            }
            ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) | ICNFInner::Print(args) | ICNFInner::FfiCall { args, .. } => {
                for &a in args {
                    out.insert(a);
                }
            }
            ICNFInner::Assign(_, val) => {
                out.insert(*val);
            }
            ICNFInner::MakeVariant { field_ids, .. } => {
                for &f in field_ids {
                    out.insert(f);
                }
            }
            ICNFInner::If { cond_ssa, then_body, else_body, .. } => {
                out.insert(*cond_ssa);
                for n in then_body {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
                for n in else_body {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
            }
            ICNFInner::While { cond_body, body, .. } => {
                for n in cond_body {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
                for n in body {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
            }
            ICNFInner::For { cond_nodes, body, .. } => {
                for n in cond_nodes {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
                for n in body {
                    Self::collect_operand_ids_in_node(&n.node, out);
                }
            }
            ICNFInner::Match { arms, .. } => {
                for arm in arms {
                    for n in &arm.body {
                        Self::collect_operand_ids_in_node(&n.node, out);
                    }
                }
            }
            ICNFInner::Begin(stmts) => {
                for s in stmts {
                    Self::collect_operand_ids_in_node(&s.node, out);
                }
            }
            _ => {}
        }
    }

    /// Emit buffered spawn wrapper functions (standalone functions with their own prologue/epilogue).
    fn emit_spawn_wrappers(&mut self) {
        for wrapper in &self.spawn_wrappers {
            self.asm.push(wrapper.clone());
        }
        self.spawn_wrappers.clear();
    }

    /// Look up the byte offset of a field within a struct.
    fn struct_field_offset(&self, struct_name: &str, field_name: &str) -> Option<usize> {
        self.struct_layouts
            .get(struct_name)
            .and_then(|fields| {
                fields
                    .iter()
                    .position(|(name, _, _)| name == field_name)
                    .map(|pos| pos * 8) // 8 bytes per field (64-bit)
            })
    }

    /// Generate assembly from an optimized ICNF program.
    pub fn generate(&mut self, program: &ICNFProgram) {
        // Build a program-wide id -> node map so deeply nested nodes (e.g. an
        // If condition inside another If's else body) can always be resolved.
        {
            fn walk<'a>(stmts: &'a [ICNFNode], map: &mut crate::deterministic::HashMap<usize, ICNFNode>) {
                for st in stmts {
                    map.insert(st.id, st.clone());
                    let nested: Vec<&Vec<ICNFNode>> = match &st.node {
                        ICNFInner::If { then_body, else_body, .. } => vec![then_body, else_body],
                        ICNFInner::Match { arms, .. } => arms.iter().map(|a| &a.body).collect(),
                        ICNFInner::While { cond_body, body, .. } => vec![cond_body, body],
                        ICNFInner::For { cond_nodes, body, .. } => vec![cond_nodes, body],
                        ICNFInner::Begin(b) => vec![b],
                        ICNFInner::TryCatch { try_body, catch_body, .. } => vec![try_body, catch_body],
                        _ => vec![],
                    };
                    for b in nested {
                        walk(b, map);
                    }
                }
            }
            walk(&program.statements, &mut self.all_nodes);
            for f in &program.functions {
                walk(&f.body, &mut self.all_nodes);
            }
            for body in program.closure_bodies.values() {
                walk(body, &mut self.all_nodes);
            }
        }
        // Always-spill pre-pass: assign a stack slot to every value-producing
        // statement (recursively through embedded bodies) so operand loads can
        // read memory instead of trusting clobber-prone registers.
        {
            fn vwalk(stmts: &[ICNFNode], next: &mut usize, out: &mut crate::deterministic::HashMap<usize, usize>) {
                for st in stmts {
                    let value_kind = matches!(
                        &st.node,
                        ICNFInner::Call(..)
                            | ICNFInner::CallIndirect(..)
                            | ICNFInner::FfiCall { .. }
                            | ICNFInner::BinOp(..)
                            | ICNFInner::UnOp(..)
                            | ICNFInner::Eq { .. }
                            | ICNFInner::MakeVariant { .. }
                            | ICNFInner::MakeStruct(..)
                            | ICNFInner::StructGet(..)
                            | ICNFInner::FileWrite { .. }
                            | ICNFInner::I32Imm(_)
                            | ICNFInner::StrImm(_)
                            | ICNFInner::ReadLine
                    );
                    if value_kind && !out.contains_key(&st.id) {
                        out.insert(st.id, *next);
                        *next += 1;
                    }
                    let nested: Vec<&Vec<ICNFNode>> = match &st.node {
                        ICNFInner::If { then_body, else_body, .. } => vec![then_body, else_body],
                        ICNFInner::Match { arms, .. } => arms.iter().map(|a| &a.body).collect(),
                        ICNFInner::While { cond_body, body, .. } => vec![cond_body, body],
                        ICNFInner::For { cond_nodes, body, .. } => vec![cond_nodes, body],
                        ICNFInner::Begin(b) => vec![b],
                        ICNFInner::TryCatch { try_body, catch_body, .. } => vec![try_body, catch_body],
                        _ => vec![],
                    };
                    for b in nested {
                        vwalk(b, next, out);
                    }
                }
            }
            let mut next = 512usize; // base above named-local slots
            vwalk(&program.statements, &mut next, &mut self.value_slots);
            for f in &program.functions {
                vwalk(&f.body, &mut next, &mut self.value_slots);
            }
            for body in program.closure_bodies.values() {
                vwalk(body, &mut next, &mut self.value_slots);
            }
            // Frame must cover the highest slot offset used anywhere.
            self.spill_frame = ((next + 2) * 8 + 15) / 16 * 16;
        }

        // Use Intel syntax (no % prefix for registers).
        self.asm.push(".intel_syntax noprefix".to_string());

        // Collect all string literals and float constants upfront.
        let mut strings = HashSet::default();
        let mut floats: Vec<(f64, String)> = Vec::new();
        Self::collect_strings(program, &mut strings);
        Self::collect_floats(program, &mut floats);

        // Build the set of known function names for direct-vs-indirect call
        // disambiguation and function-pointer materialization.
        self.function_names.clear();
        for func in &program.functions {
            self.function_names.insert(func.name.clone());
        }
        self.function_names
            .extend(self.func_params.keys().cloned());
        self.function_names
            .extend(self.func_returns.keys().cloned());
        // Add closure names (nested defn inside functions) to function_names
        // so they are materialized as function pointers and emitted as code.
        for (_, (cname, _)) in &program.closures {
            self.function_names.insert(cname.clone());
        }
        // Build closure original-name → unique-name map for call resolution.
        // Unique names follow patterns: `base_XXXX` or `base_fn_XXXX` where XXXX is hex SSA ID.
        self.closure_name_map.clear();
        for (_, (unique_name, _)) in &program.closures {
            if let Some(orig) = closure_original_name(unique_name) {
                self.closure_name_map.insert(orig, unique_name.clone());
            }
        }
        // Also register unqualified closure names (strip "fn_" prefix) so that
        // code references like `add` resolve to the closure's function pointer.
        for (_, (cname, _)) in &program.closures {
            if let Some(unqualified) = cname.strip_prefix("fn_") {
                self.function_names.insert(unqualified.to_string());
            }
        }

        // Structurally infer which names hold function-pointer values: any call
        // callee that is not a known function is an indirect function value
        // (e.g. a higher-order parameter or local). This is type-independent
        // because unresolved HOF param vars never surface Type::Fun to codegen.
        self.fn_value_names.clear();
        {
            let mut callee_names: HashSet<String> = HashSet::default();
            for stmt in &program.statements {
                collect_call_names(stmt, &program.closure_bodies, &mut callee_names);
            }
            for func in &program.functions {
                for stmt in &func.body {
                    collect_call_names(stmt, &program.closure_bodies, &mut callee_names);
                }
            }
            for (_, body) in &program.closure_bodies {
                for stmt in body {
                    collect_call_names(stmt, &program.closure_bodies, &mut callee_names);
                }
            }
            self.fn_value_names = callee_names
                .iter()
                .filter(|n| !self.function_names.contains(*n))
                .cloned()
                .collect();
        }

        // Dead-function elimination: only emit functions reachable from the
        // top-level statements and the auto-called main.
        let reachable = reachable_functions(program);

        // Emit rodata section with all static data first.
        self.emit_rodata(&strings, &floats);

        // Emit bss section for writable buffers (hexbuf, str_minus) BEFORE any code.
        self.asm_push_align();
        self.asm.push(".section .bss".to_string());
        self.asm_push_align();
        self.asm.push(".align 16".to_string());
        self.asm_push_align();
        self.asm.push(".hexbuf:".to_string());
        self.asm_push_align();
        self.asm.push("    .space 35".to_string());
        self.asm_push_align();
        self.asm.push(".stdin_buf:".to_string());
        self.asm_push_align();
        self.asm.push("    .space 4096".to_string());

        // Global buffer for file reads. Sized well above any single
        // `file-read` count callers request (e.g. boot-run reads up to
        // 1048576 bytes) — the read syscall writes the full requested
        // count straight into this buffer with no clamping, so it must
        // be at least that large or larger reads corrupt adjacent bss.
        self.asm_push_align();
        self.asm.push(".file_read_buf:".to_string());
        self.asm_push_align();
        self.asm.push("    .space 8388608".to_string());

        // Emit text (code) section.
        self.asm_push_align();
        self.asm.push(".text".to_string());

        // Entry point: main() called by C runtime.
        let entry_label = "main";
        self.asm_push_align();
        self.asm.push(".globl main".to_string());
        self.asm_push_align();
        self.asm.push(format!("{}:", entry_label));

        // Set up stack frame.
        self.asm_push_align();
        self.asm.push("    push rbp".to_string());
        self.asm_push_align();
        self.asm.push("    mov rbp, rsp".to_string());

        // Allocate stack space for locals + always-spill value slots.
        self.asm_push_align();
        self.asm
            .push(format!("    sub rsp, {}", self.spill_frame.max(256)));

        // Ensure Heap/Pin arenas are initialized before any allocations.
        self.asm_push_align();
        self.asm.push("    mov r15, rsp".to_string());
        self.asm.push("    and rsp, -16".to_string());
        self.asm.push("    call zyl_ensure_arenas@plt".to_string());
        self.asm.push("    mov rsp, r15".to_string());

        if !program.statements.is_empty() {
            let mut local_vars: HashMap<String, usize> = HashMap::default();
            // Track emitted IDs to avoid duplicate emission of branch body nodes.
            let mut emitted_ids: crate::deterministic::HashSet<usize> =
                program.emitted_branch_ids.clone();

            // Collect all IDs that appear inside embedded branch bodies (If/While/etc).
            let mut branch_body_ids: crate::deterministic::HashSet<usize> =
                crate::deterministic::HashSet::default();
            for stmt in &program.statements {
                if let ICNFInner::If {
                        then_body,
                        else_body,
                        ..
                    } = &stmt.node {
                        for n in then_body.iter().chain(else_body.iter()) {
                            branch_body_ids.insert(n.id);
                            // Also collect operand IDs referenced by Print/Call nodes.
                            if let ICNFInner::Print(args) = &n.node {
                                for &arg_id in args {
                                    branch_body_ids.insert(arg_id);
                                }
                            } else if let ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) = &n.node {
                                for &arg_id in args {
                                    branch_body_ids.insert(arg_id);
                                }
                            } else if let ICNFInner::FfiCall { args, .. } = &n.node {
                                for &arg_id in args {
                                    branch_body_ids.insert(arg_id);
                                }
                            }
                        }
                    }
                // Match arm bodies are embedded control flow: their nodes live both
                // in program.statements and in arm.body. Mark them so the main emit
                // loop skips them (the Match handler emits them exactly once).
                if let ICNFInner::Match { arms, .. } = &stmt.node {
                    for arm in arms {
                        for n in &arm.body {
                            branch_body_ids.insert(n.id);
                        }
                    }
                }
            }

            // Collect operand IDs for the main body to skip intermediate Load nodes.
            let mut main_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
            for stmt in &program.statements {
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => {
                        main_operand_ids.insert(*left);
                        main_operand_ids.insert(*right);
                    }
                    ICNFInner::UnOp(_, id) => {
                        main_operand_ids.insert(*id);
                    }
                    ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) => {
                        for &a in args {
                            main_operand_ids.insert(a);
                        }
                    }
                    ICNFInner::FfiCall { args, .. } => {
                        for &a in args {
                            main_operand_ids.insert(a);
                        }
                    }
                    ICNFInner::Print(args) => {
                        for &a in args {
                            main_operand_ids.insert(a);
                        }
                    }
                    ICNFInner::If { cond_ssa, .. } => {
                        main_operand_ids.insert(*cond_ssa);
                    }
                    ICNFInner::For { cond_nodes, body, .. } => {
                        collect_body_operand_ids(cond_nodes, &mut main_operand_ids);
                        collect_body_operand_ids(body, &mut main_operand_ids);
                    }
                    ICNFInner::StructGet(struct_id, _) => {
                        main_operand_ids.insert(*struct_id);
                    }
                    ICNFInner::Send(actor_id, msg_id) => {
                        main_operand_ids.insert(*actor_id);
                        main_operand_ids.insert(*msg_id);
                    }
                    ICNFInner::SendClosure(actor_id, _, _, _) => {
                        main_operand_ids.insert(*actor_id);
                    }
                    ICNFInner::MakeStruct(_, field_ids) => {
                        for &fid in field_ids {
                            main_operand_ids.insert(fid);
                        }
                    }
                    ICNFInner::MakeVariant { field_ids, .. } => {
                        for &fid in field_ids {
                            main_operand_ids.insert(fid);
                        }
                    }
                    ICNFInner::FileOpen { path, mode } => {
                        main_operand_ids.insert(*path);
                        main_operand_ids.insert(*mode);
                    }
                    ICNFInner::FileRead { handle, count } => {
                        main_operand_ids.insert(*handle);
                        main_operand_ids.insert(*count);
                    }
                    ICNFInner::FileWrite { handle, data } => {
                        main_operand_ids.insert(*handle);
                        main_operand_ids.insert(*data);
                    }
                    ICNFInner::BufAppend { dst, src } => {
                        main_operand_ids.insert(*dst);
                        main_operand_ids.insert(*src);
                    }
                    ICNFInner::FileClose(handle) => {
                        main_operand_ids.insert(*handle);
                    }
                    _ => {}
                }
            }

            // Capture phi slots for top-level If result variables before the emit loop.
            // Find the phi Assign node for each If and use its slot.
            let mut empty_phi: crate::deterministic::HashMap<String, String> = HashMap::default();
            // Build slot map first: count Assign nodes to get correct slot indices.
            // Only pre-register If result_vars that have their phi Assign as a direct
            // child in program.statements (not nested Ifs — their assigns live inside
            // branch bodies and must compute slots dynamically).
            let mut assign_count: usize = 0;
            let mut assign_slots: crate::deterministic::HashMap<String, usize> = HashMap::default();
            // Collect result_vars whose phi Assign is a top-level program statement.
            let mut top_level_result_vars: crate::deterministic::HashSet<String> =
                crate::deterministic::HashSet::default();
            for stmt in &program.statements {
                if let ICNFInner::If { result_var, .. } = &stmt.node {
                    // Check if there's a phi Assign for this result_var in program.statements.
                    let has_phi_assign = program.statements.iter().any(|s| {
                        if let ICNFInner::Assign(name, _) = &s.node {
                            name == result_var
                        } else {
                            false
                        }
                    });
                    if has_phi_assign {
                        top_level_result_vars.insert(result_var.clone());
                    }
                }
            }
            for stmt in &program.statements {
                if let ICNFInner::If { result_var, .. } = &stmt.node {
                    // Only register If result_vars whose phi Assign is a top-level statement.
                    if top_level_result_vars.contains(result_var)
                        && !local_vars.contains_key(result_var)
                    {
                        local_vars.insert(result_var.clone(), assign_count);
                        assign_slots.insert(result_var.clone(), assign_count);
                        assign_count += 1;
                    }
                }
                if let ICNFInner::Assign(name, _) = &stmt.node {
                    if !assign_slots.contains_key(name) {
                        assign_slots.insert(name.clone(), assign_count);
                        assign_count += 1;
                    }
                }
            }
            // Register nested If result_vars in local_vars so phi load can find their slots.
            fn register_nested_ifs_recursive(
                stmts: &[ICNFNode],
                local_vars: &mut HashMap<String, usize>,
                assign_slots: &mut HashMap<String, usize>,
                assign_count: &mut usize,
            ) {
                for stmt in stmts {
                    if let ICNFInner::If { result_var, then_body, else_body, .. } = &stmt.node {
                        if !local_vars.contains_key(result_var) {
                            local_vars.insert(result_var.clone(), *assign_count);
                            assign_slots.insert(result_var.clone(), *assign_count);
                            *assign_count += 1;
                        }
                        register_nested_ifs_recursive(then_body, local_vars, assign_slots, assign_count);
                        register_nested_ifs_recursive(else_body, local_vars, assign_slots, assign_count);
                    }
                    if let ICNFInner::Match { arms, .. } = &stmt.node {
                        for arm in arms {
                            register_nested_ifs_recursive(&arm.body, local_vars, assign_slots, assign_count);
                        }
                    }
                    if let ICNFInner::While { cond_body, body, .. } = &stmt.node {
                        register_nested_ifs_recursive(cond_body, local_vars, assign_slots, assign_count);
                        register_nested_ifs_recursive(body, local_vars, assign_slots, assign_count);
                    }
                    if let ICNFInner::For { body, .. } = &stmt.node {
                        register_nested_ifs_recursive(body, local_vars, assign_slots, assign_count);
                    }
                    if let ICNFInner::Begin(stmts) = &stmt.node {
                        register_nested_ifs_recursive(stmts, local_vars, assign_slots, assign_count);
                    }
                }
            }
            register_nested_ifs_recursive(&program.statements, &mut local_vars, &mut assign_slots, &mut assign_count);
            // Compute phi_slots for If nodes in program.statements.
            // If ICNF has phi Assigns, use those slots. Otherwise compute dynamically.
            for (i, stmt) in program.statements.iter().enumerate() {
                if let ICNFInner::If { result_var, .. } = &stmt.node {
                    // Find the phi Assign for this result_var (it's an Assign node after the If).
                    for (j, s) in program.statements.iter().enumerate() {
                        if j > i {
                            if let ICNFInner::Assign(name, _) = &s.node {
                                if name == result_var {
                                    if let Some(&slot) = assign_slots.get(result_var) {
                                        let offset = ((slot + 1) * 8).to_string();
                                        empty_phi.insert(result_var.clone(), offset);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    // If no phi Assign found, compute slot dynamically like emit_node does.
                    if !empty_phi.contains_key(result_var) {
                        let slot_count = empty_phi.len();
                        let offset = ((slot_count + 1) * 8).to_string();
                        empty_phi.insert(result_var.clone(), offset);
                    }
                }
            }

            // Pre-scan: assign slots to For loop variables before processing statements.
            // Also mark For-loop body/step/cond nodes as already emitted so they don't get emitted by the parent loop.
            let mut next_slot: usize = 0;
            let mut for_loop_vars: crate::deterministic::HashSet<String> = crate::deterministic::HashSet::default();
            let _for_body_ids: crate::deterministic::HashSet<usize> = crate::deterministic::HashSet::default();
            for stmt in &program.statements {
                if let ICNFInner::For { init_bindings, cond_nodes, body, result_var: _, } = &stmt.node {
                    for (name, _) in init_bindings {
                        if !local_vars.contains_key(name) {
                            local_vars.insert(name.clone(), next_slot);
                            next_slot += 1;
                        }
                        for_loop_vars.insert(name.clone());
                    }
                    for n in cond_nodes {
                        emitted_ids.insert(n.id);
                    }
                    for n in body {
                        emitted_ids.insert(n.id);
                    }
                }
            }

            for stmt in program.statements.iter() {
                // Skip nodes that are part of branch bodies - they're handled by their parent If/While/etc.
                if stmt.is_branch_body {
                    continue;
                }
                // Also skip nodes whose IDs appear inside embedded branch body vectors (e.g., Const args to Print in branches).
                if branch_body_ids.contains(&stmt.id) {
                    continue;
                }
                // Skip Load/Const/Assign nodes that are operands to a parent node.
                // Also skip BinOp/UnOp when they are Print operands — Print handles them
                // via emit_float_load_into, which ensures correct register usage.
                // Also skip Load nodes for For loop variables — the For handler manages them.
                if main_operand_ids.contains(&stmt.id) {
                    match &stmt.node {
                        ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                        | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                        ICNFInner::FfiCall { .. } => continue,
                        ICNFInner::BinOp(_, _, _) => continue,
                        ICNFInner::UnOp(_, _) => continue,
                        ICNFInner::Eq { .. } => continue,
                        ICNFInner::I32Imm(_) => continue,
                        ICNFInner::MakeVariant { .. } => continue,
                        // Emitted inline by emit_load_into when its parent
                        // requests the value — must not be emitted twice (a
                        // second, "already emitted" fetch finds no phi slot
                        // for a Match embedded only as an operand, and
                        // silently leaves stale register data instead).
                        ICNFInner::Match { .. } => continue,
                        // Same bug class as Match above, for If: eagerly
                        // emitting it here marks it "already emitted" with
                        // no phi slot recorded for this embedding, so a
                        // later on-demand fetch silently falls back to
                        // whatever happens to be in the register instead of
                        // the if-expression's real result.
                        ICNFInner::If { .. } => continue,
                        _ => {}
                    }
                }
                if let ICNFInner::Load(name) = &stmt.node {
                    if for_loop_vars.contains(name) {
                        continue;
                    }
                }
                // Track variable assignments for stack slot mapping using a counter.
                // Formula: (slot + 1) * 8 for stack slot.
                if let ICNFInner::Assign(name, _) = &stmt.node {
                    if !local_vars.contains_key(name) {
                        local_vars.insert(name.clone(), next_slot);
                        next_slot += 1;
                    }
                }
            }
            // Reset temp_slot_counter past all local variable slots so BinOp temp
            // slots don't collide with variable slots (same as the function path).
            self.temp_slot_counter = next_slot;

            // Build a full lookup map for the main program statements.
            let mut main_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
            for stmt in &program.statements {
                main_lookup.insert(stmt.id, stmt);
            }
            // Collect IDs of BinOp statements that are If conditions — these must be
            // skipped in the main loop because the If handler emits them inline.
            // Must also collect from branch bodies (nested Ifs whose If-statement is
            // not in program.statements but whose condition BinOp was pushed to globals).
            let mut if_condition_ids: crate::deterministic::HashSet<usize> = HashSet::default();
            fn collect_if_cond_ids(node: &ICNFNode, ids: &mut HashSet<usize>) {
                if let ICNFInner::If { cond_ssa, then_body, else_body, .. } = &node.node {
                    ids.insert(*cond_ssa);
                    for n in then_body.iter().chain(else_body.iter()) {
                        collect_if_cond_ids(n, ids);
                    }
                }
            }
            for stmt in &program.statements {
                if let ICNFInner::If { cond_ssa, .. } = &stmt.node {
                    if main_lookup.contains_key(cond_ssa) {
                        if_condition_ids.insert(*cond_ssa);
                    }
                }
                collect_if_cond_ids(stmt, &mut if_condition_ids);
            }
            for stmt in &program.statements {
                // Skip nodes that are part of branch bodies.
                if stmt.is_branch_body {
                    continue;
                }
                // Skip nodes whose IDs appear inside embedded branch body vectors.
                if branch_body_ids.contains(&stmt.id) {
                    continue;
                }
                if matches!(stmt.node, ICNFInner::If { .. }) {
                    // If statements are handled via emit_node directly.
                }
                // Skip BinOp statements that are If conditions — the If handler
                // emits them inline before its branch logic.
                if if_condition_ids.contains(&stmt.id) {
                    continue;
                }
                // Skip Load/Const/Assign nodes that are operands to a parent node.
                // BinOp/UnOp must be emitted even when in operand_ids.
                if main_operand_ids.contains(&stmt.id) {
                    match &stmt.node {
                        ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                        | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                        ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => {
                            // Emitted on-demand by their parent handler.
                            continue
                        }
                        ICNFInner::BinOp(_, _, _) => {} // keep BinOp in lookup for emit_condition_inline
                        ICNFInner::StructGet(..) => {
                            // Pure value: emitted on demand by its consumer.
                            continue
                        }
                        _ => {}
                    }
                }
                if let ICNFInner::Load(name) = &stmt.node {
                    if for_loop_vars.contains(name) {
                        continue;
                    }
                }
                self.emit_node(
                    stmt,
                    &program.statements,
                    &local_vars,
                    &mut emitted_ids,
                    &main_operand_ids,
                    &main_lookup,
                    &empty_phi,
                );
            }
        }

        // If there's a user-defined main function, run it on a worker
        // thread with a very large stack: deep recursion in self-hosted
        // compiler runs cannot rely on the 8MB main-thread stack (growth
        // is often blocked by adjacent mmaps).
        if program.functions.iter().any(|f| f.name == "main") {
            self.asm_push_align();
            self.asm
                .push("    lea rdi, [rip+_ZYL_main]".to_string());
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_call_on_big_stack@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
        }

        // Call exit(0).
        self.asm_push_align();
        self.asm
            .push("    xor edi, edi           # exit code 0".to_string());
        self.asm_push_align();
        self.asm.push("    mov r15, rsp".to_string());
        self.asm.push("    and rsp, -16".to_string());
        self.asm.push("    call exit@plt".to_string());
        self.asm.push("    mov rsp, r15".to_string());

        // Restore stack frame and return.
        self.asm_push_align();
        self.asm.push("    pop rbp".to_string());
        self.asm_push_align();
        self.asm.push("    ret".to_string());

        // Emit functions for user-defined defn.
        for func in &program.functions {
            // Skip dead functions (not reachable from top-level statements or main).
            // Exception: test functions (_test_*) are always emitted since they're
            // referenced via FnPtrImm which isn't tracked by reachability analysis.
            if !reachable.contains(&func.name) && !func.name.starts_with("_test_") {
                if std::env::var("ZYL_DBG_DCE").is_ok() {
                    eprintln!("[dce] SKIP {}", func.name);
                }
                continue;
            }
            self.current_func = func.name.clone();
            // Tail positions: walk the final-statement chain; an If/Match in
            // final position passes tail status into its branches/arms, so a
            // self-call nested inside if/match chains still qualifies.
            self.tail_call_ids.clear();
            if let Some(last) = func.body.last() {
                let mut ids = crate::deterministic::HashSet::default();
                collect_tail_calls(&last.node, last.id, &func.name, &mut ids);
                self.tail_call_ids = ids;
            }
            if std::env::var("ZYL_DBG_TCO").is_ok() && !self.tail_call_ids.is_empty() {
                eprintln!("[tco] {} -> {:?} ids", func.name, self.tail_call_ids);
            }
            let fn_name = format!("_ZYL_{}", func.name);
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", fn_name));
            self.asm_push_align();
            self.asm.push("    push rbp".to_string());
            self.asm_push_align();
            self.asm.push("    mov rbp, rsp".to_string());

            // Reserve stack space for locals + always-spill value slots.
            self.asm_push_align();
            self.asm
                .push(format!("    sub rsp, {}", self.spill_frame.max(256)));

            // Store function parameters from registers to known stack slots.
            // Float params come in XMM registers (as bit patterns), non-floats in GPRs.
            let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
            let abi_xmm_regs = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
            let resolved_params = self
                .func_params
                .get(&func.name)
                .cloned()
                .unwrap_or_else(|| func.params.clone());
            for (i, (param_name, param_type)) in func.params.iter().enumerate() {
                let resolved_type = resolved_params
                    .iter()
                    .find(|(n, _)| n == param_name)
                    .map(|(_, t)| t)
                    .unwrap_or(param_type);
                if i < 6 && !param_name.is_empty() {
                    let offset = (i + 1) * 8;
                    if matches!(resolved_type, Type::Prim(PrimType::Float)) {
                        // Float params travel as 64-bit IEEE bit patterns in
                        // GPRs (matching the caller's arg-spill path); store
                        // the GPR directly. 64-bit store (don't truncate).
                        let gpr_reg = abi_regs_64[i];
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {}",
                            offset,
                            gpr_reg
                        ));
                    } else if matches!(resolved_type, Type::Prim(PrimType::String)) {
                        // String param: pointer value, keep full 64-bit.
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {} # {}",
                            offset,
                            abi_regs_64[i],
                            param_name
                        ));
                    } else if matches!(resolved_type, Type::Fun(..)) || self.fn_value_names.contains(param_name) {
                        // Function param: function-pointer value, keep full 64-bit.
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {:#} # {}",
                            offset,
                            abi_regs_64[i],
                            param_name
                        ));
                    } else if matches!(resolved_type, Type::Prim(PrimType::Int | PrimType::Bool | PrimType::Unit)) {
                        // Scalar param: store full 64-bit. Slots are 8 bytes;
                        // a 32-bit store leaves stale upper-half garbage that
                        // later 64-bit slot reads (e.g. recursive-call args)
                        // would pick up.
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {} # {}",
                            offset,
                            abi_regs_64[i],
                            param_name
                        ));
                    } else {
                        // Nominal (struct/ADT) / pointer-TCap param: full 64-bit pointer.
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {} # {}",
                            offset,
                            abi_regs_64[i],
                            param_name
                        ));
                    }
                } else if !param_name.is_empty() {
                    // Stack-passed arg (System V): [rbp+16] is the first
                    // stack argument (index 6).
                    let offset = (i + 1) * 8;
                    let stack_off = 16 + 8 * (i - 6);
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov r10, [rbp+{}] # {}",
                        stack_off, param_name
                    ));
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov [rbp-{}], r10",
                        offset
                    ));
                }
            }

            // TCO re-entry point: self-tail-calls rewrite their arguments
            // into the parameter slots and jump here (frame is reused).
            self.asm_push_align();
            self.asm
                .push(format!(".__TCO_entry_{}:", sanitize_name(&func.name)));

            // Emit the function body statements inline.
            let mut local_vars: HashMap<String, usize> = HashMap::default();

            // Pre-populate local_vars with parameter names pointing to their stack slot indices.
            // The offset formula is (slot_idx + 1) * 8, so params use consecutive slots.
            for (i, param) in func.params.iter().enumerate() {
                if !param.0.is_empty() {
                    local_vars.insert(param.0.clone(), i);
                }
            }

            // Track String-typed parameters for print type detection.
            self.string_params.clear();
            self.float_params.clear();
            self.float_locals.clear();
            let resolved_params = self
                .func_params
                .get(&func.name)
                .cloned()
                .unwrap_or_else(|| func.params.clone());
            for param in resolved_params.iter() {
                if matches!(param.1, Type::Prim(PrimType::String)) {
                    self.string_params.insert(param.0.clone());
                }
                if matches!(param.1, Type::Prim(PrimType::Float)) {
                    self.float_params.insert(param.0.clone());
                }
            }

            // Build a lookup for body nodes by ID so we can find operand values.
            let body_stmts: Vec<ICNFNode> = func.body.clone();
            let mut func_emitted_ids: crate::deterministic::HashSet<usize> = HashSet::default();

            // First pass: assign stack slots to all local variable assignments
            // and collect operand IDs to skip intermediate Load nodes.
            let mut next_slot = func.params.len().max(6);
            let mut operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
            // Capture phi slots for all If result variables.
            let mut phi_slots: crate::deterministic::HashMap<String, String> = HashMap::default();
            for stmt in &func.body {
                if let ICNFInner::Assign(name, _) = &stmt.node {
                    if !local_vars.contains_key(name) {
                        local_vars.insert(name.clone(), next_slot);
                        next_slot += 1;
                    }
                }
                // Register If result_vars in local_vars so phi_slots can be computed.
                if let ICNFInner::If { result_var, .. } = &stmt.node {
                    if !local_vars.contains_key(result_var) {
                        local_vars.insert(result_var.clone(), next_slot);
                        next_slot += 1;
                    }
                }
                // Register Match result_vars the same way (phi slot for join).
                if let ICNFInner::Match { result_var, .. } = &stmt.node {
                    if !local_vars.contains_key(result_var) {
                        local_vars.insert(result_var.clone(), next_slot);
                        next_slot += 1;
                    }
                }
                // Collect all operand SSA IDs, including from embedded control flow bodies.
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => {
                        operand_ids.insert(*left);
                        operand_ids.insert(*right);
                    }
                    ICNFInner::UnOp(_, id) => {
                        operand_ids.insert(*id);
                    }
                    ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) => {
                        for &a in args {
                            operand_ids.insert(a);
                        }
                    }
                    ICNFInner::FfiCall { args, .. } => {
                        for &a in args {
                            operand_ids.insert(a);
                        }
                    }
                    ICNFInner::Print(args) => {
                        for &a in args {
                            operand_ids.insert(a);
                        }
                    }
                    ICNFInner::If {
                        cond_ssa,
                        then_body,
                        else_body,
                        ..
                    } => {
                        operand_ids.insert(*cond_ssa);
                        collect_cond_operand_ids(*cond_ssa, &func.body, &mut operand_ids);
                        collect_body_operand_ids(then_body, &mut operand_ids);
                        collect_body_operand_ids(else_body, &mut operand_ids);
                    }
                    ICNFInner::While { cond_body, body, result_var: _ } => {
                        collect_body_operand_ids(cond_body, &mut operand_ids);
                        collect_body_operand_ids(body, &mut operand_ids);
                    }
                    ICNFInner::For { init_bindings, cond_nodes, body, result_var: _, } => {
                        for (name, _) in init_bindings {
                            if !local_vars.contains_key(name) {
                                local_vars.insert(name.clone(), next_slot);
                                next_slot += 1;
                            }
                        }
                        collect_body_operand_ids(cond_nodes, &mut operand_ids);
                        collect_body_operand_ids(body, &mut operand_ids);
                    }
                    ICNFInner::Begin(stmts) => {
                        for s in stmts {
                            match &s.node {
                                ICNFInner::BinOp(_, l, r) => {
                                    operand_ids.insert(*l);
                                    operand_ids.insert(*r);
                                }
                                ICNFInner::UnOp(_, id) => {
                                    operand_ids.insert(*id);
                                }
                                ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) => {
                                    for &a in args {
                                        operand_ids.insert(a);
                                    }
                                }
                                ICNFInner::FfiCall { args, .. } => {
                                    for &a in args {
                                        operand_ids.insert(a);
                                    }
                                }
                                ICNFInner::Print(args) => {
                                    for &a in args {
                                        operand_ids.insert(a);
                                    }
                                }
                                ICNFInner::Eq { left, right } => {
                                    operand_ids.insert(*left);
                                    operand_ids.insert(*right);
                                }
                                _ => {}
                            }
                        }
                    }
                    ICNFInner::MakeStruct(_, field_ids) => {
                        for &fid in field_ids {
                            operand_ids.insert(fid);
                        }
                    }
                    ICNFInner::MakeVariant { field_ids, .. } => {
                        for &fid in field_ids {
                            operand_ids.insert(fid);
                        }
                    }
                    ICNFInner::Send(actor_id, msg_id) => {
                        operand_ids.insert(*actor_id);
                        operand_ids.insert(*msg_id);
                    }
                    ICNFInner::SendClosure(actor_id, _, _, _) => {
                        operand_ids.insert(*actor_id);
                    }
                    ICNFInner::Assert { cond_ssa, .. } => {
                        operand_ids.insert(*cond_ssa);
                    }
                    ICNFInner::Eq { left, right } => {
                        operand_ids.insert(*left);
                        operand_ids.insert(*right);
                    }
                    ICNFInner::Return(val_id) => {
                        operand_ids.insert(*val_id);
                    }
                    _ => {}
                }
            }

            // After first pass: register slots for ALL named variables in nested
            // bodies (If/Match/While/For/Begin) so stack slots are deterministic and
            // non-colliding before any emission. The emit-time branch handlers must
            // NOT re-assign these slots.
            fn register_func_slots(
                stmts: &[ICNFNode],
                local_vars: &mut HashMap<String, usize>,
                next_slot: &mut usize,
            ) {
                for stmt in stmts {
                    match &stmt.node {
                        ICNFInner::Assign(name, _) => {
                            if !local_vars.contains_key(name) {
                                local_vars.insert(name.clone(), *next_slot);
                                *next_slot += 1;
                            }
                        }
                        ICNFInner::If { result_var, then_body, else_body, .. } => {
                            if !local_vars.contains_key(result_var) {
                                local_vars.insert(result_var.clone(), *next_slot);
                                *next_slot += 1;
                            }
                            register_func_slots(then_body, local_vars, next_slot);
                            register_func_slots(else_body, local_vars, next_slot);
                        }
                        ICNFInner::Match { arms, .. } => {
                            for arm in arms {
                                register_func_slots(&arm.body, local_vars, next_slot);
                            }
                        }
                        ICNFInner::While { cond_body, body, result_var, .. } => {
                            if !local_vars.contains_key(result_var) {
                                local_vars.insert(result_var.clone(), *next_slot);
                                *next_slot += 1;
                            }
                            register_func_slots(cond_body, local_vars, next_slot);
                            register_func_slots(body, local_vars, next_slot);
                        }
                        ICNFInner::For { init_bindings, body, result_var, .. } => {
                            for (name, _) in init_bindings {
                                if !local_vars.contains_key(name) {
                                    local_vars.insert(name.clone(), *next_slot);
                                    *next_slot += 1;
                                }
                            }
                            if !local_vars.contains_key(result_var) {
                                local_vars.insert(result_var.clone(), *next_slot);
                                *next_slot += 1;
                            }
                            register_func_slots(body, local_vars, next_slot);
                        }
                        ICNFInner::Begin(stmts) => {
                            register_func_slots(stmts, local_vars, next_slot);
                        }
                        _ => {}
                    }
                }
            }
            register_func_slots(&func.body, &mut local_vars, &mut next_slot);
            if std::env::var("ZYL_DBG2").is_ok() {
                let mut lv: Vec<_> = local_vars.iter().collect();
                lv.sort_by_key(|(_,v)| **v);
                eprintln!("SLOTS {} next={} map={:?}", func.name, next_slot, lv);
            }

            // After first pass: capture phi slots for all If result variables.
            fn collect_func_phi_slots(
                stmts: &[ICNFNode],
                local_vars: &HashMap<String, usize>,
                phi_slots: &mut crate::deterministic::HashMap<String, String>,
            ) {
                for stmt in stmts {
                    if let ICNFInner::If { result_var, then_body, else_body, .. } = &stmt.node {
                        if let Some(&slot) = local_vars.get(result_var) {
                            phi_slots.insert(result_var.clone(), ((slot + 1) * 8).to_string());
                        }
                        collect_func_phi_slots(then_body, local_vars, phi_slots);
                        collect_func_phi_slots(else_body, local_vars, phi_slots);
                    }
                    if let ICNFInner::Match { result_var, arms, .. } = &stmt.node {
                        if let Some(&slot) = local_vars.get(result_var) {
                            phi_slots.insert(result_var.clone(), ((slot + 1) * 8).to_string());
                        }
                        for arm in arms {
                            collect_func_phi_slots(&arm.body, local_vars, phi_slots);
                        }
                    }
                    if let ICNFInner::While { cond_body, body, .. } = &stmt.node {
                        collect_func_phi_slots(cond_body, local_vars, phi_slots);
                        collect_func_phi_slots(body, local_vars, phi_slots);
                    }
                    if let ICNFInner::For { body, .. } = &stmt.node {
                        collect_func_phi_slots(body, local_vars, phi_slots);
                    }
                    if let ICNFInner::Begin(stmts) = &stmt.node {
                        collect_func_phi_slots(stmts, local_vars, phi_slots);
                    }
                }
            }
            collect_func_phi_slots(&func.body, &mut local_vars, &mut phi_slots);

            // Reset temp_slot_counter for this function. Must start after all param slots (0-5),
            // all local var slots, and all If result_var slots — to avoid colliding with params.
            self.temp_slot_counter = next_slot;
            self.sg_slots.clear();

            // Second pass: emit code.
            // Collect condition IDs to skip them in the emit loop (they'll be emitted inline by If handler).
            let mut condition_ids: crate::deterministic::HashSet<usize> = HashSet::default();
            // Collect IDs of nodes embedded in If/While/Match branch bodies so the
            // flat emit loop skips them (their parent handler emits them exactly once).
            let mut func_branch_body_ids: crate::deterministic::HashSet<usize> = HashSet::default();
            for stmt in &func.body {
                if let ICNFInner::If { then_body, else_body, .. } = &stmt.node {
                    for n in then_body.iter().chain(else_body.iter()) {
                        func_branch_body_ids.insert(n.id);
                    }
                }
                if let ICNFInner::Match { arms, .. } = &stmt.node {
                    for arm in arms {
                        for n in &arm.body {
                            func_branch_body_ids.insert(n.id);
                        }
                    }
                }
            }
            for stmt in &func.body {
                if let ICNFInner::If { cond_ssa, then_body, else_body, .. } = &stmt.node {
                    condition_ids.insert(*cond_ssa);                    // Also collect condition IDs from nested If nodes in branch bodies.
                    fn collect_cond_ids(nodes: &[ICNFNode], set: &mut HashSet<usize>) {
                        for n in nodes {
                            if let ICNFInner::If { cond_ssa, then_body, else_body, .. } = &n.node {
                                set.insert(*cond_ssa);
                                collect_cond_ids(then_body, set);
                                collect_cond_ids(else_body, set);
                            }
                        }
                    }
                    collect_cond_ids(then_body, &mut condition_ids);
                    collect_cond_ids(else_body, &mut condition_ids);
                }
            }
            let mut func_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
            for n in &body_stmts {
                func_lookup.insert(n.id, n);
            }
            for (stmt_idx, stmt) in func.body.iter().enumerate() {
                // Skip condition BinOps — they're emitted inline by the If handler.
                // Only value-computing kinds are skipped here; an If whose
                // cond_ssa collides with its own node id must still be emitted.
                if condition_ids.contains(&stmt.id)
                    && matches!(&stmt.node, ICNFInner::BinOp(_, _, _) | ICNFInner::Eq { .. })
                {
                    continue;
                }
                // Skip nodes embedded in If/Match branch bodies — emitted by parent handler.
                if func_branch_body_ids.contains(&stmt.id) {
                    continue;
                }
                // Skip standalone Call/FfiCall that is followed by an Assign
                // referencing their result (from Def["r", Call] flattening).
                // The Assign handler will emit the call on-demand.
                if matches!(&stmt.node, ICNFInner::Call(..) | ICNFInner::CallIndirect(..) | ICNFInner::FfiCall { .. }) {
                    let is_def_call = func.body.iter().skip_while(|s| s.id == stmt.id).skip(1)
                        .take_while(|s| matches!(&s.node, ICNFInner::Const(_) | ICNFInner::Load(_)))
                        .find_map(|s| {
                            if let ICNFInner::Assign(_, assigned_id) = &s.node {
                                Some(*assigned_id)
                            } else { None }
                        })
                        .map_or(false, |assigned_id| assigned_id == stmt.id);
                    if is_def_call {
                        continue;
                    }
                }
                // Skip unreferenced pure statements (dead Load/Const supply nodes from a
                // let's temp buffer) that are followed by a non-pure statement. They
                // exist only for operand lookup; emitting them mid-body clobbers the
                // value a preceding If/While/For left in eax. Trailing pure statements
                // (after the last control node) ARE emitted: one of them is the real
                // function result, and leaked control-flow supply nodes load the same
                // variable it does.
                let later_non_pure = func.body[stmt_idx + 1..]
                    .iter()
                    .any(|n| !matches!(&n.node, ICNFInner::Load(_) | ICNFInner::Const(_)));
                if !operand_ids.contains(&stmt.id)
                    && matches!(&stmt.node, ICNFInner::Load(_) | ICNFInner::Const(_))
                    && later_non_pure
                {
                    continue;
                }
                // Skip nodes already emitted by a parent handler (e.g. Eq inside Assert).
                if func_emitted_ids.contains(&stmt.id) {
                    continue;
                }
                // Skip nodes that are operands to a parent node (Print/Call/BinOp/etc.).
                // These are emitted on-demand via emit_load_into when a parent handler
                // requests the result, preventing clobbering by subsequent statements.
                if operand_ids.contains(&stmt.id) {
                    match &stmt.node {
                        ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                        | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                        ICNFInner::FfiCall { .. } => continue,
                        ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => {
                            // Emitted on-demand by their parent handler.
                            continue
                        }
                        ICNFInner::BinOp(_, _, _) => continue,
                        ICNFInner::UnOp(_, _) => continue,
                        ICNFInner::Eq { .. } => continue,
                        ICNFInner::MakeVariant { .. } => continue,
                        ICNFInner::StructGet(..) => continue,
                        // Emitted inline by emit_load_into when its parent
                        // requests the value — must not be emitted twice.
                        ICNFInner::Match { .. } => continue,
                        // Same bug class as Match above, for If: eagerly
                        // emitting it here marks it "already emitted" with
                        // no phi slot recorded for this embedding, so a
                        // later on-demand fetch silently falls back to
                        // whatever happens to be in the register instead of
                        // the if-expression's real result.
                        ICNFInner::If { .. } => continue,
                        _ => {}
                    }
                }
                self.emit_node(
                    stmt,
                    &body_stmts,
                    &local_vars,
                    &mut func_emitted_ids,
                    &operand_ids,
                    &func_lookup,
                    &phi_slots,
                );
            }

            // End of user-defined function body — emit wait_all for main,
            // but ONLY when the program can have live actors: the runtime
            // loop spins forever on uninitialized/garbage mailbox state
            // otherwise (P1: no phantom waits).
            if func.name == "main" && self.spawn_wrappers.len() > 0 {
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_actor_wait_all@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
            }

            // Return result: re-materialize the body's tail expression into
            // rax. Leaked control-flow supply nodes may have been emitted
            // after the real tail load, clobbering eax — an explicit reload
            // makes the return value independent of statement ordering.
            if std::env::var("ZYL_DBG_EPI").is_ok() {
                let lastdesc = func.body.last().map(|n| format!("#{} {:?}", n.id, n.node));
                eprintln!("[epi] {} result_id={} body_last={:?}", func.name, func.result_id, lastdesc);
            }
            if func.result_id != 0 {
                if let Some(node) = func.body.iter().find(|n| n.id == func.result_id) {
                    match &node.node {
                        ICNFInner::Load(name) => {
                            if let Some(&slot_idx) = local_vars.get(name) {
                                self.asm_push_align();
                                self.asm
                                    .push(format!("    mov rax, [rbp-{}]", (slot_idx + 1) * 8));
                            } else {
                                let hash = simple_hash(name);
                                let offset = ((hash % 32) + 1) * 8;
                                self.asm_push_align();
                                self.asm
                                    .push(format!("    mov rax, [rbp-{}]", offset));
                            }
                        }
                        _ => {
                            // Non-pure results (Call/If/For/...) leave the
                            // value in rax via their handlers. Const results
                            // were emitted as the final statement.
                        }
                    }
                }
            }
            self.asm_push_align();
            self.asm.push(format!("    add rsp, {}", self.spill_frame.max(256)));
            self.asm_push_align();
            self.asm.push("    pop rbp".to_string());
            self.asm_push_align();
            self.asm.push("    ret".to_string());
        }
        self.current_func = String::new();

        // Emit closure bodies (nested defn inside functions) as top-level functions.
        // These are not in program.functions but are called indirectly as function pointers.
        for (&closure_id, (closure_name, captures)) in &program.closures {
            if let Some(body) = program.closure_bodies.get(&closure_id) {
                // Use the param names recorded on the Closure value node
                // (id == closure_id); fall back to leading Load nodes.
                let mut param_names = Self::find_closure_params(program, closure_id);
                let capture_count = captures.len();
                if param_names.is_empty() {
                    for stmt in body.iter() {
                        if let ICNFInner::Load(name) = &stmt.node {
                            param_names.push(name.clone());
                        } else {
                            break;
                        }
                    }
                    param_names = param_names
                        .into_iter()
                        .skip(capture_count)
                        .collect();
                }
                let params: Vec<String> = param_names;

                self.current_func = closure_name.clone();
                let fn_name = format!("_ZYL_{}", closure_name);
                self.asm_push_align();
                self.asm_push_align();
                self.asm.push(format!("{}:", fn_name));
                self.asm_push_align();
                self.asm.push("    push rbp".to_string());
                self.asm_push_align();
                self.asm.push("    mov rbp, rsp".to_string());
                self.asm_push_align();
                self.asm.push(format!("    sub rsp, {}", self.spill_frame.max(256)));

                // Emit prologue. Capturing closures use the env convention:
                // rdi = env block ([env]=code, [env+8+8i]=capture i), params
                // arrive in rsi onward. Captureless closures take params in
                // rdi onward.
                let start_param_idx = capture_count;
                let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
                if capture_count > 0 {
                    // Load captures from the env block into their slots.
                    for (i, cap) in captures.iter().enumerate() {
                        let offset = (start_param_idx + i + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov r10, [rdi + {}] # cap {}",
                            8 * (i + 1),
                            cap.name
                        ));
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], r10",
                            offset
                        ));
                    }
                }
                for (i, param_name) in params.iter().enumerate() {
                    if !param_name.is_empty() {
                        // Param slots precede capture slots (local_vars
                        // registers params at index i).
                        let offset = (i + 1) * 8;
                        // Env convention (captures>0): rdi holds the env, so
                        // params arrive one ABI register over.
                        let abi_idx = i + if capture_count > 0 { 1 } else { 0 };
                        if abi_idx < 6 {
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov [rbp-{}], {} # {}",
                                offset, abi_regs_64[abi_idx], param_name
                            ));
                        } else {
                            let stack_off = 16 + 8 * (abi_idx - 6);
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov r10, [rbp+{}] # {}",
                                stack_off, param_name
                            ));
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov [rbp-{}], r10",
                                offset
                            ));
                        }
                    }
                }

                // Emit the function body.
                let mut local_vars: HashMap<String, usize> = HashMap::default();
                // Pre-populate parameter slots.
                for (i, param_name) in params.iter().enumerate() {
                    if !param_name.is_empty() {
                        local_vars.insert(param_name.clone(), i);
                    }
                }
                // Pre-populate capture slots.
                for (i, cap) in captures.iter().enumerate() {
                    local_vars.insert(cap.name.clone(), start_param_idx + i);
                }
                // First pass: assign slots to let-bound variables (Assign
                // nodes) and If/Match result vars, so nested closure calls
                // resolve to the indirect path instead of an undefined
                // direct `_ZYL_<name>` call.
                {
                    let mut next_slot = params.len().max(6);
                    fn register_slots(
                        stmts: &[ICNFNode],
                        local_vars: &mut HashMap<String, usize>,
                        next_slot: &mut usize,
                    ) {
                        for stmt in stmts {
                            match &stmt.node {
                                ICNFInner::Assign(name, _) => {
                                    if !local_vars.contains_key(name) {
                                        local_vars.insert(name.clone(), *next_slot);
                                        *next_slot += 1;
                                    }
                                }
                                ICNFInner::If { result_var, then_body, else_body, .. } => {
                                    if !local_vars.contains_key(result_var) {
                                        local_vars.insert(result_var.clone(), *next_slot);
                                        *next_slot += 1;
                                    }
                                    register_slots(then_body, local_vars, next_slot);
                                    register_slots(else_body, local_vars, next_slot);
                                }
                                ICNFInner::Match { arms, .. } => {
                                    for arm in arms {
                                        register_slots(&arm.body, local_vars, next_slot);
                                    }
                                }
                                ICNFInner::While { cond_body, body, .. } => {
                                    register_slots(cond_body, local_vars, next_slot);
                                    register_slots(body, local_vars, next_slot);
                                }
                                ICNFInner::For { init_bindings, body, .. } => {
                                    // For-loop variables must own slots like any
                                    // other local, otherwise set! on them falls
                                    // back to hash-based slots that can collide
                                    // with parameter/let slots.
                                    for (name, _) in init_bindings {
                                        if !local_vars.contains_key(name) {
                                            local_vars.insert(name.clone(), *next_slot);
                                            *next_slot += 1;
                                        }
                                    }
                                    register_slots(body, local_vars, next_slot);
                                }
                                ICNFInner::Begin(stmts2) => {
                                    register_slots(stmts2, local_vars, next_slot);
                                }
                                _ => {}
                            }
                        }
                    }
                    register_slots(body, &mut local_vars, &mut next_slot);
                }

                // Collect operand IDs for body statements.
                let mut operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                for stmt in body {
                    Self::collect_operand_ids_in_node(&stmt.node, &mut operand_ids);
                }

                let mut body_emitted_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                let mut func_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in body {
                    func_lookup.insert(n.id, n);
                }
                let phi_slots: crate::deterministic::HashMap<String, String> = HashMap::default();

                for stmt in body {
                    if operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => {
                                continue
                            }
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            ICNFInner::Eq { .. } => continue,
                            ICNFInner::MakeVariant { .. } => continue,
                            ICNFInner::StructGet(..) => continue,
                            // Emitted inline by emit_load_into when its parent
                            // requests the value — must not be emitted twice.
                            ICNFInner::Match { .. } => continue,
                        // Same bug class as Match above, for If: eagerly
                        // emitting it here marks it "already emitted" with
                        // no phi slot recorded for this embedding, so a
                        // later on-demand fetch silently falls back to
                        // whatever happens to be in the register instead of
                        // the if-expression's real result.
                        ICNFInner::If { .. } => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        stmt,
                        body,
                        &local_vars,
                        &mut body_emitted_ids,
                        &operand_ids,
                        &func_lookup,
                        &phi_slots,
                    );
                }

                // Epilogue.
                self.asm_push_align();
                self.asm.push(format!("    add rsp, {}", self.spill_frame.max(256)));
                self.asm_push_align();
                self.asm.push("    pop rbp".to_string());
                self.asm_push_align();
                self.asm.push("    ret".to_string());
            }
        }

        // Emit buffered spawn wrapper functions (standalone with proper prologue/epilogue).
        self.emit_spawn_wrappers();

        // Emit string literals used in the program.
        for func in &program.functions {
            let _ = func; // Reserved for future use with closures capturing strings.
        }
    }




    /// True when the node statically resolves to an ADT variant value: a call
    /// to a function whose resolved return type is a Nominal that is NOT a
    /// declared struct (i.e. a variant/ADT), or anything transitively
    /// carrying such a value (Assign / result-var Load).
    /// True when the node is a primitive constant (Int/Float/Bool) — such
    /// values must never be routed to structural (dereferencing) equality.

    /// Emit a StructGet: computes fresh on first use and caches the result
    /// in a dedicated stack slot keyed by node id, so repeated consumers
    /// neither recompute (extra heap derefs) nor read stale registers.
    fn emit_struct_get_cached(
        &mut self,
        src_ssa_id: usize,
        struct_id: usize,
        field_offset: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
        if !self.sg_slots.contains_key(&src_ssa_id) {
            self.emit_load_into(
                struct_id, "rax", stmts, local_vars, lookup, emitted_ids,
                operand_ids, phi_slots,
            );
            self.asm_push_align();
            self.asm.push(format!("    mov rax, [rax + {}]", field_offset));
            let slot = self.temp_slot_counter;
            self.temp_slot_counter += 1;
            self.asm_push_align();
            self.asm.push(format!("    mov [rbp-{}], rax", (slot + 1) * 8));
            self.sg_slots.insert(src_ssa_id, slot);
            emitted_ids.insert(src_ssa_id);
        }
        let slot = self.sg_slots[&src_ssa_id];
        let offset = (slot + 1) * 8;
        self.asm_push_align();
        self.asm.push(format!(
            "    mov {}, [rbp-{}]",
            reg_to_64(target_reg),
            offset
        ));
    }



    /// Count all ICNF nodes in a statement list, recursing into branch
    /// bodies and closure bodies. Used to size stack frames: every node
    /// may need at most one temp slot, so this bounds the frame size.
    fn count_frame_nodes(stmts: &[ICNFNode], closure_bodies: &crate::deterministic::HashMap<usize, Vec<ICNFNode>>) -> usize {
        fn walk(stmts: &[ICNFNode], closure_bodies: &crate::deterministic::HashMap<usize, Vec<ICNFNode>>, n: &mut usize) {
            for s in stmts {
                *n += 1;
                match &s.node {
                    ICNFInner::If { then_body, else_body, .. } => {
                        walk(then_body, closure_bodies, n);
                        walk(else_body, closure_bodies, n);
                    }
                    ICNFInner::While { cond_body, body, .. } => {
                        walk(cond_body, closure_bodies, n);
                        walk(body, closure_bodies, n);
                    }
                    ICNFInner::For { init_bindings, cond_nodes, body, .. } => {
                        for (_, v) in init_bindings {
                            if v.is_some() { *n += 1; }
                        }
                        walk(cond_nodes, closure_bodies, n);
                        walk(body, closure_bodies, n);
                    }
                    ICNFInner::Match { arms, .. } => {
                        for a in arms { walk(&a.body, closure_bodies, n); }
                    }
                    ICNFInner::TryCatch { try_body, catch_body, .. } => {
                        walk(try_body, closure_bodies, n);
                        walk(catch_body, closure_bodies, n);
                    }
                    ICNFInner::Closure { .. } => {
                        if let Some(cb) = closure_bodies.get(&s.id) {
                            walk(cb, closure_bodies, n);
                        }
                    }
                    _ => {}
                }
            }
        }
        let mut n = 0usize;
        walk(stmts, closure_bodies, &mut n);
        n
    }


    /// Compute the `sub rsp, N` amount for a function frame: every ICNF
    /// node may claim one 8-byte temp/variable slot; round up to 16 bytes,
    /// with a 256-byte floor for small functions.
    fn frame_size_for(node_count: usize) -> usize {
        let bytes = (node_count + 8) * 8;
        let rounded = (bytes + 15) & !15;
        if rounded < 256 { 256 } else { rounded }
    }

    fn node_is_primitive_const(
        id: usize,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
    ) -> bool {
        match lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id)) {
            Some(n) => matches!(
                &n.node,
                ICNFInner::Const(Atom::Int(_))
                    | ICNFInner::Const(Atom::Float(_))
                    | ICNFInner::Const(Atom::Bool(_))
                    | ICNFInner::I32Imm(_)
            ),
            None => false,
        }
    }

    fn node_looks_variant(
        &self,
        id: usize,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
        depth: usize,
    ) -> bool {
        if depth > 4 {
            return false;
        }
        let node = match lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id)) {
            Some(n) => n,
            None => return false,
        };
        match &node.node {
            ICNFInner::MakeVariant { .. } => true,
            ICNFInner::Call(name, _) => {
                let sanitized = sanitize_name(name);
                matches!(
                    self.func_returns.get(&sanitized),
                    Some(Type::Nominal(t)) if !self.struct_layouts.contains_key(t)
                )
            }
            ICNFInner::CallIndirect(_, _) => false,
            ICNFInner::Assign(_, val) => self.node_looks_variant(*val, lookup, stmts, depth + 1),
            ICNFInner::Load(nm) => {
                for s in stmts {
                    if let ICNFInner::Assign(n2, val) = &s.node {
                        if n2 == nm && self.node_looks_variant(*val, lookup, stmts, depth + 1) {
                            return true;
                        }
                    }
                }
                false
            }
            _ => false,
        }
    }

    /// Emit a structural equality check for heap aggregates (ADT variants /
    /// structs) via the runtime's hidden-size headers.
    fn emit_variant_eq(
        &mut self,
        left: usize,
        right: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
    ) {
        // Evaluate both sides first (each side may involve calls whose arg
        // setup clobbers rdi/rsi), stashing the left result on the stack.
        self.emit_load_into(
            left, "rax", stmts, local_vars, lookup, emitted_ids,
            &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push("    push rax".to_string());
        self.emit_load_into(
            right, "rsi", stmts, local_vars, lookup, emitted_ids,
            &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push("    pop rdi".to_string());
        self.asm_push_align();
        self.asm.push("    mov r15, rsp".to_string());
        self.asm.push("    and rsp, -16".to_string());
        self.asm.push("    call zyl_variant_eq@plt".to_string());
        self.asm.push("    mov rsp, r15".to_string());
        self.asm_push_align();
        self.asm
            .push(format!("    mov {}, rax", reg_to_64(target_reg)));
    }

    /// True when the node statically looks like a string value (string
    /// literal or call to a known str-* builtin).
    fn node_looks_string(
        &self,
        id: usize,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
    ) -> bool {
        let owned;
        let found = match lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id)) {
            Some(n) => Some(n),
            None => {
                // Branch-body nodes several levels of nesting deep may not
                // have been merged into `lookup`/`stmts` by every caller —
                // fall back to the function-wide node registry so string
                // detection doesn't silently fail on deeply-nested operands.
                owned = self.all_nodes.get(&id).cloned();
                owned.as_ref()
            }
        };
        match found {
            Some(n) => match &n.node {
                ICNFInner::Const(crate::ast::Atom::Str(_)) | ICNFInner::StrImm(_) => true,
                ICNFInner::Call(name, _) => {
                    matches!(name.as_str(), "str-concat" | "str_concat" | "str-substring" | "str_substring" | "read-line" | "read_line")
                }
                ICNFInner::CallIndirect(_, _) => false,
                ICNFInner::Assign(_, val) => self.node_looks_string(*val, lookup, stmts),
                ICNFInner::If { then_body, else_body, .. } => {
                    self.branch_bodies_look_string(then_body, lookup, stmts)
                        || self.branch_bodies_look_string(else_body, lookup, stmts)
                }
                ICNFInner::Match { arms, .. } => arms
                    .iter()
                    .any(|arm| self.branch_bodies_look_string(&arm.body, lookup, stmts)),
                ICNFInner::Load(name) if name.starts_with("___") => {
                    // Result var (cond/if/match phi): resolve its producing
                    // statement and inspect the branch value(s).
                    for s in stmts {
                        match &s.node {
                            ICNFInner::Assign(nm, val) if nm == name => {
                                if self.node_looks_string(*val, lookup, stmts) {
                                    return true;
                                }
                            }
                            ICNFInner::If { result_var, then_body, else_body, .. }
                                if result_var == name =>
                            {
                                if self.branch_bodies_look_string(then_body, lookup, stmts)
                                    || self.branch_bodies_look_string(else_body, lookup, stmts)
                                {
                                    return true;
                                }
                            }
                            _ => {}
                        }
                    }
                    false
                }
                _ => false,
            },
            None => false,
        }
    }

    fn branch_bodies_look_string(
        &self,
        body: &[ICNFNode],
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
    ) -> bool {
        body.iter().any(|n| match &n.node {
            ICNFInner::Const(crate::ast::Atom::Str(_)) | ICNFInner::StrImm(_) => true,
            _ => self.node_looks_string(n.id, lookup, stmts),
        })
    }

    /// Emit a string equality check (byte comparison via zyl_cstr_eq).
    fn emit_str_eq(
        &mut self,
        left: usize,
        right: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
    ) {
        self.emit_load_into(
            left, "rax", stmts, local_vars, lookup, emitted_ids,
            &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push("    push rax".to_string());
        self.emit_load_into(
            right, "rsi", stmts, local_vars, lookup, emitted_ids,
            &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push("    pop rdi".to_string());
        self.asm_push_align();
        self.asm.push("    mov r15, rsp".to_string());
        self.asm.push("    and rsp, -16".to_string());
        self.asm.push("    call zyl_cstr_eq@plt".to_string());
        self.asm.push("    mov rsp, r15".to_string());
        self.asm_push_align();
        self.asm
            .push(format!("    mov {}, rax", reg_to_64(target_reg)));
    }

    /// Best-effort static float detection for Eq operands: follows one level/// of arithmetic nesting and recognizes Float constants. Used because
    /// ICNF Eq/BinOp nodes often carry no type annotation.
    fn node_looks_float(
        &self,
        id: usize,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
        depth: usize,
    ) -> bool {
        if depth > 4 {
            return false;
        }
        let node = match lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id)) {
            Some(n) => n,
            None => return false,
        };
        if let ICNFInner::Load(name) = &node.node {
            if self.float_params.contains(name) || self.float_locals.contains(name) {
                return true;
            }
        }
        if matches!(
            node.typ.as_ref(),
            Some(t) if matches!(t, Type::Prim(PrimType::Float))
        ) {
            return true;
        }
        match &node.node {
            ICNFInner::Const(crate::ast::Atom::Float(_)) => true,
            ICNFInner::BinOp(_, l, r) => {
                self.node_looks_float(*l, lookup, stmts, depth + 1)
                    || self.node_looks_float(*r, lookup, stmts, depth + 1)
            }
            ICNFInner::UnOp(_, a) => self.node_looks_float(*a, lookup, stmts, depth + 1),
            ICNFInner::Assign(_, v) => self.node_looks_float(*v, lookup, stmts, depth + 1),
            ICNFInner::Call(name, _) => matches!(
                self.func_returns.get(&sanitize_name(name)),
                Some(Type::Prim(PrimType::Float))
            ),
            ICNFInner::CallIndirect(_, _) => false,
            ICNFInner::UnOp(op, a) if *op == crate::icnf::UnOpKind::Negate => {
                // Float negation result (integer Negate on floats is invalid).
                self.node_looks_float(*a, lookup, stmts, depth + 1)
            }
            ICNFInner::Load(name) => {
                // Follow the most recent assignment of this local in the
                // enclosing statement list.
                let mut found = None;
                for n in stmts.iter().rev() {
                    if let ICNFInner::Assign(an, avid) = &n.node {
                        if an == name {
                            found = Some(*avid);
                            break;
                        }
                    }
                }
                match found {
                    Some(vid) => self.node_looks_float(vid, lookup, stmts, depth + 1),
                    None => false,
                }
            }
            _ => false,
        }
    }

    /// Find the param names recorded on the Closure value node whose SSA id is
    /// `closure_id`, searching top-level statements, function bodies, and all
    /// nested (branch/arm/loop) bodies.
    fn find_closure_params(program: &ICNFProgram, closure_id: usize) -> Vec<String> {
        fn search(stmts: &[ICNFNode], id: usize) -> Option<Vec<String>> {
            for stmt in stmts {
                if stmt.id == id {
                    if let ICNFInner::Closure { params, .. } = &stmt.node {
                        return Some(params.clone());
                    }
                }
                // Nested bodies (If/Match/While/For/Begin/TryCatch).
                let nested: Vec<&Vec<ICNFNode>> = match &stmt.node {
                    ICNFInner::If { then_body, else_body, .. } => {
                        vec![then_body, else_body]
                    }
                    ICNFInner::Match { arms, .. } => {
                        arms.iter().map(|a| &a.body).collect()
                    }
                    ICNFInner::While { cond_body, body, .. } => {
                        vec![cond_body, body]
                    }
                    ICNFInner::For { cond_nodes, body, .. } => {
                        vec![cond_nodes, body]
                    }
                    ICNFInner::Begin(stmts2) => vec![stmts2],
                    ICNFInner::TryCatch { try_body, catch_body, .. } => {
                        vec![try_body, catch_body]
                    }
                    _ => vec![],
                };
                for body in nested {
                    if let Some(p) = search(body, id) {
                        return Some(p);
                    }
                }
            }
            None
        }
        if let Some(p) = search(&program.statements, closure_id) {
            return p;
        }
        for func in &program.functions {
            if let Some(p) = search(&func.body, closure_id) {
                return p;
            }
        }
        for body in program.closure_bodies.values() {
            if let Some(p) = search(body, closure_id) {
                return p;
            }
        }
        Vec::new()
    }

    /// Collect all unique string literals from an ICNF program (recursively).
    fn collect_strings(program: &ICNFProgram, out: &mut HashSet<String>) {
        for stmt in &program.statements {
            Self::collect_from_node_deep(stmt, out);
        }
        for func in &program.functions {
            for stmt in &func.body {
                Self::collect_from_node_deep(stmt, out);
            }
        }
        for (_closure_id, body_stmts) in &program.closure_bodies {
            for stmt in body_stmts {
                Self::collect_from_node_deep(stmt, out);
            }
        }
    }

    /// Recursively collect string constants from a node and every embedded
    /// body (If branches, Match arms, loops, Begin, TryCatch).
    fn collect_from_node_deep(node: &ICNFNode, out: &mut HashSet<String>) {
        Self::collect_from_node(node, out);
        match &node.node {
            ICNFInner::If { then_body, else_body, .. } => {
                for n in then_body.iter().chain(else_body.iter()) {
                    Self::collect_from_node_deep(n, out);
                }
            }
            ICNFInner::Match { arms, .. } => {
                for arm in arms {
                    for n in &arm.body {
                        Self::collect_from_node_deep(n, out);
                    }
                }
            }
            ICNFInner::While { cond_body, body, .. } => {
                for n in cond_body.iter().chain(body.iter()) {
                    Self::collect_from_node_deep(n, out);
                }
            }
            ICNFInner::For { cond_nodes, body, .. } => {
                for n in cond_nodes.iter().chain(body.iter()) {
                    Self::collect_from_node_deep(n, out);
                }
            }
            ICNFInner::Begin(stmts) => {
                for n in stmts {
                    Self::collect_from_node_deep(n, out);
                }
            }
            ICNFInner::TryCatch { try_body, catch_body, .. } => {
                for n in try_body.iter().chain(catch_body.iter()) {
                    Self::collect_from_node_deep(n, out);
                }
            }
            _ => {}
        }
    }

    fn collect_floats(program: &ICNFProgram, out: &mut Vec<(f64, String)>) {
        let mut seen: HashMap<u64, String> = HashMap::default();

        fn collect_floats_from_node(node: &ICNFNode, seen: &mut HashMap<u64, String>, out: &mut Vec<(f64, String)>) {
            match &node.node {
                ICNFInner::Const(Atom::Float(v)) => {
                    let bits = v.to_bits();
                    if let std::collections::hash_map::Entry::Vacant(e) = seen.entry(bits) {
                        let label = format!(".flt_{}", bits);
                        e.insert(label.clone());
                        out.push((*v, label));
                    }
                }
                ICNFInner::If { then_body, else_body, .. } => {
                    for n in then_body.iter().chain(else_body.iter()) {
                        collect_floats_from_node(n, seen, out);
                    }
                }
                ICNFInner::While { cond_body, body, .. } => {
                    for n in cond_body.iter().chain(body.iter()) {
                        collect_floats_from_node(n, seen, out);
                    }
                }
                ICNFInner::For { body, .. } => {
                    for n in body.iter() {
                        collect_floats_from_node(n, seen, out);
                    }
                }
                ICNFInner::Begin(stmts) => {
                    for n in stmts.iter() {
                        collect_floats_from_node(n, seen, out);
                    }
                }
                ICNFInner::TryCatch { try_body, catch_body, .. } => {
                    for n in try_body.iter().chain(catch_body.iter()) {
                        collect_floats_from_node(n, seen, out);
                    }
                }
                ICNFInner::Match { arms, .. } => {
                    for arm in arms {
                        for n in &arm.body {
                            collect_floats_from_node(n, seen, out);
                        }
                    }
                }
                _ => {}
            }
        }

        for stmt in &program.statements {
            collect_floats_from_node(stmt, &mut seen, out);
        }
        for stmt in &program.statements {
            if let ICNFInner::If {
                then_body,
                else_body,
                ..
            } = &stmt.node
            {
                for node in then_body.iter().chain(else_body.iter()) {
                    collect_floats_from_node(node, &mut seen, out);
                }
            }
        }
        for func in &program.functions {
            for stmt in &func.body {
                collect_floats_from_node(stmt, &mut seen, out);
                if let ICNFInner::If {
                    then_body,
                    else_body,
                    ..
                } = &stmt.node
                {
                    for node in then_body.iter().chain(else_body.iter()) {
                        collect_floats_from_node(node, &mut seen, out);
                    }
                }
                if let ICNFInner::While { cond_body, body, .. } = &stmt.node {
                    for node in cond_body.iter().chain(body.iter()) {
                        collect_floats_from_node(node, &mut seen, out);
                    }
                }
            }
        }
        // Also check closure body nodes.
        for (_closure_id, body_stmts) in &program.closure_bodies {
            for stmt in body_stmts {
                collect_floats_from_node(stmt, &mut seen, out);
                if let ICNFInner::If { then_body, else_body, .. } = &stmt.node {
                    for node in then_body.iter().chain(else_body.iter()) {
                        collect_floats_from_node(node, &mut seen, out);
                    }
                }
                if let ICNFInner::While { cond_body, body, .. } = &stmt.node {
                    for node in cond_body.iter().chain(body.iter()) {
                        collect_floats_from_node(node, &mut seen, out);
                    }
                }
            }
        }

        // Sort for determinism
        out.sort_by_key(|a| a.0.to_bits());
    }

    fn collect_from_node(node: &ICNFNode, out: &mut HashSet<String>) {
        match &node.node {
            ICNFInner::Const(Atom::Str(s)) => {
                out.insert(s.clone());
            }
            ICNFInner::StrImm(s) => {
                out.insert(s.clone());
            }
            ICNFInner::Assert { msg, .. } => {
                if let Some(s) = msg {
                    out.insert(s.clone());
                }
            }
            ICNFInner::If {
                then_body,
                else_body,
                ..
            } => {
                for n in then_body.iter().chain(else_body.iter()) {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::While { cond_body, body, .. } => {
                for n in cond_body.iter().chain(body.iter()) {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::For { body, .. } => {
                for n in body.iter() {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::Begin(stmts) => {
                for n in stmts.iter() {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::TryCatch {
                try_body,
                catch_body,
                ..
            } => {
                for n in try_body.iter().chain(catch_body.iter()) {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::Match { arms, .. } => {
                for arm in arms {
                    for n in &arm.body {
                        Self::collect_from_node(n, out);
                    }
                }
            }
            _ => {}
        }
    }

    /// Emit rodata section with all static data (strings, floats, format specifiers).
    fn emit_rodata(&mut self, collected_strings: &HashSet<String>, collected_floats: &[(f64, String)]) {
        self.asm_push_align();
        self.asm.push(".section .rodata".to_string());

        // Emit all string literals first (sorted for determinism).
        let mut strings_vec: Vec<_> = collected_strings.iter().collect();
        strings_vec.sort();
        self.asm_push_align(); // align before strings section
        for s in &strings_vec {
            let str_label = Self::string_label(s);
            self.asm_push_align();
            self.asm.push(format!("{}:", str_label));
            let escaped = s
                .replace('\\', "\\\\")
                .replace('\n', "\\n")
                .replace('"', "\\\"");
            self.asm.push(format!(r#"    .string "{}""#, escaped));
        }

        // Emit all float literals (sorted for determinism).
        for (_v, label) in collected_floats {
            self.asm_push_align();
            self.asm.push(format!("{}:", label));
            // Use .quad to emit the raw 64-bit IEEE 754 representation
            self.asm.push(format!("    .quad {}", _v.to_bits()));
        }

        // Format string for printing integers.
        let fmt_int = ".fmt_int";
        if !self.asm.iter().any(|l| l.starts_with(fmt_int)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", fmt_int));
            self.asm.push(r#"    .string "%d\n""#.to_string());
        }

        // Format string for printing strings.
        let fmt_str = ".fmt_str";
        if !self.asm.iter().any(|l| l.starts_with(fmt_str)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", fmt_str));
            self.asm.push(r#"    .string "%s\n""#.to_string());
        }

        // Minus sign character for negative number printing.
        let minus_str = ".str_minus";
        if !self.asm.iter().any(|l| l.starts_with(minus_str)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", minus_str));
            self.asm.push(r#"    .string "-""#.to_string());
        }

        // Newline string.
        let nl = ".nl";
        if !self.asm.iter().any(|l| l.starts_with(nl)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", nl));
            self.asm.push(r#"    .string "\n""#.to_string());
        }

        // Zero string.
        let zero = ".zero_str";
        if !self.asm.iter().any(|l| l.starts_with(zero)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", zero));
            self.asm.push(r#"    .ascii "0""#.to_string());
        }

        // Newline char.
        let nl_char = ".nl_char";
        if !self.asm.iter().any(|l| l.starts_with(nl_char)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", nl_char));
            self.asm.push(r#"    .ascii "\n""#.to_string());
        }

        // Format string for printing floats.
        let fmt_float = ".fmt_float";
        if !self.asm.iter().any(|l| l.starts_with(fmt_float)) {
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", fmt_float));
            self.asm.push(r#"    .string "%.6f\n""#.to_string());
        }

        // Minus sign string (moved to emit_int_to_str for proper section handling).

        // Zero double for float negation.
        let zero_label = ".zero_sd";
        self.asm_push_align();
        self.asm_push_align();
        self.asm.push(format!("{}:", zero_label));
        self.asm.push("    .quad 0".to_string());

        // Absolute-value bit mask (clears the sign bit) for float |a-b|.
        self.asm_push_align();
        self.asm.push(".flt_abs_mask:".to_string());
        self.asm.push("    .quad 0x7fffffffffffffff".to_string());

        // Epsilon for approximate float equality (assert-equal): 1e-5.
        self.asm_push_align();
        self.asm.push(".flt_epsilon:".to_string());
        self.asm.push("    .quad 4532020583610935537".to_string());

        // Switch back to text section.
        self.asm_push_align();
        self.asm_push_align();
        self.asm.push(".text".to_string());
    }

    /// Push an alignment directive before a label or symbol definition.
    fn asm_push_align(&mut self) {
        self.asm.push(".align 16".to_string());
    }

    // ─── Operand Loading Helpers ──────────────────────────────────────

    /// Emit instruction to load value from SSA ID into the specified target_reg.
    /// If the node is a computed value (BinOp/Call/UnOp) that hasn't been emitted yet,
    /// emits it first to ensure the computation happens.
    #[expect(clippy::too_many_arguments)]
    #[expect(clippy::only_used_in_recursion)]
    /// Emit a single ICNF node, then spill its result (rax) into the
    /// always-spill slot so later operand loads never trust registers.
    fn emit_node(
        &mut self,
        node: &ICNFNode,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
        self.emit_node_inner(node, stmts, local_vars, emitted_ids, operand_ids, lookup, phi_slots);
        self.spill_result(node.id);
    }

    /// Spill rax into the value slot for statement `id` (always-spill scheme).
    #[inline]
    fn spill_result(&mut self, id: usize) {
        if let Some(&slot) = self.value_slots.get(&id) {
            let off = (slot + 1) * 8;
            self.asm_push_align();
            self.asm.push(format!("    mov [rbp-{}], rax", off));
        }
    }

    fn emit_load_into(
        &mut self,
        src_ssa_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
        // Check if already emitted. Only skip if the node type stores its result in eax
        // AND we can safely assume eax still has that value.
        // Look up the statement by ID: check lookup first (branch bodies), then stmts.
        // Always-spill: an already-emitted value-producing statement's
        // result lives in its own slot — load it rather than trusting any
        // register that intervening calls may have clobbered.
        if let Some(&slot) = self.value_slots.get(&src_ssa_id) {
            if emitted_ids.contains(&src_ssa_id)
                || self.standalone_emitted.contains(&src_ssa_id)
            {
                let off = (slot + 1) * 8;
                self.asm_push_align();
                self.asm.push(format!(
                    "    mov {}, [rbp-{}]",
                    reg_to_64(target_reg),
                    off
                ));
                return;
            }
        }
        let node = lookup
            .get(&src_ssa_id)
            .copied()
            .or_else(|| stmts.iter().find(|n| n.id == src_ssa_id));
        match node {
            Some(ICNFNode {
                node: ICNFInner::Const(Atom::Ident(var_name)),
                ..
            }) => {
                // ICNF uses Const{Ident} for variable references. Load from slot.
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                } else if self.function_names.contains(var_name) {
                    // Function reference used as a value: materialize its address.
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    lea {}, [rip+_ZYL_{}]",
                        target_reg,
                        sanitize_name(var_name)
                    ));
                } else {
                    // Fallback: hash-based slot.
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Const(atom),
                ..
            }) => {
                self.emit_const_into(target_reg, atom);
            }
            Some(ICNFNode {
                node: ICNFInner::I32Imm(val),
                ..
            }) => {
                self.emit_const_into(target_reg, &crate::ast::Atom::Int(*val as i64));
            }
            Some(ICNFNode {
                node: ICNFInner::StrImm(val),
                ..
            }) => {
                let label = self.emit_string_literal(val);
                self.asm_push_align();
                self.asm.push(format!("    lea {}, [{}]", target_reg, label));
            }
            Some(ICNFNode {
                node: ICNFInner::FnPtrImm(name),
                ..
            }) => {
                self.asm_push_align();
                self.asm.push(format!("    lea {}, [{}]  # FnPtrImm", target_reg, name));
            }
            Some(ICNFNode {
                node: ICNFInner::Load(name),
                typ,
                ..
            }) => {
                // Always load from stack slot — never skip based on emitted_ids.
                // The emitted value might have been overwritten by subsequent operations.
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                let has_slot = local_vars.contains_key(name);
                if !has_slot {
                    // Variable not in local_vars — check if it's a ReadLine result.
                    // Emit the ReadLine statement and load from rax.
                    if let Some(read_line_node) = stmts.iter().find(|n| matches!(&n.node, ICNFInner::ReadLine)) {
                        let rid = read_line_node.id;
                        if !emitted_ids.contains(&rid) {
                            self.asm_push_align();
                            self.asm.push("    lea rsi, [.stdin_buf]  # buffer pointer (rsi for syscall)".to_string());
                            self.asm_push_align();
                            self.asm.push("    mov rax, 0             # sys_read".to_string());
                            self.asm_push_align();
                            self.asm.push("    mov rdi, 0             # stdin fd".to_string());
                            self.asm_push_align();
                            self.asm.push("    mov rdx, 4096          # buffer size".to_string());
                            self.asm_push_align();
                            self.asm.push("    syscall".to_string());
                            self.asm_push_align();
                            self.asm.push("    test rax, rax".to_string());
                            let rl_err = self.new_label();
                            let rl_done = self.new_label();
                            self.asm.push(format!("    js {}", rl_err));
                            self.asm_push_align();
                            self.asm.push(format!("    je {}", rl_err));
                            self.asm_push_align();
                            self.asm.push("    dec rax                # bytes_read - 1".to_string());
                            self.asm_push_align();
                            self.asm.push("    cmp byte ptr [rsi + rax], 10".to_string());
                            self.asm_push_align();
                            self.asm.push(format!("    jne {}", rl_done));
                            self.asm_push_align();
                            self.asm.push("    mov byte ptr [rsi + rax], 0  # strip newline".to_string());
                            self.asm_push_align();
                            self.asm.push(format!("    jmp {}", rl_done));
                            self.asm_push_align();
                            self.asm.push(format!("{}:", rl_err));
                            self.asm_push_align();
                            self.asm.push("    xor rax, rax           # null pointer on error/EOF".to_string());
                            self.asm_push_align();
                            self.asm.push(format!("    jmp {}", rl_done));
                            self.asm_push_align();
                            self.asm.push(format!("{}:", rl_done));
                            self.asm_push_align();
                            self.asm.push("    mov rax, rsi           # return buffer pointer".to_string());
                            self.asm_push_align();
                            self.asm.push(format!("    mov [rbp-{}], rax", ((local_vars.get(name).copied().unwrap_or(0) + 1) * 8)).to_string());
                            emitted_ids.insert(rid);
                        }
                    }
                }
                if is_float {
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    movsd xmm0, [rbp-{}]", offset));
                        self.asm_push_align();
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    movsd xmm0, [rbp-{}]", offset));
                        self.asm_push_align();
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    }
                } else {
                    // Always use 64-bit form of target register for Int/Bool/Unit values.
                    // Int fields often hold pointers (arena handles, addresses), and
                    // using 32-bit truncates them. For actual small integers, 64-bit
                    // arithmetic is safe (sign/zero extension doesn't affect results).
                    let dest64 = reg_to_64(target_reg).to_string();
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, [rbp-{}]", dest64, offset));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, [rbp-{}]", dest64, offset));
                    }
                }
            }
            Some(ICNFNode {
                node: ICNFInner::BinOp(op, left_id, right_id),
                typ,
                ..
            }) => {
                let is_cmp = matches!(op, BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge);
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)))
                    || (!is_cmp
                        && (self.node_looks_float(*left_id, lookup, stmts, 0)
                            || self.node_looks_float(*right_id, lookup, stmts, 0)))
                    || {
                        if !is_cmp { false }
                        else {
                            let left_is_float = self.node_looks_float(*left_id, lookup, stmts, 0);
                            let right_is_float = self.node_looks_float(*right_id, lookup, stmts, 0);
                            left_is_float || right_is_float
                        }
                    };
                // Pure value: always re-emit. The previous "already
                // emitted → copy eax" shortcut was unsafe — intervening
                // code between the standalone emission and this use may
                // have clobbered eax.
                let already_emitted = false;
                if already_emitted {
                    self.asm_push_align();
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        self.asm
                            .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                    }
                } else if matches!(op, BinOpKind::Eq | BinOpKind::Neq)
                    && (self.node_looks_string(*left_id, lookup, stmts)
                        || self.node_looks_string(*right_id, lookup, stmts))
                {
                    // Strings compare by content, not pointer identity — the
                    // generic BinOp path (unlike the dedicated Eq node) had
                    // no string awareness and fell through to a raw pointer
                    // compare via emit_binop_direct.
                    self.emit_str_eq(*left_id, *right_id, target_reg, stmts, local_vars, lookup, emitted_ids);
                    if matches!(op, BinOpKind::Neq) {
                        self.asm_push_align();
                        self.asm.push(format!("    xor {}, 1", reg_to_64(target_reg)));
                    }
                    emitted_ids.insert(src_ssa_id);
                } else {
                    self.emit_binop_direct(
                        op,
                        *left_id,
                        *right_id,
                        target_reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        is_float,
                        src_ssa_id,
                    );
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Call(name, args),
                typ,
                ..
            }) => {
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if already_emitted {
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        let is_pointer = !is_float && !matches!(typ.as_ref(), Some(Type::Prim(PrimType::Int | PrimType::Bool | PrimType::Unit)));
                        if is_pointer {
                            self.asm_push_align();
                            if target_reg != "rax" {
                                self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                            }
                        } else {
                            self.asm_push_align();
                            if target_reg != "eax" {
                                self.asm
                                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                            }
                        }
                    }
                } else {
                    self.emit_call_direct(
                        name,
                        args,
                        target_reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        src_ssa_id,
                        is_float,
                    );
                }
            }
            Some(ICNFNode {
                node: ICNFInner::FfiCall { name, args, timeout },
                ..
            }) => {
                // Emit the FFI call on demand (it is skipped in the main emit loop
                // when it is an operand) and load the result into target_reg.
                // FFI results are always 64-bit (pointers, arena handles, file descriptors).
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if already_emitted {
                    self.asm_push_align();
                    if target_reg != "rax" {
                        self.asm
                            .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                    }
                } else {
                    self.emit_ffi_call_direct(
                        name,
                        args,
                        *timeout,
                        target_reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        operand_ids,
                        phi_slots,
                        src_ssa_id,
                    );
                }
            }
            Some(ICNFNode {
                node: ICNFInner::UnOp(op, arg_id),
                typ,
                ..
            }) => {
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)))
                    || self.node_looks_float(*arg_id, lookup, stmts, 0);
                // Pure value: always re-emit (see BinOp arm note).
                let already_emitted = false;
                if already_emitted {
                    self.asm_push_align();
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        self.asm
                            .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                    }
                } else {
                    self.emit_unop_direct(
                        op,
                        *arg_id,
                        target_reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        src_ssa_id,
                        is_float,
                    );
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Assign(var_name, _),
                ..
            }) => {
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                } else {
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::MakeStruct(name, field_ids),
                ..
            }) if !emitted_ids.contains(&src_ssa_id) => {
                // Not yet emitted — emit MakeStruct inline.
                //
                // Compute ALL field values first and push them; only then
                // allocate. Field expressions may contain calls whose arg
                // staging uses r10 — computing them while r10 holds the new
                // struct's base pointer corrupts the struct (fields written
                // into the wrong object).
                // The zyl_heap_alloc call below needs a 16-byte-aligned rsp
                // per the SysV ABI; an odd number of 8-byte field pushes
                // would misalign it (no discriminant slot here to make the
                // count even for us), so pad with one throwaway push first.
                let needs_align_pad = field_ids.len() % 2 == 1;
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    push rbp".to_string());
                }
                for &fid in field_ids.iter() {
                    match lookup.get(&fid).copied().or_else(|| stmts.iter().find(|n| n.id == fid)) {
                        Some(ICNFNode { node: ICNFInner::Const(atom), .. }) => {
                            match atom {
                                Atom::Int(v) => {
                                    self.asm_push_align();
                                    self.asm.push(format!("    mov rax, {}", v));
                                }
                                Atom::Bool(v) => {
                                    let val = if *v { 1 } else { 0 };
                                    self.asm_push_align();
                                    self.asm.push(format!("    mov rax, {}", val));
                                }
                                _ => self.emit_const_into("rax", atom),
                            }
                        }
                        Some(ICNFNode { node: ICNFInner::Load(lvar), .. }) => {
                            if let Some(&si) = local_vars.get(lvar) {
                                let slot = (si + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                            } else {
                                let hash = simple_hash(lvar);
                                let slot = ((hash % 32) + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                            }
                        }
                        Some(_n) => {
                            self.emit_load_into(fid, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                        }
                        None => {
                            self.asm_push_align();
                            self.asm.push("    xor eax, eax".to_string());
                        }
                    }
                    self.asm_push_align();
                    self.asm.push("    push rax".to_string());
                }
                let total_size = field_ids.len() * 8;
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", total_size));
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_heap_alloc@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string());
                // Fields were pushed in order; pop in REVERSE so field i lands
                // at offset i*8.
                for (i, &fid) in field_ids.iter().enumerate().rev() {
                    let off = i * 8;
                    self.asm_push_align();
                    self.asm.push("    pop rax".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", off));
                }
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    pop rbp".to_string());
                }
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(src_ssa_id);
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::StructGet(struct_id, field_offset),
                ..
            }) => {
                self.emit_struct_get_cached(src_ssa_id, *struct_id, *field_offset, target_reg, stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
            }
            n @ Some(ICNFNode {
                node: ICNFInner::MakeStruct(..),
                ..
            }) => {
                // Already emitted — do NOT assume rax still holds the struct
                // pointer (any intervening call clobbers it). Re-emit the
                // construction inline: fresh heap allocation, fields stored,
                // pointer left in rax. Safe because field SSA ids point to
                // pure Const/Load nodes for immutable struct literals.
                self.emit_node(n.unwrap(), stmts, local_vars, emitted_ids, operand_ids, lookup, phi_slots);
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            n @ Some(ICNFNode {
                node: ICNFInner::MakeVariant { .. },
                ..
            }) => {
                // Re-emit the variant construction inline: emits a fresh heap
                // allocation and leaves the struct pointer in rax, then copies to
                // the target register. Safe because field SSA ids point to pure
                // Load/Const nodes (side-effecting calls are hoisted by ICNF).
                self.emit_node(n.unwrap(), stmts, local_vars, emitted_ids, operand_ids, lookup, phi_slots);
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::For { .. },
                ..
            }) => {
                // For loop result is in eax after the loop completes.
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::If { cond_ssa, then_body, else_body, result_var },
                typ,
                ..
            }) => {
                if emitted_ids.contains(&src_ssa_id) {
                    // Already emitted — load from phi slot (full 64-bit; slots are 8 bytes).
                    // Use phi_slots (same source as the join point) for the slot index.
                    let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if is_float {
                        self.asm_push_align();
                        self.asm.push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        if let Some(slot) = phi_slots.get(result_var.as_str()) {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    mov {}, [rbp-{}]", reg_to_64(target_reg), slot));
                        } else if let Some(&slot_idx) = local_vars.get(result_var.as_str()) {
                            let offset = (slot_idx + 1) * 8;
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov {}, [rbp-{}]",
                                reg_to_64(target_reg),
                                offset
                            ));
                        } else {
                            // Fallback: load from eax (may be stale).
                            if target_reg != "rax" && target_reg != "eax" {
                                self.asm_push_align();
                                self.asm
                                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                            }
                        }
                    }
                } else {
                    // Emit the If inline.
                    self.emit_if_inline(
                        cond_ssa, then_body, else_body, result_var, typ,
                        stmts, local_vars, lookup, emitted_ids,
                    );
                    // Mark this If node as emitted so it won't be re-emitted.
                    emitted_ids.insert(src_ssa_id);
                    let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if is_float {
                        if target_reg != "xmm0" {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    movsd {}, xmm0", target_reg));
                        }
                    } else {
                        // Join leaves the result in rax; copy full 64-bit.
                        if target_reg != "rax" && target_reg != "eax" {
                            self.asm_push_align();
                            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                        }
                    }
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Match { scrutinee_ssa, type_name, arms, result_var },
                typ,
                ..
            }) => {
                if emitted_ids.contains(&src_ssa_id) {
                    // Already emitted — load from phi slot.
                    let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    let slot = phi_slots.get(result_var.as_str()).cloned()
                        .or_else(|| local_vars.get(result_var.as_str()).map(|&s| ((s + 1) * 8).to_string()));
                    if is_float {
                        self.asm_push_align();
                        self.asm.push(format!("    movsd {}, xmm0", target_reg));
                    } else if let Some(slot) = slot {
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, [rbp-{}]", reg_to_64(target_reg), slot));
                    } else if target_reg != "rax" && target_reg != "eax" {
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                    }
                } else {
                    // Emit the whole match inline; join leaves result in rax/xmm0.
                    // The matched node is guaranteed present (match on `node`).
                    let match_node = node.expect("match node in lookup");
                    self.emit_match_inline(
                        match_node,
                        *scrutinee_ssa,
                        type_name,
                        arms,
                        result_var,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        operand_ids,
                        phi_slots,
                    );
                    emitted_ids.insert(src_ssa_id);
                    let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if is_float {
                        if target_reg != "xmm0" {
                            self.asm_push_align();
                            self.asm.push(format!("    movsd {}, xmm0", target_reg));
                        }
                    } else if target_reg != "rax" && target_reg != "eax" {
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                    }
                }
            }
            Some(ICNFNode {
                 node: ICNFInner::Eq { left, right },
                ..
            }) => {
                // Pure value: always re-emit (see BinOp arm note).
                let already_emitted = false;
                if already_emitted {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                } else if self.node_looks_string(*left, lookup, stmts)
                    || self.node_looks_string(*right, lookup, stmts)
                {
                    // Strings compare by content, not pointer identity.
                    self.emit_str_eq(*left, *right, target_reg, stmts, local_vars, lookup, emitted_ids);
                    emitted_ids.insert(src_ssa_id);
                } else if (self.node_looks_variant(*left, lookup, stmts, 0)
                    || self.node_looks_variant(*right, lookup, stmts, 0))
                    && !Self::node_is_primitive_const(*left, lookup, stmts)
                    && !Self::node_is_primitive_const(*right, lookup, stmts)
                {
                    // ADT variants / structs compare structurally.
                    self.emit_variant_eq(*left, *right, target_reg, stmts, local_vars, lookup, emitted_ids);
                    emitted_ids.insert(src_ssa_id);
                } else {
                    // Floats compare via UCOMISD, not integer cmp.
                    let eq_is_float = self.node_looks_float(*left, lookup, stmts, 0)
                        || self.node_looks_float(*right, lookup, stmts, 0);
                    self.emit_binop_direct(
                        &BinOpKind::Eq,
                        *left,
                        *right,
                        target_reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        eq_is_float,
                        src_ssa_id,
                    );
                    emitted_ids.insert(src_ssa_id);
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Closure { name, .. },
                ..
            }) => {
                // Closure value: its address is the function pointer.
                let fn_name = format!("_ZYL_{}", name);
                self.asm_push_align();
                self.asm.push(format!("    lea {}, [{}]", reg_to_64(target_reg), fn_name));
            }
            Some(ICNFNode {
                node: ICNFInner::While { result_var, .. },
                ..
            }) => {
                // Loop results live in their phi/result slots.
                if let Some(&slot_idx) = local_vars.get(result_var) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov {}, [rbp-{}]",
                        reg_to_64(target_reg),
                        offset
                    ));
                } else if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::For { result_var, .. },
                ..
            }) => {
                if let Some(&slot_idx) = local_vars.get(result_var) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov {}, [rbp-{}]",
                        reg_to_64(target_reg),
                        offset
                    ));
                } else if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::TryCatch { .. },
                ..
            }) => {
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if !already_emitted {
                    if let Some(stmt) = stmts.iter().find(|n| n.id == src_ssa_id) {
                        self.emit_node(
                            stmt,
                            stmts,
                            local_vars,
                            emitted_ids,
                            operand_ids,
                            lookup,
                            phi_slots,
                        );
                    }
                    emitted_ids.insert(src_ssa_id);
                }
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::FileWrite { .. },
                ..
            }) => {
                // Emit the write (if needed) — its syscall leaves the byte
                // count in rax; then move to the target.
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if !already_emitted {
                    if let Some(stmt) = stmts.iter().find(|n| n.id == src_ssa_id) {
                        self.emit_node(
                            stmt,
                            stmts,
                            local_vars,
                            emitted_ids,
                            operand_ids,
                            lookup,
                            phi_slots,
                        );
                    }
                    emitted_ids.insert(src_ssa_id);
                }
                if target_reg != "rax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            Some(_) => {
                // Last resort: the node may exist somewhere else in the
                // program (deeply nested). Emit it from the global map.
                if self.all_nodes.contains_key(&src_ssa_id) {
                    // Recurse against the program-wide node map.
                    self.emit_load_into_owned(
                        src_ssa_id,
                        target_reg,
                        stmts,
                        local_vars,
                        emitted_ids,
                        phi_slots,
                    );
                    return;
                }
                let hash = simple_hash(&format!("{}", src_ssa_id));
                let offset = ((hash % 32) + 1) * 8;
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, [rbp-{}]", target_reg, offset));
            }
            None => {
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
        }
    }

    /// emit_load_into against the program-wide node map (used when local
    /// lookups fail for deeply nested nodes).
    fn emit_load_into_owned(
        &mut self,
        src_ssa_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
        if let Some(n) = self.all_nodes.get(&src_ssa_id) {
            let node = n.clone();
            let lookup: HashMap<usize, &ICNFNode> = crate::deterministic::HashMap::default();
            let empty: crate::deterministic::HashSet<usize> = crate::deterministic::HashSet::default();
            self.emit_node(
                &node,
                stmts,
                local_vars,
                emitted_ids,
                &empty,
                &lookup,
                phi_slots,
            );
            if target_reg != "rax" && target_reg != "eax" {
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
        }
    }

    /// Emit an FFI call directly: load args into ABI registers, call the C
    /// function via the PLT, and load the result into `target_reg`.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    #[expect(clippy::too_many_arguments)]
    fn emit_ffi_call_direct(
        &mut self,
        name: &str,
        args: &[usize],
        _timeout: u64,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
        node_id: usize,
    ) {
        // FFI call — pass arguments in registers per System V ABI, call external C function.
        let abi_regs = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
        let abi_xmm_regs = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
        let mut xmm_arg_count: usize = 0;

        // Save xmm0-xmm7 on stack before arg setup (printf clobbers them).
        self.asm_push_align();
        self.asm.push("    sub rsp, 128".to_string());

        for (i, &arg_id) in args.iter().enumerate() {
            if i < 6 {
                let node = lookup
                    .get(&arg_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == arg_id));
                let is_float = match node {
                    Some(ICNFNode { typ: Some(t), .. }) => matches!(t, Type::Prim(PrimType::Float)),
                    _ => false,
                };
                if is_float {
                    self.emit_float_load_into(
                        arg_id, abi_xmm_regs[i], stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );
                    xmm_arg_count += 1;
                } else {
                    let reg = abi_regs[i];
                    self.emit_load_into(
                        arg_id, reg, stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                    );
                }
            }
        }

        // Restore xmm0-xmm7 after arg setup.
        self.asm_push_align();
        self.asm.push("    add rsp, 128".to_string());

        // Set al = number of XMM registers used for variadic calling convention.
        self.asm_push_align();
        self.asm.push(format!("    mov al, {}", xmm_arg_count));

        // Call the external C function (with plt stub for dynamic linking).
        self.asm_push_align();
        self.asm.push("    mov r15, rsp".to_string());
        self.asm.push("    and rsp, -16".to_string());
        self.asm.push(format!("    call {}@plt", name));
        self.asm.push("    mov rsp, r15".to_string());

        emitted_ids.insert(node_id);

        // Load the result into the target register (results are always 64-bit in rax).
        if target_reg != "rax" {
            self.asm_push_align();
            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
        }
    }

    /// Emit a BinOp directly: load operands, compute, store result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    #[expect(clippy::too_many_arguments)]
    fn emit_binop_direct(
        &mut self,
        op: &BinOpKind,
        left_id: usize,
        right_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        is_float: bool,
        node_id: usize,
    ) {

        if is_float {
            let xmm1 = format!("xmm{}", self.alloc_xmm());
            let xmm2 = format!("xmm{}", self.alloc_xmm());
            let xmm_dest = "xmm0".to_string();

            self.emit_float_load_into(
                left_id, &xmm1, stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(),
            );
            self.emit_float_load_into(
                right_id, &xmm2, stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(),
            );
            emitted_ids.insert(node_id);

            match op {
                BinOpKind::Add => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    addsd {}, {}", xmm_dest, xmm2));
                    // Result must also land in rax as a 64-bit bit pattern;
                    // downstream consumers read GPRs, never xmm0.
                    self.asm_push_align();
                    self.asm.push("    movq rax, xmm0".to_string());
                }
                BinOpKind::Sub => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    subsd {}, {}", xmm_dest, xmm2));
                    // Result must also land in rax as a 64-bit bit pattern;
                    // downstream consumers read GPRs, never xmm0.
                    self.asm_push_align();
                    self.asm.push("    movq rax, xmm0".to_string());
                }
                BinOpKind::Mul => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    mulsd {}, {}", xmm_dest, xmm2));
                    // Result must also land in rax as a 64-bit bit pattern;
                    // downstream consumers read GPRs, never xmm0.
                    self.asm_push_align();
                    self.asm.push("    movq rax, xmm0".to_string());
                }
                BinOpKind::Div => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    divsd {}, {}", xmm_dest, xmm2));
                    // Result must also land in rax as a 64-bit bit pattern;
                    // downstream consumers read GPRs, never xmm0.
                    self.asm_push_align();
                    self.asm.push("    movq rax, xmm0".to_string());
                }
                BinOpKind::Eq => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    sete al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Neq => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    setnz al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Lt => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    setb al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Gt => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    seta al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Le => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    setbe al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Ge => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm_push_align();
                    self.asm.push("    setae al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                _ => {
                    self.asm_push_align();
                    self.asm.push(format!("    xor {}, {}", xmm_dest, xmm_dest));
                }
            }
            return;
        }

        let src2 = "rdx";

        // Load left operand into rax, save to temp stack slot to survive nested calls.
        // Use 64-bit throughout to preserve pointer values (Int fields hold pointers).
        let temp_slot = self.temp_slot_counter;
        self.temp_slot_counter += 1;
        let temp_offset = (temp_slot + 1) * 8;
        self.emit_load_into(
            left_id,
            "rax",
            stmts,
            local_vars,
            lookup,
            emitted_ids,
            &crate::deterministic::HashSet::default(),
            &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push(format!("    mov [rbp-{}], rax", temp_offset));
        self.emit_load_into(
            right_id,
            src2,
            stmts,
            local_vars,
            lookup,
            emitted_ids,
            &crate::deterministic::HashSet::default(),
            &crate::deterministic::HashMap::default(),
        );
        self.asm_push_align();
        self.asm.push(format!("    mov rax, [rbp-{}]", temp_offset));
        self.asm_push_align();
        self.asm.push("    mov rbx, rax".to_string());

        match op {
            BinOpKind::Add => {
                self.asm_push_align();
                self.asm.push(format!("    add rax, {}", src2));
                self.asm_push_align();
                self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
            BinOpKind::Sub => {
                self.asm_push_align();
                self.asm.push(format!("    sub rax, {}", src2));
                self.asm_push_align();
                self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
            BinOpKind::Mul => {
                self.asm_push_align();
                self.asm.push(format!("    imul rax, {}", src2));
                self.asm_push_align();
                self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
            BinOpKind::Div | BinOpKind::Rem => {
                // Divisor arrives in rdx; cqo overwrites rdx, so move it to
                // rbx (the saved left-operand copy is not needed here).
                self.asm_push_align();
                self.asm.push("    mov rbx, rdx".to_string());
                self.asm_push_align();
                self.asm.push("    cqo".to_string());
                self.asm_push_align();
                self.asm.push("    idiv rbx".to_string());
                self.asm_push_align();
                if op == &BinOpKind::Div {
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                } else {
                    // Remainder is delivered in rdx.
                    self.asm
                        .push(format!("    mov {}, rdx", reg_to_64(target_reg)));
                }
            }
            BinOpKind::Eq
            | BinOpKind::Neq
            | BinOpKind::Lt
            | BinOpKind::Gt
            | BinOpKind::Le
            | BinOpKind::Ge => {
                let d = reg_to_64(target_reg);
                self.asm_push_align();
                self.asm.push("    cmp rbx, rdx".to_string());
                let (set_instr, _) = match op {
                    BinOpKind::Eq => ("sete", ""),
                    BinOpKind::Neq => ("setne", ""),
                    BinOpKind::Lt => ("setl", ""),
                    BinOpKind::Gt => ("setg", ""),
                    BinOpKind::Le => ("setle", ""),
                    BinOpKind::Ge => ("setge", ""),
                    _ => unreachable!(),
                 };
                 self.asm.push(format!("    {} al", set_instr));
                 self.asm.push(format!("    movzx {}, al", d));
            }
            BinOpKind::And => {
                self.asm_push_align();
                self.asm.push("    mov rax, rbx".to_string());
                self.asm_push_align();
                self.asm.push("    and rax, rdx".to_string());
            }
            BinOpKind::Or => {
                self.asm_push_align();
                self.asm.push("    mov rax, rbx".to_string());
                self.asm_push_align();
                self.asm.push("    or rax, rdx".to_string());
            }
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a Call directly: load args into ABI regs, call, result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    #[expect(clippy::too_many_arguments)]
    fn emit_call_direct(
        &mut self,
        name: &str,
        args: &[usize],
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        node_id: usize,
        is_float: bool,
    ) {
        // Use 64-bit ABI regs for all non-float args to preserve pointers.
        let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
        let abi_xmm = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];

        // Built-in (str-length s): byte length of NUL-terminated string.
        if name == "str-length" || name == "str_length" {
            if let Some(&s_id) = args.first() {
                self.emit_load_into(
                    s_id, "rdi", stmts, local_vars, lookup, emitted_ids,
                    &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                );
            } else {
                self.asm_push_align();
                self.asm.push("    xor edi, edi".to_string());
            }
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_cstr_len@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            emitted_ids.insert(node_id);
            return;
        }

        // Built-in (str-concat a b): new heap-allocated concatenated string.
        if (name == "str-concat" || name == "str_concat") && args.len() == 2 {
            self.emit_load_into(
                args[0], "rdi", stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
            );
            self.emit_load_into(
                args[1], "rsi", stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
            );
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_cstr_concat@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            emitted_ids.insert(node_id);
            return;
        }

        // Built-in (str-equal a b): byte-identical comparison.
        if name == "str-equal" || name == "str_equal" {
            if let (Some(&a_id), Some(&b_id)) = (args.first(), args.get(1)) {
                self.emit_load_into(
                    a_id, "rdi", stmts, local_vars, lookup, emitted_ids,
                    &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                );
                self.emit_load_into(
                    b_id, "rsi", stmts, local_vars, lookup, emitted_ids,
                    &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                );
            }
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_cstr_eq@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            emitted_ids.insert(node_id);
            return;
        }

        // Built-in (str-substring s start len): heap-allocated copy of the
        // requested range.
        if (name == "str-substring" || name == "str_substring") && args.len() == 3 {
            self.emit_load_into(
                args[0], "rdi", stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
            );
            self.emit_load_into(
                args[1], "rsi", stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
            );
            self.emit_load_into(
                args[2], "rdx", stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
            );
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_cstr_substr@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
            self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
            emitted_ids.insert(node_id);
            return;
        }

        // Built-in (error msg): panic via zyl_panic. Never returns, but emit a
        // sentinel so SSA consumers of the result register stay well-defined.
        if name == "error" {
            if let Some(&msg_id) = args.first() {
                self.emit_load_into(
                    msg_id, "rdi", stmts, local_vars, lookup, emitted_ids,
                    &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                );
            } else {
                self.asm_push_align();
                self.asm.push("    xor edi, edi".to_string());
            }
            self.asm_push_align();
            self.asm.push("    mov r15, rsp".to_string());
            self.asm.push("    and rsp, -16".to_string());
            self.asm.push("    call zyl_panic@plt".to_string());
            self.asm.push("    mov rsp, r15".to_string());
            self.asm_push_align();
            self.asm.push(format!("    mov {}, -1", reg_to_64(target_reg)));
            emitted_ids.insert(node_id);
            return;
        }

        // Determine whether the callee is a function-typed variable (indirect
        // call) or a known function name (direct call). Locals shadow functions.
        // The ICNF call name is sanitized; local_vars keys are the raw names.
        let callee_slot = local_vars.get(name).copied().or_else(|| {
            local_vars
                .iter()
                .find(|(k, _)| sanitize_name(k) == *name)
                .map(|(_, &s)| s)
        });

        if let Some(_slot) = callee_slot {
            // --- Indirect call path ---
            // Skip the push/pop dance (it leaves stale pushes on the stack
            // after the call, corrupting subsequent calls). Instead:
            //   1. Evaluate each arg, save to a dedicated temp slot on the stack
            //   2. Load each temp slot into its ABI register
            //   3. Load function-pointer from its frame slot and call
            //
            // Capturing closures use the env convention: the value is an env
            // block ([env]=code ptr, captures follow), rdi carries the env,
            // and user args start at rsi.
            // Static callee-shape detection:
            //   - Assign(name, Closure{captures}) -> known convention
            //   - anything else (call result, fn param) -> ambiguous: use
            //     the dynamic zyl_callN dispatcher.
            let mut env_call = false;
            let mut known = false;
            for s in stmts.iter() {
                if let ICNFInner::Assign(nm, vid) = &s.node {
                    if nm == name || sanitize_name(nm) == *name {
                        match lookup.get(vid) {
                            Some(ICNFNode {
                                node: ICNFInner::Closure { captures, .. },
                                ..
                            }) => {
                                env_call = !captures.is_empty();
                                known = true;
                            }
                            _ => {}
                        }
                    }
                }
            }
            let dynamic_dispatch = !known;
            let num_args = args.len().min(6);
            let mut is_floats: Vec<bool> = Vec::with_capacity(num_args);
            for (i, &arg_id) in args.iter().enumerate().take(num_args) {
                let arg_node = lookup
                    .get(&arg_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == arg_id));
                let arg_is_float = arg_node
                    .and_then(|n| n.typ.as_ref())
                    .is_some_and(|t| matches!(t, Type::Prim(PrimType::Float)));
                if arg_is_float {
                    let xmm_reg = abi_xmm[i];
                    self.emit_float_load_into(
                        arg_id, &xmm_reg, stmts, local_vars, lookup,
                        emitted_ids, &crate::deterministic::HashSet::default(),
                    );
                    // Save XMM result to stack slot
                    self.asm_push_align();
                    self.asm.push("    sub rsp, 16".to_string());
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd [rsp], {}", xmm_reg));
                    is_floats.push(true);
                } else {
                    let reg = abi_regs_64[i];
                    self.emit_load_into(
                        arg_id, reg, stmts, local_vars, lookup, emitted_ids,
                        &crate::deterministic::HashSet::default(),
                        &crate::deterministic::HashMap::default(),
                    );
                    // Save GPR result to a dedicated temp stack slot.
                    // We alloc *after* the load so the load's destination
                    // register is not clobbered by the sub rsp.
                    self.asm_push_align();
                    self.asm.push("    sub rsp, 8".to_string());
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov [rsp], {}", reg));
                    is_floats.push(false);
                }
            }
            // Now load each saved arg into its ABI register. Args were pushed
            // in order (arg 0 deepest), so pop in REVERSE order: the top of
            // the stack is arg n-1, which belongs in abi_regs[n-1].
            let abi_base = if env_call || dynamic_dispatch { 1 } else { 0 };
            for (i, &arg_is_float) in is_floats.iter().enumerate().rev() {
                if arg_is_float {
                    let xmm_reg = abi_xmm[i + abi_base];
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, [rsp]", xmm_reg));
                    self.asm_push_align();
                    self.asm.push("    add rsp, 16".to_string());
                } else {
                    let reg_64 = abi_regs_64[i + abi_base];
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rsp]", reg_64));
                    self.asm_push_align();
                    self.asm.push("    add rsp, 8".to_string());
                }
            }
            // Load the closure value from its frame slot and call.
            let slot = _slot;
            let offset = (slot + 1) * 8;
            self.asm_push_align();
            self.asm.push(format!("    mov rax, [rbp-{}]", offset));
            self.asm_push_align();
            if dynamic_dispatch {
                // Move the closure value into rdi; args already sit in
                // rsi.. — exactly the zyl_callN signature. The helper
                // detects env vs raw by address range and forwards.
                self.asm.push("    mov rdi, rax".to_string());
                self.asm_push_align();
                let helper = format!("zyl_call{}@plt", num_args);
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push(format!("    call {}", helper));
                self.asm.push("    mov rsp, r15".to_string());
            } else if env_call {
                self.asm.push("    mov rdi, rax".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, [rax]".to_string());
                self.asm_push_align();
                self.asm.push("    call rax".to_string());
            } else {
                self.asm_push_align();
                self.asm.push("    call rax".to_string());
            }
            if is_float {
                self.asm_push_align();
                self.asm.push(format!("    movsd {}, xmm0", target_reg));
            } else {
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
        } else {
            // --- Direct call path ---
            let num_args = args.len();
            let arg_is_floats: Vec<bool> = args
                .iter()
                .map(|&arg_id| {
                    let arg_node = lookup
                        .get(&arg_id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == arg_id));
                    arg_node
                        .and_then(|n| n.typ.as_ref())
                        .is_some_and(|t| matches!(t, Type::Prim(PrimType::Float)))
                })
                .collect();

            // ── Tail-call optimization (sibling + self) ─────────────────
            // A tail-position call with only register-class args becomes:
            // evaluate each argument into a scratch slot, copy them into the
            // CALLEE's parameter slots, pop the scratch, and jump to the
            // callee's re-entry label. Safe because every frame is the same
            // uniform size (global spill_frame) and parameter slots live at
            // the same rbp-relative offsets in every frame — so replacing
            // call+return-address with a jump reuses the caller's frame.
            // Sibling TCO: any tail-position user-function call qualifies.
            // Sound because all frames are uniform and r12 (the only
            // callee-saved reg used) is never live across calls in this
            // codebase — match handlers consume it before any call.
            if self.tail_call_ids.contains(&node_id)
                && target_reg == "rax"
                && !is_float
                && num_args <= 6
                && !arg_is_floats.iter().any(|f| *f)
            {
                for (i, &arg_id) in args.iter().enumerate() {
                    self.emit_load_into(
                        arg_id, "r10", stmts, local_vars, lookup, emitted_ids,
                        &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                    );
                    self.asm_push_align();
                    self.asm.push("    sub rsp, 8".to_string());
                    self.asm_push_align();
                    self.asm.push("    mov [rsp], r10".to_string());
                }
                // Copy scratch slots into this frame's param slots.
                for i in 0..num_args {
                    let off = 8 * (num_args - 1 - i);
                    self.asm_push_align();
                    self.asm.push(format!("    mov r10, [rsp+{}]", off));
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov [rbp-{}], r10",
                        (i + 1) * 8
                    ));
                }
                self.asm_push_align();
                self.asm.push(format!("    add rsp, {}", 8 * num_args));
                self.asm_push_align();
                self.asm
                    .push(format!("    jmp .__TCO_entry_{}", sanitize_name(name)));
                return;
            }

            // Evaluate every argument once and spill it into an 8-byte
            // scratch slot on the stack. Then load register args into their
            // ABI registers and push args >= 6 onto the stack in reverse
            // order per System V ABI.
            //
            // The call below needs a 16-byte-aligned rsp per the SysV ABI.
            // Assuming this call site is reached with rsp 16-aligned (the
            // invariant every call site is expected to maintain), the
            // scratch pushes below (one per arg, plus one more per stack
            // arg beyond the first 6) must total an even count or the call
            // lands misaligned — with no discriminant/tag slot here to
            // absorb the parity like MakeVariant has, so pad explicitly.
            // The pad itself is pushed AFTER argument evaluation (Phase 1),
            // not before: argument expressions can themselves contain calls
            // (e.g. `(f (g x))`), and those nested calls compute their own
            // alignment padding assuming rsp is 16-aligned on entry to
            // their own Phase 1 — a pad pushed here before Phase 1 would
            // throw that assumption off by 8 bytes for every nested call
            // evaluated below.
            let total_scratch_pushes = num_args + num_args.saturating_sub(6);
            let needs_align_pad = total_scratch_pushes % 2 == 1;
            let arg_is_floats: Vec<bool> = args
                .iter()
                .map(|&arg_id| {
                    let arg_node = lookup
                        .get(&arg_id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == arg_id));
                    let is_float = arg_node
                        .and_then(|n| n.typ.as_ref())
                        .is_some_and(|t| {
                            matches!(t, Type::Prim(PrimType::Float))
                        });
                    is_float
                })
                .collect();
            // Phase 1: evaluate each argument once and spill it into an
            // 8-byte scratch slot (push order = arg 0 first, deepest).
            for (i, &arg_id) in args.iter().enumerate().take(num_args) {
                let arg_is_float = arg_is_floats[i];
                if arg_is_float {
                    self.emit_float_load_into(
                        arg_id, "xmm0", stmts, local_vars, lookup,
                        emitted_ids, &crate::deterministic::HashSet::default(),
                    );
                    self.asm_push_align();
                    self.asm.push("    movq r10, xmm0".to_string());
                } else {
                    self.emit_load_into(
                        arg_id, "r10", stmts, local_vars, lookup, emitted_ids,
                        &crate::deterministic::HashSet::default(),
                        &crate::deterministic::HashMap::default(),
                    );
                }
                self.asm_push_align();
                self.asm.push("    sub rsp, 8".to_string());
                self.asm_push_align();
                self.asm.push("    mov [rsp], r10".to_string());
            }
            // Phase 2: push stack args (index >= 6) in reverse order so that
            // arg 6 ends up at the lowest address ([rsp] at the call).
            // No alignment pad needed: total displacement is 8*N scratch +
            // 8*S copy-pushes (S = stack args), and N+S is always even, so
            // rsp stays 16-byte aligned at the call.
            let mut pushed = 0usize;
            for i in (6..num_args).rev() {
                let off = 8 * (num_args - 1 - i) + pushed;
                self.asm_push_align();
                self.asm
                    .push(format!("    mov r10, [rsp+{}]", off));
                self.asm_push_align();
                self.asm.push("    push r10".to_string());
                pushed += 8;
            }
            // Alignment pad, pushed only now (after all argument
            // expressions — including any nested calls they contain — have
            // finished evaluating) so it can't throw off a nested call's
            // own alignment math. See the Phase 1 comment above.
            if needs_align_pad {
                self.asm_push_align();
                self.asm.push("    push rbp".to_string());
            }
            let pad_off = if needs_align_pad { 8 } else { 0 };
            // Phase 3: load register args from their scratch slots.
            for i in (0..num_args.min(6)).rev() {
                let off = 8 * (num_args - 1 - i) + pushed + pad_off;
                if arg_is_floats[i] {
                    self.asm_push_align();
                    self.asm.push(format!("    movq r10, [rsp+{}]", off));
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movq {}, r10", abi_xmm[i]));
                } else {
                    let reg = abi_regs_64[i];
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rsp+{}]", reg, off));
                }
            }
            // Phase 4: call and clean up the scratch + stack-arg area
            // (scratch slots for all args + one copy-push per stack arg +
            // the alignment pad, if one was pushed).
            let cleanup = 8 * num_args + pushed + if needs_align_pad { 8 } else { 0 };

            // Emit the direct call.
            if name != "printf" && name != "exit" {
                self.asm_push_align();
                self.asm.push(format!("    call _ZYL_{}", name));
                if is_float {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, xmm0", target_reg));
                } else if target_reg == "rax" || target_reg == "rcx" || target_reg == "rdx" || target_reg == "rsi" || target_reg == "rdi" || target_reg == "r8" || target_reg == "r9" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", target_reg));
                } else {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            } else if !target_reg.is_empty() {
                if is_float {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, xmm0", target_reg));
                } else if target_reg == "rax" || target_reg == "rcx" || target_reg == "rdx" || target_reg == "rsi" || target_reg == "rdi" || target_reg == "r8" || target_reg == "r9" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", target_reg));
                } else {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }
            self.asm_push_align();
            self.asm.push(format!("    add rsp, {}", cleanup));
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a UnOp directly: load arg, apply op, result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    #[expect(clippy::too_many_arguments)]
    fn emit_unop_direct(
        &mut self,
        op: &UnOpKind,
        arg_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        node_id: usize,
        is_float: bool,
    ) {
        if is_float {
            let mut xmm_src = format!("xmm{}", self.alloc_xmm());
            // xmm0 is the negation destination; never use it for the source.
            if xmm_src == "xmm0" {
                xmm_src = "xmm7".to_string();
            }
            self.emit_float_load_into(
                arg_id, &xmm_src, stmts, local_vars, lookup, emitted_ids,
                &crate::deterministic::HashSet::default(),
            );
            let xmm_dest = "xmm0".to_string();
            // Float negation: 0 - x (never `neg`, which is integer-only).
            self.asm_push_align();
            self.asm.push("    movsd xmm0, [.zero_sd]".to_string());
            self.asm_push_align();
            self.asm.push(format!("    subsd {}, {}", xmm_dest, xmm_src));
            // Result must also land in rax as a 64-bit bit pattern.
            self.asm_push_align();
            self.asm.push("    movq rax, xmm0".to_string());
            if target_reg.starts_with("xmm") {
                self.asm_push_align();
                self.asm.push(format!("    movsd {}, xmm0", target_reg));
            } else {
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, rax", reg_to_64(target_reg)));
            }
        } else {
            self.emit_load_into(
                arg_id,
                target_reg,
                stmts,
                local_vars,
                lookup,
                emitted_ids,
                &crate::deterministic::HashSet::default(),
                &crate::deterministic::HashMap::default(),
            );

            match op {
                UnOpKind::Not => {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    xor {}, 1", reg_to_32(target_reg)));
                }
                UnOpKind::Negate => {
                    self.asm_push_align();
                    self.asm.push(format!("    neg {}", reg_to_64(target_reg)));
                }
            }
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a constant directly into dest_reg.
    fn emit_const_into(&mut self, dest_reg: &str, atom: &Atom) {
        match atom {
            Atom::Int(v) => {
                // Negative values must be sign-extended to 64 bit: a 32-bit
                // `mov r32, imm` zero-fills the upper half, so a value like
                // -5 becomes 0x00000000FFFFFFFB and breaks any 64-bit
                // consumer (e.g. stack-passed call arguments).
                if *v < 0 && !dest_reg.starts_with("xmm") {
                    self.asm
                        .push(format!("    mov {}, {}", reg_to_64(dest_reg), v));
                } else {
                    self.asm
                        .push(format!("    mov {}, {}", reg_to_32(dest_reg), v));
                }
            }
            Atom::Float(v) => {
                let float_label = format!(".flt_{}", v.to_bits());
                let is_xmm = dest_reg.starts_with("xmm");
                self.asm_push_align();
                if is_xmm {
                    self.asm
                        .push(format!("    movsd {}, [{}]", dest_reg, float_label));
                } else {
                    // Float bit pattern needs 64-bit load regardless of target width.
                    let gpr = if dest_reg.len() == 4 {
                        // 32-bit name (eax, ecx...) → use 64-bit reg (rax, rcx...)
                        match dest_reg {
                            "eax" => "rax",
                            "ecx" => "rcx",
                            "edx" => "rdx",
                            "ebx" => "rbx",
                            "esi" => "rsi",
                            "edi" => "rdi",
                            "ebp" => "rbp",
                            "esp" => "rsp",
                            "r8d" => "r8",
                            "r9d" => "r9",
                            "r10d" => "r10",
                            "r11d" => "r11",
                            "r12d" => "r12",
                            "r13d" => "r13",
                            "r14d" => "r14",
                            "r15d" => "r15",
                            _ => "rax",
                        }
                    } else {
                        dest_reg
                    };
                    self.asm
                        .push(format!("    mov {}, [{}]", gpr, float_label));
                }
            }
            Atom::Bool(v) => {
                self.asm.push(format!(
                    "    mov {}, {}",
                    reg_to_32(dest_reg),
                    if *v { 1 } else { 0 }
                ));
            }
            Atom::Str(s) => {
                let str_label = Self::string_label(s);

                // Load pointer to string (already emitted in rodata section).
                self.asm_push_align();
                self.asm
                    .push(format!("    lea {}, [{}] ", dest_reg, str_label));
            }
            Atom::Ident(_) => {
                self.asm.push(format!("    mov {}, 0", reg_to_32(dest_reg)));
            }
            _ => {
                self.asm_push_align();
                self.asm.push(format!(
                    "    xor {}, {}",
                    reg_to_32(dest_reg),
                    reg_to_32(dest_reg)
                ));
            }
        }
    }

    /// Emit a Match expression inline: discriminant dispatch + arm bodies +
    /// phi join. Used both by the statement handler and when a Match appears
    /// as an operand (emit_load_into) — leaves the result in rax/xmm0.
    #[allow(clippy::too_many_arguments)]
    fn emit_match_inline(
        &mut self,
        node: &ICNFNode,
        scrutinee_ssa: usize,
        type_name: &str,
        arms: &[MatchArmICNF],
        result_var: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &HashSet<usize>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
                // Load scrutinee into rax (struct pointer).
                // Read discriminant from [rax + 0].
                // Compare with each arm's variant discriminant, jump to matching arm.
                // Each arm body runs with field values loaded from the struct.
                // Phi join: load result from phi slot.

                let match_id = self.label_counter;
                self.label_counter += 1;
                // Labels must be valid asm symbols — strip non-identifier chars
                // (monomorphized type names can contain '?', e.g. Option_?258).
                let type_label = sanitize_name(type_name);
                let join_label = if type_label.is_empty() {
                    format!(".___match_join_{}", match_id)
                } else {
                    format!(".___match_join_{}_{}", type_label, match_id)
                };

                // Load scrutinee pointer.
                self.emit_load_into(scrutinee_ssa, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);

                // Save scrutinee pointer in callee-saved r12 before discriminant load.
                self.asm_push_align();
                self.asm.push("    mov r12, rax".to_string());

                // Load discriminant: [rax + 0].
                self.asm_push_align();
                self.asm.push("    mov eax, [rax]".to_string());

                // Build arm labels and discriminant values.
                let arm_labels: Vec<String> = (0..arms.len())
                    .map(|i| {
                        if type_label.is_empty() {
                            format!(".___match_arm_{}_{}", match_id, i)
                        } else {
                            format!(".___match_arm_{}_{}_{}", type_label, match_id, i)
                        }
                    })
                    .collect();
                let default_label = if type_label.is_empty() {
                    format!(".___match_default_{}", match_id)
                } else {
                    format!(".___match_default_{}_{}", type_label, match_id)
                };

                 // For each arm, compare discriminant and jump if match.
                // NOTE: compare against the arm's actual discriminant, not the
                // arm index — the ICNF sort does not guarantee index == disc.
                // A wildcard/catch-all arm gets sentinel discriminant usize::MAX
                // (see icnf.rs) — no real value ever carries that discriminant,
                // so a `cmp`/`je` against it can never fire. Skip it here and
                // route the "no match" fallthrough straight to its body instead,
                // since a wildcard arm means "anything not listed above".
                let wildcard_idx = arms.iter().position(|a| a.discriminant == usize::MAX);
                for (i, arm) in arms.iter().enumerate() {
                    if Some(i) == wildcard_idx {
                        continue;
                    }
                    self.asm_push_align();
                    self.asm.push(format!("    cmp eax, {}", arm.discriminant));
                    self.asm_push_align();
                    self.asm.push(format!("    je {}", arm_labels[i]));
                }

                // No match — fall through to the wildcard arm's body if one
                // exists, otherwise the generic (undefined-behavior) default.
                self.asm_push_align();
                if let Some(wi) = wildcard_idx {
                    self.asm.push(format!("    jmp {}", arm_labels[wi]));
                } else {
                    self.asm.push(format!("    jmp {}", default_label));
                }

                // Emit each arm body.
                for (i, arm) in arms.iter().enumerate() {
                    let arm_label = &arm_labels[i];
                    self.asm_push_align();
                    self.asm.push(format!("{}:", arm_label));

                    // Load field values from the scrutinee struct (now in r12).
                    // Fields are at [r12 + 8], [r12 + 16], etc. All fields are 8 bytes.
                    // Clone local_vars for this arm scope since we need to add pattern bindings.
                    let mut arm_local_vars = local_vars.clone();
                    for (j, field_name) in arm.field_names.iter().enumerate() {
                        // Track Float-typed pattern bindings so downstream
                        // BinOp/print emission can pick SSE paths.
                        if arm.field_types.get(j).map(|t| t == "Float").unwrap_or(false) {
                            self.float_locals.insert(field_name.clone());
                        }
                        let field_offset = (j + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rcx, [r12 + {}]", field_offset)); // Load field as 64-bit (can be pointer)
                        self.asm_push_align();

                        // Store to a stack slot for the pattern variable.
                        // Use the original field_name (matches ICNF Load operand).
                        if !arm_local_vars.contains_key(field_name) {
                            // Allocate a new slot.
                            let max_slot: usize = arm_local_vars.values().cloned().max().unwrap_or(0);
                            let slot = max_slot + 1;
                            let offset = (slot + 1) * 8;
                            self.asm.push(format!("    mov [rbp-{}], rcx", offset));
                            arm_local_vars.insert(field_name.clone(), slot);
                        } else {
                            // Update existing slot.
                            if let Some(&slot_idx) = arm_local_vars.get(field_name) {
                                let offset = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov [rbp-{}], rcx", offset));
                            }
                        }
                    }

                    // Advance temp_slot_counter past all arm-local slots (pattern vars
                    // plus any pre-registered Assign names) so BinOp/UnOp temp slots
                    // never collide with a live arm variable.
                    if let Some(&max_slot) = arm_local_vars.values().max() {
                        if max_slot + 1 > self.temp_slot_counter {
                            self.temp_slot_counter = max_slot + 1;
                        }
                    }

                    // Emit the arm body statements.
                    let mut arm_operand_ids: HashSet<usize> = HashSet::default();
                    collect_body_operand_ids(&arm.body, &mut arm_operand_ids);

                    let arm_stmts: Vec<ICNFNode> = stmts.to_vec();
                    let mut arm_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                    for n in &arm_stmts {
                        arm_lookup.insert(n.id, n);
                    }
                    for n in &arm.body {
                        arm_lookup.insert(n.id, n);
                    }

                    for stmt in &arm.body {
                        // Slots for Assign names are pre-registered by register_func_slots.
                        // Do NOT mutate arm_local_vars here (a `+= 1` corruption caused
                        // Assign slots to shift and collide with pattern-var slots).
                        // Skip intermediate nodes that are operands of the arm body's value expression.
                        // These are emitted on-demand via emit_load_into when a parent handler
                        // requests the result, preventing clobbering by subsequent statements.
                        if arm_operand_ids.contains(&stmt.id) {
                            match &stmt.node {
                                ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                        | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                                ICNFInner::FfiCall { .. } => continue,
                                ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => {
                                    continue
                                }
                        ICNFInner::BinOp(_, _, _) => continue,
                        ICNFInner::UnOp(_, _) => continue,
                        ICNFInner::Eq { .. } => continue,
                        ICNFInner::MakeVariant { .. } => continue,
                        // A nested match used only as an operand (e.g. a
                        // MakeVariant field) must stay unemitted here and be
                        // generated fresh by emit_load_into at its use site.
                        // Eagerly emitting it as a plain arm statement marks
                        // its id "already emitted" with no phi slot recorded
                        // for it, so the later on-demand fetch silently
                        // leaves stale register data instead of the match's
                        // real result — the root cause of a whole class of
                        // "MakeVariant field quietly wrong when one field is
                        // a nested match" bugs.
                        ICNFInner::Match { .. } => continue,
                        // Same bug class as Match above, for If: eagerly
                        // emitting it here marks it "already emitted" with
                        // no phi slot recorded for this embedding, so a
                        // later on-demand fetch silently falls back to
                        // whatever happens to be in the register instead of
                        // the if-expression's real result.
                        ICNFInner::If { .. } => continue,
                        _ => {}
                            }
                        }
                        self.emit_node(
                            stmt,
                            &arm_stmts,
                            &arm_local_vars,
                            emitted_ids,
                            &arm_operand_ids,
                            &arm_lookup,
                            phi_slots,
                        );
                        emitted_ids.insert(stmt.id);
                    }

                    // Store arm body result to phi slot (full 64-bit).
                    if let Some(ref slot) = phi_slots.get(result_var) {
                        self.asm_push_align();
                        let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                        if res_is_float {
                            self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                        } else {
                            self.asm.push(format!("    mov [rbp-{}], rax", slot));
                        }
                    }

                    // Jump to join.
                    self.asm_push_align();
                    self.asm.push(format!("    jmp {}", join_label));
                }

                // Default (no match) — undefined behavior, but still store
                // the sentinel to the phi slot before joining. Every real
                // arm above stores its result there; the join point reads
                // from that slot, not from eax — leaving it unwritten here
                // meant the "sentinel" was silently discarded and the join
                // picked up whatever stale value already occupied the slot
                // (this was the actual source of the "garbage pointer"
                // corruption chased through this whole file: any match that
                // unexpectedly hit its default arm — e.g. because an outer
                // catch-all pattern like `d1` got compiled to this same
                // default path instead of an explicit arm — would silently
                // propagate leftover stack bytes as its result).
                self.asm_push_align();
                self.asm.push(format!("{}:", default_label));
                self.asm_push_align();
                self.asm.push("    mov eax, -1".to_string()); // Error sentinel.
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    cvtsi2sd xmm0, eax"));
                        self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                    } else {
                        self.asm.push(format!("    mov [rbp-{}], rax", slot));
                    }
                }
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", join_label));

                // Join point.
                self.asm_push_align();
                self.asm.push(format!("{}:", join_label));
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", slot));
                    } else {
                        self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                    }
                }
    }

    
    /// Emit condition computation inline: look up operands and compute.
    /// Used by the If handler when the condition BinOp's operands aren't
    /// findable via normal lookup (e.g., they were removed by DCE).
    fn emit_condition_inline(
        &mut self,
        cond_node: &ICNFInner,
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        stmts: &[ICNFNode],
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        cond_id: usize,
    ) {
        // Check if the condition is a float comparison by inspecting operand types.
        let is_float = if let ICNFInner::BinOp(_, left_id, right_id) = cond_node {
            let left_node = lookup.get(left_id).copied();
            let right_node = lookup.get(right_id).copied();
            // Check explicit type first, then fallback to Const(Atom::Float) check
            // since Const nodes may not have typ set after optimization.
            let left_is_float = matches!(left_node, Some(ICNFNode { typ: Some(Type::Prim(PrimType::Float)), .. }))
                || matches!(left_node, Some(ICNFNode { node: ICNFInner::Const(Atom::Float(_)), .. }));
            let right_is_float = matches!(right_node, Some(ICNFNode { typ: Some(Type::Prim(PrimType::Float)), .. }))
                || matches!(right_node, Some(ICNFNode { node: ICNFInner::Const(Atom::Float(_)), .. }));
            left_is_float || right_is_float
        } else {
            false
        };

        let operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();

        if is_float {
            match cond_node {
                ICNFInner::BinOp(op, left_id, right_id) => {
                    // Use emit_load_into to properly handle all operand types
                    // (Load, Const, StructGet, Call, BinOp results, etc.)
                    self.emit_load_into(*left_id, "xmm1", stmts, local_vars, lookup, emitted_ids, &operand_ids, &crate::deterministic::HashMap::default());
                    self.emit_load_into(*right_id, "xmm2", stmts, local_vars, lookup, emitted_ids, &operand_ids, &crate::deterministic::HashMap::default());
                    self.emit_cmp_float_set(op, "xmm1", "xmm2");
                }
                ICNFInner::Load(name) => {
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                        self.asm_push_align();
                        self.asm.push("    movq xmm0, rax".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov eax, 1".to_string());
                    }
                }
                ICNFInner::Const(atom) => {
                    self.emit_const_into("eax", atom);
                }
                _ => {
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                }
            }
            return;
        }

        match cond_node {
            ICNFInner::BinOp(op, left_id, right_id)
                if matches!(op, BinOpKind::Eq | BinOpKind::Neq)
                    && (self.node_looks_string(*left_id, lookup, stmts)
                        || self.node_looks_string(*right_id, lookup, stmts)) =>
            {
                // Strings compare by content, not pointer identity — see the
                // matching fix in the generic BinOp-as-value path.
                self.emit_str_eq(*left_id, *right_id, "eax", stmts, local_vars, lookup, emitted_ids);
                if matches!(op, BinOpKind::Neq) {
                    self.asm_push_align();
                    self.asm.push("    xor eax, 1".to_string());
                }
            }
            ICNFInner::BinOp(op, left_id, right_id) => {
                // Use emit_load_into to properly handle all operand types
                // (Load, Const, StructGet, Call, BinOp results, etc.)
                self.emit_load_into(*left_id, "ecx", stmts, local_vars, lookup, emitted_ids, &operand_ids, &crate::deterministic::HashMap::default());
                self.emit_load_into(*right_id, "edx", stmts, local_vars, lookup, emitted_ids, &operand_ids, &crate::deterministic::HashMap::default());
                // Emit the comparison into eax.
                self.emit_cmp_and_set(op, "ecx", "edx", "eax");
            }
            ICNFInner::Load(name) => {
                if let Some(&slot_idx) = local_vars.get(name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!("    mov eax, [rbp-{}]", offset));
                }
            }
            ICNFInner::Const(atom) => {
                self.emit_const_into("eax", atom);
            }
            ICNFInner::Call(name, args) => {
                // Emit the call to get the condition result in eax.
                let is_float = false;
                let sanitized_name = if name.chars().all(|c| c.is_alphanumeric() || c == '_') && !name.is_empty() {
                    name.to_string()
                } else {
                    let cleaned: String = name.chars().filter(|c| c.is_alphanumeric() || *c == '_').collect();
                    if cleaned.is_empty() { "__" } else { &cleaned }.to_string()
                };
                self.emit_call_direct(&sanitized_name, args, "eax", stmts, local_vars, lookup, emitted_ids, cond_id, is_float);
                emitted_ids.insert(cond_id);
            }
            ICNFInner::UnOp(op, arg_id) => {
                // Boolean negation of a value used directly as a condition.
                self.emit_load_into(
                    *arg_id, "eax", stmts, local_vars, lookup, emitted_ids,
                    &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default(),
                );
                if matches!(op, crate::icnf::UnOpKind::Not) {
                    self.asm_push_align();
                    self.asm.push("    xor eax, 1".to_string());
                }
                // Negate preserves truthiness — nothing further needed.
            }
            ICNFInner::If { cond_ssa, then_body, else_body, result_var } => {
                // A nested If (e.g. produced by `and`/`or` chains) used as a
                // condition. If the or-chain If node was already emitted as a
                // standalone statement in the enclosing branch body, it cannot be
                // emitted inline again (that would duplicate its join labels).
                // Instead, load its stored result from the phi slot.
                if emitted_ids.contains(&cond_id) || emitted_ids.contains(cond_ssa) {
                    if let Some(&slot_idx) = local_vars.get(result_var) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                    } else {
                        let hash = simple_hash(result_var);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                    }
                } else {
                    // Emit the whole chain inline so the join point leaves its
                    // result in eax/rax (truthiness of the whole chain).
                    self.emit_if_inline(
                        cond_ssa, then_body, else_body, result_var, &None,
                        stmts, local_vars, lookup, emitted_ids,
                    );
                    emitted_ids.insert(cond_id);
                }
            }
            _ => {
                self.asm_push_align();
                self.asm.push("    xor eax, eax".to_string());
            }
        }
    }

    /// Emit compare-and-set instruction for float comparison operators.
    fn emit_cmp_float_set(
        &mut self,
        op: &BinOpKind,
        xmm1_reg: &str,
        xmm2_reg: &str,
    ) {
        self.asm_push_align();
        self.asm.push(format!("    ucomisd {}, {}", xmm1_reg, xmm2_reg));
        self.asm_push_align();
        // Do NOT use xor eax,eax here - it clears CF which setcc needs!
        let (set_instr, _) = match op {
            BinOpKind::Eq => ("setz", ""),
            BinOpKind::Neq => ("setnz", ""),
            BinOpKind::Lt => ("setb", ""),
            BinOpKind::Gt => ("seta", ""),
            BinOpKind::Le => ("setbe", ""),
            BinOpKind::Ge => ("setae", ""),
            _ => unreachable!(),
        };
        self.asm_push_align();
        self.asm.push(format!("    {} al", set_instr));
        self.asm_push_align();
        self.asm.push("    movzx eax, al".to_string());
    }

    /// Emit an If expression inline (used by emit_load_into when an If is encountered as an operand).
    #[expect(clippy::too_many_arguments)]
    fn emit_if_inline(
        &mut self,
        cond_ssa: &usize,
        then_body: &[ICNFNode],
        else_body: &[ICNFNode],
        result_var: &str,
        result_typ: &Option<Type>,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
    ) {
        emitted_ids.insert(*cond_ssa);

        let cond_label = self.new_label();
        let then_start = format!("{}.then", result_var);
        let else_start = format!("{}.else", result_var);
        let join_point = format!("{}.join", result_var);

        // Emit condition.
        let cond_node = lookup
            .get(cond_ssa)
            .copied()
            .or_else(|| stmts.iter().find(|n| n.id == *cond_ssa))
            .or_else(|| self.all_nodes.get(cond_ssa).map(|n| {
                static SENTINEL: Option<ICNFNode> = None;
                let _ = &SENTINEL;
                Box::leak(Box::new(n.clone())) as &ICNFNode
            }));
        if let Some(ICNFNode { node, id: cond_id, .. }) = cond_node {
            // Merge body nodes into lookup so emit_condition_inline can find
            // condition operands (e.g., Const nodes in nested if conditions).
            let mut merged_lookup = lookup.clone();
            for n in then_body { merged_lookup.insert(n.id, n); }
            for n in else_body { merged_lookup.insert(n.id, n); }
            self.emit_condition_inline(node, local_vars, &merged_lookup, stmts, emitted_ids, *cond_id);
            // Also mark the condition BinOp's own ID as emitted to prevent
            // re-emission when processing branch bodies that contain it.
            emitted_ids.insert(*cond_id);
        } else {
            self.asm_push_align();
            self.asm.push("    xor eax, eax".to_string());
        }

        // Test condition and branch.
        self.asm_push_align();
        self.asm.push("    test eax, eax".to_string());
        self.asm_push_align();
        self.asm.push(format!("    je  {}", cond_label));

        // Compute phi slot from local_vars (same formula as Assign/Load handlers).
        // Used by both then and else branches, and at the join point.
        let phi_slot = local_vars
            .get(result_var)
            .map(|&slot| ((slot + 1) * 8).to_string());

        // Then branch.
        self.asm_push_align();
        self.asm.push(format!("{}:", then_start));
        let then_stmts: Vec<ICNFNode> = stmts.to_vec();
        let mut then_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
        for n in &then_stmts { then_lookup.insert(n.id, n); }
        for n in then_body { then_lookup.insert(n.id, n); }
        let mut then_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
        // Collect condition IDs to skip — emit_condition_inline handles them.
        let mut then_cond_ids: crate::deterministic::HashSet<usize> = HashSet::default();
        for stmt in then_body {
            match &stmt.node {
                ICNFInner::BinOp(_, l, r) => { then_operand_ids.insert(*l); then_operand_ids.insert(*r); }
                ICNFInner::UnOp(_, id) => { then_operand_ids.insert(*id); }
                ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) => { for &a in args { then_operand_ids.insert(a); } }
                ICNFInner::Print(args) => { for &a in args { then_operand_ids.insert(a); } }
                ICNFInner::StructGet(struct_id, _) => { then_operand_ids.insert(*struct_id); }
                ICNFInner::MakeStruct(_, field_ids) => { for &f in field_ids { then_operand_ids.insert(f); } }
                ICNFInner::MakeVariant { field_ids, .. } => { for &f in field_ids { then_operand_ids.insert(f); } }
                ICNFInner::If { cond_ssa: c, .. } => {
                    then_operand_ids.insert(*c);
                    then_cond_ids.insert(*c);
                }
                _ => {}
            }
        }
        let mut then_local_vars = local_vars.clone();
        let then_last_id = then_body.last().map(|s| s.id);
        let mut then_done = false;
        for stmt in then_body {
            // Skip condition BinOps — already emitted by emit_condition_inline.
            if then_cond_ids.contains(&stmt.id) {
                continue;
            }
            // The branch's final node is its result value: emit it fresh into
            // rax even if flagged as an operand (the phi store below reads
            // rax; operand-skipping would leave a stale value there).
            if Some(stmt.id) == then_last_id && !then_cond_ids.contains(&stmt.id) {
                if matches!(
                    stmt.node,
                    ICNFInner::Const(_)
                        | ICNFInner::I32Imm(_)
                        | ICNFInner::StrImm(_)
                        | ICNFInner::Load(_)
                        | ICNFInner::BinOp(..)
                        | ICNFInner::UnOp(..)
                        | ICNFInner::Eq { .. }
                        | ICNFInner::StructGet(..)
                ) {
                    self.emit_load_into(
                        stmt.id, "rax", &then_stmts, &then_local_vars, &then_lookup,
                        emitted_ids, &crate::deterministic::HashSet::default(),
                        &crate::deterministic::HashMap::default(),
                    );
                    self.spill_result(stmt.id);
                    continue;
                }
            }
            if let ICNFInner::Assign(name, _) = &stmt.node {
                then_local_vars.entry(name.clone()).or_insert_with(|| {
                    let slot = self.temp_slot_counter;
                    self.temp_slot_counter += 1;
                    slot
                });
            }
            self.emit_node(
                stmt, &then_stmts, &then_local_vars, emitted_ids,
                &then_operand_ids, &then_lookup, &crate::deterministic::HashMap::default(),
            );
        }
        // Store then branch result to phi slot (same slot as Assign handler).
        // Slots are 8 bytes; store full 64-bit even for Int/Bool results.
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
            if res_is_float {
                self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
            } else {
                self.asm.push(format!("    mov [rbp-{}], rax", slot));
            }
        }
        self.asm_push_align();
        self.asm.push(format!("    jmp {}", join_point));

        // Else branch.
        self.asm_push_align();
        self.asm.push(format!("{}:", cond_label));
        self.asm_push_align();
        self.asm.push(format!("{}:", else_start));
        let else_stmts: Vec<ICNFNode> = stmts.to_vec();
        let mut else_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
        for n in &else_stmts { else_lookup.insert(n.id, n); }
        for n in else_body { else_lookup.insert(n.id, n); }
        let mut else_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
        // Collect condition IDs to skip — emit_condition_inline handles them.
        let mut else_cond_ids: crate::deterministic::HashSet<usize> = HashSet::default();
        for stmt in else_body {
            match &stmt.node {
                ICNFInner::BinOp(_, l, r) => { else_operand_ids.insert(*l); else_operand_ids.insert(*r); }
                ICNFInner::UnOp(_, id) => { else_operand_ids.insert(*id); }
                ICNFInner::Call(_, args) | ICNFInner::CallIndirect(_, args) => { for &a in args { else_operand_ids.insert(a); } }
                ICNFInner::Print(args) => { for &a in args { else_operand_ids.insert(a); } }
                ICNFInner::StructGet(struct_id, _) => { else_operand_ids.insert(*struct_id); }
                ICNFInner::MakeStruct(_, field_ids) => { for &f in field_ids { else_operand_ids.insert(f); } }
                ICNFInner::MakeVariant { field_ids, .. } => { for &f in field_ids { else_operand_ids.insert(f); } }
                ICNFInner::If { cond_ssa: c, .. } => {
                    else_operand_ids.insert(*c);
                    else_cond_ids.insert(*c);
                }
                _ => {}
            }
        }
        let mut else_local_vars = local_vars.clone();
        for stmt in else_body {
            // Skip condition BinOps — already emitted by emit_condition_inline.
            if else_cond_ids.contains(&stmt.id) {
                continue;
            }
            if let ICNFInner::Assign(name, _) = &stmt.node {
                else_local_vars.entry(name.clone()).or_insert_with(|| {
                    let slot = self.temp_slot_counter;
                    self.temp_slot_counter += 1;
                    slot
                });
            }
            self.emit_node(
                stmt, &else_stmts, &else_local_vars, emitted_ids,
                &else_operand_ids, &else_lookup, &crate::deterministic::HashMap::default(),
            );
        }

        // Store else branch result to phi slot (full 64-bit).
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
            if res_is_float {
                self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
            } else {
                self.asm.push(format!("    mov [rbp-{}], rax", slot));
            }
        }

        // Join — load phi result into xmm0/rax so callers see it correctly (64-bit).
        self.asm_push_align();
        self.asm.push(format!("{}:", join_point));
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", slot));
                    } else {
                        self.asm.push(format!("    mov rax, [rbp-{}]", slot));
            }
        }

        emitted_ids.insert(*cond_ssa);
    }

    /// Emit a string literal in rodata and return its label name.
    fn emit_string_literal(&mut self, s: &str) -> String {
        Self::string_label(s)
    }

    /// Deterministic, injective label for a string literal. Every distinct
    /// byte sequence maps to a distinct safe label (alphanumeric bytes kept
    /// verbatim, every other byte hex-escaped as `_HH`), so two different
    /// strings can never collide to the same assembler symbol.
    fn string_label(s: &str) -> String {
        let mut out = String::from(".str_");
        for b in s.bytes() {
            if b.is_ascii_alphanumeric() {
                out.push(b as char);
            } else {
                out.push_str(&format!("_{:02X}", b));
            }
        }
        out
    }

    // ─── Integer-to-String Conversion ────────────────────────────────

    /// Emit integer-to-string conversion: result in rax as pointer to null-terminated string.
    /// Uses 32-bit registers throughout for GNU as compatibility with .intel_syntax noprefix.
    fn emit_int_to_str(&mut self, int_reg_64: &str) {
        let buf_label = ".hexbuf";
        // hexbuf is now always pre-defined in .bss section before any code.

        // Copy value to ecx (zero-extends from any input register).
        let tmp = "ecx";
        self.asm_push_align();
        self.asm.push(format!(
            "    mov {}, {}",
            reg_to_32(tmp),
            reg_to_32(int_reg_64)
        ));

        // Handle negative numbers: check sign, negate if negative, clear/set r8 flag.
        let neg_path = format!(".___neg_{}", self.label_counter);
        let buf_setup = format!(".___bufsetup_{}", self.label_counter);
        self.label_counter += 1;

        self.asm_push_align();
        self.asm.push(format!("    test {}, {}", tmp, tmp));
        self.asm_push_align();
        self.asm.push(format!("    jns {}", neg_path));

        // Negative path: negate value, set sign flag in r8, then jump to buffer setup.
        self.asm_push_align();
        self.asm.push(format!("    neg {}", tmp)); // make value positive
        self.asm_push_align();
        self.asm.push("    mov r8, 1".to_string()); // sign flag: 1 = negative
        self.asm_push_align();
        self.asm.push(format!("    jmp {}", buf_setup));

        // Positive/zero path: clear sign flag in r8.
        self.asm_push_align();
        self.asm.push(format!("{}:", neg_path));
        self.asm_push_align();
        self.asm.push("    xor r8, r8".to_string()); // clear sign flag: 0 = positive
        self.asm_push_align();
        self.asm.push(format!("{}:", buf_setup));
        self.asm_push_align();
        self.asm
            .push(format!("    lea rdi, [{}] ", buf_label)); // RDI = hexbuf start
        self.asm_push_align();
        self.asm.push("    add rdi, 32".to_string()); // point to hexbuf[32]
        self.asm_push_align();
        self.asm.push("    mov byte ptr [rdi], 0".to_string()); // null-terminate at hexbuf[32]
        self.asm_push_align();
        self.asm.push("    dec rdi".to_string()); // move pointer back to hexbuf[31] (last digit position)

        // Handle zero: if value is 0, write "0" and skip divloop.
        let div_loop = format!(".___divloop_{}", self.label_counter);
        self.label_counter += 1;
        let div_done = format!(".___divdone_{}", self.label_counter);
        self.label_counter += 1;
        let _zero_label = format!(".___zero_{}", self.label_counter);
        self.label_counter += 1;

        self.asm_push_align();
        self.asm.push(format!("    test {}, {}", tmp, tmp));
        self.asm_push_align();
        self.asm.push(format!("    jne {}", div_loop));

        // Zero case: write "0" at current RDI position (hexbuf[31]), then move RDI back
        // so div_done's lea rdx, [rdi+1] gives the correct string start.
        self.asm_push_align();
        self.asm.push("    mov byte ptr [rdi], 48".to_string()); // '0' = ASCII 48
        self.asm_push_align();
        self.asm.push("    dec rdi".to_string()); // rdi = position before the digit
        self.asm_push_align();
        self.asm.push(format!("    jmp {}", div_done));

        // Division loop: extract digits right-to-left using idiv.
        self.asm_push_align();
        self.asm.push(format!("{}:", div_loop));
        self.asm_push_align();
        self.asm.push(format!("    test {}, {}", tmp, tmp));
        self.asm_push_align();
        self.asm.push(format!("    je {}", div_done));

        // Load value into eax for division. Use ebx as temp divisor register (edi is our buffer pointer).
        self.asm_push_align();
        self.asm.push("    xor edx, edx".to_string()); // clear high half (value is positive after negation)
        self.asm_push_align();
        self.asm.push(format!("    mov eax, {}", tmp)); // load value into eax

        self.asm_push_align();
        self.asm.push("    mov ebx, 10".to_string()); // divisor in EBX (edi holds buffer pointer!)
        self.asm_push_align();
        self.asm.push("    idiv ebx".to_string()); // eax = quotient, edx = remainder (digit)

        // Move quotient back to ecx for next iteration check.
        self.asm_push_align();
        self.asm.push(format!("    mov {}, eax", tmp)); // update working register with new quotient

        // Store digit at current RDI position, then move pointer left for next digit.
        let digit = "dl"; // remainder is in dl after div
        self.asm_push_align();
        self.asm.push(format!("    mov [rdi], {}", digit)); // store digit at current position
        self.asm_push_align();
        self.asm.push("    add byte ptr [rdi], 48".to_string()); // convert to ASCII

        self.asm_push_align();
        self.asm.push("    dec rdi".to_string()); // move pointer left for next digit

        self.asm_push_align();
        self.asm.push(format!("    jmp {}", div_loop));

          // Done: rdi points to position before first digit. First digit = rdi+1.
          // Null is already at hexbuf[32] from buffer setup.
          // Handle negative numbers: write '-' before the digits.
          self.asm_push_align();
          self.asm.push(format!("{}:", div_done));
          self.asm_push_align();
          let neg_done_label = format!(".___neg_done_{}", self.label_counter);
          self.label_counter += 1;
          // r8 holds the sign flag (1=negative, 0=positive).
          self.asm_push_align();
          self.asm.push("    test r8, r8".to_string());
          self.asm_push_align();
          self.asm.push(format!("    jz {}", neg_done_label));
          // Negative: save first digit position (rdi+1), write '-' at rdi, use rdx = rdi.
          self.asm_push_align();
          self.asm.push("    mov r9, rdi".to_string()); // r9 = position before first digit
          self.asm_push_align();
          let minus_str = ".str_minus";
          self.asm.push(format!("    mov al, byte ptr [{}]", minus_str));
          self.asm_push_align();
          self.asm.push("    mov [rdi], al".to_string()); // write '-' at position before first digit
          self.asm_push_align();
          self.asm.push("    mov rdx, rdi".to_string()); // rdx = string start (at '-')
          self.asm_push_align();
          self.asm.push(format!("    jmp .___print_str_{}", self.label_counter));
          self.asm_push_align();
          self.asm.push(format!("{}:", neg_done_label));
          // Positive: first digit = rdi+1. rdx = first digit.
          self.asm_push_align();
          self.asm.push("    lea rdx, [rdi+1]".to_string()); // rdx = first digit position
          self.asm_push_align();
          self.asm.push(format!(".___print_str_{}:", self.label_counter));
          self.label_counter += 1;
          self.asm_push_align();
          self.asm.push("    mov rsi, rdx".to_string()); // rsi = string start for printf
          self.asm_push_align();
          self.asm.push("    lea rdi, [.fmt_str]".to_string()); // fmt = "%s\n"
          self.asm_push_align();
          self.asm.push("    xor eax, eax".to_string()); // no xmm args
          self.asm_push_align();
          self.asm.push("    mov r15, rsp".to_string());
          self.asm.push("    and rsp, -16".to_string());
          self.asm.push("    call printf@plt".to_string());
          self.asm.push("    mov rsp, r15".to_string());
    }

    // ─── Node Emission ──────────────────────────────────────────────

    /// Emit a single ICNF node as x86_64 instructions.
    #[expect(clippy::too_many_arguments)]
    fn emit_node_inner(
        &mut self,
        node: &ICNFNode,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        phi_slots: &crate::deterministic::HashMap<String, String>,
    ) {
        // Skip nodes already emitted by a parent handler (e.g. Eq inside Assert's emit_load_into).
        if emitted_ids.contains(&node.id) {
            return;
        }
        match &node.node {
            ICNFInner::Const(atom) => {
                // Skip intermediate Const nodes whose result is used as an operand elsewhere.
                if operand_ids.contains(&node.id) {
                    return;
                }
                // Use xmm0 for float constants, rax for others.
                let target = if matches!(atom, Atom::Float(_)) { "xmm0" } else { "rax" };
                self.emit_const_into(target, atom);
            }

            ICNFInner::Load(name) => {
                // Skip if this Load is a known operand (its value is computed by the parent).
                if operand_ids.contains(&node.id) {
                    return;
                }
                let is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                if is_float {
                    if let Some(&offset_idx) = local_vars.get(name) {
                        let offset = (offset_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", offset));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", offset));
                    }
                } else {
                    // Slots are 8 bytes; load full 64-bit for all types (Int may hold pointers).
                    if let Some(&offset_idx) = local_vars.get(name) {
                        let offset = (offset_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                    }
                }
            }

            ICNFInner::Assign(var_name, value_id) => {
                // Check if this is a phi load: value_id points to an If expression
                // or an Assign whose var_name is a result_var of a nested If.
                // In that case, load from the If's phi slot instead of storing.
                let mut resolved_value_id = *value_id;
                let mut check_assign_names = Vec::new();
                loop {
                    let vnode = lookup
                        .get(&resolved_value_id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == resolved_value_id));
                    if let Some(ICNFNode { node: ICNFInner::Assign(n, inner_id), .. }) = vnode {
                        check_assign_names.push(n.clone());
                        resolved_value_id = *inner_id;
                    } else {
                        break;
                    }
                }
                // Check if resolved_value_id points to an If node directly.
                let value_node = lookup
                    .get(&resolved_value_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == resolved_value_id));
                let mut if_result_var: Option<String> = None;
                if let Some(ICNFNode { node: ICNFInner::If { result_var, .. }, .. }) = value_node {
                    if_result_var = Some(result_var.clone());
                }
                // Also check if any Assign in the chain targets an If result_var
                // by checking phi_slots (which contains all registered If result_vars).
                if if_result_var.is_none() {
                    for aname in &check_assign_names {
                        if phi_slots.contains_key(aname.as_str()) {
                            if_result_var = Some(aname.clone());
                            break;
                        }
                    }
                }
                if let Some(ref result_var) = if_result_var {
                    // Load from the If's phi slot and store to this Assign's slot.
                    // Slots are always 8 bytes, so use full 64-bit moves even for
                    // Int/Bool results (a 32-bit store leaves garbage in the upper
                    // half of the slot, corrupting later 64-bit reads).
                    if let Some(&slot_idx) = local_vars.get(result_var) {
                        let phi_offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", phi_offset));
                        if let Some(&my_slot) = local_vars.get(var_name) {
                            let my_offset = (my_slot + 1) * 8;
                            self.asm_push_align();
                            self.asm.push(format!("    mov [rbp-{}], rax", my_offset));
                        }
                        return;
                    }
                }
                // Store current register (result of value computation) to stack slot.
                // Standalone Call/FfiCall statements are no-ops in the emit loop, so
                // a Call-valued Assign must emit the call on-demand to get its result.
                let needs_on_demand = matches!(value_node, Some(ICNFNode { node: ICNFInner::Call(..), .. }))
                    || matches!(value_node, Some(ICNFNode { node: ICNFInner::CallIndirect(..), .. }))
                    || matches!(value_node, Some(ICNFNode { node: ICNFInner::FfiCall { .. }, .. }))
                    || matches!(value_node, Some(ICNFNode { node: ICNFInner::Const(crate::ast::Atom::Ident(n)), .. }) if self.function_names.contains(n));
                if needs_on_demand && !emitted_ids.contains(&resolved_value_id) {
                    self.emit_load_into(
                        resolved_value_id,
                        "rax",
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        operand_ids,
                        phi_slots,
                    );
                }
                // Also need to load Const(Int/Bool) and Load values into eax.
                // The main emit loop skips Const/Load/Assign nodes, so their values
                // are never pre-loaded into eax. The store below assumes eax has the value.
                let needs_value_load = matches!(
                    value_node,
                    Some(ICNFNode { node: ICNFInner::Const(atom), .. }) if !matches!(atom, crate::ast::Atom::Ident(_))
                ) || matches!(
                    value_node,
                    Some(ICNFNode { node: ICNFInner::Load(_), .. })
                );
                if needs_value_load && !emitted_ids.contains(&resolved_value_id) {
                    self.emit_load_into(
                        resolved_value_id,
                        "rax",
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        operand_ids,
                        phi_slots,
                    );
                }
                let val_is_float = lookup
                    .get(value_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == *value_id))
                    .and_then(|n| n.typ.as_ref())
                    .is_some_and(|t| matches!(t, Type::Prim(PrimType::Float)));
                // Check if value is a pointer (ReadLine, FileRead, MakeStruct, MakeVariant, StructGet).
                let val_is_pointer = stmts.iter().any(|n| {
                    matches!(n.node, ICNFInner::ReadLine | ICNFInner::FileRead { .. }
                        | ICNFInner::MakeStruct { .. } | ICNFInner::MakeVariant { .. }
                        | ICNFInner::StructGet { .. })
                        && *value_id == n.id
                });
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    if val_is_float {
                        self.asm
                            .push(format!("    movsd [rbp-{}], xmm0", offset));
                    } else if val_is_pointer || needs_on_demand {
                        // Pointer-valued results (calls returning structs/strings/ADT boxes).
                        self.asm
                            .push(format!("    mov [rbp-{}], rax", offset));
                    } else {
                        // Int/Bool/Unit: slots are 8 bytes, store full 64-bit.
                        self.asm
                            .push(format!("    mov [rbp-{}], rax", offset));
                    }
                } else {
                    // Fallback: use hash-based offset if not in local_vars.
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    if val_is_float {
                        self.asm
                            .push(format!("    movsd [rbp-{}], xmm0", offset));
                    } else if val_is_pointer {
                        self.asm
                            .push(format!("    mov [rbp-{}], rax", offset));
                    } else {
                        // Int/Bool/Unit: slots are 8 bytes, store full 64-bit.
                        self.asm
                            .push(format!("    mov [rbp-{}], rax", offset));
                    }
                }
            }

                ICNFInner::BinOp(op, left_id, right_id) => {
                    let is_cmp = matches!(op, BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge);
                    let is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)))
                        || (self.node_looks_float(*left_id, lookup, stmts, 0)
                            || self.node_looks_float(*right_id, lookup, stmts, 0));
                    // Strings compare by content, not pointer identity — see
                    // the matching fix in the other BinOp emission sites.
                    let is_string_eq = !is_float
                        && matches!(op, BinOpKind::Eq | BinOpKind::Neq)
                        && (self.node_looks_string(*left_id, lookup, stmts)
                            || self.node_looks_string(*right_id, lookup, stmts));

                    if is_string_eq {
                        self.emit_str_eq(*left_id, *right_id, "rax", stmts, local_vars, lookup, emitted_ids);
                        if matches!(op, BinOpKind::Neq) {
                            self.asm_push_align();
                            self.asm.push("    xor rax, 1".to_string());
                        }
                        emitted_ids.insert(node.id);
                    } else if is_float {
                       let xmm1 = format!("xmm{}", self.alloc_xmm());
                       let xmm2 = format!("xmm{}", self.alloc_xmm());
                       let xmm_dest = "xmm0".to_string();

                       self.emit_float_load_into(
                           *left_id, &xmm1, stmts, local_vars, lookup, emitted_ids, operand_ids,
                       );
                       self.emit_float_load_into(
                           *right_id, &xmm2, stmts, local_vars, lookup, emitted_ids, operand_ids,
                       );
                       emitted_ids.insert(node.id);

                       match op {
                          BinOpKind::Add => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    addsd {}, {}", xmm_dest, xmm2));
                              // Result must also land in rax as a 64-bit bit
                              // pattern: downstream consumers (match joins,
                              // result slots) read GPRs, never xmm0.
                              self.asm_push_align();
                              self.asm.push("    movq rax, xmm0".to_string());
                          }
                          BinOpKind::Sub => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    subsd {}, {}", xmm_dest, xmm2));
                              // Result must also land in rax as a 64-bit bit
                              // pattern: downstream consumers (match joins,
                              // result slots) read GPRs, never xmm0.
                              self.asm_push_align();
                              self.asm.push("    movq rax, xmm0".to_string());
                          }
                          BinOpKind::Mul => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    mulsd {}, {}", xmm_dest, xmm2));
                              // Result must also land in rax as a 64-bit bit
                              // pattern: downstream consumers (match joins,
                              // result slots) read GPRs, never xmm0.
                              self.asm_push_align();
                              self.asm.push("    movq rax, xmm0".to_string());
                          }
                          BinOpKind::Div => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    divsd {}, {}", xmm_dest, xmm2));
                              // Result must also land in rax as a 64-bit bit
                              // pattern: downstream consumers (match joins,
                              // result slots) read GPRs, never xmm0.
                              self.asm_push_align();
                              self.asm.push("    movq rax, xmm0".to_string());
                          }
                           BinOpKind::Eq => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    setz al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                           BinOpKind::Neq => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    setnz al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                           BinOpKind::Lt => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    setb al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                           BinOpKind::Gt => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    seta al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                           BinOpKind::Le => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    setbe al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                           BinOpKind::Ge => {
                               self.asm_push_align();
                               self.asm
                                   .push(format!("    ucomisd {}, {}", xmm1, xmm2));
                               self.asm_push_align();
                               self.asm.push("    setae al".to_string());
                               self.asm_push_align();
                               self.asm.push("    movzx eax, al".to_string());
                           }
                             _ => {
                                 self.asm_push_align();
                             }
                         }
                         } else {
                           // Load left operand into rax, save to temp stack slot.
                           // Right operand loading may clobber rax via nested calls/BinOps.
                           // Use 64-bit throughout to preserve pointer values (arena handles, struct addresses).
                           let temp_slot = self.temp_slot_counter;
                           self.temp_slot_counter += 1;
                           let temp_offset = (temp_slot + 1) * 8;
                           self.emit_load_into(
                               *left_id,
                               "rax",
                               stmts,
                               local_vars,
                               lookup,
                               emitted_ids,
                               operand_ids,
                               phi_slots,
                           );
                           self.asm_push_align();
                           self.asm.push(format!("    mov [rbp-{}], rax", temp_offset));
                           self.emit_load_into(
                               *right_id,
                               "rdx",
                               stmts,
                               local_vars,
                               lookup,
                               emitted_ids,
                               operand_ids,
                               phi_slots,
                            );
                            self.asm_push_align();
                            self.asm.push(format!("    mov rax, [rbp-{}]", temp_offset));
                           emitted_ids.insert(node.id);

                          match op {
                              BinOpKind::Add => {
                                  self.asm_push_align();
                                  self.asm.push("    add rax, rdx".to_string());
                              }
                              BinOpKind::Sub => {
                                  self.asm_push_align();
                                  self.asm.push("    sub rax, rdx".to_string());
                              }
                              BinOpKind::Mul => {
                                  self.asm_push_align();
                                  self.asm.push("    imul rax, rdx".to_string());
                              }
                              BinOpKind::Div | BinOpKind::Rem => {
                                  // cqo sign-extends rax into rdx, destroying
                                  // the divisor if it lives in rdx — save it
                                  // in rbx first.
                                  self.asm_push_align();
                                  self.asm.push("    mov rbx, rdx".to_string());
                                  self.asm_push_align();
                                  self.asm.push("    cqo".to_string()); // Sign-extend rax into rdx:rax (64-bit)
                                  self.asm_push_align();
                                  self.asm.push("    idiv rbx".to_string());
                                  if op == &BinOpKind::Rem {
                                      self.asm_push_align();
                                      self.asm.push("    mov rax, rdx".to_string()); // Remainder in rdx
                                  }
                              }
                              BinOpKind::Eq
                              | BinOpKind::Neq
                              | BinOpKind::Lt
                              | BinOpKind::Gt
                              | BinOpKind::Le
                              | BinOpKind::Ge => {
                                  self.asm_push_align();
                                  self.asm.push(format!("    mov rbx, [rbp-{}]", temp_offset));
                                  self.asm_push_align();
                                  self.asm.push("    cmp rbx, rdx".to_string());
                                 let (set_instr, _) = match op {
                                     BinOpKind::Eq => ("sete", ""),
                                     BinOpKind::Neq => ("setne", ""),
                                     BinOpKind::Lt => ("setl", ""),
                                     BinOpKind::Gt => ("setg", ""),
                                     BinOpKind::Le => ("setle", ""),
                                     BinOpKind::Ge => ("setge", ""),
                                     _ => unreachable!(),
                                 };
                                 self.asm_push_align();
                                 self.asm.push(format!("    {} al", set_instr));
                                 self.asm_push_align();
                                 self.asm.push("    movzx rax, al".to_string());
                             }
                             BinOpKind::And => {
                                 self.asm_push_align();
                                 self.asm.push("    mov rax, rdx".to_string());
                                 self.asm_push_align();
                                 self.asm.push(format!("    mov rdx, [rbp-{}]", temp_offset));
                                 self.asm_push_align();
                                 self.asm.push("    and rax, rdx".to_string());
                             }
                             BinOpKind::Or => {
                                 self.asm_push_align();
                                 self.asm.push("    mov rax, rdx".to_string());
                                 self.asm_push_align();
                                 self.asm.push(format!("    mov rdx, [rbp-{}]", temp_offset));
                                 self.asm_push_align();
                                 self.asm.push("    or rax, rdx".to_string());
                             }
                         }
                    }
               }

            ICNFInner::UnOp(op, arg_id) => {
                let is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));

                if is_float {
                    let xmm_arg = format!("xmm{}", self.alloc_xmm());
                    let xmm_result = format!("xmm{}", self.alloc_xmm());

                    self.emit_float_load_into(
                        *arg_id, &xmm_arg, stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );

                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, [zero_sd]", xmm_result));
                    self.asm_push_align();
                    self.asm.push(format!("    subsd {}, {}", xmm_result, xmm_arg));

                    let hash = simple_hash(&format!("{}", node.id));
                    let slot_idx = (hash % 32) + 1;
                    self.asm_push_align();
                    self.asm.push(format!("    movsd [rbp-{}], {}", slot_idx * 8, xmm_result));
                    // Result must also land in rax as a 64-bit bit pattern;
                    // downstream consumers read GPRs, never xmm0.
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movq rax, {}", xmm_result));
                } else {
                    // Evaluate the operand on demand — it may be any value
                    // node (If/Call/BinOp result); hashing to a stack slot
                    // would read garbage for nodes with no assigned slot.
                    // Result lands in rax so it doubles as the function
                    // return value when the UnOp ends the body.
                    self.emit_load_into(
                        *arg_id,
                        "rax",
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        operand_ids,
                        phi_slots,
                    );

                    match op {
                        UnOpKind::Not => {
                            self.asm_push_align();
                            self.asm.push("    xor eax, 1".to_string());
                        }
                        UnOpKind::Negate => {
                            self.asm_push_align();
                            self.asm.push("    neg rax".to_string());
                        }
                    }
                }
            }
            ICNFInner::SetBang(target, val_id) => {
                // Load val_id into rax first (64-bit to preserve pointer values), then store to target variable's slot.
                self.emit_load_into(*val_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                if let Some(&slot_idx) = local_vars.get(target) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov [rbp-{}], rax", offset));
                    emitted_ids.insert(node.id);
                } else {
                    let hash = simple_hash(target);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov [rbp-{}], rax", offset));
                }
            }
            ICNFInner::If {
                cond_ssa,
                then_body,
                else_body,
                result_var,
            } => {
                // Compute a phi slot for the result_var if not already present.
                // Top-level Ifs get slots from empty_phi (pre-computed).
                // Nested Ifs compute their slot dynamically.
                let mut phi_slots = phi_slots.clone();
                if !phi_slots.contains_key(result_var) {
                    // Prefer the registered local_vars slot (covers nested Ifs inside
                    // While/For/Begin bodies whose phi slots were not pre-computed).
                    if let Some(&slot) = local_vars.get(result_var) {
                        phi_slots.insert(result_var.clone(), ((slot + 1) * 8).to_string());
                    } else {
                        let slot_count = phi_slots.len() + 1;
                        let offset = ((slot_count + 1) * 8).to_string();
                        phi_slots.insert(result_var.clone(), offset);
                    }
                }
                // Emit the condition inline by looking up the condition node and
                // computing it directly. This handles the case where the condition
                // BinOp's operands are not findable via normal lookup.
                let cond_label = self.new_label();

                // Collect all branch body nodes for operand lookup.
                let all_branch_nodes: Vec<&ICNFNode> =
                    then_body.iter().chain(else_body.iter()).collect();

                // Build a lookup that includes func.body AND branch bodies.
                let mut full_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in stmts {
                    full_lookup.insert(n.id, n);
                }
                for n in &all_branch_nodes {
                    full_lookup.insert(n.id, n);
                }

                // Look up the condition node in the full lookup.
                let cond_node = full_lookup.get(cond_ssa).copied().or_else(|| {
                    self.all_nodes.get(cond_ssa).map(|n| Box::leak(Box::new(n.clone())) as &ICNFNode)
                });
                // Merge the program-wide map so condition operands from
                // deeply nested contexts resolve too.
                let mut full_lookup = full_lookup;
                let all: Vec<(usize, ICNFNode)> =
                    self.all_nodes.iter().map(|(k, v)| (*k, v.clone())).collect();
                for (id, n) in &all {
                    full_lookup.entry(*id).or_insert(n);
                }
                // Emit condition computation if found.
                if let Some(cond) = cond_node {
                    self.emit_condition_inline(&cond.node, local_vars, &full_lookup, stmts, emitted_ids, cond.id);
                    // Mark condition ID as emitted so the emit loop won't re-emit it.
                    emitted_ids.insert(cond.id);
                } else {
                    // Fallback: test zero (condition not found, assume false).
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                }

                // Collect operand IDs for branch bodies to skip intermediate Load nodes.
                let mut then_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                collect_body_operand_ids(then_body, &mut then_operand_ids);
                let mut else_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                collect_body_operand_ids(else_body, &mut else_operand_ids);

                // Check condition (result in eax).
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je  {}", cond_label));

                // Then branch — fall through (emit inline like While does).
                let then_start = format!("{}.then", result_var);
                let else_start = format!("{}.else", result_var);
                let join_point = format!("{}.join", result_var);

                self.asm_push_align();
                self.asm.push(format!("{}:", then_start));

                // Build combined lookup: branch body nodes take priority over func.body.
                let then_stmts: Vec<ICNFNode> = stmts.to_vec();
                let mut then_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in &then_stmts {
                    then_lookup.insert(n.id, n);
                }
                for n in then_body {
                    then_lookup.insert(n.id, n);
                }

                // Emit the 'then' branch statements inline. Clone local_vars for each branch scope.
                let mut then_local_vars = local_vars.clone();
                let then_last_id = then_body.last().map(|s| s.id);
                let mut then_done = false;
                for stmt in then_body {
                    // The branch's final node is its result value: emit it
                    // fresh into rax even when flagged as an operand or
                    // previously emitted (the phi store below reads rax).
                    // This check must precede the emitted_ids skip below,
                    // otherwise a value node emitted by the outer walk leaves
                    // the phi store reading a stale register.
                    let is_value_kind = matches!(
                        stmt.node,
                        ICNFInner::Const(_)
                            | ICNFInner::I32Imm(_)
                            | ICNFInner::StrImm(_)
                            | ICNFInner::Load(_)
                            | ICNFInner::BinOp(..)
                            | ICNFInner::UnOp(..)
                            | ICNFInner::Eq { .. }
                             | ICNFInner::StructGet(..)
                            | ICNFInner::Call(..)
                            | ICNFInner::CallIndirect(..)
                            | ICNFInner::FfiCall { .. }
                            | ICNFInner::MakeStruct(..)
                            | ICNFInner::MakeVariant { .. }
                    );
                    if Some(stmt.id) == then_last_id && is_value_kind {
                        self.emit_load_into(
                            stmt.id,
                            "rax",
                            &then_stmts,
                            &then_local_vars,
                            &then_lookup,
                            emitted_ids,
                            &crate::deterministic::HashSet::default(),
                            &phi_slots,
                        );
                        emitted_ids.insert(stmt.id);
                        then_done = true;
                        continue;
                    }
                    // Anything after the branch's final node is a leaked
                    // supply copy — emitting it would clobber rax between the
                    // result value and the phi store below.
                    if then_done {
                        continue;
                    }
                    // Skip nodes already emitted as part of a nested control-flow structure
                    // (nested If/For/While branch members get flattened into this branch's
                    // statement list by the Let temp-buffer handling; re-emitting them after
                    // the nested join corrupts control flow and re-executes side effects).
                    if emitted_ids.contains(&stmt.id) {
                        continue;
                    }
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        then_local_vars.entry(name.clone()).or_insert_with(|| {
                    let slot = self.temp_slot_counter;
                    self.temp_slot_counter += 1;
                    slot
                });
                    }
                    if then_operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        stmt,
                        &then_stmts,
                        &then_local_vars,
                        emitted_ids,
                        &then_operand_ids,
                        &then_lookup,
                        &phi_slots,
                    );
                    emitted_ids.insert(stmt.id);
                }

                // Store then branch result to phi slot (full 64-bit).
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                    } else {
                        self.asm.push(format!("    mov [rbp-{}], rax", slot));
                    }
                }

                // Jump over else branch.
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", join_point));

                // Else label (for false condition).
                self.asm_push_align();
                self.asm.push(format!("{}:", cond_label));
                self.asm_push_align();
                self.asm.push(format!("{}:", else_start));

                // Build combined lookup for else branch.
                let else_stmts: Vec<ICNFNode> = stmts.to_vec();
                let mut else_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in &else_stmts {
                    else_lookup.insert(n.id, n);
                }
                for n in else_body {
                    else_lookup.insert(n.id, n);
                }

                // Emit the 'else' branch statements inline. Clone local_vars for each branch scope.
                let mut else_local_vars = local_vars.clone();
                let else_last_id = else_body.last().map(|s| s.id);
                let mut else_done = false;
                for stmt in else_body {
                    // The branch's final node is its result value: emit it
                    // fresh into rax even when flagged as an operand or
                    // previously emitted (the phi store below reads rax).
                    // This check must precede the emitted_ids skip below.
                    let is_value_kind_else = matches!(
                        stmt.node,
                        ICNFInner::Const(_)
                            | ICNFInner::I32Imm(_)
                            | ICNFInner::StrImm(_)
                            | ICNFInner::Load(_)
                            | ICNFInner::BinOp(..)
                            | ICNFInner::UnOp(..)
                            | ICNFInner::Eq { .. }
                             | ICNFInner::StructGet(..)
                            | ICNFInner::Call(..)
                            | ICNFInner::CallIndirect(..)
                            | ICNFInner::FfiCall { .. }
                            | ICNFInner::MakeStruct(..)
                            | ICNFInner::MakeVariant { .. }
                    );
                    if Some(stmt.id) == else_last_id && is_value_kind_else {
                        self.emit_load_into(
                            stmt.id,
                            "rax",
                            &else_stmts,
                            &else_local_vars,
                            &else_lookup,
                            emitted_ids,
                            &crate::deterministic::HashSet::default(),
                            &phi_slots,
                        );
                        emitted_ids.insert(stmt.id);
                        else_done = true;
                        continue;
                    }
                                        // Anything after the branch's final node is a leaked
                    // supply copy — emitting it would clobber rax between the
                    // result value and the phi store below.
                    if else_done {
                        continue;
                    }
// Skip nodes already emitted by a nested control-flow structure (see then arm).
                    if emitted_ids.contains(&stmt.id) {
                        continue;
                    }
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        else_local_vars.entry(name.clone()).or_insert_with(|| {
                    let slot = self.temp_slot_counter;
                    self.temp_slot_counter += 1;
                    slot
                });
                    }
                    if else_operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) | ICNFInner::CallIndirect(..) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        stmt,
                        &else_stmts,
                        &else_local_vars,
                        emitted_ids,
                        &else_operand_ids,
                        &else_lookup,
                        &phi_slots,
                    );
                    emitted_ids.insert(stmt.id);
                }

                // Store else branch result to phi slot (full 64-bit).
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                    } else {
                        self.asm.push(format!("    mov [rbp-{}], rax", slot));
                    }
                }

                // Join point (phi merge): load phi result into xmm0/rax (64-bit).
                self.asm_push_align();
                self.asm.push(format!("{}:", join_point));

                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", slot));
                    } else {
                        self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                    }
                }

                // Mark this If node as emitted so value handlers won't re-emit it.
                emitted_ids.insert(node.id);
            }

            ICNFInner::While { cond_body, body, result_var } => {
                let loop_start = format!(".while_{}", self.label_counter);
                let loop_end = format!(".wend_{}", self.label_counter);
                self.label_counter += 1;

                // Collect operand IDs for cond_body to skip intermediate Load nodes.
                let mut cond_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                for stmt in cond_body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => {
                            cond_operand_ids.insert(*l);
                            cond_operand_ids.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            cond_operand_ids.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                cond_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                cond_operand_ids.insert(a);
                            }
                        }
                        _ => {}
                    }
                }

                // Collect operand IDs for body to skip intermediate Load nodes.
                let mut while_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                for stmt in body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => {
                            while_operand_ids.insert(*l);
                            while_operand_ids.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            while_operand_ids.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                while_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                while_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::If { cond_ssa: c, .. } => {
                            while_operand_ids.insert(*c);
                        }
                        ICNFInner::SetBang(_, val_id) => {
                            while_operand_ids.insert(*val_id);
                        }
                        _ => {}
                    }
                }

                // Build lookups for condition and body — inherit parent local_vars.
                let local_vars = local_vars.clone();
                let mut while_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in stmts {
                    while_lookup.insert(n.id, n);
                }
                for n in cond_body {
                    while_lookup.insert(n.id, n);
                }
                for n in body {
                    while_lookup.insert(n.id, n);
                }

                // Zero-init the result slot so a zero-iteration loop yields 0
                // instead of an uninitialized slot read at the join.
                if let Some(&slot_idx) = local_vars.get(result_var) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    mov [rbp-{}], rax", offset));
                }

                self.asm_push_align();
                self.asm.push(format!("{}:", loop_start));

                // Emit condition body (re-evaluated each iteration).
                // Use collected operand_ids to skip intermediate Load/Const nodes that are BinOp operands.
                let mut cond_local_vars = local_vars.clone();
                for stmt in cond_body {
                    // Don't re-count Assigns for variables already in parent scope.
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        if !cond_local_vars.contains_key(name) {
                            *cond_local_vars.entry(name.clone()).or_insert(0) += 1;
                        }
                    }
                    if cond_operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        stmt,
                        stmts,
                        &cond_local_vars,
                        emitted_ids,
                        &cond_operand_ids,
                        &while_lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(stmt.id);
                }

                // Condition check (result in eax).
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je  {}", loop_end));

                // Loop body.
                // Use collected operand_ids to skip intermediate Load/Const nodes that are operands.
                let mut body_local_vars = local_vars.clone();
                for stmt in body {
                    // Don't re-count Assigns for variables already in parent scope.
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        if !body_local_vars.contains_key(name) {
                            *body_local_vars.entry(name.clone()).or_insert(0) += 1;
                        }
                    }
                    if while_operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        stmt,
                        stmts,
                        &body_local_vars,
                        emitted_ids,
                        &while_operand_ids,
                        &while_lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(stmt.id);
                }

                // Store result to phi slot (full 64-bit).
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    self.asm.push(format!("    mov [rbp-{}], rax", slot));
                }

                // Back jump.
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", loop_start));
                self.asm_push_align();
                self.asm.push(format!("{}:", loop_end));
            }

            ICNFInner::For {
                init_bindings,
                cond_nodes,
                body,
                result_var: _,
            } => {
                let loop_start = format!(".for_{}", self.label_counter);
                let loop_end = format!(".fend_{}", self.label_counter);
                self.label_counter += 1;

                // Initialize loop variables from init_bindings.
                for (name, val_id_opt) in init_bindings {
                    if let Some(slot) = local_vars.get(name.as_str()) {
                        let slot_offset = *slot;
                        if let Some(val_id) = val_id_opt {
                            // Load value and store to slot. Look in stmts first (for main), then lookup.
                            let val_node = stmts.iter().find(|n| n.id == *val_id).or_else(|| lookup.get(val_id).copied());
                            if let Some(node) = val_node {
                                match &node.node {
                                    ICNFInner::Const(Atom::Int(v)) => {
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov rax, {}", v));
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], rax", (slot_offset + 1) * 8));
                                    }
                                    ICNFInner::Const(Atom::Bool(v)) => {
                                        let val = if *v { 1 } else { 0 };
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov rax, {}", val));
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], rax", (slot_offset + 1) * 8));
                                    }
                                    _ => {
                                        // Emit the value node
                                        let init_local_vars = local_vars.clone();
                                        self.emit_node(
                                            node,
                                            stmts,
                                            &init_local_vars,
                                            emitted_ids,
                                            operand_ids,
                                            lookup,
                                            phi_slots,
                                        );
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], rax", (slot_offset + 1) * 8));
                                    }
                                }
                            }
                        }
                        // If no val_id, variable already has a value from outer scope — do nothing.
                    }
                }

                // Collect operand IDs.
                let mut for_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                let all_nodes: Vec<&ICNFNode> = cond_nodes.iter()
                    .chain(body.iter())
                    .collect();
                for stmt in &all_nodes {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => {
                            for_operand_ids.insert(*l);
                            for_operand_ids.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            for_operand_ids.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                for_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                for_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::If { cond_ssa: c, .. } => {
                            for_operand_ids.insert(*c);
                        }
                        _ => {}
                    }
                }

                self.asm_push_align();
                self.asm.push(format!("{}:", loop_start));

                // Build lookup for all nodes.
                let mut for_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in stmts {
                    for_lookup.insert(n.id, n);
                }
                for n in body {
                    for_lookup.insert(n.id, n);
                }
                for n in cond_nodes {
                    for_lookup.insert(n.id, n);
                }

                // Check condition — if false, exit loop.
                for cond_stmt in cond_nodes {
                    if for_operand_ids.contains(&cond_stmt.id) {
                        match &cond_stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Assign(_, _)
                            | ICNFInner::Call(_, _) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    self.emit_node(
                        cond_stmt,
                        stmts,
                        local_vars,
                        emitted_ids,
                        &for_operand_ids,
                        &for_lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(cond_stmt.id);
                }
                self.asm.push("    mov r11, rax".into());
                self.asm.push("    test r11, r11".into());
                self.asm.push(format!("    je {}", loop_end));

                // Emit body.
                let body_local_vars: HashMap<String, usize> = local_vars.clone();
                let for_body_last_id = body.last().map(|s| s.id);
                let mut for_body_done = false;
                for stmt in body {
                    // Skip Assign nodes that are created by SetBang for SSA tracking.
                    // They would emit redundant stores to stack slots.
                    if matches!(&stmt.node, ICNFInner::Assign(_, _)) {
                        continue;
                    }
                    if for_operand_ids.contains(&stmt.id) {
                        match &stmt.node {
                            ICNFInner::Load(_) | ICNFInner::Const(_) | ICNFInner::Call(_, _) => continue,
                            ICNFInner::FfiCall { .. } => continue,
                            ICNFInner::Spawn(_) | ICNFInner::Send(..) | ICNFInner::SendClosure(..) => continue,
                            ICNFInner::BinOp(_, _, _) => continue,
                            ICNFInner::UnOp(_, _) => continue,
                            _ => {}
                        }
                    }
                    // The loop body's final node is its result value (consumed
                    // by an enclosing value context): emit it fresh into rax
                    // even when flagged as an operand. Anything after it is a
                    // leaked supply copy — skip.
                    if Some(stmt.id) == for_body_last_id && !for_body_done {
                        self.emit_load_into(
                            stmt.id,
                            "rax",
                            stmts,
                            &body_local_vars,
                            &for_lookup,
                            emitted_ids,
                            &crate::deterministic::HashSet::default(),
                            phi_slots,
                        );
                        emitted_ids.insert(stmt.id);
                        for_body_done = true;
                        continue;
                    }
                    if for_body_done {
                        continue;
                    }
                    self.emit_node(
                        stmt,
                        stmts,
                        &body_local_vars,
                        emitted_ids,
                        &for_operand_ids,
                        &for_lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(stmt.id);
                }

                self.asm_push_align();
                self.asm.push(format!("    jmp {}", loop_start));
                self.asm_push_align();
                self.asm_push_align();
                self.asm.push(format!("{}:", loop_end));

                // The exit path arrives through the failed condition, which
                // left rax = 0 (comparison result). Re-materialize the body's
                // tail value so the loop's result survives the exit.
                if let Some(last) = body.last() {
                    match &last.node {
                        ICNFInner::Load(_) | ICNFInner::Const(_)
                        | ICNFInner::BinOp(..) | ICNFInner::StructGet(..) => {
                            let mut empty = crate::deterministic::HashSet::default();
                            self.emit_load_into(
                                last.id,
                                "rax",
                                stmts,
                                &body_local_vars,
                                &for_lookup,
                                emitted_ids,
                                &empty,
                                phi_slots,
                            );
                            emitted_ids.insert(last.id);
                        }
                        _ => {}
                    }
                }
            }

            ICNFInner::Print(args) => {
                if args.is_empty() {
                    return;
                }

                let find_node = |id: usize| -> Option<&ICNFNode> {
                    lookup
                        .get(&id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == id))
                };

                for &arg_id in args.iter() {
                    let node = find_node(arg_id);
                    // An If/Cond result whose branches are string constants is
                    // a string (branch bodies were de-leaked; the phi slot
                    // holds the branch value).
                    let if_string_branches = match node {
                        Some(ICNFNode { node: ICNFInner::If { then_body, else_body, .. }, .. }) => {
                            let branch_str = |b: &[ICNFNode]| {
                                b.last().map(|n| matches!(&n.node, ICNFInner::Const(Atom::Str(_)) | ICNFInner::StrImm(_))).unwrap_or(false)
                            };
                            let has_else = !else_body.is_empty();
                            branch_str(then_body) && (!has_else || branch_str(else_body))
                        }
                        _ => false,
                    };
                    let is_string = if_string_branches
                        || match node {
                        Some(ICNFNode {
                            node: ICNFInner::Const(Atom::Str(_)),
                            ..
                        }) => true,
                        Some(ICNFNode {
                            node: ICNFInner::Load(var_name),
                            ..
                        }) => {
                            // Check if this Load's variable name matches an Assign whose value_id
                            // points to a ReadLine result or a string constant.
                            // Build a var→Assign value_id map from lookup (all nodes by ID).
                            let mut var_assigns: crate::deterministic::HashMap<String, usize> =
                                crate::deterministic::HashMap::default();
                            for &n in lookup.values() {
                                if let ICNFInner::Assign(aname, avid) = &n.node {
                                    if !var_assigns.contains_key(aname) {
                                        var_assigns.insert(aname.clone(), *avid);
                                    }
                                }
                            }
                            let mut result = false;
                            if let Some(&value_id) = var_assigns.get(var_name) {
                                // Check if value_id is a ReadLine or FileRead result
                                let io_result_id = stmts.iter()
                                    .find(|n| matches!(&n.node, ICNFInner::ReadLine | ICNFInner::FileRead { .. }))
                                    .map(|n| n.id);
                                if let Some(rid) = io_result_id {
                                    result = value_id == rid;
                                }
                                // Check if value_id resolves to a string const
                                if !result {
                                    if let Some(vn) = find_node(value_id) {
                                        result = matches!(vn.node, ICNFInner::Const(Atom::Str(_)));
                                    }
                                }
                                // Check if value_id resolves to a string-returning call
                                if !result {
                                    if let Some(vn) = find_node(value_id) {
                                        if let ICNFInner::Call(fname, _) = &vn.node {
                                            result = self.func_returns.get(&fname.replace('-', "_")).is_some_and(|t| matches!(t, Type::Prim(PrimType::String)))
                                                || matches!(fname.as_str(), "str-concat" | "str_concat" | "str-substring" | "str_substring" | "read-line" | "read_line");
                                        }
                                    }
                                }
                            } else {
                                // No Assign found — check if this is a String-typed parameter.
                                result = self.string_params.contains(var_name);
                            }
                            result || self.string_params.contains(var_name) || self.string_locals.contains(var_name)
                        }
                        Some(ICNFNode {
                            node: ICNFInner::Call(fname, _),
                            ..
                        }) => self.func_returns.get(&fname.replace('-', "_")).is_some_and(|t| matches!(t, Type::Prim(PrimType::String)))
                            || matches!(fname.as_str(), "str-concat" | "str_concat" | "str-substring" | "str_substring" | "read-line" | "read_line"),
                        _ => false,
                    };
                    // Check if node's type is explicitly set.
                    // If it's an Assign with no type, look up the value_id.
                    let node_type = node.and_then(|n| n.typ.as_ref());
                    let is_float = matches!(node_type, Some(Type::Prim(PrimType::Float)));
                    // If no type yet and this is an Assign, resolve from value_id.
                    let is_float = if !is_float {
                        if let Some(ICNFNode { node: ICNFInner::Assign(_, value_id), .. }) = node {
                            let value_node = find_node(*value_id);
                            matches!(value_node.and_then(|n| n.typ.as_ref()), Some(Type::Prim(PrimType::Float)))
                        } else { false }
                    } else { is_float };
                    // Structural fallback: type info is often absent on ICNF
                    // nodes, so also detect float-shaped values (float
                    // constants, binops over floats, loads of float locals).
                    let is_float = is_float
                        || (!is_string && self.node_looks_float(arg_id, lookup, stmts, 0));

                     if is_string {
                     match find_node(arg_id) {
                             Some(ICNFNode {
                                 node: ICNFInner::Const(Atom::Str(s)),
                                 ..
                             }) => {
                                 let str_label = self.emit_string_literal(s);
                                 self.asm_push_align();
                                 self.asm.push(format!("    lea rsi, [{}] ", str_label));
                             }
                             Some(ICNFNode {
                                 node: ICNFInner::Load(var_name),
                                 ..
                             }) => {
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                                     self.asm.push(format!("    mov rsi, [rbp-{}]", offset));
                                 } else {
                                     self.asm_push_align();
                                     self.asm.push("    mov rsi, rax".to_string());
                                 }
                             }
                             Some(ICNFNode {
                                 node: ICNFInner::Call(..),
                                 ..
                             }) => {
                                 self.emit_load_into(arg_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                                 self.asm_push_align();
                                 self.asm.push("    mov rsi, rax".to_string());
                             }
                             _ => {
                                 self.asm_push_align();
                                 self.asm.push("    mov rsi, rax".to_string());
                             }
                         }

                        self.asm_push_align();
                        self.asm.push("    lea rdi, [.fmt_str]".to_string());

                        // Save xmm0 before printf (printf clobbers XMM registers).
                        self.asm_push_align();
                        self.asm.push("    sub rsp, 16".to_string());
                        self.asm_push_align();
                        self.asm.push("    movsd [rsp], xmm0".to_string());

                        self.asm_push_align();
                        self.asm
                            .push("    xor eax, eax           # No xmm args to printf".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov r15, rsp".to_string());
                        self.asm.push("    and rsp, -16".to_string());
                        self.asm.push("    call printf@plt".to_string());
                        self.asm.push("    mov rsp, r15".to_string());

                        // Restore xmm0 after printf.
                        self.asm_push_align();
                        self.asm.push("    movsd xmm0, [rsp]".to_string());
                        self.asm_push_align();
                        self.asm.push("    add rsp, 16".to_string());
                    } else if is_float {
                        match find_node(arg_id) {
                            Some(ICNFNode {
                                node: ICNFInner::Const(Atom::Float(v)),
                                ..
                            }) => {
                                let float_label = format!(".flt_{}", v.to_bits());
                                self.asm_push_align();
                                self.asm.push(format!("    movsd xmm0, [{}]", float_label));
                            }
                            _ => {
                                let xmm_arg = format!("xmm{}", self.alloc_xmm());
                                self.emit_float_load_into(
                                    arg_id, &xmm_arg, stmts, local_vars, lookup, emitted_ids, operand_ids,
                                );
                                self.asm_push_align();
                                self.asm
                                    .push(format!("    movsd xmm0, {}", xmm_arg));
                            }
                        }
                        self.asm_push_align();
                        self.asm.push("    lea rdi, [.fmt_float]".to_string());
                        // printf spills xmm args with aligned SSE stores when
                        // al != 0, so dynamically align rsp to 16 here.
                        self.asm_push_align();
                        self.asm.push("    mov rax, rsp".to_string());
                        self.asm_push_align();
                        self.asm.push("    and rsp, -16".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov eax, 1".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov r15, rsp".to_string());
                        self.asm.push("    and rsp, -16".to_string());
                        self.asm.push("    call printf@plt".to_string());
                        self.asm.push("    mov rsp, r15".to_string());
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    lea rsp, [rbp-{}]",
                            self.spill_frame.max(256)
                        ));
                    } else {
                        self.emit_load_into(
                            arg_id,
                            "eax",
                            stmts,
                            local_vars,
                            lookup,
                            emitted_ids,
                            operand_ids,
                            phi_slots,
                        );
                        let int_reg = "eax"; // Value should be in eax from prior computation.

                        // First, emit the integer-to-string conversion.
                        self.emit_int_to_str(int_reg);

                    }
                }
            }

            ICNFInner::ReadLine => {
                // Read a line from stdin using the read syscall.
                // sys_read: rax=0, rdi=fd, rsi=buf, rdx=count
                // Result: bytes read in rax, or -1 on error.
                self.asm_push_align();
                self.asm.push("    lea rsi, [.stdin_buf]  # buffer pointer (rsi for syscall)".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 0             # sys_read".to_string());
                self.asm_push_align();
                self.asm.push("    mov rdi, 0             # stdin fd".to_string());
                self.asm_push_align();
                self.asm.push("    mov rdx, 4096          # buffer size".to_string());
                self.asm_push_align();
                self.asm.push("    syscall".to_string());

                // Check for error (rax < 0) or EOF (rax == 0).
                self.asm_push_align();
                self.asm.push("    test rax, rax".to_string());
                self.asm_push_align();
                let err_label = self.new_label();
                let done_label = self.new_label();
                self.asm.push(format!("    js {}", err_label));
                self.asm_push_align();
                self.asm.push(format!("    je {}", err_label));

                // Strip trailing newline (if present).
                // rax = bytes_read, rsi = buffer pointer.
                self.asm_push_align();
                self.asm.push("    dec rax                # bytes_read - 1".to_string());
                self.asm_push_align();
                self.asm.push("    cmp byte ptr [rsi + rax], 10".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jne {}", done_label));
                self.asm_push_align();
                self.asm.push("    mov byte ptr [rsi + rax], 0  # strip newline".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", done_label));

                // Error/EOF: return 0 (null pointer).
                self.asm_push_align();
                self.asm.push(format!("{}:", err_label));
                self.asm_push_align();
                self.asm.push("    xor rax, rax           # null pointer on error/EOF".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", done_label));

                // Success: rax = buffer pointer (return value as String).
                self.asm_push_align();
                self.asm.push(format!("{}:", done_label));
                self.asm_push_align();
                self.asm.push("    mov rax, rsi           # return buffer pointer as String".to_string());
            }

            ICNFInner::FileOpen { path, mode } => {
                // open(path_ptr, flags) -> fd or -1
                // SYS_OPEN = 2
                // Determine flags based on mode string at compile time.
                let mode_node = lookup.get(mode).copied().or_else(|| stmts.iter().find(|n| n.id == *mode));
                let mode_str = match mode_node {
                    Some(ICNFNode { node: ICNFInner::Const(Atom::Str(m)), .. }) => Some(m.clone()),
                    _ => None,
                };
                let mode_is_write = match &mode_str {
                    Some(m) => m.contains('w') || m.contains('a') || m.contains('+'),
                    None => true, // default to write mode
                };
                let mode_is_append = match &mode_str {
                    Some(m) => m.contains('a'),
                    None => false,
                };

                let path_node = lookup.get(path).copied().or_else(|| stmts.iter().find(|n| n.id == *path));
                let path_label = match path_node {
                    Some(ICNFNode {
                        node: ICNFInner::Const(Atom::Str(s)),
                        ..
                    }) => self.emit_string_literal(s),
                    _ => {
                        // Fallback: load path via emit_load_into
                        self.emit_load_into(
                            *path, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                        );
                        self.asm_push_align();
                        self.asm.push("    mov rdi, rax         # path pointer".to_string());
                        self.asm_push_align();
                        if mode_is_write {
                            if mode_is_append {
                                self.asm.push("    mov rsi, 1089   # O_WRONLY|O_CREAT|O_APPEND".to_string());
                            } else {
                                self.asm.push("    mov rsi, 577       # O_WRONLY|O_CREAT|O_TRUNC".to_string());
                            }
                            self.asm.push("    mov rdx, 420       # 0o644".to_string());
                        } else {
                            self.asm.push("    mov rsi, 0         # O_RDONLY".to_string());
                        }
                        self.asm_push_align();
                        self.asm.push("    mov rax, 2         # SYS_OPEN".to_string());
                        self.asm_push_align();
                        self.asm.push("    syscall".to_string());
                        return;
                    }
                };

                self.asm_push_align();
                self.asm.push(format!("    lea rdi, [{}]      # path pointer", path_label));
                self.asm_push_align();
                if mode_is_write {
                    if mode_is_append {
                        self.asm.push("    mov rsi, 1089   # O_WRONLY|O_CREAT|O_APPEND".to_string());
                    } else {
                        self.asm.push("    mov rsi, 577       # O_WRONLY|O_CREAT|O_TRUNC".to_string());
                    }
                    self.asm.push("    mov rdx, 420       # 0o644".to_string());
                } else {
                    self.asm.push("    mov rsi, 0         # O_RDONLY".to_string());
                }
                self.asm_push_align();
                self.asm.push("    mov rax, 2         # SYS_OPEN".to_string());
                self.asm_push_align();
                self.asm.push("    syscall".to_string());
                // rax = fd or -1
            }

            ICNFInner::FileRead { handle, count } => {
                // read(fd, buf, count) -> bytes_read
                // SYS_READ = 0
                // Load handle (fd) into rax first
                self.emit_load_into(
                    *handle, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );

                let count_node = lookup.get(count).copied().or_else(|| stmts.iter().find(|n| n.id == *count));
                let count_is_int_const = matches!(count_node, Some(ICNFNode { node: ICNFInner::Const(Atom::Int(_)), .. }));

                if count_is_int_const {
                    if let Some(ICNFNode { node: ICNFInner::Const(Atom::Int(c)), .. }) = count_node {
                        self.asm_push_align();
                        self.asm.push("    mov rdi, rax         # fd (from file-open result in rax)".to_string());
                        self.asm_push_align();
                        self.asm.push("    lea rsi, [.file_read_buf]  # buffer pointer".to_string());
                        self.asm_push_align();
                        self.asm.push(format!("    mov rdx, {}        # count: {} bytes", c, c));
                        self.asm_push_align();
                        self.asm.push("    mov rax, 0         # SYS_READ".to_string());
                        self.asm_push_align();
                        self.asm.push("    syscall".to_string());
                        self.asm_push_align();
                        // null-terminate the buffer so it can be printed as a C string
                        self.asm.push("    push rsi           # save buffer pointer".to_string());
                        self.asm_push_align();
                        self.asm.push("    lea rsi, [.file_read_buf]  # buffer address".to_string());
                        self.asm_push_align();
                        self.asm.push("    add rsi, rax         # rsi = buffer + bytes_read".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov byte ptr [rsi], 0  # null-terminate".to_string());
                        self.asm_push_align();
                        self.asm.push("    pop rsi              # restore buffer pointer".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov rax, rsi         # return buffer pointer (not bytes_read)".to_string());
                        return;
                    }
                }

                // General case: load handle and count from registers
                self.asm_push_align();
                self.asm.push("    mov rdi, rax         # fd (from prior computation)".to_string());
                self.asm_push_align();
                self.asm.push("    lea rsi, [.file_read_buf]  # buffer pointer".to_string());
                self.asm_push_align();
                self.asm.push("    mov rdx, rcx         # count (from rcx)".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 0         # SYS_READ".to_string());
                self.asm_push_align();
                self.asm.push("    syscall".to_string());
                self.asm_push_align();
                // null-terminate the buffer so it can be printed as a C string
                self.asm.push("    push rsi           # save buffer pointer".to_string());
                self.asm_push_align();
                self.asm.push("    lea rsi, [.file_read_buf]  # buffer address".to_string());
                self.asm_push_align();
                self.asm.push("    add rsi, rax         # rsi = buffer + bytes_read".to_string());
                self.asm_push_align();
                self.asm.push("    mov byte ptr [rsi], 0  # null-terminate".to_string());
                self.asm_push_align();
                self.asm.push("    pop rsi              # restore buffer pointer".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, rsi         # return buffer pointer (not bytes_read)".to_string());
                // rax = buffer pointer, rsi = buffer pointer with data
            }

            ICNFInner::FileWrite { handle, data } => {
                // write(fd, buf, count) -> bytes_written or -1
                // SYS_WRITE = 1
                // fd is in rax (from prior computation)
                // data pointer should end up in rsi
                // we use r12 to preserve fd across the strlen loop
                let data_node = lookup.get(data).copied().or_else(|| stmts.iter().find(|n| n.id == *data));
                let data_label = match data_node {
                    Some(ICNFNode {
                        node: ICNFInner::Const(Atom::Str(s)),
                        ..
                    }) => Some(self.emit_string_literal(s)),
                    _ => None,
                };

                // Load the data pointer first and preserve it on the stack, THEN
                // load the handle. Evaluating data first into rax and then reloading
                // the handle into rax would clobber the data pointer (the write would
                // emit bytes from the handle value, not from the buffer).
                let strlen_done = self.new_label();
                // Load a FileWrite handle freshly: if the handle is a
                // StructGet that was already emitted standalone, the "already
                // emitted" skip in emit_load_into would assume eax still holds
                // the field value — but any intervening load (e.g. the data
                // pointer) clobbers eax. Re-derive StructGet handles from the
                // struct slot instead.
                let emit_handle_fresh = |cg: &mut Self,
                                         handle_id: usize,
                                         stmts: &[ICNFNode],
                                         local_vars: &HashMap<String, usize>,
                                         lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
                                         emitted_ids: &mut crate::deterministic::HashSet<usize>,
                                         operand_ids: &crate::deterministic::HashSet<usize>,
                                         phi_slots: &crate::deterministic::HashMap<String, String>| {
                    if let Some(ICNFNode {
                        node: ICNFInner::StructGet(sid, off),
                        ..
                    }) = lookup.get(&handle_id).copied().or_else(|| {
                        stmts.iter().find(|n| n.id == handle_id)
                    }) {
                        cg.emit_load_into(
                            *sid, "rax", stmts, local_vars, lookup, emitted_ids,
                            operand_ids, phi_slots,
                        );
                        cg.asm_push_align();
                        cg.asm.push(format!("    mov rax, [rax + {}]", off));
                    } else {
                        cg.emit_load_into(
                            handle_id, "rax", stmts, local_vars, lookup, emitted_ids,
                            operand_ids, phi_slots,
                        );
                    }
                };
                if let Some(ref label) = data_label {
                    // String literal: materialize directly into rsi (never clobbered).
                    self.asm_push_align();
                    self.asm.push(format!("    lea rsi, [{}]      # data pointer (rodata)", label));
                    // Load handle (fd) preserving it in r12.
                    self.asm_push_align();
                    self.asm.push("    push r12           # preserve fd".to_string());
                    self.asm_push_align();
                    emit_handle_fresh(
                        self, *handle, stmts, local_vars, lookup, emitted_ids,
                        operand_ids, phi_slots,
                    );
                    self.asm_push_align();
                    self.asm.push("    mov r12, rax         # save fd to r12".to_string());
                } else {
                    // Variable data pointer: load it 64-bit into rax, save to the
                    // stack, then load the handle (which uses rax). Pop the data
                    // pointer back into rsi afterwards so the strlen/copy loop uses
                    // the correct bytes.
                    // 0. Preserve caller's r12 (popped at the very end).
                    self.asm_push_align();
                    self.asm.push("    push r12            # preserve old r12".to_string());
                    // 1. Data pointer -> rax (full 64-bit, no truncation).
                    self.emit_load_into(
                        *data, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                    );
                    // 2. Preserve it on the stack (above old r12).
                    self.asm_push_align();
                    self.asm.push("    push rax            # preserve data pointer".to_string());
                    // 3. Load handle (fd) into rax then save to r12.
                    self.asm_push_align();
                    emit_handle_fresh(
                        self, *handle, stmts, local_vars, lookup, emitted_ids,
                        operand_ids, phi_slots,
                    );
                    self.asm_push_align();
                    self.asm.push("    mov r12, rax         # save fd to r12".to_string());
                    // 4. Restore data pointer into rsi (pops the data, old r12 stays).
                    self.asm_push_align();
                    self.asm.push("    pop rax             # restore data pointer".to_string());
                    self.asm_push_align();
                    self.asm.push("    mov rsi, rax         # data pointer".to_string());
                }
                self.asm_push_align();
                self.asm.push("    mov rax, 0           # strlen result counter".to_string());
                self.asm_push_align();
                self.asm.push("    mov rcx, rsi         # rcx = string pointer".to_string());
                self.asm_push_align();
                self.asm.push(format!("strlen_loop_{}:", self.label_counter));
                self.asm_push_align();
                self.asm.push("    cmp byte ptr [rcx], 0".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je {}", strlen_done));
                self.asm_push_align();
                self.asm.push("    inc rcx".to_string());
                self.asm_push_align();
                self.asm.push("    inc rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp strlen_loop_{}", self.label_counter));
                self.label_counter += 1;
                self.asm_push_align();
                self.asm.push(format!("{}:", strlen_done));
                self.asm_push_align();
                // rax = string length
                self.asm.push("    mov rdx, rax         # count = string length".to_string());
                self.asm_push_align();
                self.asm.push("    mov rdi, r12         # fd (restored from r12)".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 1           # SYS_WRITE".to_string());
                self.asm_push_align();
                self.asm.push("    syscall".to_string());
                self.asm_push_align();
                self.asm.push("    pop r12            # restore r12".to_string());
                // rax = bytes_written or -1
                emitted_ids.insert(node.id);
            }

            ICNFInner::FileClose(handle_id) => {
                // close(fd) -> 0 on success, -1 on error
                // SYS_CLOSE = 3
                self.emit_load_into(
                    *handle_id, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );
                self.asm_push_align();
                self.asm.push("    mov rdi, rax         # fd (handle from prior computation)".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 3           # SYS_CLOSE".to_string());
                self.asm_push_align();
                self.asm.push("    syscall".to_string());
            }

            ICNFInner::BufAppend { dst, src } => {
                // buf-append(dst, src)
                // dst = null-terminated arena pointer (Int), src = string pointer (String).
                // Appends src's bytes (including terminator) at the end of dst's content.
                // Returns the new total content length (Int) in eax.
                // r12 preserves the dst start pointer across both strlen loops.
                let strlen_dst_done = self.new_label();
                let strlen_src_done = self.new_label();
                let copy_done = self.new_label();

                // buf-append's operands are pointers by contract (dst = arena/heap
                // buffer, src = NUL-terminated string). Load them full 64-bit
                // regardless of their inferred type, since an Int-typed variable may
                // hold a 64-bit heap address (e.g. arena-alloc); 32-bit load truncates.
                //
                // Load SRC FIRST and save it on the stack. If src is a function-call
                // result that was already emitted (e.g. pool-str pool id), emit_load_into
                // leaves that value in rax expecting no intervening code to clobber it;
                // the dst computation below pushes and loads r12/rax/rsi/rcx, destroying
                // rax. Saving src first lets us pop it into rdx after computing dst,
                // and rdx is not clobbered by the dst strlen either.
                self.emit_load_into(
                    *src, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );
                // Push order matters: r12 (caller-saved dst-start) is pushed FIRST,
                // then src on TOP. The pops below must then take src into rdx before
                // restoring r12 — matching the LIFO order.
                self.asm_push_align();
                self.asm.push("    push r12           # preserve dst start".to_string());
                self.asm_push_align();
                self.asm.push("    push rax            # save src pointer".to_string());
                self.emit_load_into(
                    *dst, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );
                self.asm_push_align();
                self.asm.push("    mov r12, rax        # r12 = dst start".to_string());
                self.asm_push_align();
                self.asm.push("    mov rsi, rax        # rsi = dst pointer".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 0          # strlen counter".to_string());
                self.asm_push_align();
                self.asm.push("    mov rcx, rsi        # rcx = scan pointer".to_string());
                self.asm_push_align();
                self.asm.push(format!("strlen_dst_{}:", self.label_counter));
                self.asm_push_align();
                self.asm.push("    cmp byte ptr [rcx], 0".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je {}", strlen_dst_done));
                self.asm_push_align();
                self.asm.push("    inc rcx".to_string());
                self.asm_push_align();
                self.asm.push("    inc rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp strlen_dst_{}", self.label_counter));
                self.label_counter += 1;
                self.asm_push_align();
                self.asm.push(format!("{}:", strlen_dst_done));
                self.asm_push_align();
                self.asm.push("    mov rdi, rcx        # rdi = copy destination (dst end)".to_string());
                self.asm_push_align();
                self.asm.push("    pop rdx             # rdx = src pointer".to_string());
                self.asm_push_align();
                self.asm.push("    mov rax, 0          # strlen counter".to_string());
                self.asm_push_align();
                self.asm.push("    mov rcx, rdx        # rcx = scan pointer".to_string());
                self.asm_push_align();
                self.asm.push(format!("strlen_src_{}:", self.label_counter));
                self.asm_push_align();
                self.asm.push("    cmp byte ptr [rcx], 0".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je {}", strlen_src_done));
                self.asm_push_align();
                self.asm.push("    inc rcx".to_string());
                self.asm_push_align();
                self.asm.push("    inc rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp strlen_src_{}", self.label_counter));
                self.label_counter += 1;
                self.asm_push_align();
                self.asm.push(format!("{}:", strlen_src_done));
                self.asm_push_align();
                // rax = src_len. Copy src_len+1 bytes (including null terminator).
                self.asm.push("    inc rax             # count = src_len + 1".to_string());
                self.asm_push_align();
                self.asm.push("    mov rcx, rax        # rcx = byte count".to_string());
                self.asm_push_align();
                self.asm.push("    xor rax, rax        # copy index".to_string());
                self.asm_push_align();
                self.asm.push(format!("copy_loop_{}:", self.label_counter));
                self.asm_push_align();
                self.asm.push("    cmp rax, rcx".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jge {}", copy_done));
                self.asm_push_align();
                self.asm.push("    mov r8b, byte ptr [rdx + rax]".to_string());
                self.asm_push_align();
                self.asm.push("    mov byte ptr [rdi + rax], r8b".to_string());
                self.asm_push_align();
                self.asm.push("    inc rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp copy_loop_{}", self.label_counter));
                self.label_counter += 1;
                self.asm_push_align();
                self.asm.push(format!("{}:", copy_done));
                self.asm_push_align();
                // Return new total length = dst_len + src_len.
                // rcx = src_len + 1 at this point; rax is a copy index (== count).
                self.asm.push("    mov rax, rdi".to_string());
                self.asm_push_align();
                self.asm.push("    sub rax, r12       # rax = dst_len".to_string());
                self.asm_push_align();
                self.asm.push("    lea rax, [rax + rcx - 1]  # + src_len".to_string());
                self.asm_push_align();
                self.asm.push("    pop r12             # restore r12".to_string());
            }

            ICNFInner::Call(name, args) => {
                // Skip standalone Call statements that are operands to a parent node.
                // Top-level (non-operand) Call statements need to be emitted.
                // Check: is this node an operand to a parent? If so, skip.
                if operand_ids.contains(&node.id) {
                    return;
                }
                // Top-level Call — emit directly. Pass the real emitted_ids (not a
                // clone) so the node is marked emitted; otherwise an Assign that
                // consumes this call's result re-emits it on-demand, executing the
                // call twice (observable with side-effecting FFI/counter values).
                let target_reg = match &node.typ {
                    Some(t) if !matches!(t, Type::Prim(PrimType::Int | PrimType::Bool | PrimType::Unit | PrimType::Float)) => "rax",
                    // ICNF call nodes often lack a type annotation; fall back to the
                    // known return type of the callee so pointer-returning calls
                    // (structs/ADTs/strings) preserve the full 64-bit pointer.
                    _ if self
                        .func_returns
                        .get(&name.replace('-', "_"))
                        .is_some_and(|t| !matches!(t, Type::Prim(PrimType::Int | PrimType::Bool | PrimType::Unit | PrimType::Float)))
                        => "rax",
                    _ => "eax",
                };
                self.emit_call_direct(
                    name,
                    args,
                    target_reg,
                    stmts,
                    local_vars,
                    lookup,
                    emitted_ids,
                    node.id,
                    false,
                );
            }

            ICNFInner::CallIndirect(callee_ssa, args) => {
                if operand_ids.contains(&node.id) {
                    return;
                }
                let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
                let abi_xmm = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
                let target_reg = match &node.typ {
                    Some(t) if !matches!(t, Type::Prim(PrimType::Int | PrimType::Bool | PrimType::Unit | PrimType::Float)) => "rax",
                    _ => "eax",
                };
                let is_float = matches!(node.typ.as_ref(), Some(Type::Prim(PrimType::Float)));

                // Reverse-lookup the callee variable name from the Assign node.
                let callee_name = if let Some(ICNFNode { node: ICNFInner::Assign(nm, _), .. }) = lookup.get(callee_ssa) {
                    Some(nm.clone())
                } else {
                    None
                };

                // Determine if this is a known closure with env convention.
                let mut env_call = false;
                let mut known = false;
                if let Some(ref nm) = callee_name {
                    for s in stmts.iter() {
                        if let ICNFInner::Assign(n, vid) = &s.node {
                            if n == nm || sanitize_name(n) == *nm {
                                if let Some(ICNFNode { node: ICNFInner::Closure { captures, .. }, .. }) = lookup.get(vid) {
                                    env_call = !captures.is_empty();
                                    known = true;
                                }
                                break;
                            }
                        }
                    }
                }
                let dynamic_dispatch = !known;
                let num_args = args.len().min(6);

                // Evaluate args and save to stack temps.
                let mut is_floats: Vec<bool> = Vec::with_capacity(num_args);
                for (i, &arg_id) in args.iter().enumerate().take(num_args) {
                    let arg_node = lookup.get(&arg_id).copied().or_else(|| stmts.iter().find(|n| n.id == arg_id));
                    let arg_is_float = arg_node.and_then(|n| n.typ.as_ref()).is_some_and(|t| matches!(t, Type::Prim(PrimType::Float)));
                    if arg_is_float {
                        let xmm_reg = abi_xmm[i];
                        self.emit_float_load_into(arg_id, &xmm_reg, stmts, local_vars, lookup, emitted_ids, operand_ids);
                        self.asm_push_align();
                        self.asm.push("    sub rsp, 16".to_string());
                        self.asm_push_align();
                        self.asm.push(format!("    movsd [rsp], {}", xmm_reg));
                        is_floats.push(true);
                    } else {
                        let reg = abi_regs_64[i];
                        self.emit_load_into(arg_id, reg, stmts, local_vars, lookup, emitted_ids, &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default());
                        self.asm_push_align();
                        self.asm.push("    sub rsp, 8".to_string());
                        self.asm_push_align();
                        self.asm.push(format!("    mov [rsp], {}", reg));
                        is_floats.push(false);
                    }
                }

                // Load saved args into ABI registers (shift by 1 if env/dynamic to leave rdi for env/closure).
                let abi_base = if env_call || dynamic_dispatch { 1 } else { 0 };
                for (i, &arg_is_float) in is_floats.iter().enumerate().rev() {
                    if arg_is_float {
                        let xmm_reg = abi_xmm[i + abi_base];
                        self.asm_push_align();
                        self.asm.push(format!("    movsd {}, [rsp]", xmm_reg));
                        self.asm_push_align();
                        self.asm.push("    add rsp, 16".to_string());
                    } else {
                        let reg_64 = abi_regs_64[i + abi_base];
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, [rsp]", reg_64));
                        self.asm_push_align();
                        self.asm.push("    add rsp, 8".to_string());
                    }
                }

                // Load closure value from frame slot and call.
                if let Some(ref nm) = callee_name {
                    if let Some(&slot_idx) = local_vars.get(nm).or_else(|| {
                        local_vars.iter().find(|(k, _)| sanitize_name(k) == *nm).map(|(_, v)| v)
                    }) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                        self.asm_push_align();
                        if dynamic_dispatch {
                            self.asm.push("    mov rdi, rax".to_string());
                            self.asm_push_align();
                            let helper = format!("zyl_call{}@plt", num_args);
                            self.asm.push("    mov r15, rsp".to_string());
                            self.asm.push("    and rsp, -16".to_string());
                            self.asm.push(format!("    call {}", helper));
                            self.asm.push("    mov rsp, r15".to_string());
                        } else if env_call {
                            self.asm.push("    mov rdi, rax".to_string());
                            self.asm_push_align();
                            self.asm.push("    mov rax, [rax]".to_string());
                            self.asm_push_align();
                            self.asm.push("    call rax".to_string());
                        } else {
                            self.asm.push("    call rax".to_string());
                        }
                    } else {
                        // Fallback: load SSA directly and use dynamic dispatch.
                        self.emit_load_into(*callee_ssa, "rax", stmts, local_vars, lookup, emitted_ids, &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default());
                        self.asm_push_align();
                        let helper = format!("zyl_call{}@plt", num_args);
                        self.asm.push("    mov rdi, rax".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov r15, rsp".to_string());
                        self.asm.push("    and rsp, -16".to_string());
                        self.asm.push(format!("    call {}", helper));
                        self.asm.push("    mov rsp, r15".to_string());
                    }
                } else {
                    // No name resolved: load SSA directly and use dynamic dispatch.
                    self.emit_load_into(*callee_ssa, "rax", stmts, local_vars, lookup, emitted_ids, &crate::deterministic::HashSet::default(), &crate::deterministic::HashMap::default());
                    self.asm_push_align();
                    let helper = format!("zyl_call{}@plt", num_args);
                    self.asm.push("    mov rdi, rax".to_string());
                    self.asm_push_align();
                    self.asm.push("    mov r15, rsp".to_string());
                    self.asm.push("    and rsp, -16".to_string());
                    self.asm.push(format!("    call {}", helper));
                    self.asm.push("    mov rsp, r15".to_string());
                }

                if is_float {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, xmm0", target_reg));
                } else {
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, rax", reg_to_64(target_reg)));
                }
            }

            ICNFInner::Exit(code_id) => {
                // Exit with status code using exit() from libc.
                self.emit_load_into(
                    *code_id, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );
                self.asm_push_align();
                self.asm.push("    mov edi, eax".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call exit@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
            }

            ICNFInner::Eq { left, right } => {
                if self.node_looks_string(*left, lookup, stmts)
                    || self.node_looks_string(*right, lookup, stmts)
                {
                    self.emit_str_eq(*left, *right, "eax", stmts, local_vars, lookup, emitted_ids);
                    emitted_ids.insert(node.id);
                } else if (self.node_looks_variant(*left, lookup, stmts, 0)
                    || self.node_looks_variant(*right, lookup, stmts, 0))
                    && !Self::node_is_primitive_const(*left, lookup, stmts)
                    && !Self::node_is_primitive_const(*right, lookup, stmts)
                {
                    self.emit_variant_eq(*left, *right, "eax", stmts, local_vars, lookup, emitted_ids);
                    emitted_ids.insert(node.id);
                } else {
                // Detect float comparisons from operand shapes.
                let eq_is_float = self.node_looks_float(*left, lookup, stmts, 0)
                    || self.node_looks_float(*right, lookup, stmts, 0);
                self.emit_binop_direct(
                    &BinOpKind::Eq,
                    *left,
                    *right,
                    "eax",
                    stmts,
                    local_vars,
                    lookup,
                    emitted_ids,
                    eq_is_float,
                    node.id,
                );
                }
            }

            ICNFInner::Assert { cond_ssa, msg } => {
                // Float equality is approximate: assert-equal literals are
                // written to %.6f precision and rarely match computed doubles
                // bit-for-bit (e.g. (/ 1.0 2.0 3.0) vs 0.166667). When the
                // condition is a float Eq, compare |a - b| <= 1e-5 instead.
                let float_eq_operands = match lookup.get(cond_ssa).map(|n| &n.node) {
                    Some(ICNFInner::Eq { left, right }) if self.node_looks_float(*left, lookup, stmts, 0)
                        || self.node_looks_float(*right, lookup, stmts, 0) =>
                    {
                        Some((*left, *right))
                    }
                    _ => None,
                };
                if let Some((l, r)) = float_eq_operands {
                    self.emit_float_load_into(
                        l, "xmm1", stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );
                    self.asm_push_align();
                    self.emit_float_load_into(
                        r, "xmm2", stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );
                    // eax = (|a - b| <= epsilon)
                    self.asm_push_align();
                    self.asm.push("    movsd xmm0, xmm1".to_string());
                    self.asm_push_align();
                    self.asm.push("    subsd xmm0, xmm2".to_string());
                    self.asm_push_align();
                    self.asm.push("    andpd xmm0, [.flt_abs_mask]".to_string());
                    self.asm_push_align();
                    self.asm.push("    comisd xmm0, [.flt_epsilon]".to_string());
                    self.asm_push_align();
                    self.asm.push("    setbe al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                } else {
                    // Load condition into eax.
                    self.emit_load_into(
                        *cond_ssa, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                    );
                }
                let msg = msg.as_deref().unwrap_or("assertion failed");
                let label = format!(".assert_fail_{}", self.label_counter);
                self.label_counter += 1;
                // Branch to panic if condition is zero.
                self.asm.push("    test eax, eax".to_string());
                self.asm.push(format!("    je {}", label));
                // If we get here, the assertion passed — do nothing, let next stmts execute.
                // The panic label is emitted later by the codegen when needed.
                // For now, we store the label in a map so subsequent stmts know to jump over it.
                // Actually, the simplest fix: emit the panic label AFTER all subsequent stmts.
                // We can't do that here, so instead we emit a jump over the panic code.
                let after_panic_label = format!(".assert_after_{}", self.label_counter);
                self.label_counter += 1;
                self.asm.push(format!("    jmp {}", after_panic_label));
                // Emit panic label.
                self.asm.push(format!("{}:", label));
                let str_label = self.emit_string_literal(msg);
                self.asm.push(format!("    lea rdi, [{}]", str_label));
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_panic@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm.push(format!("{}:", after_panic_label));
            }

            ICNFInner::I32Imm(val) => {
                if operand_ids.contains(&node.id) {
                    return;
                }
                self.emit_const_into("rax", &crate::ast::Atom::Int(*val as i64));
            }

            ICNFInner::StrImm(val) => {
                if operand_ids.contains(&node.id) {
                    return;
                }
                let label = self.emit_string_literal(val);
                self.asm_push_align();
                self.asm.push(format!("    lea rax, [{}]", label));
            }

            ICNFInner::FnPtrImm(name) => {
                if operand_ids.contains(&node.id) {
                    return;
                }
                self.asm_push_align();
                self.asm.push(format!("    lea rax, [{}]  # FnPtrImm", name));
            }

            ICNFInner::Return(val_id) => {
                // Load return value into eax. The function-end epilogue handles pop rbp/ret.
                self.emit_load_into(
                    *val_id, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots,
                );
            }

            ICNFInner::TryCatch { try_body, catch_var, catch_body } => {
                // Panic-handler try/catch: link a handler frame, setjmp, run
                // the body; zyl_panic longjmps back with eax=1 and the catch
                // path binds the message pointer to `catch_var`.
                let tc_label = self.new_label();
                let catch_label = format!(".tc_catch_{}", tc_label);
                let after_label = format!(".tc_after_{}", tc_label);

                let mut tc_local = local_vars.clone();
                // Bind the catch variable to a stack slot up-front so both
                // paths and nested code agree on its location.
                if !tc_local.contains_key(catch_var) {
                    let slot = self.temp_slot_counter;
                    self.temp_slot_counter += 1;
                    tc_local.insert(catch_var.clone(), slot);
                }

                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_try_push@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    mov rdi, rax".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call setjmp@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jne {}", catch_label));

                // Try body — result value in rax at the end.
                for stmt in try_body {
                    self.emit_node(
                        stmt,
                        stmts,
                        &mut tc_local,
                        emitted_ids,
                        operand_ids,
                        lookup,
                        phi_slots,
                    );
                }
                // Preserve the body result across zyl_try_pop (rax is not
                // preserved by the C call).
                self.asm_push_align();
                self.asm.push("    push rax".to_string());
                self.asm_push_align();
                self.asm.push("    sub rsp, 8".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_try_pop@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    add rsp, 8".to_string());
                self.asm_push_align();
                self.asm.push("    pop rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", after_label));

                // Catch path: bind error message pointer, run catch body.
                self.asm_push_align();
                self.asm.push(format!("{}:", catch_label));
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_try_last_msg@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                if let Some(&slot_idx) = tc_local.get(catch_var) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm
                        .push(format!("    mov [rbp-{}], rax", offset));
                }
                for stmt in catch_body {
                    self.emit_node(
                        stmt,
                        stmts,
                        &mut tc_local,
                        emitted_ids,
                        operand_ids,
                        lookup,
                        phi_slots,
                    );
                }
                self.asm_push_align();
                self.asm.push("    push rax".to_string());
                self.asm_push_align();
                self.asm.push("    sub rsp, 8".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_try_pop@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    add rsp, 8".to_string());
                self.asm_push_align();
                self.asm.push("    pop rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("{}:", after_label));
                emitted_ids.insert(node.id);
            }

            ICNFInner::Unit => {
                // No-op in assembly.
            }

            ICNFInner::Closure { name, captures, .. } if captures.is_empty() => {
                // Captureless closure: value = raw code address.
                let fn_name = format!("_ZYL_{}", name);
                self.asm_push_align();
                self.asm.push(format!("    lea rax, [{}]", fn_name));
                emitted_ids.insert(node.id);
            }
            ICNFInner::Closure { name, captures, .. } => {
                // Capturing closure: value = env block pointer
                //   [env+0] = code ptr, [env+8+8i] = capture i.
                let fn_name = format!("_ZYL_{}", name);
                let n = captures.len();
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", 8 * (n + 1)));
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_heap_alloc@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    lea rax, [{}]", fn_name));
                self.asm_push_align();
                self.asm.push("    mov [r10], rax".to_string());
                for (i, cap) in captures.iter().enumerate() {
                    // Captured variables live in this frame's slots — resolve
                    // by name; fall back to on-demand node emission.
                    if let Some(&slot_idx) = local_vars.get(&cap.name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov rax, [rbp-{}]", offset));
                    } else {
                        self.emit_load_into(
                            cap.ssa_id, "rax", stmts, local_vars, lookup, emitted_ids,
                            operand_ids, phi_slots,
                        );
                    }
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", 8 * (i + 1)));
                }
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(node.id);
            }

            ICNFInner::Begin(stmts) => {
                let mut local_vars: HashMap<String, usize> = HashMap::default();
                let mut begin_operand_ids: crate::deterministic::HashSet<usize> = HashSet::default();
                for stmt in stmts.iter() {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => {
                            begin_operand_ids.insert(*l);
                            begin_operand_ids.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            begin_operand_ids.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                begin_operand_ids.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                begin_operand_ids.insert(a);
                            }
                        }
                        _ => {}
                    }
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                }
                // Build lookup from Begin's own stmts.
                let mut begin_lookup: crate::deterministic::HashMap<usize, &ICNFNode> = HashMap::default();
                for n in stmts {
                    begin_lookup.insert(n.id, n);
                }
                for stmt in stmts {
                    self.emit_node(
                        stmt,
                        stmts,
                        &local_vars,
                        emitted_ids,
                        &begin_operand_ids,
                        &crate::deterministic::HashMap::default(),
                        &crate::deterministic::HashMap::default(),
                    );
                }
            }

            ICNFInner::MakeStruct(name, field_ids) => {
                // Allocate heap arena memory for the struct: call zyl_heap_alloc(n * 8), then store each field.
                let _ = name;
                let field_count = field_ids.len();
                let total_size = field_count * 8;

                // FIX: Save field values to the stack before heap alloc, because alloc clobbers eax.
                // Push rbp to mark the boundary (only when needed for 16-byte
                // alignment at the call below — see the MakeVariant case for
                // the same fix and rationale). Push in reverse order so
                // fields pop in correct order.
                let needs_align_pad = field_count % 2 == 1;
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    push rbp".to_string());
                }
                self.asm_push_align();
                for &field_id in field_ids.iter().rev() {
                    // Resolve via the local lookup/statement list first, then
                    // the program-wide node map (fields may live in another
                    // function's or arm's statement list after embedding).
                    let field_node = lookup
                        .get(&field_id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == field_id))
                        .cloned()
                        .or_else(|| self.all_nodes.get(&field_id).cloned());
                    let field_node = field_node.as_ref();
                    match field_node {
                        Some(ICNFNode {
                            node: ICNFInner::Const(atom),
                            ..
                        }) => {
                            match atom {
                                Atom::Int(v) => {
                                    self.asm_push_align();
                                    self.asm.push(format!("    mov rax, {}", v));
                                    self.asm_push_align();
                                    self.asm.push("    push rax".to_string());
                                }
                                Atom::Bool(v) => {
                                    let val = if *v { 1 } else { 0 };
                                    self.asm_push_align();
                                    self.asm.push(format!("    mov rax, {}", val));
                                    self.asm_push_align();
                                    self.asm.push("    push rax".to_string());
                                }
                                _ => {
                                    self.emit_const_into("rax", atom);
                                    self.asm_push_align();
                                    self.asm.push("    push rax".to_string());
                                }
                            }
                        }
                        Some(ICNFNode {
                            node: ICNFInner::Load(lvar),
                            ..
                        }) => {
                            if let Some(&slot_idx) = local_vars.get(lvar) {
                                let slot = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                            } else {
                                let hash = simple_hash(lvar);
                                let slot = ((hash % 32) + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                            }
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        Some(_n) => {
                            self.emit_load_into(field_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        None => {}
                    }
                }

                // Allocate and save the pointer in r10 (callee-saved, survives function calls).
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", total_size));
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_heap_alloc@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string()); // Save struct base pointer in r10.

                // Fields were pushed in reverse (last field first), so popping yields fields in forward order.
                for i in 0..field_count {
                    self.asm_push_align();
                    self.asm.push("    pop rax".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", i * 8));
                }

                // Pop the alignment pad, if one was pushed.
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    pop rbp".to_string());
                }

                // Restore struct pointer to eax as the result.
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(node.id);
            }

            ICNFInner::StructGet(struct_id, field_offset) => {
                self.emit_struct_get_cached(node.id, *struct_id, *field_offset, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
            }

            ICNFInner::MakeVariant { type_name: _, variant_name: _, discriminant, field_ids } => {
                // Tagged union construction: zyl_heap_alloc(sizeof(discriminant + fields)), store discriminant, then fields.
                let field_count = field_ids.len();
                let total_size = (field_count + 1) * 8; // discriminant + fields.

                // Save field values to stack before heap alloc. The call
                // below must land on a 16-byte-aligned rsp per the SysV ABI;
                // an odd number of 8-byte pushes here would misalign it, so
                // pad with one throwaway push only when field_count is odd
                // (an even field_count already keeps the push count even).
                let needs_align_pad = field_count % 2 == 1;
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    push rbp".to_string());
                }
                self.asm_push_align();
                for &field_id in field_ids.iter().rev() {
                    // Resolve via the local lookup/statement list first, then
                    // the program-wide node map (fields may live in another
                    // function's or arm's statement list after embedding).
                    let field_node = lookup
                        .get(&field_id)
                        .copied()
                        .or_else(|| stmts.iter().find(|n| n.id == field_id))
                        .cloned()
                        .or_else(|| self.all_nodes.get(&field_id).cloned());
                    let field_node = field_node.as_ref();
                    match field_node {
                        Some(ICNFNode { node: ICNFInner::Const(atom), .. }) => {
                            // A Const whose atom is an Ident is a variable
                            // reference (ICNF encodes idents this way): load
                            // from its local slot, never emit a literal 0.
                            if let Atom::Ident(lvar) = atom {
                                if let Some(&slot_idx) = local_vars.get(lvar) {
                                    let slot = (slot_idx + 1) * 8;
                                    self.asm_push_align();
                                    self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                                    self.asm_push_align();
                                    self.asm.push("    push rax".to_string());
                                    continue;
                                }
                            }
                            self.emit_const_into("rax", atom);
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        Some(ICNFNode { node: ICNFInner::Load(lvar), .. }) => {
                            if let Some(&slot_idx) = local_vars.get(lvar) {
                                let slot = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", slot));
                            } else {
                                // P1: never fabricate a zero for an unresolvable
                                // variable reference in a variant field.
                                self.fatal_errors.push(format!(
                                    "MakeVariant field load of `{}` (field ssa {}) has no local slot",
                                    lvar, field_id
                                ));
                                self.asm_push_align();
                                self.asm.push("    mov rax, 0".to_string());
                            }
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        Some(_n) => {
                            self.emit_load_into(field_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        None => {
                            // P1: a field id that resolves to no node at all is
                            // an ICNF integrity failure, not something to paper
                            // over with whatever happens to be in rax.
                            self.fatal_errors.push(format!(
                                "MakeVariant field ssa {} not found in lookup or statement list",
                                field_id
                            ));
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                    }
                }

                // Allocate memory.
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", total_size));
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_heap_alloc@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string());

                // Store discriminant at offset 0.
                self.asm_push_align();
                self.asm.push(format!("    mov eax, {}", discriminant));
                self.asm_push_align();
                self.asm.push("    mov [r10], eax".to_string());

                // Store fields (popped in correct order).
                for i in 0..field_count {
                    self.asm_push_align();
                    self.asm.push("    pop rax".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", (i + 1) * 8));
                }

                // Pop the alignment pad, if one was pushed.
                if needs_align_pad {
                    self.asm_push_align();
                    self.asm.push("    pop rbp".to_string());
                }

                // Result: struct pointer in rax.
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(node.id);
            }

            ICNFInner::Match { scrutinee_ssa, type_name, arms, result_var } => {
                self.emit_match_inline(
                    node,
                    *scrutinee_ssa,
                    type_name,
                    arms,
                    result_var,
                    stmts,
                    local_vars,
                    lookup,
                    emitted_ids,
                    operand_ids,
                    phi_slots,
                );
            }

            ICNFInner::FfiCall { name, args, timeout } => {
                self.emit_ffi_call_direct(
                    name,
                    args,
                    *timeout,
                    "rax",
                    stmts,
                    local_vars,
                    lookup,
                    emitted_ids,
                    operand_ids,
                    phi_slots,
                    node.id,
                );
            }

            ICNFInner::Spawn(closure_id) => {
                // Look up closure metadata (name + captures) from the closures map.
                if let Some((name, captures)) = self.closures.get(closure_id) {
                    let name = name.clone();
                    let captures = captures.clone();
                    // Allocate and populate environment struct for captures.
                    let env_size = captures.len() * 8;
                    let mut env_ptr_in_rsi = false;

                    if env_size > 0 {
                        // Allocate env struct from heap arena -> rax = env pointer
                        self.asm_push_align();
                        self.asm.push(format!("    mov edi, {}", env_size));
                        self.asm_push_align();
                        self.asm.push("    mov r15, rsp".to_string());
                        self.asm.push("    and rsp, -16".to_string());
                        self.asm.push("    call zyl_heap_alloc@plt".to_string());
                        self.asm.push("    mov rsp, r15".to_string());

                        // Copy captured values into env struct.
                        // Save env ptr in r10 once (before the loop) so it isn't overwritten.
                        self.asm_push_align();
                        self.asm.push("    mov r10, rax".to_string());
                        for (i, cap) in captures.iter().enumerate() {
                            let offset = i * 8;
                            // Load captured value from [rbp - slot_offset] into rax
                            if let Some(&slot) = local_vars.get(&cap.name) {
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp - {}]", (slot + 1) * 8));
                            } else {
                                // Variable not in local_vars — it may be in a register from a previous emit.
                                // Try to find it in operand_ids to re-emit.
                                if operand_ids.contains(&cap.ssa_id) {
                                    // Re-emit the node to get value into rax
                                    let cap_node = lookup.get(&cap.ssa_id).copied()
                                        .or_else(|| stmts.iter().find(|n| n.id == cap.ssa_id));
                                    if let Some(cn) = cap_node {
                                        self.emit_node(cn, stmts, local_vars, emitted_ids, operand_ids, lookup, phi_slots);
                                    }
                                }
                            }
                            // Store into [r10 + offset]
                            self.asm_push_align();
                            self.asm.push(format!("    mov [r10 + {}], rax", offset));
                        }
                        // Result: env ptr is in r10
                        // Move to rsi for spawn call
                        self.asm_push_align();
                        self.asm.push("    mov rsi, r10".to_string());
                        env_ptr_in_rsi = true;
                    }

                     if name.is_empty() || name == "fn_" {
                        // Anonymous lambda — generate a unique wrapper function.
                        let wrapper_name = format!("_ZYL_actor_{}", self.spawn_counter);
                        self.spawn_counter += 1;

                        // Buffer the wrapper as a standalone function (not inline).
                        let wrapper_stack = 256 + captures.len() * 8;
                        let start_len = self.asm.len();
                        self.asm_push_align();
                        self.asm.push(format!("{}:", wrapper_name));
                        self.asm_push_align();
                        self.asm.push("    push rbp".to_string());
                        self.asm_push_align();
                        self.asm.push("    mov rbp, rsp".to_string());
                        self.asm_push_align();
                        self.asm.push(format!("    sub rsp, {}", wrapper_stack));

                         // Load captured values from env struct (rsi) into stack slots.
                        // Build a wrapper-local variable map so captured vars use consistent
                        // offsets between the capture-loading code and the body's Load nodes.
                        // The Load handler uses (slot + 1) * 8, so we store using the same.
                        let mut wrapper_local_vars: crate::deterministic::HashMap<String, usize> =
                            crate::deterministic::HashMap::default();
                        for (i, cap) in captures.iter().enumerate() {
                            let offset = i * 8;
                            let wslot = i; // slot index; actual offset = (wslot+1)*8
                            wrapper_local_vars.insert(cap.name.clone(), wslot);
                            // The thread entry passes state in rdi (first arg), not rsi.
                            self.asm_push_align();
                            self.asm.push(format!("    mov rax, [rdi + {}]", offset));
                            self.asm_push_align();
                            self.asm.push(format!("    mov [rbp - {}], rax", (wslot + 1) * 8));
                        }

                        // Emit the closure body statements from closure_bodies.
                        let body_clone = self.closure_bodies.get(closure_id).cloned();
                        if let Some(ref body_stmts) = body_clone {
                            for stmt in body_stmts {
                                self.emit_node(
                                    stmt,
                                    body_stmts,
                                    &wrapper_local_vars,
                                    emitted_ids,
                                    operand_ids,
                                    lookup,
                                    phi_slots,
                                );
                            }
                        }

                        // Epilogue: restore stack + return.
                        self.asm_push_align();
                        self.asm.push("    mov rsp, rbp".to_string());
                        self.asm_push_align();
                        self.asm.push("    pop rbp".to_string());
                        self.asm_push_align();
                        self.asm.push("    ret".to_string());

                        // Extract buffered wrapper lines and store for later emission.
                        let wrapper_lines: Vec<String> = self.asm[start_len..].to_vec();
                        self.asm.truncate(start_len);
                        self.spawn_wrappers.extend(wrapper_lines);

                        // Load the wrapper address into rdi.
                        self.asm_push_align();
                        self.asm.push(format!("    lea rdi, [rip+{}]", wrapper_name));
                    } else {
                        // Named closure — load the function address.
                        self.asm_push_align();
                        self.asm.push(format!("    lea rdi, [rip+_ZYL_{}]", name));
                    }

                        // rsi already has env ptr if captures > 0, else set to 0.
                        if !env_ptr_in_rsi {
                        self.asm_push_align();
                        self.asm.push("    xor rsi, rsi".to_string());
                    }

                    // Call zyl_actor_spawn(entry, state) -> returns actor_id in rax.
                    self.asm_push_align();
                    self.asm.push("    mov r15, rsp".to_string());
                    self.asm.push("    and rsp, -16".to_string());
                    self.asm.push("    call zyl_actor_spawn@plt".to_string());
                    self.asm.push("    mov rsp, r15".to_string());
                } else {
                    // Unknown closure — emit a stub.
                    self.asm_push_align();
                    self.asm.push("    xor rax, rax".to_string());
                    self.asm_push_align();
                    self.asm.push("    mov r15, rsp".to_string());
                    self.asm.push("    and rsp, -16".to_string());
                    self.asm.push("    call zyl_actor_spawn@plt".to_string());
                    self.asm.push("    mov rsp, r15".to_string());
                }
                emitted_ids.insert(node.id);
            }

            ICNFInner::Send(actor_id, msg_id) => {
                // Ensure actor_id node is emitted (so its value is in eax).
                let actor_node = lookup
                    .get(actor_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == *actor_id));
                if let Some(actor_n) = actor_node {
                    self.emit_node(
                        actor_n,
                        stmts,
                        local_vars,
                        emitted_ids,
                        operand_ids,
                        lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(*actor_id);
                }

                // Load actor_id (in eax) into rdi, and preserve in r12 (callee-saved)
                // since the msg emit below may clobber caller-saved registers.
                self.asm_push_align();
                self.asm.push("    mov rdi, rax".to_string());
                self.asm_push_align();
                self.asm.push("    mov r12, rax".to_string());

                // Ensure msg_id is emitted.
                let msg_node = lookup
                    .get(msg_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == *msg_id));
                if let Some(msg_n) = msg_node {
                    self.emit_node(
                        msg_n,
                        stmts,
                        local_vars,
                        emitted_ids,
                        operand_ids,
                        lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(*msg_id);
                }

                // Load msg (in rax — pointer) into rsi.
                self.asm_push_align();
                self.asm.push("    mov rsi, rax".to_string());

                // Call zyl_actor_send(actor_id, msg).
                self.asm_push_align();
                self.asm.push("    mov rdi, r12".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_actor_send@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());

                // Return Unit (eax = 0).
                self.asm_push_align();
                self.asm.push("    xor eax, eax".to_string());

                emitted_ids.insert(node.id);
            }

            ICNFInner::SendClosure(actor_id, closure_name, handler_name, capture_ids) => {
                // Emit the closure wrapper function: void (closure_name)(void* state).
                // The actor runtime invokes it as fn(state); state holds the captured
                // values (msg + captures) that this wrapper forwards to the handler.
                // Buffered as a standalone function (not inline).
                if !handler_name.is_empty() {
                    let start_len = self.asm.len();
                    self.asm_push_align();
                    self.asm.push(format!("{}:", closure_name));
                    self.asm_push_align();
                    self.asm.push("    push rbp".to_string());
                    self.asm_push_align();
                    self.asm.push("    mov rbp, rsp".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    sub rsp, {}", 256 + capture_ids.len() * 8));
                    // Load captured values from state (rdi) into stack slots.
                    let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
                    for i in 0..capture_ids.len().min(6) {
                        let offset = i * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rdi + {}]", offset));
                        self.asm_push_align();
                        self.asm.push(format!("    mov [rbp - {}], rax", (i + 1) * 8));
                    }
                    // Load captures as handler args.
                    for i in 0..capture_ids.len().min(6) {
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, [rbp - {}]", abi_regs_64[i], (i + 1) * 8));
                    }
                    // Call the handler with the forwarded args.
                    self.asm_push_align();
                    self.asm.push(format!("    call _ZYL_{}", handler_name));
                    // Epilogue.
                    self.asm_push_align();
                    self.asm.push("    mov rsp, rbp".to_string());
                    self.asm_push_align();
                    self.asm.push("    pop rbp".to_string());
                    self.asm_push_align();
                    self.asm.push("    ret".to_string());
                    let wrapper_lines: Vec<String> = self.asm[start_len..].to_vec();
                    self.asm.truncate(start_len);
                    self.spawn_wrappers.extend(wrapper_lines);
                }

                // Emit actor_id node → value in eax.
                let actor_node = lookup
                    .get(actor_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == *actor_id));
                if let Some(actor_n) = actor_node {
                    self.emit_node(
                        actor_n,
                        stmts,
                        local_vars,
                        emitted_ids,
                        operand_ids,
                        lookup,
                        phi_slots,
                    );
                    emitted_ids.insert(*actor_id);
                }

                // Load actor_id (in eax) into rdi, and preserve it in r12
                // (callee-saved) since the arena alloc + capture loop below clobbers rdi.
                self.asm_push_align();
                self.asm.push("    mov rdi, rax".to_string());
                self.asm_push_align();
                self.asm.push("    mov r12, rax".to_string());

                // Load closure function pointer into rsi, preserve in r13.
                self.asm_push_align();
                self.asm.push(format!("    lea rsi, [rip+{}]@PLT", closure_name));
                self.asm_push_align();
                self.asm.push("    mov r13, rsi".to_string());

                // Allocate capture state struct on heap arena.
                let state_size = capture_ids.len() * 8;
                if state_size > 0 {
                    self.asm_push_align();
                    self.asm.push(format!("    mov edi, {}", state_size));
                    self.asm_push_align();
                    self.asm.push("    mov r15, rsp".to_string());
                    self.asm.push("    and rsp, -16".to_string());
                    self.asm.push("    call zyl_heap_alloc@plt".to_string());
                    self.asm.push("    mov rsp, r15".to_string());
                    // Save state ptr in r10.
                    self.asm_push_align();
                    self.asm.push("    mov r10, rax".to_string());

                    // Copy each captured value into the state struct.
                    for (i, cap_id) in capture_ids.iter().enumerate() {
                        let offset = i * 8;
                        // Load the capture's value into rax (handles Const/Load/Assign/Call).
                        self.emit_load_into(
                            *cap_id,
                            "rax",
                            stmts,
                            local_vars,
                            lookup,
                            emitted_ids,
                            operand_ids,
                            phi_slots,
                        );
                        // Store into [r10 + offset].
                        self.asm_push_align();
                        self.asm.push(format!("    mov [r10 + {}], rax", offset));
                    }
                    // State ptr is now in r10.
                    self.asm_push_align();
                    self.asm.push("    mov rdx, r10".to_string());
                } else {
                    // No captures — pass NULL as state.
                    self.asm_push_align();
                    self.asm.push("    xor rdx, rdx".to_string());
                }

                // Call zyl_actor_send_closure(actor_id, fn_ptr, state_ptr).
                self.asm_push_align();
                self.asm.push("    mov rdi, r12".to_string());
                self.asm_push_align();
                self.asm.push("    mov rsi, r13".to_string());
                self.asm_push_align();
                self.asm.push("    mov r15, rsp".to_string());
                self.asm.push("    and rsp, -16".to_string());
                self.asm.push("    call zyl_actor_send_closure@plt".to_string());
                self.asm.push("    mov rsp, r15".to_string());

                // Return Unit (eax = 0).
                self.asm_push_align();
                self.asm.push("    xor eax, eax".to_string());

                emitted_ids.insert(node.id);
            }

            _ => {
                // Unsupported/unimplemented nodes — emit a nop placeholder.
                self.asm_push_align();
                self.asm.push("    nop  # unimplemented".to_string());
            }
        }
    }

    /// Emit a float constant or load into an XMM register.
    #[expect(clippy::too_many_arguments)]
    #[expect(clippy::only_used_in_recursion)]
    fn emit_float_load_into(
        &mut self,
        id: usize,
        xmm_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &crate::deterministic::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut crate::deterministic::HashSet<usize>,
        operand_ids: &crate::deterministic::HashSet<usize>,
    ) {
        // Check if already emitted — but allow re-emission for BinOp/UnOp/Load
        // since xmm0 may have been clobbered by intervening calls (e.g., printf).
        if emitted_ids.contains(&id) {
            let node = lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id));
            if let Some(ICNFNode { node: ICNFInner::BinOp(_, _, _) | ICNFInner::UnOp(_, _) | ICNFInner::Load(_), .. }) = node {
                // Re-emit BinOp/UnOp/Load since xmm0/xmm1/xmm2 may be stale.
            } else {
                return;
            }
        }

        let node = lookup
            .get(&id)
            .copied()
            .or_else(|| stmts.iter().find(|n| n.id == id));

        if let Some(node) = node {
            match &node.node {
                ICNFInner::Const(Atom::Float(v)) => {
                    let float_label = format!(".flt_{}", v.to_bits());
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, [{}]", xmm_reg, float_label));
                }
                ICNFInner::Load(name) => {
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        // Load 8 bytes from stack into integer reg, then move to XMM.
                        let tmp_reg = "rax";
                        self.asm
                            .push(format!("    mov {}, [rbp-{}]", tmp_reg, offset));
                        self.asm
                            .push(format!("    movq {}, {}", xmm_reg, tmp_reg));
                    } else {
                        // Fallback: zero the XMM register.
                        self.asm_push_align();
                        self.asm
                            .push(format!("    pxor {}, {}", xmm_reg, xmm_reg));
                    }
                }
                ICNFInner::BinOp(op, left_id, right_id) => {
                    // If this BinOp was already emitted by the main loop,
                    // don't rely on xmm0 (it may have been clobbered by intervening calls).
                    // Always re-emit the operation to ensure correct values.
                    // Emit the sub-operation first (left operand into xmm1, right into xmm2),
                    // then apply the operation and copy result to target xmm_reg.
                    let xmm1 = format!("xmm{}", self.alloc_xmm());
                    let xmm2 = format!("xmm{}", self.alloc_xmm());
                    let xmm_tmp = format!("xmm{}", self.alloc_xmm());

                    self.emit_float_load_into(
                        *left_id, &xmm1, stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );
                    self.emit_float_load_into(
                        *right_id, &xmm2, stmts, local_vars, lookup, emitted_ids, operand_ids,
                    );
                    emitted_ids.insert(*left_id);
                    emitted_ids.insert(*right_id);

                    match op {
                        BinOpKind::Add => {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    movsd {}, {}", xmm_tmp, xmm1));
                            self.asm_push_align();
                            self.asm
                                .push(format!("    addsd {}, {}", xmm_tmp, xmm2));
                        }
                        BinOpKind::Sub => {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    movsd {}, {}", xmm_tmp, xmm1));
                            self.asm_push_align();
                            self.asm
                                .push(format!("    subsd {}, {}", xmm_tmp, xmm2));
                        }
                        BinOpKind::Mul => {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    movsd {}, {}", xmm_tmp, xmm1));
                            self.asm_push_align();
                            self.asm
                                .push(format!("    mulsd {}, {}", xmm_tmp, xmm2));
                        }
                        BinOpKind::Div => {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    movsd {}, {}", xmm_tmp, xmm1));
                            self.asm_push_align();
                            self.asm
                                .push(format!("    divsd {}, {}", xmm_tmp, xmm2));
                        }
                        _ => {
                            // Fallback: unsupported float op — zero the register.
                            self.asm_push_align();
                            self.asm
                                .push(format!("    pxor {}, {}", xmm_tmp, xmm_tmp));
                        }
                    }

                    // Copy result to target register.
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, {}", xmm_reg, xmm_tmp));
                }
                ICNFInner::UnOp(op, arg_id) => {
                    // Re-emit the float unary op; its result lands in rax as
                    // a bit pattern under the GPR convention.
                    self.emit_unop_direct(
                        op, *arg_id, "rax", stmts, local_vars, lookup, emitted_ids,
                        id, true,
                    );
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movq {}, rax", xmm_reg));
                }
                ICNFInner::Call(name, args) => {
                    // Float-valued call under the GPR bit-pattern convention:
                    // emit the call normally (result bits in rax) and move
                    // the pattern into the target XMM register.
                    self.emit_call_direct(
                        name,
                        args,
                        "rax",
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        id,
                        false,
                    );
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movq {}, rax", xmm_reg));
                }
                _ => {
                    // Fallback: zero the XMM register.
                    self.asm_push_align();
                    self.asm
                        .push(format!("    pxor {}, {}", xmm_reg, xmm_reg));
                }
            }
        } else {
            // ID not found — zero the register.
            self.asm_push_align();
            self.asm
                .push(format!("    pxor {}, {}", xmm_reg, xmm_reg));
        }

        emitted_ids.insert(id);
    }

    /// Emit compare-and-set instruction for comparison operators.
    fn emit_cmp_and_set(
        &mut self,
        op: &BinOpKind,
        src1_reg: &str, // first operand (already loaded)
        src2_reg: &str, // second operand (already loaded)
        dest_reg: &str, // destination for result (0 or 1).
    ) {
        let (set_instr, _comment) = match op {
            BinOpKind::Eq => ("sete", "equal"),
            BinOpKind::Neq => ("setne", "not equal"),
            BinOpKind::Lt => ("setl", "signed less"),
            BinOpKind::Gt => ("setg", "signed greater"),
            BinOpKind::Le => ("setle", "less or equal"),
            BinOpKind::Ge => ("setge", "greater or equal"),
            _ => unreachable!("compare op: {:?}", op),
        };

        // Compare two registers and set destination to 0 or 1 based on condition.
        self.asm_push_align();
        self.asm.push(format!("    cmp {}, {}", src1_reg, src2_reg));
        // Zero-extend the result byte into full register (e.g., al → eax).
        match op {
            BinOpKind::Eq
            | BinOpKind::Neq
            | BinOpKind::Lt
            | BinOpKind::Gt
            | BinOpKind::Le
            | BinOpKind::Ge => {
                self.asm_push_align();
                self.asm.push(
                    format!("    {} al", set_instr), // Sets al.
                );
                let dest_full = reg_to_32(dest_reg);
                self.asm_push_align();
                self.asm.push(format!("    movzx {}, al", dest_full));
            }
            _ => {}
        }

        let _ = _comment; // For debugging comments if needed later.
    }

    /// Generate a unique label name (e.g., .L0, .L1).
    fn new_label(&mut self) -> String {
        let label = format!(".L{}", self.label_counter);
        self.label_counter += 1;
        label
    }

    /// Allocate an x86_64 general-purpose register for storing a value.
    /// Uses round-robin among caller-saved registers (System V ABI).
    fn alloc_reg(&self) -> &'static str {
        // Caller-saved integer registers: rax, rcx, rdx, rsi, rdi, r8-r15 (64-bit names).
        static REGS: &[&str] = &["rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9"];
        let idx = self.label_counter % REGS.len();
        REGS[idx]
    }

    /// Allocate a 64-bit x86_64 general-purpose register.
    fn alloc_reg_64(&self) -> &'static str {
        // Caller-saved integer registers (64-bit names).
        static REGS: &[&str] = &["rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9"];
        let idx = self.label_counter % REGS.len();
        REGS[idx]
    }

    /// Allocate an SSE/XMM register for floating-point values.
    fn alloc_xmm(&mut self) -> usize {
        let idx = self.xmm_counter % 8;
        self.xmm_counter += 1;
        idx
    }
}

// ─── Helpers ──────────────────────────────────────────────────────────────


/// Find the phi slot offset for an If result variable in local_vars.
/// Returns the stack offset string (e.g., "24") if found, None otherwise.
#[allow(dead_code)]
fn find_phi_slot(
    _stmts: &[ICNFNode],
    result_var: &str,
    local_vars: &HashMap<String, usize>,
) -> Option<String> {
    if let Some(&slot) = local_vars.get(result_var) {
        return Some(((slot + 1) * 8).to_string());
    }
    None
}

/// Collect operand SSA IDs referenced by an If condition node tree. The cond node
/// (a BinOp/UnOp, possibly nested) lives in the function body; its operand Loads
/// must be treated as operand-supply nodes so the emit loop skips them instead of
/// clobbering the value a preceding If left in eax.
fn collect_cond_operand_ids(cond_id: usize, stmts: &[ICNFNode], out: &mut HashSet<usize>) {
    if let Some(node) = stmts.iter().find(|n| n.id == cond_id) {
        match &node.node {
            ICNFInner::BinOp(_, l, r) => {
                out.insert(*l);
                out.insert(*r);
                collect_cond_operand_ids(*l, stmts, out);
                collect_cond_operand_ids(*r, stmts, out);
            }
            ICNFInner::UnOp(_, id) => {
                out.insert(*id);
                collect_cond_operand_ids(*id, stmts, out);
            }
            ICNFInner::Call(_, args) => {
                for &a in args {
                    out.insert(a);
                }
            }
            _ => {}
        }
    }
}

/// Collect all operand SSA IDs from a branch body (then/else bodies of If, body of While/For).
fn collect_body_operand_ids(body: &[ICNFNode], out: &mut HashSet<usize>) {
    for node in body {
        match &node.node {
            ICNFInner::BinOp(_, l, r) => {
                out.insert(*l);
                out.insert(*r);
            }
            ICNFInner::UnOp(_, id) => {
                out.insert(*id);
            }
            ICNFInner::Call(_, args) => {
                for &a in args {
                    out.insert(a);
                }
            }
            ICNFInner::FfiCall { args, .. } => {
                for &a in args {
                    out.insert(a);
                }
            }
            ICNFInner::Print(args) => {
                for &a in args {
                    out.insert(a);
                }
            }
            ICNFInner::StructGet(struct_id, _) => {
                out.insert(*struct_id);
            }
            ICNFInner::MakeStruct(_, field_ids) => {
                for &f in field_ids {
                    out.insert(f);
                }
            }
            ICNFInner::MakeVariant { field_ids, .. } => {
                for &f in field_ids {
                    out.insert(f);
                }
            }
            ICNFInner::FileOpen { path, mode } => {
                out.insert(*path);
                out.insert(*mode);
            }
            ICNFInner::FileRead { handle, count } => {
                out.insert(*handle);
                out.insert(*count);
            }
            ICNFInner::FileWrite { handle, data } => {
                out.insert(*handle);
                out.insert(*data);
            }
            ICNFInner::BufAppend { dst, src } => {
                out.insert(*dst);
                out.insert(*src);
            }
            ICNFInner::FileClose(handle) => {
                out.insert(*handle);
            }
            ICNFInner::ReadLine => {}
            ICNFInner::If {
                cond_ssa,
                then_body,
                else_body,
                ..
            } => {
                out.insert(*cond_ssa);
                collect_body_operand_ids(then_body, out);
                collect_body_operand_ids(else_body, out);
            }
            ICNFInner::While { cond_body, body, .. } => {
                for node in cond_body {
                    match &node.node {
                        ICNFInner::BinOp(_, l, r) => {
                            out.insert(*l);
                            out.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            out.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        _ => {}
                    }
                }
                collect_body_operand_ids(body, out);
            }
            ICNFInner::For { init_bindings, cond_nodes, body, result_var: _ } => {
                for (_, init_id) in init_bindings {
                    if let Some(id) = init_id {
                        out.insert(*id);
                    }
                }
                for n in cond_nodes {
                    match &n.node {
                        ICNFInner::BinOp(_, l, r) => {
                            out.insert(*l);
                            out.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            out.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        _ => {}
                    }
                }
                collect_body_operand_ids(body, out);
            }
            ICNFInner::Begin(stmts) => {
                for s in stmts {
                    match &s.node {
                        ICNFInner::BinOp(_, l, r) => {
                            out.insert(*l);
                            out.insert(*r);
                        }
                        ICNFInner::UnOp(_, id) => {
                            out.insert(*id);
                        }
                        ICNFInner::Call(_, args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        ICNFInner::Print(args) => {
                            for &a in args {
                                out.insert(a);
                            }
                        }
                        _ => {}
                    }
                }
            }
            _ => {}
        }
    }
}

/// Simple hash function for variable name → stack offset mapping.
fn simple_hash(name: &str) -> u64 {
    let mut hash: u64 = 5381;
    for c in name.bytes() {
        hash = hash.wrapping_mul(31).wrapping_add(c as u64);
    }
    hash
}

/// Sanitize a function/variable name for the assembly symbol namespace.
/// Collect ids of self-calls in TRUE tail position: walk down the final
/// statement chain — an If/Match whose node is last passes tail status into
/// its branches/arms; anything else terminates the walk.
fn collect_tail_calls(
    node: &ICNFInner,
    id: usize,
    func_name: &str,
    out: &mut crate::deterministic::HashSet<usize>,
) {
    match node {
        // Only SELF-calls qualify: sibling TCO causes systematic
        // double-emission of symbols in deep mutual-recursion chains.
        ICNFInner::Call(name, _) if name == func_name => {
            out.insert(id);
        }
        ICNFInner::If { then_body, else_body, .. } => {
            if let Some(t) = then_body.last() {
                collect_tail_calls(&t.node, t.id, func_name, out);
            }
            if let Some(e) = else_body.last() {
                collect_tail_calls(&e.node, e.id, func_name, out);
            }
        }
        // NOTE: Match arms are intentionally NOT descended into: the match
        // protocol stores each arm's result to [rsp] and jumps to the join
        // label AFTER the arm body — a tail call there would skip both,
        // corrupting control flow (this bit us during stage2).
        _ => {}
    }
}

fn sanitize_name(name: &str) -> String {
    name.chars()
        .map(|c| match c {
            'a'..='z' | 'A'..='Z' | '0'..='9' | '_' => c,
            _ => '_',
        })
        .collect()
}

/// Extract the original closure name from a unique closure name.
/// Unique names follow patterns: `base_XXXX` or `base_fn_XXXX` where XXXX is hex SSA ID.
/// Returns the base name (without the `_XXXX` suffix).
fn closure_original_name(unique: &str) -> Option<String> {
    // Pattern: `base_fn_XXXX` — explicit named closure
    if let Some(pos) = unique.rfind('_') {
        let suffix = &unique[pos + 1..];
        if suffix.len() == 4 && suffix.chars().all(|c| c.is_ascii_hexdigit()) {
            let base = &unique[..pos];
            // Pattern `base_fn_XXXX`
            if let Some(fn_pos) = base.rfind("_fn_") {
                return Some(base[..fn_pos].to_string());
            }
            // Pattern `base_XXXX` (let_binding_name or anonymous)
            if !base.starts_with("fn_") || base.len() > 3 {
                return Some(base.to_string());
            }
        }
    }
    None
}

/// Recursively collect names of functions referenced by an ICNF node: direct
/// calls, function references (`Const(Ident)`), send-closure handlers, named
/// closures, and spawn-closure targets (resolved against `enclosing` stmts).
/// Also walks closure bodies stored in `closure_bodies`. Names are in the
/// sanitized function namespace.
fn collect_func_refs(
    node: &ICNFNode,
    enclosing: &[ICNFNode],
    closure_bodies: &IndexMap<usize, Vec<ICNFNode>>,
    out: &mut Vec<String>,
) {
    match &node.node {
        ICNFInner::Call(name, _) => out.push(name.clone()),
        ICNFInner::Const(crate::ast::Atom::Ident(name)) => out.push(name.clone()),
        ICNFInner::SendClosure(_, _, handler_name, _) => {
            if !handler_name.is_empty() {
                out.push(handler_name.clone());
            }
        }
        ICNFInner::Closure { name, .. } => out.push(name.clone()),
        ICNFInner::Spawn(id) => {
            if let Some(op) = enclosing.iter().find(|n| n.id == *id) {
                if let ICNFInner::Closure { name, .. } = &op.node {
                    out.push(name.clone());
                }
            }
        }
        ICNFInner::If { then_body, else_body, .. } => {
            for n in then_body.iter().chain(else_body.iter()) {
                collect_func_refs(n, enclosing, closure_bodies, out);
            }
        }
        ICNFInner::While { cond_body, body, .. } => {
            for n in cond_body.iter().chain(body.iter()) {
                collect_func_refs(n, enclosing, closure_bodies, out);
            }
        }
        ICNFInner::For { cond_nodes, body, .. } => {
            for n in cond_nodes.iter().chain(body.iter()) {
                collect_func_refs(n, enclosing, closure_bodies, out);
            }
        }
        ICNFInner::Begin(stmts) => {
            for s in stmts {
                collect_func_refs(s, enclosing, closure_bodies, out);
            }
        }
        ICNFInner::Match { arms, .. } => {
            for arm in arms {
                for n in &arm.body {
                    collect_func_refs(n, enclosing, closure_bodies, out);
                }
            }
        }
        ICNFInner::TryCatch { try_body, catch_body, .. } => {
            for n in try_body.iter().chain(catch_body.iter()) {
                collect_func_refs(n, enclosing, closure_bodies, out);
            }
        }
        _ => {}
    }
    // Walk this closure's own body (keyed by the closure node's SSA id).
    if matches!(node.node, ICNFInner::Closure { .. }) {
        if let Some(body) = closure_bodies.get(&node.id) {
            for n in body {
                collect_func_refs(n, body, closure_bodies, out);
            }
        }
    }
}

/// Recursively collect all `Call` callee names from an ICNF node and its
/// embedded bodies. Used to structurally identify function-typed variables
/// (any callee that is not a known function must be an indirect function value).
fn collect_call_names(
    node: &ICNFNode,
    closure_bodies: &IndexMap<usize, Vec<ICNFNode>>,
    out: &mut HashSet<String>,
) {
    match &node.node {
        ICNFInner::Call(name, _) => {
            out.insert(name.clone());
        }
        ICNFInner::If { then_body, else_body, .. } => {
            for n in then_body.iter().chain(else_body.iter()) {
                collect_call_names(n, closure_bodies, out);
            }
        }
        ICNFInner::While { cond_body, body, .. } => {
            for n in cond_body.iter().chain(body.iter()) {
                collect_call_names(n, closure_bodies, out);
            }
        }
        ICNFInner::For { cond_nodes, body, .. } => {
            for n in cond_nodes.iter().chain(body.iter()) {
                collect_call_names(n, closure_bodies, out);
            }
        }
        ICNFInner::Begin(stmts) => {
            for s in stmts {
                collect_call_names(s, closure_bodies, out);
            }
        }
        ICNFInner::Match { arms, .. } => {
            for arm in arms {
                for n in &arm.body {
                    collect_call_names(n, closure_bodies, out);
                }
            }
        }
        ICNFInner::TryCatch { try_body, catch_body, .. } => {
            for n in try_body.iter().chain(catch_body.iter()) {
                collect_call_names(n, closure_bodies, out);
            }
        }
        _ => {}
    }
    if matches!(node.node, ICNFInner::Closure { .. }) {
        if let Some(body) = closure_bodies.get(&node.id) {
            for n in body {
                collect_call_names(n, closure_bodies, out);
            }
        }
    }
}

/// Compute the set of functions reachable from the top-level statements and the
    /// handlers, and closure bodies. Functions outside this set are dead and can be
    /// omitted to avoid emitting bodies with undefined-symbol references.
fn reachable_functions(program: &ICNFProgram) -> HashSet<String> {
    let mut reachable: HashSet<String> = HashSet::default();
    let mut worklist: Vec<String> = Vec::new();
    for stmt in &program.statements {
        collect_func_refs(stmt, &program.statements, &program.closure_bodies, &mut worklist);
    }
    if program.functions.iter().any(|f| f.name == "main") {
        worklist.push("main".to_string());
    }
    // Test functions are referenced only via FnPtrImm (untracked by this
    // analysis), so seed them explicitly to keep their callees alive.
    for f in &program.functions {
        if f.name.starts_with("_test_") {
            worklist.push(f.name.clone());
        }
    }
    while let Some(name) = worklist.pop() {
        if !reachable.insert(name.clone()) {
            continue;
        }
        if let Some(func) = program.functions.iter().find(|f| f.name == name) {
            for stmt in &func.body {
                collect_func_refs(stmt, &func.body, &program.closure_bodies, &mut worklist);
            }
        } else {
        }
    }
    reachable
}

/// Convert f64 to its IEEE-754 bit representation.
#[allow(dead_code)]
fn f64_to_bits(v: f64) -> u64 {
    v.to_bits()
}

/// x86_64 general-purpose registers (caller-saved per System V ABI, 64-bit names).
#[allow(dead_code)]
const X86_REGISTERS: &[&str] = &["rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9"];

/// Convert a register name to its 32-bit counterpart.
fn reg_to_32(name: &str) -> &str {
    match name {
        // 32-bit names pass through.
        "eax" => "eax",
        "ecx" => "ecx",
        "edx" => "edx",
        "esi" => "esi",
        "edi" => "edi",
        "r8d" => "r8d",
        "r9d" => "r9d",
        // 64-bit to 32-bit.
        "rax" => "eax",
        "rcx" => "ecx",
        "rdx" => "edx",
        "rsi" => "esi",
        "rdi" => "edi",
        "r8" => "r8d",
        "r9" => "r9d",
        "r10" => "r10d",
        "r11" => "r11d",
        "r12" => "r12d",
        "r13" => "r13d",
        "r14" => "r14d",
        "r15" => "r15d",
        _ => name,
    }
}

/// Convert a register name to its 64-bit counterpart.
fn reg_to_64(name: &str) -> &str {
    match name {
        "eax" => "rax",
        "ecx" => "rcx",
        "edx" => "rdx",
        "esi" => "rsi",
        "edi" => "rdi",
        "r8d" => "r8",
        "r9d" => "r9",
        "rax" => "rax",
        "rcx" => "rcx",
        "rdx" => "rdx",
        "rsi" => "rsi",
        "rdi" => "rdi",
        "r8" => "r8",
        "r9" => "r9",
        "r10" => "r10",
        "r11" => "r11",
        "r12" => "r12",
        "r13" => "r13",
        "r14" => "r14",
        "r15" => "r15",
        _ => name,
    }
}
