use crate::ast::Atom;
use crate::icnf::*;
use crate::region_inference::Region;
use crate::type_system::{PrimType, Type};
use std::collections::{HashMap, HashSet};

// ─── x86_64 Code Generation (spec §22 — Phase 9) ──────────────────────
/// Generates Linux x86_64 System V ABI assembly from optimized ICNF.
/// Uses a linear-scan register allocator over SSA values within each function body.

/// Struct field layout: struct name → [(field_name, byte_offset)].
/// All fields are 8 bytes (64-bit aligned) in the MVP.
pub type StructLayout = HashMap<String, Vec<(String, usize)>>;

pub struct CodeGen {
    /// Collected assembly output lines.
    pub asm: Vec<String>,
    /// Label counter for unique jump targets and string literals.
    label_counter: usize,
    /// XMM register counter for SSE floating-point register allocation.
    xmm_counter: usize,
    /// IDs of nodes already emitted as standalone statements.
    standalone_emitted: std::collections::HashSet<usize>,
    /// Struct field layouts for offset computation.
    struct_layouts: StructLayout,
    /// ADT definitions: type_name → list of (variant_name, field_count).
    adt_defs: std::collections::HashMap<String, Vec<(String, usize)>>,
}

impl CodeGen {
    pub fn new() -> Self {
        Self {
            asm: Vec::new(),
            label_counter: 0,
            xmm_counter: 0,
            standalone_emitted: std::collections::HashSet::new(),
            struct_layouts: StructLayout::new(),
            adt_defs: std::collections::HashMap::new(),
        }
    }

    /// Set struct field layouts for codegen (built from AST struct definitions).
    pub fn with_struct_layouts(mut self, layouts: StructLayout) -> Self {
        self.struct_layouts = layouts;
        self
    }

    /// Set ADT definitions for codegen (built from AST deftype).
    pub fn with_adt_defs(mut self, defs: std::collections::HashMap<String, Vec<(String, usize)>>) -> Self {
        self.adt_defs = defs;
        self
    }

    /// Look up the byte offset of a field within a struct.
    fn struct_field_offset(&self, struct_name: &str, field_name: &str) -> Option<usize> {
        self.struct_layouts
            .get(struct_name)
            .and_then(|fields| {
                fields
                    .iter()
                    .position(|(name, _)| name == field_name)
                    .map(|pos| pos * 8) // 8 bytes per field (64-bit)
            })
    }

    /// Generate assembly from an optimized ICNF program.
    pub fn generate(&mut self, program: &ICNFProgram) {
        // Use Intel syntax (no % prefix for registers).
        self.asm.push(".intel_syntax noprefix".to_string());

        // Collect all string literals and float constants upfront.
        let mut strings = HashSet::new();
        let mut floats: Vec<(f64, String)> = Vec::new();
        Self::collect_strings(program, &mut strings);
        Self::collect_floats(program, &mut floats);

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

        // Allocate stack space for local variables (conservative: 256 bytes).
        self.asm_push_align();
        self.asm.push("    sub rsp, 256".to_string());

        if !program.statements.is_empty() {
            let mut local_vars: HashMap<String, usize> = HashMap::new();
            // Track emitted IDs to avoid duplicate emission of branch body nodes.
            let mut emitted_ids: std::collections::HashSet<usize> =
                program.emitted_branch_ids.clone();

            // Collect all IDs that appear inside embedded branch bodies (If/While/etc).
            let mut branch_body_ids: std::collections::HashSet<usize> =
                std::collections::HashSet::new();
            for stmt in &program.statements {
                match &stmt.node {
                    ICNFInner::If {
                        then_body,
                        else_body,
                        ..
                    } => {
                        for n in then_body.iter().chain(else_body.iter()) {
                            branch_body_ids.insert(n.id);
                            // Also collect operand IDs referenced by Print/Call nodes.
                            if let ICNFInner::Print(args) = &n.node {
                                for &arg_id in args {
                                    branch_body_ids.insert(arg_id);
                                }
                            } else if let ICNFInner::Call(_, args) = &n.node {
                                for &arg_id in args {
                                    branch_body_ids.insert(arg_id);
                                }
                            }
                        }
                    }
                    _ => {}
                }
            }

            // Collect operand IDs for the main body to skip intermediate Load nodes.
            let mut main_operand_ids: std::collections::HashSet<usize> = HashSet::new();
            for stmt in &program.statements {
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => {
                        main_operand_ids.insert(*left);
                        main_operand_ids.insert(*right);
                    }
                    ICNFInner::UnOp(_, id) => {
                        main_operand_ids.insert(*id);
                    }
                    ICNFInner::Call(_, args) => {
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
                    ICNFInner::MakeStruct(_, field_ids) => {
                        for &fid in field_ids {
                            main_operand_ids.insert(fid);
                        }
                    }
                    _ => {}
                }
            }

            // Capture phi slots for top-level If result variables before the emit loop.
            // Find the phi Assign node for each If and use its slot.
            let mut empty_phi: std::collections::HashMap<String, String> = HashMap::new();
            // Build slot map first: count Assign nodes to get correct slot indices.
            // Only pre-register If result_vars that have their phi Assign as a direct
            // child in program.statements (not nested Ifs — their assigns live inside
            // branch bodies and must compute slots dynamically).
            let mut assign_count: usize = 0;
            let mut assign_slots: std::collections::HashMap<String, usize> = HashMap::new();
            // Collect result_vars whose phi Assign is a top-level program statement.
            let mut top_level_result_vars: std::collections::HashSet<String> =
                std::collections::HashSet::new();
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
            let mut for_loop_vars: std::collections::HashSet<String> = std::collections::HashSet::new();
            let mut for_body_ids: std::collections::HashSet<usize> = std::collections::HashSet::new();
            for stmt in &program.statements {
                if let ICNFInner::For { init_bindings, cond_nodes, body, result_var: _, .. } = &stmt.node {
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

            for (i, stmt) in program.statements.iter().enumerate() {
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
                        | ICNFInner::Call(_, _) => continue,
                        ICNFInner::BinOp(_, _, _) | ICNFInner::UnOp(_, _) => continue,
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
            // Build a full lookup map for the main program statements.
            let mut main_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
            for stmt in &program.statements {
                main_lookup.insert(stmt.id, stmt);
            }
            // Collect IDs of BinOp statements that are If conditions — these must be
            // skipped in the main loop because the If handler emits them inline.
            // Must also collect from branch bodies (nested Ifs whose If-statement is
            // not in program.statements but whose condition BinOp was pushed to globals).
            let mut if_condition_ids: std::collections::HashSet<usize> = HashSet::new();
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
                        | ICNFInner::Call(_, _) => continue,
                        ICNFInner::BinOp(_, _, _) => {} // keep BinOp in lookup for emit_condition_inline
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

        // Call exit(0).
        self.asm_push_align();
        self.asm
            .push("    xor edi, edi           # exit code 0".to_string());
        self.asm_push_align();
        self.asm.push("    call exit@plt".to_string());

        // Restore stack frame and return.
        self.asm_push_align();
        self.asm.push("    pop rbp".to_string());
        self.asm_push_align();
        self.asm.push("    ret".to_string());

        // Emit functions for user-defined defn.
        for func in &program.functions {
            let fn_name = format!("_ZYL_{}", func.name);
            self.asm_push_align();
            self.asm_push_align();
            self.asm.push(format!("{}:", fn_name));
            self.asm_push_align();
            self.asm.push("    push rbp".to_string());
            self.asm_push_align();
            self.asm.push("    mov rbp, rsp".to_string());

            // Reserve stack space for local variables (conservative: 256 bytes).
            self.asm_push_align();
            self.asm.push("    sub rsp, 256".to_string());

            // Store function parameters from registers to known stack slots.
            // Float params come in XMM registers (as bit patterns), non-floats in GPRs.
            let abi_regs_64 = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
            let abi_xmm_regs = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
            for (i, (param_name, param_type)) in func.params.iter().enumerate() {
                if i < 6 && !param_name.is_empty() {
                    let offset = (i + 1) * 8;
                    if matches!(param_type, Type::Prim(PrimType::Float)) {
                        // Float param: load from XMM register as bit pattern.
                        let xmm_reg = abi_xmm_regs[i];
                        let gpr_reg = abi_regs_64[i];
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    movq {}, {}",
                            gpr_reg, xmm_reg
                        ));
                        self.asm_push_align();
                        // 64-bit store for float (don't truncate to 32-bit).
                        self.asm.push(format!(
                            "    mov [rbp-{}], {}",
                            offset,
                            gpr_reg
                        ));
                    } else {
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov [rbp-{}], {} # {}",
                            offset,
                            reg_to_32(abi_regs_64[i]),
                            param_name
                        ));
                    }
                }
            }

            // Emit the function body statements inline.
            let mut local_vars: HashMap<String, usize> = HashMap::new();

            // Pre-populate local_vars with parameter names pointing to their stack slot indices.
            // The offset formula is (slot_idx + 1) * 8, so params use (i + 1) as their slot index.
            for (i, param) in func.params.iter().enumerate() {
                if !param.0.is_empty() && i < 6 {
                    local_vars.insert(param.0.clone(), i);
                }
            }

            // Build a lookup for body nodes by ID so we can find operand values.
            let body_stmts: Vec<ICNFNode> = func.body.clone();
            let mut func_emitted_ids: std::collections::HashSet<usize> = HashSet::new();

            // First pass: assign stack slots to all local variable assignments
            // and collect operand IDs to skip intermediate Load nodes.
            let mut next_slot = 6usize; // params use slots 0-5
            let mut operand_ids: std::collections::HashSet<usize> = HashSet::new();
            // Capture phi slots for all If result variables.
            let mut phi_slots: std::collections::HashMap<String, String> = HashMap::new();
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
                // Collect all operand SSA IDs, including from embedded control flow bodies.
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => {
                        operand_ids.insert(*left);
                        operand_ids.insert(*right);
                    }
                    ICNFInner::UnOp(_, id) => {
                        operand_ids.insert(*id);
                    }
                    ICNFInner::Call(_, args) => {
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
                        collect_body_operand_ids(then_body, &mut operand_ids);
                        collect_body_operand_ids(else_body, &mut operand_ids);
                    }
                    ICNFInner::While { cond_body, body, result_var: _ } => {
                        collect_body_operand_ids(cond_body, &mut operand_ids);
                        collect_body_operand_ids(body, &mut operand_ids);
                    }
                    ICNFInner::For { init_bindings, cond_nodes, body, result_var: _, .. } => {
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
                                ICNFInner::Call(_, args) => {
                                    for &a in args {
                                        operand_ids.insert(a);
                                    }
                                }
                                ICNFInner::Print(args) => {
                                    for &a in args {
                                        operand_ids.insert(a);
                                    }
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
                    _ => {}
                }
            }

            // After first pass: capture phi slots for all If result variables.
            for stmt in &func.body {
                if let ICNFInner::If { result_var, .. } = &stmt.node {
                    if let Some(&slot) = local_vars.get(result_var) {
                        phi_slots.insert(result_var.clone(), (((slot + 1) * 8).to_string()));
                    }
                }
            }

            // Second pass: emit code.
            // Collect condition IDs to skip them in the emit loop (they'll be emitted inline by If handler).
            let mut condition_ids: std::collections::HashSet<usize> = HashSet::new();
            for stmt in &func.body {
                if let ICNFInner::If { cond_ssa, then_body, else_body, .. } = &stmt.node {
                    condition_ids.insert(*cond_ssa);
                    // Also collect condition IDs from nested If nodes in branch bodies.
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
            let mut func_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
            for n in &body_stmts {
                func_lookup.insert(n.id, n);
            }
            for stmt in &func.body {
                // Skip condition BinOps — they're emitted inline by the If handler.
                if condition_ids.contains(&stmt.id) {
                    continue;
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

            // Return result: if body ends with a value in eax, keep it; otherwise return 0.
            self.asm_push_align();
            self.asm.push("    add rsp, 256".to_string());
            self.asm_push_align();
            self.asm.push("    pop rbp".to_string());
            self.asm_push_align();
            self.asm.push("    ret".to_string());
        }

        // Emit string literals used in the program.
        for func in &program.functions {
            let _ = func; // Reserved for future use with closures capturing strings.
        }
    }

    /// Collect all unique string literals from an ICNF program (recursively).
    fn collect_strings(program: &ICNFProgram, out: &mut HashSet<String>) {
        for stmt in &program.statements {
            Self::collect_from_node(stmt, out);
        }
        // Also check branch body nodes embedded in If expressions in global statements.
        for stmt in &program.statements {
            if let ICNFInner::If {
                then_body,
                else_body,
                ..
            } = &stmt.node
            {
                for node in then_body.iter().chain(else_body.iter()) {
                    Self::collect_from_node(node, out);
                }
            }
        }
        // Also check function body nodes.
        for func in &program.functions {
            for stmt in &func.body {
                Self::collect_from_node(stmt, out);
                if let ICNFInner::If {
                    then_body,
                    else_body,
                    ..
                } = &stmt.node
                {
                    for node in then_body.iter().chain(else_body.iter()) {
                        Self::collect_from_node(node, out);
                    }
                }
                if let ICNFInner::While { cond_body, body, .. } = &stmt.node {
                    for node in cond_body.iter().chain(body.iter()) {
                        Self::collect_from_node(node, out);
                    }
                }
            }
        }
    }

    /// Collect all unique float literals from an ICNF program (recursively), with unique labels.
    fn collect_floats(program: &ICNFProgram, out: &mut Vec<(f64, String)>) {
        let mut seen: HashMap<u64, String> = HashMap::new();

        fn collect_floats_from_node(node: &ICNFNode, seen: &mut HashMap<u64, String>, out: &mut Vec<(f64, String)>) {
            match &node.node {
                ICNFInner::Const(Atom::Float(v)) => {
                    let bits = v.to_bits();
                    if !seen.contains_key(&bits) {
                        let label = format!(".flt_{}", bits);
                        seen.insert(bits, label.clone());
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

        // Sort for determinism
        out.sort_by(|a, b| a.0.to_bits().cmp(&b.0.to_bits()));
    }

    fn collect_from_node(node: &ICNFNode, out: &mut HashSet<String>) {
        match &node.node {
            ICNFInner::Const(Atom::Str(s)) => {
                out.insert(s.clone());
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
            let safe_name: String = s
                .chars()
                .map(|c| {
                    if c.is_ascii_alphanumeric() {
                        c.to_string()
                    } else {
                        "_".to_string()
                    }
                })
                .collect();
            let str_label = format!(".str_{}", safe_name);
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
    fn emit_load_into(
        &mut self,
        src_ssa_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        operand_ids: &std::collections::HashSet<usize>,
        phi_slots: &std::collections::HashMap<String, String>,
    ) {
        // Check if already emitted. Only skip if the node type stores its result in eax
        // AND we can safely assume eax still has that value.
        // Look up the statement by ID: check lookup first (branch bodies), then stmts.
        let node = lookup
            .get(&src_ssa_id)
            .copied()
            .or_else(|| stmts.iter().find(|n| n.id == src_ssa_id));
        match node {
            Some(ICNFNode {
                node: ICNFInner::Const(atom),
                ..
            }) => {
                self.emit_const_into(target_reg, atom);
            }
            Some(ICNFNode {
                node: ICNFInner::Load(name),
                typ,
                ..
            }) => {
                // Always load from stack slot — never skip based on emitted_ids.
                // The emitted value might have been overwritten by subsequent operations.
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
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
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), offset));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), offset));
                    }
                }
            }
            Some(ICNFNode {
                node: ICNFInner::BinOp(op, left_id, right_id),
                typ,
                ..
            }) => {
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)))
                    || {
                        let is_cmp = matches!(op, BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge);
                        if !is_cmp { false }
                        else {
                            let find_node = |id: usize| -> Option<&ICNFNode> {
                                lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id))
                            };
                            let left_is_float = find_node(*left_id)
                                .and_then(|n| n.typ.as_ref())
                                .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                            let right_is_float = find_node(*right_id)
                                .and_then(|n| n.typ.as_ref())
                                .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                            left_is_float || right_is_float
                        }
                    };
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if already_emitted {
                    self.asm_push_align();
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        self.asm
                            .push(format!("    mov {}, eax", reg_to_32(target_reg)));
                    }
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
                    self.asm_push_align();
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        self.asm
                            .push(format!("    mov {}, eax", reg_to_32(target_reg)));
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
                node: ICNFInner::UnOp(op, arg_id),
                typ,
                ..
            }) => {
                let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                let already_emitted = emitted_ids.contains(&src_ssa_id)
                    || self.standalone_emitted.contains(&src_ssa_id);
                if already_emitted {
                    self.asm_push_align();
                    if is_float {
                        self.asm
                            .push(format!("    movsd {}, xmm0", target_reg));
                    } else {
                        self.asm
                            .push(format!("    mov {}, eax", reg_to_32(target_reg)));
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
                let total_size = field_ids.len() * 8;
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", total_size));
                self.asm_push_align();
                self.asm.push("    call malloc@plt".to_string());
                self.asm_push_align();
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string());
                for (i, &fid) in field_ids.iter().enumerate() {
                    let off = i * 8;
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
                            }
                        }
                        Some(n) => {
                            self.emit_load_into(fid, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                            self.asm_push_align();
                            self.asm.push("    mov rax, rax".to_string());
                        }
                        None => {}
                    }
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", off));
                }
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(src_ssa_id);
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, eax", reg_to_32(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::StructGet(struct_id, field_offset),
                ..
            }) => {
                // Always emit loading code — operand nodes are skipped by emit_loop,
                // so they need to be emitted inline by the parent handler.
                self.emit_load_into(*struct_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                self.asm_push_align();
                self.asm.push(format!("    mov eax, [rax + {}]", field_offset));
                emitted_ids.insert(src_ssa_id);
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, eax", reg_to_32(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::MakeStruct(..),
                ..
            }) => {
                // Already emitted — result is in eax. Just copy to target.
                if target_reg != "rax" && target_reg != "eax" {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, eax", reg_to_32(target_reg)));
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
                        .push(format!("    mov {}, eax", reg_to_32(target_reg)));
                }
            }
            Some(ICNFNode {
                node: ICNFInner::If { cond_ssa, then_body, else_body, result_var },
                typ,
                ..
            }) => {
                if emitted_ids.contains(&src_ssa_id) {
                    // Already emitted — load from phi slot (eax may be clobbered by calls).
                    // Use phi_slots (same source as the join point) for the slot index.
                    let is_float = matches!(typ.as_ref(), Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if is_float {
                        self.asm_push_align();
                        self.asm.push(format!("    movsd {}, xmm0", target_reg));
                    } else if let Some(slot) = phi_slots.get(result_var.as_str()) {
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), slot));
                    } else if let Some(&slot_idx) = local_vars.get(result_var.as_str()) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), offset));
                    } else {
                        // Fallback: load from eax (may be stale).
                        if target_reg != "rax" && target_reg != "eax" {
                            self.asm_push_align();
                            self.asm
                                .push(format!("    mov {}, eax", reg_to_32(target_reg)));
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
                    } else if target_reg != "rax" && target_reg != "eax" {
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov {}, eax", reg_to_32(target_reg)));
                    }
                }
            }
            Some(ICNFNode {
                node: ICNFInner::Assign(var_name, _),
                ..
            }) => {
                // Assign node: load from the variable's stack slot.
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), offset));
                } else {
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, [rbp-{}]", reg_to_32(target_reg), offset));
                }
            }
            Some(_) => {
                let hash = simple_hash(&format!("{}", src_ssa_id));
                let offset = ((hash % 32) + 1) * 8;
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, [rbp-{}]", target_reg, offset));
            }
            None => {
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, eax", reg_to_32(target_reg)));
            }
        }
    }

    /// Emit a BinOp directly: load operands, compute, store result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    fn emit_binop_direct(
        &mut self,
        op: &BinOpKind,
        left_id: usize,
        right_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        is_float: bool,
        node_id: usize,
    ) {

        if is_float {
            let xmm1 = format!("xmm{}", self.alloc_xmm());
            let xmm2 = format!("xmm{}", self.alloc_xmm());
            let xmm_dest = "xmm0".to_string();

            self.emit_float_load_into(
                left_id, &xmm1, stmts, local_vars, lookup, emitted_ids,
                &std::collections::HashSet::new(),
            );
            self.emit_float_load_into(
                right_id, &xmm2, stmts, local_vars, lookup, emitted_ids,
                &std::collections::HashSet::new(),
            );
            emitted_ids.insert(node_id);

            match op {
                BinOpKind::Add => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    addsd {}, {}", xmm_dest, xmm2));
                }
                BinOpKind::Sub => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    subsd {}, {}", xmm_dest, xmm2));
                }
                BinOpKind::Mul => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    mulsd {}, {}", xmm_dest, xmm2));
                }
                BinOpKind::Div => {
                    self.asm_push_align();
                    self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm1));
                    self.asm_push_align();
                    self.asm.push(format!("    divsd {}, {}", xmm_dest, xmm2));
                }
                BinOpKind::Eq => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push("    sete al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Neq => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push("    setnz al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Lt => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push("    setb al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Gt => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push("    seta al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Le => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                    self.asm_push_align();
                    self.asm.push("    setbe al".to_string());
                    self.asm_push_align();
                    self.asm.push("    movzx eax, al".to_string());
                }
                BinOpKind::Ge => {
                    self.asm_push_align();
                    self.asm.push(format!("    ucomisd {}, {}", xmm1, xmm2));
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
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

        let dest = "eax";
        let src1 = "ecx";
        let src2 = "edx";

        self.emit_load_into(
            left_id,
            src1,
            stmts,
            local_vars,
            lookup,
            emitted_ids,
            &std::collections::HashSet::new(),
            &std::collections::HashMap::new(),
        );
        self.emit_load_into(
            right_id,
            src2,
            stmts,
            local_vars,
            lookup,
            emitted_ids,
            &std::collections::HashSet::new(),
            &std::collections::HashMap::new(),
        );

        match op {
            BinOpKind::Add => {
                self.asm_push_align();
                self.asm.push(format!("    mov {}, {}", dest, src1));
                self.asm_push_align();
                self.asm.push(format!("    add {}, {}", dest, src2));
            }
            BinOpKind::Sub => {
                self.asm_push_align();
                self.asm.push(format!("    sub {}, {}", dest, src2));
            }
            BinOpKind::Mul => {
                self.asm_push_align();
                self.asm.push(format!("    mov {}, {}", dest, src1));
                self.asm_push_align();
                self.asm.push(format!("    imul {}, {}", dest, src2));
            }
            BinOpKind::Div | BinOpKind::Rem => {
                self.asm_push_align();
                self.asm.push(format!("    mov eax, {}", src1));
                self.asm_push_align();
                self.asm.push("    cdq".to_string());
                if op == &BinOpKind::Div {
                    self.asm_push_align();
                    self.asm.push(format!("    idiv {}", src2));
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, eax", reg_to_32(target_reg)));
                } else {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, edx", reg_to_32(target_reg)));
                }
            }
            BinOpKind::Eq
            | BinOpKind::Neq
            | BinOpKind::Lt
            | BinOpKind::Gt
            | BinOpKind::Le
            | BinOpKind::Ge => {
                let d = reg_to_32(target_reg);
                self.asm_push_align();
                self.asm.push(format!("    cmp {}, {}", src1, src2));
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
                self.asm.push(format!("    movzx {}, al", d));
            }
            BinOpKind::And => {
                self.asm_push_align();
                self.asm.push(format!("    and {}, {}", dest, src1));
            }
            BinOpKind::Or => {
                self.asm_push_align();
                self.asm.push(format!("    or {}, {}", dest, src1));
            }
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a Call directly: load args into ABI regs, call, result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    fn emit_call_direct(
        &mut self,
        name: &str,
        args: &[usize],
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        node_id: usize,
        is_float: bool,
    ) {
        let abi_regs = ["edi", "esi", "edx", "ecx", "r8d", "r9d"];
        let abi_xmm = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
        for (i, &arg_id) in args.iter().enumerate() {
            if i < 6 {
                // Check if this argument is a float type.
                let arg_is_float = lookup
                    .get(&arg_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == arg_id))
                    .and_then(|n| n.typ.as_ref())
                    .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                if arg_is_float {
                    // Float args go in XMM registers.
                    let xmm_reg = abi_xmm[i];
                    self.emit_float_load_into(
                        arg_id, xmm_reg, stmts, local_vars, lookup, emitted_ids,
                        &std::collections::HashSet::new(),
                    );
                } else {
                    // Non-float args go in GPRs.
                    let reg = abi_regs[i];
                    self.emit_load_into(
                        arg_id,
                        reg,
                        stmts,
                        local_vars,
                        lookup,
                        emitted_ids,
                        &std::collections::HashSet::new(),
                        &std::collections::HashMap::new(),
                    );
                }
            }
        }

        if name != "printf" && name != "exit" {
            let fn_name = format!("_ZYL_{}", name);
            self.asm_push_align();
            self.asm.push(format!("    call {}", fn_name));
            if is_float {
                self.asm_push_align();
                self.asm
                    .push(format!("    movsd {}, xmm0", target_reg));
            } else {
                // Always keep result in eax (ABI convention) — callers may need it there.
                self.asm_push_align();
                self.asm
                    .push(format!("    mov {}, eax", reg_to_32(target_reg)));
            }
        } else {
            // For printf/exit, move result to target_reg if specified.
            if !target_reg.is_empty() {
                if is_float {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, xmm0", target_reg));
                } else {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov {}, eax", reg_to_32(target_reg)));
                }
            }
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a UnOp directly: load arg, apply op, result in target_reg.
    /// Marks the node's ID in emitted_ids so it won't be re-emitted.
    fn emit_unop_direct(
        &mut self,
        op: &UnOpKind,
        arg_id: usize,
        target_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        node_id: usize,
        is_float: bool,
    ) {
        if is_float {
            let xmm_src = format!("xmm{}", self.alloc_xmm());
            self.emit_float_load_into(
                arg_id, &xmm_src, stmts, local_vars, lookup, emitted_ids,
                &std::collections::HashSet::new(),
            );
            let xmm_dest = "xmm0".to_string();
            self.asm_push_align();
            self.asm.push(format!("    movsd {}, {}", xmm_dest, xmm_src));
            self.asm_push_align();
            self.asm.push(format!("    subsd {}, .zero_sd", xmm_dest));
            self.asm_push_align();
            self.asm
                .push(format!("    movsd {}, {}", target_reg, xmm_dest));
        } else {
            self.emit_load_into(
                arg_id,
                target_reg,
                stmts,
                local_vars,
                lookup,
                emitted_ids,
                &std::collections::HashSet::new(),
                &std::collections::HashMap::new(),
            );

            match op {
                UnOpKind::Not => {
                    self.asm_push_align();
                    self.asm
                        .push(format!("    xor {}, 1", reg_to_32(target_reg)));
                }
                UnOpKind::Negate => {
                    self.asm_push_align();
                    self.asm.push(format!("    neg {}", reg_to_32(target_reg)));
                }
            }
        }
        emitted_ids.insert(node_id);
    }

    /// Emit a constant directly into dest_reg.
    fn emit_const_into(&mut self, dest_reg: &str, atom: &Atom) {
        match atom {
            Atom::Int(v) => {
                self.asm
                    .push(format!("    mov {}, {}", reg_to_32(dest_reg), v));
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
                let safe_name: String = s
                    .chars()
                    .map(|c| {
                        if c.is_ascii_alphanumeric() {
                            c.to_string()
                        } else {
                            "_".to_string()
                        }
                    })
                    .collect();
                let str_label = format!(".str_{}", safe_name);

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

    /// Emit condition computation inline: look up operands and compute.
    /// Used by the If handler when the condition BinOp's operands aren't
    /// findable via normal lookup (e.g., they were removed by DCE).
    fn emit_condition_inline(
        &mut self,
        cond_node: &ICNFInner,
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
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

        if is_float {
            match cond_node {
                ICNFInner::BinOp(op, left_id, right_id) => {
                    let left_node = lookup.get(left_id).copied();
                    let right_node = lookup.get(right_id).copied();

                    // Emit left operand into xmm1.
                    match left_node {
                        Some(ICNFNode {
                            node: ICNFInner::Load(name),
                            ..
                        }) => {
                            if let Some(&slot_idx) = local_vars.get(name) {
                                let offset = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                                self.asm_push_align();
                                self.asm.push(format!("    movq xmm1, rax"));
                            } else {
                                self.asm_push_align();
                                self.asm.push("    xorps xmm1, xmm1".to_string());
                            }
                        }
                        Some(ICNFNode {
                            node: ICNFInner::Const(Atom::Float(v)),
                            ..
                        }) => {
                            let float_label = format!(".flt_{}", v.to_bits());
                            self.asm_push_align();
                            self.asm.push(format!("    movsd xmm1, [{}]", float_label));
                        }
                        _ => {
                            self.asm_push_align();
                            self.asm.push("    xorps xmm1, xmm1".to_string());
                        }
                    }

                    // Emit right operand into xmm2.
                    match right_node {
                        Some(ICNFNode {
                            node: ICNFInner::Load(name),
                            ..
                        }) => {
                            if let Some(&slot_idx) = local_vars.get(name) {
                                let offset = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                                self.asm_push_align();
                                self.asm.push(format!("    movq xmm2, rax"));
                            } else {
                                self.asm_push_align();
                                self.asm.push("    xorps xmm2, xmm2".to_string());
                            }
                        }
                        Some(ICNFNode {
                            node: ICNFInner::Const(Atom::Float(v)),
                            ..
                        }) => {
                            let float_label = format!(".flt_{}", v.to_bits());
                            self.asm_push_align();
                            self.asm.push(format!("    movsd xmm2, [{}]", float_label));
                        }
                        _ => {
                            self.asm_push_align();
                            self.asm.push("    xorps xmm2, xmm2".to_string());
                        }
                    }

                    // Emit the float comparison into eax.
                    if let ICNFInner::BinOp(bop, _, _) = cond_node {
                        self.emit_cmp_float_set(bop, "xmm1", "xmm2");
                    }
                }
                ICNFInner::Load(name) => {
                    if let Some(&slot_idx) = local_vars.get(name) {
                        let offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov rax, [rbp-{}]", offset));
                        self.asm_push_align();
                        self.asm.push(format!("    movq xmm0, rax"));
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
            ICNFInner::BinOp(op, left_id, right_id) => {
                // Look up actual operand nodes to determine types.
                let left_node = lookup.get(left_id).copied();
                let right_node = lookup.get(right_id).copied();

                // Emit left operand into ecx.
                match left_node {
                    Some(ICNFNode {
                        node: ICNFInner::Load(name),
                        ..
                    }) => {
                        if let Some(&slot_idx) = local_vars.get(name) {
                            let offset = (slot_idx + 1) * 8;
                            self.asm_push_align();
                            self.asm.push(format!("    mov ecx, [rbp-{}]", offset));
                        } else {
                            self.asm_push_align();
                            self.asm.push("    mov ecx, 0".to_string());
                        }
                    }
                    Some(ICNFNode {
                        node: ICNFInner::Const(Atom::Int(v)),
                        ..
                    }) => {
                        self.asm_push_align();
                        self.asm.push(format!("    mov ecx, {}", v));
                    }
                    _ => {
                        self.asm_push_align();
                        self.asm.push("    mov ecx, 0".to_string());
                    }
                }

                // Emit right operand into edx.
                match right_node {
                    Some(ICNFNode {
                        node: ICNFInner::Load(name),
                        ..
                    }) => {
                        if let Some(&slot_idx) = local_vars.get(name) {
                            let offset = (slot_idx + 1) * 8;
                            self.asm_push_align();
                            self.asm.push(format!("    mov edx, [rbp-{}]", offset));
                        } else {
                            self.asm_push_align();
                            self.asm.push("    mov edx, 0".to_string());
                        }
                    }
                    Some(ICNFNode {
                        node: ICNFInner::Const(Atom::Int(v)),
                        ..
                    }) => {
                        self.asm_push_align();
                        self.asm.push(format!("    mov edx, {}", v));
                    }
                    _ => {
                        self.asm_push_align();
                        self.asm.push("    mov edx, 0".to_string());
                    }
                }

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
    fn emit_if_inline(
        &mut self,
        cond_ssa: &usize,
        then_body: &[ICNFNode],
        else_body: &[ICNFNode],
        result_var: &str,
        result_typ: &Option<Type>,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
    ) {
        emitted_ids.insert(*cond_ssa);

        let cond_label = self.new_label();
        let then_start = format!("{}.then", result_var);
        let else_start = format!("{}.else", &result_var);
        let join_point = format!("{}.join", &result_var);

        // Emit condition.
        let cond_node = lookup.get(cond_ssa).copied().or_else(|| stmts.iter().find(|n| n.id == *cond_ssa));
        if let Some(ICNFNode { node, id: cond_id, .. }) = cond_node {
            // Merge body nodes into lookup so emit_condition_inline can find
            // condition operands (e.g., Const nodes in nested if conditions).
            let mut merged_lookup = lookup.clone();
            for n in then_body { merged_lookup.insert(n.id, n); }
            for n in else_body { merged_lookup.insert(n.id, n); }
            self.emit_condition_inline(node, local_vars, &merged_lookup);
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
        let mut then_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
        for n in &then_stmts { then_lookup.insert(n.id, n); }
        for n in then_body { then_lookup.insert(n.id, n); }
        let mut then_operand_ids: std::collections::HashSet<usize> = HashSet::new();
        // Collect condition IDs to skip — emit_condition_inline handles them.
        let mut then_cond_ids: std::collections::HashSet<usize> = HashSet::new();
        for stmt in then_body {
            match &stmt.node {
                ICNFInner::BinOp(_, l, r) => { then_operand_ids.insert(*l); then_operand_ids.insert(*r); }
                ICNFInner::UnOp(_, id) => { then_operand_ids.insert(*id); }
                ICNFInner::Call(_, args) => { for &a in args { then_operand_ids.insert(a); } }
                ICNFInner::Print(args) => { for &a in args { then_operand_ids.insert(a); } }
                ICNFInner::If { cond_ssa: c, .. } => {
                    then_operand_ids.insert(*c);
                    then_cond_ids.insert(*c);
                }
                _ => {}
            }
        }
        let mut then_local_vars = local_vars.clone();
        for stmt in then_body {
            // Skip condition BinOps — already emitted by emit_condition_inline.
            if then_cond_ids.contains(&stmt.id) {
                continue;
            }
            if let ICNFInner::Assign(name, _) = &stmt.node {
                *then_local_vars.entry(name.clone()).or_insert(0) += 1;
            }
            self.emit_node(
                stmt, &then_stmts, &mut then_local_vars, emitted_ids,
                &then_operand_ids, &then_lookup, &std::collections::HashMap::new(),
            );
        }
        // Store then branch result to phi slot (same slot as Assign handler).
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
            if res_is_float {
                self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
            } else {
                self.asm.push(format!("    mov [rbp-{}], eax", slot));
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
        let mut else_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
        for n in &else_stmts { else_lookup.insert(n.id, n); }
        for n in else_body { else_lookup.insert(n.id, n); }
        let mut else_operand_ids: std::collections::HashSet<usize> = HashSet::new();
        // Collect condition IDs to skip — emit_condition_inline handles them.
        let mut else_cond_ids: std::collections::HashSet<usize> = HashSet::new();
        for stmt in else_body {
            match &stmt.node {
                ICNFInner::BinOp(_, l, r) => { else_operand_ids.insert(*l); else_operand_ids.insert(*r); }
                ICNFInner::UnOp(_, id) => { else_operand_ids.insert(*id); }
                ICNFInner::Call(_, args) => { for &a in args { else_operand_ids.insert(a); } }
                ICNFInner::Print(args) => { for &a in args { else_operand_ids.insert(a); } }
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
                *else_local_vars.entry(name.clone()).or_insert(0) += 1;
            }
            self.emit_node(
                stmt, &else_stmts, &mut else_local_vars, emitted_ids,
                &else_operand_ids, &else_lookup, &std::collections::HashMap::new(),
            );
        }

        // Store else branch result to phi slot.
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
            if res_is_float {
                self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
            } else {
                self.asm.push(format!("    mov [rbp-{}], eax", slot));
            }
        }

        // Join — load phi result into eax or xmm0 so callers see it correctly.
        self.asm_push_align();
        self.asm.push(format!("{}:", join_point));
        if let Some(ref slot) = phi_slot {
            self.asm_push_align();
            let res_is_float = matches!(result_typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
            if res_is_float {
                self.asm.push(format!("    movsd xmm0, [rbp-{}]", slot));
            } else {
                self.asm.push(format!("    mov eax, [rbp-{}]", slot));
            }
        }

        emitted_ids.insert(*cond_ssa);
    }

    /// Emit a string literal in rodata and return its label name.
    fn emit_string_literal(&mut self, s: &str) -> String {
        let safe_name: String = s
            .chars()
            .map(|c| {
                if c.is_ascii_alphanumeric() {
                    c.to_string()
                } else {
                    "_".to_string()
                }
            })
            .collect();
        format!(".str_{}", safe_name)
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
        let zero_label = format!(".___zero_{}", self.label_counter);
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
          self.asm.push(format!("    test r8, r8"));
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
          self.asm.push("    call printf@plt".to_string());
    }

    // ─── Node Emission ──────────────────────────────────────────────

    /// Emit a single ICNF node as x86_64 instructions.
    fn emit_node(
        &mut self,
        node: &ICNFNode,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        operand_ids: &std::collections::HashSet<usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        phi_slots: &std::collections::HashMap<String, String>,
    ) {
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
                    // Always use eax for loads so the function return value is in eax.
                    if let Some(&offset_idx) = local_vars.get(name) {
                        let offset = (offset_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov eax, [rbp-{}]", offset));
                    } else {
                        let hash = simple_hash(name);
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov eax, [rbp-{}]", offset));
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
                    if let Some(&slot_idx) = local_vars.get(result_var) {
                        let phi_offset = (slot_idx + 1) * 8;
                        self.asm_push_align();
                        self.asm
                            .push(format!("    mov eax, [rbp-{}]", phi_offset));
                        if let Some(&my_slot) = local_vars.get(var_name) {
                            let my_offset = (my_slot + 1) * 8;
                            self.asm_push_align();
                            self.asm
                                .push(format!("    mov [rbp-{}], eax", my_offset));
                        }
                        return;
                    }
                }
                // Store current register (result of value computation) to stack slot.
                let val_is_float = lookup
                    .get(value_id)
                    .copied()
                    .or_else(|| stmts.iter().find(|n| n.id == *value_id))
                    .and_then(|n| n.typ.as_ref())
                    .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    if val_is_float {
                        self.asm
                            .push(format!("    movsd [rbp-{}], xmm0", offset));
                    } else {
                        self.asm
                            .push(format!("    mov [rbp-{}], eax", offset));
                    }
                } else {
                    // Fallback: use hash-based offset if not in local_vars.
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    if val_is_float {
                        self.asm
                            .push(format!("    movsd [rbp-{}], xmm0", offset));
                    } else {
                        self.asm
                            .push(format!("    mov [rbp-{}], eax", offset));
                    }
                }
            }

                ICNFInner::BinOp(op, left_id, right_id) => {
                    let is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)))
                        || {
                            let is_cmp = matches!(op, BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge);
                            if !is_cmp { false }
                            else {
                                let find_node = |id: usize| -> Option<&ICNFNode> {
                                    lookup.get(&id).copied().or_else(|| stmts.iter().find(|n| n.id == id))
                                };
                                let left_is_float = find_node(*left_id)
                                    .and_then(|n| n.typ.as_ref())
                                    .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                                let right_is_float = find_node(*right_id)
                                    .and_then(|n| n.typ.as_ref())
                                    .map_or(false, |t| matches!(t, Type::Prim(PrimType::Float)));
                                left_is_float || right_is_float
                            }
                        };

                    if is_float {
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
                          }
                          BinOpKind::Sub => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    subsd {}, {}", xmm_dest, xmm2));
                          }
                          BinOpKind::Mul => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    mulsd {}, {}", xmm_dest, xmm2));
                          }
                          BinOpKind::Div => {
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    movsd {}, {}", xmm_dest, xmm1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    divsd {}, {}", xmm_dest, xmm2));
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
                      let dest_reg = "eax";
                      let src1_reg = "ecx";
                      let src2_reg = "edx";

                       self.emit_load_into(
                           *left_id,
                           src1_reg,
                           stmts,
                           local_vars,
                           lookup,
                           emitted_ids,
                           operand_ids,
                           phi_slots,
                       );
                       self.emit_load_into(
                           *right_id,
                           src2_reg,
                           stmts,
                           local_vars,
                           lookup,
                           emitted_ids,
                           operand_ids,
                           phi_slots,
                       );
                       emitted_ids.insert(node.id);

                      match op {
                          BinOpKind::Add => {
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    mov {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src1_reg)
                              ));
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    add {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src2_reg)
                              ));
                          }
                          BinOpKind::Sub => {
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    mov {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src1_reg)
                              ));
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    sub {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src2_reg)
                              ));
                          }
                          BinOpKind::Mul => {
                              let d = reg_to_32(dest_reg);
                              let s1 = reg_to_32(src1_reg);
                              self.asm_push_align();
                              self.asm.push(format!("    mov {}, {}", d, s1));
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    imul {}, {}", d, reg_to_32(src2_reg)));
                          }
                          BinOpKind::Div | BinOpKind::Rem => {
                              let d = reg_to_32(dest_reg);
                              self.asm_push_align();
                              self.asm
                                  .push(format!("    mov eax, {}", reg_to_32(src1_reg)));
                              self.asm_push_align();
                              self.asm.push("    cdq".to_string());
                              if op == &BinOpKind::Div {
                                  self.asm_push_align();
                                  self.asm
                                      .push(format!("    idiv {}", reg_to_32(src2_reg)));
                                  self.asm_push_align();
                                  self.asm
                                      .push(format!("    mov {}, eax", d));
                              } else {
                                  let dd = reg_to_32(dest_reg);
                                  self.asm_push_align();
                                  self.asm.push(format!("    mov {}, edx", dd));
                              }
                          }
                          BinOpKind::Eq
                          | BinOpKind::Neq
                          | BinOpKind::Lt
                          | BinOpKind::Gt
                          | BinOpKind::Le
                          | BinOpKind::Ge => {
                              let d = reg_to_32(dest_reg);
                              self.emit_cmp_and_set(op, src1_reg, src2_reg, d);
                          }
                          BinOpKind::And => {
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    and {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src1_reg)
                              ));
                          }
                          BinOpKind::Or => {
                              self.asm_push_align();
                              self.asm.push(format!(
                                  "    or {}, {}",
                                  reg_to_32(dest_reg),
                                  reg_to_32(src1_reg)
                              ));
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
                    let slot_idx = ((hash % 32) + 1);
                    self.asm_push_align();
                    self.asm.push(format!("    movsd [rbp-{}], {}", slot_idx * 8, xmm_result));
                } else {
                    let reg = self.alloc_reg_32();
                    match stmts.iter().find(|n| n.id == *arg_id) {
                        Some(ICNFNode {
                            node: ICNFInner::Const(atom),
                            ..
                        }) => {
                            self.emit_const_into(&reg, atom);
                        }
                        _ => {
                            let hash = simple_hash(&format!("{}", arg_id));
                            let offset = ((hash % 32) + 1) * 8;
                            self.asm_push_align();
                            self.asm.push(format!("    mov {}, [rbp-{}]", reg, offset));
                        }
                    }

                    match op {
                        UnOpKind::Not => {
                            self.asm_push_align();
                            self.asm.push(format!("    xor {}, 1", reg_to_32(&reg)));
                        }
                        UnOpKind::Negate => {
                            self.asm_push_align();
                            self.asm.push(format!("    neg {}", reg_to_32(&reg)));
                        }
                    }
                }
            }
            ICNFInner::SetBang(target, val_id) => {
                // Load val_id into eax first, then store to target variable's slot.
                self.emit_load_into(*val_id, "eax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                if let Some(&slot_idx) = local_vars.get(target) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov [rbp-{}], eax", offset));
                    emitted_ids.insert(node.id);
                } else {
                    let hash = simple_hash(target);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm
                        .push(format!("    mov [rbp-{}], eax", offset));
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
                    let slot_count = phi_slots.len() + 1;
                    let offset = ((slot_count + 1) * 8).to_string();
                    phi_slots.insert(result_var.clone(), offset);
                }
                // Emit the condition inline by looking up the condition node and
                // computing it directly. This handles the case where the condition
                // BinOp's operands are not findable via normal lookup.
                let cond_label = self.new_label();

                // Collect all branch body nodes for operand lookup.
                let all_branch_nodes: Vec<&ICNFNode> =
                    then_body.iter().chain(else_body.iter()).collect();

                // Look up the condition node: check func.body stmts first,
                // then branch bodies.
                let cond_node = stmts
                    .iter()
                    .find(|n| n.id == *cond_ssa)
                    .or_else(|| all_branch_nodes.iter().copied().find(|n| n.id == *cond_ssa));

                // Build a lookup that includes func.body AND branch bodies.
                let mut full_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
                for n in stmts {
                    full_lookup.insert(n.id, n);
                }
                for n in &all_branch_nodes {
                    full_lookup.insert(n.id, n);
                }

                // Emit condition computation if found.
                if let Some(cond) = cond_node {
                    self.emit_condition_inline(&cond.node, local_vars, &full_lookup);
                    // Mark condition ID as emitted so the emit loop won't re-emit it.
                    emitted_ids.insert(*cond_ssa);
                    // Also mark the condition BinOp's own ID as emitted to prevent
                    // re-emission when processing branch bodies that contain it.
                    emitted_ids.insert(cond.id);
                } else {
                    // Fallback: test zero (condition not found, assume false).
                    self.asm_push_align();
                    self.asm.push("    xor eax, eax".to_string());
                }

                // Collect operand IDs for branch bodies to skip intermediate Load nodes.
                let mut then_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                collect_body_operand_ids(then_body, &mut then_operand_ids);
                let mut else_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                collect_body_operand_ids(else_body, &mut else_operand_ids);

                // Check condition (result in eax).
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!("    je  {}", cond_label));

                // Then branch — fall through (emit inline like While does).
                let then_start = format!("{}.then", result_var);
                let else_start = format!("{}.else", &result_var);
                let join_point = format!("{}.join", &result_var);

                self.asm_push_align();
                self.asm.push(format!("{}:", then_start));

                // Build combined lookup: branch body nodes take priority over func.body.
                let then_stmts: Vec<ICNFNode> = stmts.to_vec();
                let mut then_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
                for n in &then_stmts {
                    then_lookup.insert(n.id, n);
                }
                for n in then_body {
                    then_lookup.insert(n.id, n);
                }

                // Emit the 'then' branch statements inline. Clone local_vars for each branch scope.
                let mut then_local_vars = local_vars.clone();
                for stmt in then_body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *then_local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(
                        &stmt,
                        &then_stmts,
                        &mut then_local_vars,
                        emitted_ids,
                        &then_operand_ids,
                        &then_lookup,
                        &phi_slots,
                    );
                }

                // Store then branch result to phi slot.
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                    } else {
                        self.asm.push(format!("    mov [rbp-{}], eax", slot));
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
                let mut else_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
                for n in &else_stmts {
                    else_lookup.insert(n.id, n);
                }
                for n in else_body {
                    else_lookup.insert(n.id, n);
                }

                // Emit the 'else' branch statements inline. Clone local_vars for each branch scope.
                let mut else_local_vars = local_vars.clone();
                for stmt in else_body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *else_local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(
                        &stmt,
                        &else_stmts,
                        &mut else_local_vars,
                        emitted_ids,
                        &else_operand_ids,
                        &else_lookup,
                        &phi_slots,
                    );
                }

                // Store else branch result to phi slot.
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd [rbp-{}], xmm0", slot));
                    } else {
                        self.asm.push(format!("    mov [rbp-{}], eax", slot));
                    }
                }

                // Join point (phi merge): load phi result into eax or xmm0.
                self.asm_push_align();
                self.asm.push(format!("{}:", join_point));

                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    let res_is_float = matches!(&node.typ, Some(t) if matches!(t, Type::Prim(PrimType::Float)));
                    if res_is_float {
                        self.asm.push(format!("    movsd xmm0, [rbp-{}]", slot));
                    } else {
                        self.asm.push(format!("    mov eax, [rbp-{}]", slot));
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
                let mut cond_operand_ids: std::collections::HashSet<usize> = HashSet::new();
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
                let mut while_operand_ids: std::collections::HashSet<usize> = HashSet::new();
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
                let mut local_vars = local_vars.clone();
                let mut while_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
                for n in stmts {
                    while_lookup.insert(n.id, n);
                }
                for n in cond_body {
                    while_lookup.insert(n.id, n);
                }
                for n in body {
                    while_lookup.insert(n.id, n);
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
                    self.emit_node(
                        stmt,
                        stmts,
                        &mut cond_local_vars,
                        emitted_ids,
                        &cond_operand_ids,
                        &while_lookup,
                        &std::collections::HashMap::new(),
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
                    self.emit_node(
                        stmt,
                        stmts,
                        &mut body_local_vars,
                        emitted_ids,
                        &while_operand_ids,
                        &while_lookup,
                        &std::collections::HashMap::new(),
                    );
                    emitted_ids.insert(stmt.id);
                }

                // Store result to phi slot.
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    self.asm.push(format!("    mov [rbp-{}], eax", slot));
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
                                        self.asm.push(format!("    mov eax, {}", v));
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], eax", (slot_offset + 1) * 8));
                                    }
                                    ICNFInner::Const(Atom::Bool(v)) => {
                                        let val = if *v { 1 } else { 0 };
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov eax, {}", val));
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], eax", (slot_offset + 1) * 8));
                                    }
                                    _ => {
                                        // Emit the value node
                                        let mut init_local_vars = local_vars.clone();
                                        self.emit_node(
                                            node,
                                            stmts,
                                            &mut init_local_vars,
                                            emitted_ids,
                                            operand_ids,
                                            lookup,
                                            phi_slots,
                                        );
                                        self.asm_push_align();
                                        self.asm.push(format!("    mov [rbp-{}], eax", (slot_offset + 1) * 8));
                                    }
                                }
                            }
                        }
                        // If no val_id, variable already has a value from outer scope — do nothing.
                    }
                }

                // Collect operand IDs.
                let mut for_operand_ids: std::collections::HashSet<usize> = HashSet::new();
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
                let mut for_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
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
                    self.emit_node(
                        cond_stmt,
                        stmts,
                        local_vars,
                        emitted_ids,
                        &for_operand_ids,
                        &for_lookup,
                        &std::collections::HashMap::new(),
                    );
                    emitted_ids.insert(cond_stmt.id);
                }
                self.asm.push("    mov r11, rax".into());
                self.asm.push("    test r11, r11".into());
                self.asm.push(format!("    je {}", loop_end));

                // Emit body.
                let mut body_local_vars: HashMap<String, usize> = local_vars.clone();
                for stmt in body {
                    // Skip Assign nodes that are created by SetBang for SSA tracking.
                    // They would emit redundant stores to stack slots.
                    if matches!(&stmt.node, ICNFInner::Assign(_, _)) {
                        continue;
                    }
                    self.emit_node(
                        stmt,
                        stmts,
                        &body_local_vars,
                        emitted_ids,
                        &for_operand_ids,
                        &for_lookup,
                        &std::collections::HashMap::new(),
                    );
                    emitted_ids.insert(stmt.id);
                }

                self.asm_push_align();
                self.asm.push(format!("    jmp {}", loop_start));
                self.asm_push_align();
                self.asm_push_align();
                self.asm.push(format!("{}:", loop_end));
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
                    let is_string = match node {
                        Some(ICNFNode {
                            node: ICNFInner::Const(Atom::Str(_)),
                            ..
                        }) => true,
                        _ => false,
                    };
                    // Check if node's type is explicitly set.
                    // If it's an Assign with no type, look up the value_id.
                    let node_type = node.and_then(|n| n.typ.as_ref());
                    let is_float = match node_type {
                        Some(t) if matches!(t, Type::Prim(PrimType::Float)) => true,
                        _ => false,
                    };
                    // If no type yet and this is an Assign, resolve from value_id.
                    let is_float = if !is_float {
                        if let Some(ICNFNode { node: ICNFInner::Assign(_, value_id), .. }) = node {
                            let value_node = find_node(*value_id);
                            match value_node.and_then(|n| n.typ.as_ref()) {
                                Some(t) if matches!(t, Type::Prim(PrimType::Float)) => true,
                                _ => false,
                            }
                        } else { false }
                    } else { is_float };

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
                        self.asm.push("    call printf@plt".to_string());

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
                        self.asm_push_align();
                        self.asm.push("    xor eax, 1           # 1 xmm arg for printf".to_string());
                        self.asm_push_align();
                        self.asm.push("    call printf@plt".to_string());
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

            ICNFInner::Call(name, args) => {
                // Function call — pass arguments in registers per System V ABI.
                // Integers/pointers in GPRs, floats in XMM registers.
                let abi_regs = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"];
                let abi_xmm_regs = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
                let mut xmm_arg_count: usize = 0;

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
                            // Float arg: load directly into XMM register.
                            self.emit_float_load_into(
                                arg_id, &abi_xmm_regs[i], stmts, local_vars, lookup, emitted_ids, operand_ids,
                            );
                            xmm_arg_count += 1;
                        } else {
                            // Non-float arg: load into GPR.
                            let reg = abi_regs[i];
                            self.emit_load_into(
                                arg_id,
                                reg,
                                stmts,
                                local_vars,
                                lookup,
                                emitted_ids,
                                operand_ids,
                                phi_slots,
                            );
                        }
                    }
                }

                // Set number of XMM registers used for variadic calling convention.
                self.asm_push_align();
                self.asm.push(format!("    mov eax, {}", xmm_arg_count));

                // User-defined functions use _ZYL_ prefix; skip libc calls.
                if name == "printf" || name == "exit" {
                    return; // Skip — handled specially elsewhere.
                }

                let fn_name = format!("_ZYL_{}", name);
                self.asm_push_align();
                self.asm.push(format!("    call {}", fn_name));

                // Mark this node as emitted to prevent duplicate emission.
                emitted_ids.insert(node.id);
            }

            ICNFInner::Exit(_code_id) => {
                // Exit with status code using exit() from libc.
                self.asm_push_align();
                self.asm
                    .push("    xor edi, edi           # exit(0)".to_string());
                self.asm_push_align();
                self.asm.push("    call exit@plt".to_string());
            }

            ICNFInner::Unit | ICNFInner::Closure(_) => {
                // No-op in assembly.
            }

            ICNFInner::Begin(stmts) => {
                let mut local_vars: HashMap<String, usize> = HashMap::new();
                let mut begin_operand_ids: std::collections::HashSet<usize> = HashSet::new();
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
                let mut begin_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
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
                        &std::collections::HashMap::new(),
                        &std::collections::HashMap::new(),
                    );
                }
            }

            ICNFInner::MakeStruct(name, field_ids) => {
                // Allocate heap memory for the struct: call malloc(n * 8), then store each field.
                let _ = name;
                let field_count = field_ids.len();
                let total_size = field_count * 8;

                // FIX: Save field values to the stack before malloc, because malloc clobbers eax.
                // Push rbp to mark the boundary. Push in reverse order so fields pop in correct order.
                self.asm_push_align();
                self.asm.push("    push rbp".to_string());
                self.asm_push_align();
                for &field_id in field_ids.iter().rev() {
                    match lookup.get(&field_id).copied().or_else(|| stmts.iter().find(|n| n.id == field_id)) {
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
                        Some(n) => {
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
                self.asm.push("    call malloc@plt".to_string());
                self.asm_push_align();
                self.asm.push("    mov r10, rax".to_string()); // Save struct base pointer in r10.

                // Fields were pushed in reverse (last field first), so popping yields fields in forward order.
                for i in 0..field_count {
                    self.asm_push_align();
                    self.asm.push("    pop rax".to_string());
                    self.asm_push_align();
                    self.asm.push(format!("    mov [r10 + {}], rax", i * 8));
                }

                // Pop the rbp marker pushed before field storage.
                self.asm_push_align();
                self.asm.push("    pop rbp".to_string());

                // Restore struct pointer to eax as the result.
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(node.id);
            }

            ICNFInner::StructGet(struct_id, field_offset) => {
                // Load struct pointer into rax, then load field value from rax + offset.
                // Result in eax.
                self.emit_load_into(
                    *struct_id,
                    "rax",
                    stmts,
                    local_vars,
                    lookup,
                    emitted_ids,
                    operand_ids,
                    phi_slots,
                );
                self.asm_push_align();
                self.asm.push(format!("    mov eax, [rax + {}]", field_offset));
                emitted_ids.insert(node.id);
            }

            ICNFInner::MakeVariant { type_name, variant_name, discriminant, field_ids } => {
                // Tagged union construction: malloc(sizeof(discriminant + fields)), store discriminant, then fields.
                let field_count = field_ids.len();
                let total_size = (field_count + 1) * 8; // discriminant + fields.

                // Save field values to stack before malloc.
                self.asm_push_align();
                self.asm.push("    push rbp".to_string());
                self.asm_push_align();
                for &field_id in field_ids.iter().rev() {
                    match lookup.get(&field_id).copied().or_else(|| stmts.iter().find(|n| n.id == field_id)) {
                        Some(ICNFNode { node: ICNFInner::Const(atom), .. }) => {
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
                                self.asm_push_align();
                                self.asm.push("    mov rax, 0".to_string());
                            }
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        Some(n) => {
                            self.emit_load_into(field_id, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                        None => {
                            self.asm_push_align();
                            self.asm.push("    push rax".to_string());
                        }
                    }
                }

                // Allocate memory.
                self.asm_push_align();
                self.asm.push(format!("    mov edi, {}", total_size));
                self.asm_push_align();
                self.asm.push("    call malloc@plt".to_string());
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

                // Pop the rbp marker pushed before field storage.
                self.asm_push_align();
                self.asm.push("    pop rbp".to_string());

                // Result: struct pointer in rax.
                self.asm_push_align();
                self.asm.push("    mov rax, r10".to_string());
                emitted_ids.insert(node.id);
            }

            ICNFInner::Match { scrutinee_ssa, type_name, arms, result_var } => {
                // Load scrutinee into rax (struct pointer).
                // Read discriminant from [rax + 0].
                // Compare with each arm's variant discriminant, jump to matching arm.
                // Each arm body runs with field values loaded from the struct.
                // Phi join: load result from phi slot.

                let match_id = self.label_counter;
                self.label_counter += 1;
                let join_label = if type_name.is_empty() {
                    format!(".___match_join_{}", match_id)
                } else {
                    format!(".___match_join_{}_{}", type_name, match_id)
                };

                // Load scrutinee pointer.
                self.emit_load_into(*scrutinee_ssa, "rax", stmts, local_vars, lookup, emitted_ids, operand_ids, phi_slots);

                // Save scrutinee pointer in callee-saved r12 before discriminant load.
                self.asm_push_align();
                self.asm.push("    mov r12, rax".to_string());

                // Load discriminant: [rax + 0].
                self.asm_push_align();
                self.asm.push("    mov eax, [rax]".to_string());

                // Build arm labels and discriminant values.
                let arm_labels: Vec<String> = (0..arms.len())
                    .map(|i| {
                        if type_name.is_empty() {
                            format!(".___match_arm_{}_{}", match_id, i)
                        } else {
                            format!(".___match_arm_{}_{}_{}", type_name, match_id, i)
                        }
                    })
                    .collect();
                let default_label = if type_name.is_empty() {
                    format!(".___match_default_{}", match_id)
                } else {
                    format!(".___match_default_{}_{}", type_name, match_id)
                };

                // For each arm, compare discriminant and jump if match.
                for (i, arm) in arms.iter().enumerate() {
                    self.asm_push_align();
                    self.asm.push(format!("    cmp eax, {}", i)); // Compare with discriminant i.
                    self.asm_push_align();
                    self.asm.push(format!("    je {}", arm_labels[i]));
                }

                // No match — fall through to default (undefined behavior).
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", default_label));

                // Emit each arm body.
                for (i, arm) in arms.iter().enumerate() {
                    let arm_label = &arm_labels[i];
                    self.asm_push_align();
                    self.asm.push(format!("{}:", arm_label));

                    // Load field values from the scrutinee struct (now in r12).
                    // Fields are at [r12 + 8], [r12 + 16], etc.
                    // Clone local_vars for this arm scope since we need to add pattern bindings.
                    let mut arm_local_vars = local_vars.clone();
                    for (j, field_name) in arm.field_names.iter().enumerate() {
                        let field_offset = (j + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!("    mov ecx, [r12 + {}]", field_offset)); // Load field into temp reg.
                        self.asm_push_align();

                        // Store to a stack slot for the pattern variable.
                        // Use the original field_name (matches ICNF Load operand).
                        if !arm_local_vars.contains_key(field_name) {
                            // Allocate a new slot.
                            let max_slot: usize = arm_local_vars.values().cloned().max().unwrap_or(0);
                            let slot = max_slot + 1;
                            let offset = (slot + 1) * 8;
                            self.asm.push(format!("    mov [rbp-{}], ecx", offset));
                            arm_local_vars.insert(field_name.clone(), slot);
                        } else {
                            // Update existing slot.
                            if let Some(&slot_idx) = arm_local_vars.get(field_name) {
                                let offset = (slot_idx + 1) * 8;
                                self.asm_push_align();
                                self.asm.push(format!("    mov [rbp-{}], ecx", offset));
                            }
                        }
                    }

                    // Emit the arm body statements.
                    let mut arm_operand_ids: HashSet<usize> = HashSet::new();
                    collect_body_operand_ids(&arm.body, &mut arm_operand_ids);

                    let arm_stmts: Vec<ICNFNode> = stmts.to_vec();
                    let mut arm_lookup: std::collections::HashMap<usize, &ICNFNode> = HashMap::new();
                    for n in &arm_stmts {
                        arm_lookup.insert(n.id, n);
                    }
                    for n in &arm.body {
                        arm_lookup.insert(n.id, n);
                    }

                    for stmt in &arm.body {
                        if let ICNFInner::Assign(name, _) = &stmt.node {
                            *arm_local_vars.entry(name.clone()).or_insert(0) += 1;
                        }
                        self.emit_node(
                            stmt,
                            &arm_stmts,
                            &mut arm_local_vars,
                            emitted_ids,
                            &arm_operand_ids,
                            &arm_lookup,
                            &std::collections::HashMap::new(),
                        );
                        emitted_ids.insert(stmt.id);
                    }

                    // Store arm body result to phi slot.
                    if let Some(ref slot) = phi_slots.get(result_var) {
                        self.asm_push_align();
                        self.asm.push(format!("    mov [rbp-{}], eax", slot));
                    }

                    // Jump to join.
                    self.asm_push_align();
                    self.asm.push(format!("    jmp {}", join_label));
                }

                // Default (no match) — undefined behavior.
                self.asm_push_align();
                self.asm.push(format!("{}:", default_label));
                self.asm_push_align();
                self.asm.push("    mov eax, -1".to_string()); // Error sentinel.
                self.asm_push_align();
                self.asm.push(format!("    jmp {}", join_label));

                // Join point.
                self.asm_push_align();
                self.asm.push(format!("{}:", join_label));
                if let Some(ref slot) = phi_slots.get(result_var) {
                    self.asm_push_align();
                    self.asm.push(format!("    mov eax, [rbp-{}]", slot));
                }
            }

            _ => {
                // Unsupported/unimplemented nodes — emit a nop placeholder.
                self.asm_push_align();
                self.asm.push("    nop  # unimplemented".to_string());
            }
        }
    }

    /// Emit a float constant or load into an XMM register.
    fn emit_float_load_into(
        &mut self,
        id: usize,
        xmm_reg: &str,
        stmts: &[ICNFNode],
        local_vars: &HashMap<String, usize>,
        lookup: &std::collections::HashMap<usize, &ICNFNode>,
        emitted_ids: &mut std::collections::HashSet<usize>,
        operand_ids: &std::collections::HashSet<usize>,
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
                ICNFInner::Call(name, args) => {
                    // Float function call — pass args in XMM registers, result in xmm0.
                    let abi_xmm = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5"];
                    for (i, &arg_id) in args.iter().enumerate() {
                        if i < 6 {
                            let arg_xmm = abi_xmm[i];
                            self.emit_float_load_into(
                                arg_id, arg_xmm, stmts, local_vars, lookup, emitted_ids, operand_ids,
                            );
                        }
                    }
                    let fn_name = format!("_ZYL_{}", name);
                    self.asm_push_align();
                    self.asm.push(format!("    call {}", fn_name));
                    // Copy result from xmm0 to target register.
                    self.asm_push_align();
                    self.asm
                        .push(format!("    movsd {}, xmm0", xmm_reg));
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

    /// Allocate a 32-bit x86_64 general-purpose register.
    fn alloc_reg_32(&self) -> &'static str {
        // Caller-saved integer registers (32-bit names).
        static REGS: &[&str] = &["eax", "ecx", "edx", "esi", "edi", "r8d", "r9d"];
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
fn find_phi_slot(
    stmts: &[ICNFNode],
    result_var: &str,
    local_vars: &HashMap<String, usize>,
) -> Option<String> {
    if let Some(&slot) = local_vars.get(result_var) {
        return Some(((slot + 1) * 8).to_string());
    }
    None
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
            ICNFInner::Print(args) => {
                for &a in args {
                    out.insert(a);
                }
            }
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
            ICNFInner::For { init_bindings: _, cond_nodes, body, result_var: _ } => {
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

/// Convert f64 to its IEEE-754 bit representation.
fn f64_to_bits(v: f64) -> u64 {
    v.to_bits()
}

/// x86_64 general-purpose registers (caller-saved per System V ABI, 64-bit names).
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
