use crate::ast::Atom;
use crate::icnf::*;
use crate::region_inference::Region;
use std::collections::{HashMap, HashSet};

// ─── x86_64 Code Generation (spec §22 — Phase 9) ──────────────────────
/// Generates Linux x86_64 System V ABI assembly from optimized ICNF.
/// Uses a linear-scan register allocator over SSA values within each function body.

pub struct CodeGen {
    /// Collected assembly output lines.
    pub asm: Vec<String>,
    /// Label counter for unique jump targets and string literals.
    label_counter: usize,
}

impl CodeGen {
    pub fn new() -> Self {
        Self { asm: Vec::new(), label_counter: 0 }
    }

    /// Generate assembly from an optimized ICNF program.
    pub fn generate(&mut self, program: &ICNFProgram) {
        // Use Intel syntax (no % prefix for registers).
        self.asm.push(".intel_syntax noprefix".to_string());

        // Collect all string literals upfront and emit them in rodata before any code.
        let mut strings = HashSet::new();
        Self::collect_strings(program, &mut strings);
        
        // Emit rodata section with all static data first (including collected strings).
        self.emit_rodata(&strings);

        // Emit text (code) section.
        self.asm_push_align();
        self.asm.push(".text".to_string());

        // Entry point: main() called by C runtime.
        let entry_label = "main";
        self.asm_push_align();
        self.asm.push(".globl main".to_string());
        self.asm_push_align();
        self.asm.push(format!("{}:", entry_label));

        // Set up stack frame and align to 16 bytes for ABI compliance.
        self.asm_push_align();
        self.asm.push("    push rbp".to_string());
        self.asm_push_align();
        self.asm.push("    mov rbp, rsp".to_string());

        if !program.statements.is_empty() {
            let mut local_vars: HashMap<String, usize> = HashMap::new();
            // Track emitted IDs to avoid duplicate emission of branch body nodes.
            let mut emitted_ids: std::collections::HashSet<usize> = program.emitted_branch_ids.clone();
            
            // Collect all IDs that appear inside embedded branch bodies (If/While/etc).
            let mut branch_body_ids: std::collections::HashSet<usize> = std::collections::HashSet::new();
            for stmt in &program.statements {
                match &stmt.node { ICNFInner::If { then_body, else_body, .. } => {
                    for n in then_body.iter().chain(else_body.iter()) {
                        branch_body_ids.insert(n.id);
                        // Also collect operand IDs referenced by Print/Call nodes.
                        if let ICNFInner::Print(args) = &n.node {
                            for &arg_id in args { branch_body_ids.insert(arg_id); }
                        } else if let ICNFInner::Call(_, args) = &n.node {
                            for &arg_id in args { branch_body_ids.insert(arg_id); }
                        }
                    }
                }, _ => {} }
            }
            
            // Collect operand IDs for the main body to skip intermediate Load nodes.
            let mut main_operand_ids: std::collections::HashSet<usize> = HashSet::new();
            for stmt in &program.statements {
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => { main_operand_ids.insert(*left); main_operand_ids.insert(*right); }
                    ICNFInner::UnOp(_, id) => { main_operand_ids.insert(*id); }
                    ICNFInner::Call(_, args) => { for &a in args { main_operand_ids.insert(a); } }
                    ICNFInner::Print(args) => { for &a in args { main_operand_ids.insert(a); } }
                    ICNFInner::If { cond_ssa, .. } => { main_operand_ids.insert(*cond_ssa); }
                    _ => {}
                }
            }

            for (i, stmt) in program.statements.iter().enumerate() {
                // Skip if already emitted as part of a control flow branch.
                let inserted = emitted_ids.insert(stmt.id);
                if !inserted {
                    continue;
                }
                // Skip nodes that are part of branch bodies - they're handled by their parent If/While/etc.
                if stmt.is_branch_body {
                    continue;
                }
                // Also skip nodes whose IDs appear inside embedded branch body vectors (e.g., Const args to Print in branches).
                if branch_body_ids.contains(&stmt.id) {
                    continue;
                }
                // Track variable assignments for stack slot mapping.
                if let ICNFInner::Assign(name, _) = &stmt.node {
                    local_vars.insert(name.clone(), i);
                }
                self.emit_node(stmt, &program.statements, &local_vars, &mut emitted_ids, &main_operand_ids);
            }
        }

        // Call exit(0).
        self.asm_push_align();
        self.asm.push("    xor edi, edi           # exit code 0".to_string());
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
            let abi_regs = ["edi", "esi", "edx", "ecx", "r8d", "r9d"];
            for (i, param) in func.params.iter().enumerate() {
                if i < 6 && !param.0.is_empty() {
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov [rbp-{}], {} # {}",
                        (i + 1) * 8, abi_regs[i], param.0
                    ));
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
            eprintln!("DEBUG func body has {} stmts", func.body.len());
            for stmt in &func.body {
                eprintln!("DEBUG func body node: id={} type={}", stmt.id, match &stmt.node { ICNFInner::Call(n, _) => format!("Call({})", n), ICNFInner::BinOp(o, _, _) => format!("BinOp({})", o), ICNFInner::If { .. } => "If".to_string(), ICNFInner::Load(n) => format!("Load({})", n), ICNFInner::Const(_) => "Const".to_string(), _ => "other".to_string() });
                if let ICNFInner::Assign(name, _) = &stmt.node {
                    if !local_vars.contains_key(name) {
                        local_vars.insert(name.clone(), next_slot);
                        next_slot += 1;
                    }
                }
                // Collect all operand SSA IDs.
                match &stmt.node {
                    ICNFInner::BinOp(_, left, right) => { operand_ids.insert(*left); operand_ids.insert(*right); }
                    ICNFInner::UnOp(_, id) => { operand_ids.insert(*id); }
                    ICNFInner::Call(_, args) => { for &a in args { operand_ids.insert(a); } }
                    ICNFInner::Print(args) => { for &a in args { operand_ids.insert(a); } }
                    ICNFInner::If { cond_ssa, .. } => { operand_ids.insert(*cond_ssa); }
                    _ => {}
                }
            }
            
            // Second pass: emit code.
            for stmt in &func.body {
                self.emit_node(stmt, &body_stmts, &local_vars, &mut func_emitted_ids, &operand_ids);
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
            let _ = func;  // Reserved for future use with closures capturing strings.
        }
    }

    /// Collect all unique string literals from an ICNF program (recursively).
    fn collect_strings(program: &ICNFProgram, out: &mut HashSet<String>) {
        for stmt in &program.statements {
            Self::collect_from_node(stmt, out);
        }
        // Also check branch body nodes embedded in If expressions.
        for stmt in &program.statements {
            if let ICNFInner::If { then_body, else_body, .. } = &stmt.node {
                for node in then_body.iter().chain(else_body.iter()) {
                    Self::collect_from_node(node, out);
                }
            }
        }
    }

    fn collect_from_node(node: &ICNFNode, out: &mut HashSet<String>) {
        match &node.node {
            ICNFInner::Const(Atom::Str(s)) => { out.insert(s.clone()); }
            ICNFInner::If { then_body, else_body, .. } => {
                for n in then_body.iter().chain(else_body.iter()) {
                    Self::collect_from_node(n, out);
                }
            }
            ICNFInner::While { body, .. } => {
                for n in body.iter() {
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
            ICNFInner::TryCatch { try_body, catch_body, .. } => {
                for n in try_body.iter().chain(catch_body.iter()) {
                    Self::collect_from_node(n, out);
                }
            }
            _ => {}
        }
    }

    /// Emit rodata section with all static data (strings, format specifiers).
    fn emit_rodata(&mut self, collected_strings: &HashSet<String>) {
        self.asm_push_align();
        self.asm.push(".section .rodata".to_string());

        // Emit all string literals first (sorted for determinism).
        let mut strings_vec: Vec<_> = collected_strings.iter().collect();
        strings_vec.sort();
        self.asm_push_align();  // align before strings section
        for s in &strings_vec {
            let safe_name: String = s.chars()
                .map(|c| if c.is_ascii_alphanumeric() { c.to_string() } else { "_".to_string() })
                .collect();
            let str_label = format!(".str_{}", safe_name);
            self.asm_push_align();
            self.asm.push(format!("{}:", str_label));
            let escaped = s.replace('\\', "\\\\").replace('\n', "\\n")
                .replace('"', "\\\"");
            self.asm.push(format!(r#"    .string "{}""#, escaped));
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

        // Minus sign string (moved to emit_int_to_str for proper section handling).

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
    fn emit_load_into(&mut self, src_ssa_id: usize, target_reg: &str, stmts: &[ICNFNode], local_vars: &HashMap<String, usize>) {
        // Look up the statement by ID (not index) since IDs aren't sequential after DCE.
        match stmts.iter().find(|n| n.id == src_ssa_id) {
            Some(ICNFNode { node: ICNFInner::Const(atom), .. }) => {
                self.emit_const_into(target_reg, atom);
            }
            Some(ICNFNode { node: ICNFInner::Load(name), region, .. }) => {
                if let Some(&slot_idx) = local_vars.get(name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                } else {
                    let hash = simple_hash(name);
                    let offset = ((hash % 32) + 1) * 8;
                    match region {
                        Region::Stack | Region::Pin => {
                            self.asm_push_align();
                            self.asm.push(format!("    mov {}, [rbp-{}]", target_reg, offset));
                        }
                        _ => {
                            let ssa_offset = (src_ssa_id % 32) + 1;
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov {}, [rbp-{}]", target_reg, ssa_offset * 8
                            ));
                        }
                    }
                }
            }
            Some(ICNFNode { node: ICNFInner::BinOp(_, _, _), .. }) => {
                // BinOp result should already be in rax from prior emission.
                self.asm_push_align();
                self.asm.push(format!("    mov {}, eax", reg_to_32(target_reg)));
            }
            Some(ICNFNode { node: ICNFInner::Call(..), .. }) => {
                // Function call result is in eax from the call instruction.
                self.asm_push_align();
                self.asm.push(format!("    mov {}, eax", reg_to_32(target_reg)));
            }
            Some(_) => {
                let hash = simple_hash(&format!("{}", src_ssa_id));
                let offset = ((hash % 32) + 1) * 8;
                self.asm_push_align();
                self.asm.push(format!(
                    "    mov {}, [rbp-{}]", target_reg, offset
                ));
            }
            None => {
                // ID not found — value may be in rax from prior computation.
                self.asm_push_align();
                self.asm.push(format!("    mov {}, eax", reg_to_32(target_reg)));
            }
        }
    }

    /// Emit a constant directly into dest_reg.
    fn emit_const_into(&mut self, dest_reg: &str, atom: &Atom) {
        match atom {
            Atom::Int(v) => {
                self.asm.push(format!("    mov {}, {}", reg_to_32(dest_reg), v));
            }
            Atom::Float(_v) => {
                let xreg = format!("xmm{}", self.alloc_xmm());
                self.asm_push_align();
                self.asm.push(format!("    mov {}, 0", dest_reg));
                self.asm_push_align();
                self.asm.push(format!(
                    "    cvtsi2sd {}, {}", xreg, reg_to_32(dest_reg)
                ));
            }
            Atom::Bool(v) => {
                self.asm.push(format!(
                    "    mov {}, {}", reg_to_32(dest_reg), if *v { 1 } else { 0 }
                ));
            }
            Atom::Str(s) => {
                let safe_name: String = s.chars()
                    .map(|c| if c.is_ascii_alphanumeric() { c.to_string() } else { "_".to_string() })
                    .collect();
                let str_label = format!(".str_{}", safe_name);

                // Load pointer to string (already emitted in rodata section).
                self.asm_push_align();
                self.asm.push(format!("    lea {}, [{}] ", dest_reg, str_label));
            }
            Atom::Ident(_) => {
                self.asm.push(format!("    mov {}, 0", reg_to_32(dest_reg)));
            }
            _ => {
                self.asm_push_align();
                self.asm.push(format!(
                    "    xor {}, {}", reg_to_32(dest_reg), reg_to_32(dest_reg)
                ));
            }
        }
    }

    /// Emit a string literal in rodata and return its label name.
    fn emit_string_literal(&mut self, s: &str) -> String {
        let safe_name: String = s.chars()
            .map(|c| if c.is_ascii_alphanumeric() { c.to_string() } else { "_".to_string() })
            .collect();
        format!(".str_{}", safe_name)
    }

    // ─── Integer-to-String Conversion ────────────────────────────────

    /// Emit integer-to-string conversion: result in rax as pointer to null-terminated string.
    /// Uses 32-bit registers throughout for GNU as compatibility with .intel_syntax noprefix.
    fn emit_int_to_str(&mut self, int_reg_64: &str) {
        let buf_label = ".hexbuf";
        // Ensure buffer exists in writable section.
        if !self.asm.iter().any(|l| l.starts_with(buf_label)) {
            self.asm.push(".section .bss".to_string());
            self.asm_push_align();
            self.asm.push(format!("{}:", buf_label));
            self.asm.push("    .space 32".to_string());
            self.asm.push(".text".to_string());  // switch back to text section
        }

        // Copy value to ecx (zero-extends from any input register).
        let tmp = "ecx";
        self.asm_push_align();
        self.asm.push(format!(
            "    mov {}, {}", reg_to_32(tmp), reg_to_32(int_reg_64)
        ));

        // Handle negative numbers.
        let neg_label = format!(".___neg_{}", self.label_counter);
        self.label_counter += 1;

        self.asm_push_align();
        self.asm.push(format!("    test {}, {}", tmp, tmp));
        self.asm_push_align();
        self.asm.push(format!("    jns {}", neg_label));

        // Negative: negate value and write '-' into buffer.
        let minus_str = ".str_minus";
        if !self.asm.iter().any(|l| l.starts_with(minus_str)) {
            self.asm.push(".section .rodata".to_string());
            self.asm_push_align();
            self.asm.push(format!("{}:", minus_str));
            self.asm.push(r#"    .string "-""#.to_string());
            self.asm.push(".text".to_string());  // switch back to text section
        }

        // Load '-' character into AL and store at buffer end.
        let out_ptr = "rdi";
        self.asm_push_align();
        self.asm.push(format!("    mov al, byte ptr [{}]", minus_str));  // load '-' char (0x2D) into AL
        self.asm_push_align();
        self.asm.push(format!("    lea {}, [{}] ", out_ptr, buf_label)); // RDI = buffer start
        self.asm_push_align();
        self.asm.push("    add rdi, 31".to_string());                    // point to end of buffer
        self.asm_push_align();
        self.asm.push("    mov [rdi], al".to_string());         // write '-' at hexbuf[31]

        self.asm_push_align();
        self.asm.push(format!("    neg {}", tmp));                       // make value positive
        self.asm_push_align();
        self.asm.push("    dec rdi".to_string());                        // move pointer back one position (past '-')

        // Common setup: RDI points to where we'll write the next digit.
        // For negative numbers, it's hexbuf[30]; for positive, hexbuf[31].
        let pos_label = format!(".___pos_{}", self.label_counter);
        self.label_counter += 1;

        self.asm_push_align();
        self.asm.push(format!("{}:", neg_label));
        self.asm_push_align();
        self.asm.push(format!("    jmp {}", pos_label));
        
        // Positive path: set up RDI to point to end of buffer.
        self.asm_push_align();
        self.asm.push(format!("{}:", pos_label));
        self.asm_push_align();
        self.asm.push(format!("    lea {}, [{}] ", out_ptr, buf_label));  // RDI = hexbuf start (for positive numbers)
        self.asm_push_align();
        self.asm.push("    add rdi, 31".to_string());                    // point to end of buffer

        // Division loop: extract digits right-to-left using idiv.
        let div_loop = format!(".___divloop_{}", self.label_counter);
        self.label_counter += 1;
        let div_done = format!(".___divdone_{}", self.label_counter);
        self.label_counter += 1;

        self.asm_push_align();
        self.asm.push(format!("{}:", div_loop));
        self.asm_push_align();
        self.asm.push(format!(
            "    test {}, {}", tmp, tmp
        ));
        self.asm_push_align();
        self.asm.push(format!("    je {}", div_done));

        // Load value into eax for division. Use ebx as temp divisor register (edi is our buffer pointer).
        self.asm_push_align();
        self.asm.push("    xor edx, edx".to_string());     // clear high half (value is positive after negation)
        self.asm_push_align();
        self.asm.push(format!("    mov eax, {}", tmp));      // load value into eax

        self.asm_push_align();
        self.asm.push("    mov ebx, 10".to_string());       // divisor in EBX (edi holds buffer pointer!)
        self.asm_push_align();
        self.asm.push("    idiv ebx".to_string());           // eax = quotient, edx = remainder (digit)

        // Move quotient back to ecx for next iteration check.
        self.asm_push_align();
        self.asm.push(format!("    mov {}, eax", tmp));      // update working register with new quotient

        // Store digit at buffer position pointed by rdi (working backwards).
        let digit = "dl";  // remainder is in dl after div
        self.asm_push_align();
        self.asm.push("    dec rdi".to_string());             // move pointer back one position
        self.asm_push_align();
        self.asm.push(format!("    mov [rdi], {}", digit));   // store digit


        // Add '0' to the digit (convert from numeric to ASCII).
        self.asm_push_align();
        self.asm.push("    add byte ptr [rdi], 48".to_string());

        self.asm_push_align();
        self.asm.push(format!("    jmp {}", div_loop));

        // Done: result pointer in rdi (points to first character of converted string).
        self.asm_push_align();
        self.asm.push(format!("{}:", div_done));

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
    ) {
        match &node.node {
            ICNFInner::Const(atom) => {
                // Skip intermediate Const nodes whose result is used as an operand elsewhere.
                if operand_ids.contains(&node.id) {
                    return;
                }
                let reg = self.alloc_reg();
                self.emit_const_into(reg, atom);
            }

            ICNFInner::Load(name) => {
                // Skip intermediate Load nodes whose result is used as an operand elsewhere.
                // The value will be loaded on-demand via emit_load_into.
                if operand_ids.contains(&node.id) {
                    return;
                }
                let reg = self.alloc_reg();
                if let Some(&offset_idx) = local_vars.get(name) {
                    // Load from stack slot.
                    let offset = (offset_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov {}, [rbp-{}]", reg, offset
                    ));
                } else if name.starts_with("___") || name.chars().next()
                    .map(|c| c.is_ascii_digit())
                    .unwrap_or(false) {
                    // Numeric SSA reference — already in a register.
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov {}, {}", reg, X86_REGISTERS[0]
                    ));
                } else {
                    let hash = simple_hash(name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov {}, [rbp-{}]", reg, offset
                    ));
                }
            }

            ICNFInner::Assign(var_name, value_id) => {
                // Store current register (result of value computation) to stack slot.
                if let Some(&slot_idx) = local_vars.get(var_name) {
                    let offset = (slot_idx + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov [rbp-{}], {}", offset, X86_REGISTERS[0]
                    ));
                } else {
                    // Fallback: use hash-based offset if not in local_vars.
                    let hash = simple_hash(var_name);
                    let offset = ((hash % 32) + 1) * 8;
                    self.asm_push_align();
                    self.asm.push(format!(
                        "    mov [rbp-{}], {}", offset, X86_REGISTERS[0]
                    ));
                }
            }

            ICNFInner::BinOp(op, left_id, right_id) => {
                // Use distinct registers for each operand.
                let dest_reg = "rax";  // result goes here
                let src1_reg = "rcx";  // left operand
                let src2_reg = "rdx";  // right operand

                // Load operands into specific registers via ID-based lookup.
                self.emit_load_into(*left_id, src1_reg, stmts, local_vars);
                self.emit_load_into(*right_id, src2_reg, stmts, local_vars);

                match op {
                    BinOpKind::Add => {
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, {}", reg_to_32(dest_reg), reg_to_32(src1_reg)));
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    add {}, {}", reg_to_32(dest_reg), reg_to_32(src2_reg)
                        ));
                    }
                    BinOpKind::Sub => {
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    sub {}, {}", reg_to_32(dest_reg), reg_to_32(src2_reg)
                        ));
                    }
                    BinOpKind::Mul => {
                        let d = reg_to_32(dest_reg);
                        let s1 = reg_to_32(src1_reg);
                        self.asm_push_align();
                        self.asm.push(format!("    mov {}, {}", d, s1));
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    imul {}, {}", d, reg_to_32(src2_reg)
                        ));
                    }
                    BinOpKind::Div | BinOpKind::Rem => {
                        let d = reg_to_32(dest_reg);
                        // Use edx:eax for division.
                        self.asm_push_align();
                        self.asm.push(format!("    mov eax, {}", reg_to_32(src1_reg)));
                        self.asm_push_align();
                        self.asm.push("    cdq".to_string());  // Sign-extend into edx:eax.
                        if op == &BinOpKind::Div {
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    idiv {}", reg_to_32(src2_reg)
                            ));
                            self.asm_push_align();
                            self.asm.push(
                                format!("    mov {}, eax", d),
                            );
                        } else {
                            // Remainder is in edx after idiv.
                            let dd = reg_to_32(dest_reg);
                            self.asm_push_align();
                            self.asm.push(format!(
                                "    mov {}, edx", dd
                            ));  // Remainder in rdx.
                        }
                    }
                    BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt
                    | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge => {
                        let d = reg_to_32(dest_reg);
                        self.emit_cmp_and_set(op, src1_reg, src2_reg, d);
                    }
                    BinOpKind::And => {
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    and {}, {}", reg_to_32(dest_reg), reg_to_32(src1_reg)
                        ));
                    }
                    BinOpKind::Or => {
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    or {}, {}", reg_to_32(dest_reg), reg_to_32(src1_reg)
                        ));
                    }
                }
            }

            ICNFInner::UnOp(op, arg_id) => {
                let reg = self.alloc_reg();
                // Load operand using ID-based lookup.
                match stmts.iter().find(|n| n.id == *arg_id) {
                    Some(ICNFNode { node: ICNFInner::Const(atom), .. }) => {
                        self.emit_const_into(&reg, atom);
                    }
                    _ => {
                        let hash = simple_hash(&format!("{}", arg_id));
                        let offset = ((hash % 32) + 1) * 8;
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    mov {}, [rbp-{}]", reg, offset
                        ));
                    }
                }

                match op {
                    UnOpKind::Not => {
                        // Logical not: xor with 1 (for boolean values).
                        self.asm_push_align();
                        self.asm.push(format!(
                            "    xor {}, 1", reg_to_32(&reg)
                        ));
                    }
                    UnOpKind::Negate => {
                        // Arithmetic negation.
                        self.asm_push_align();
                        self.asm.push(
                            format!("    neg {}", reg_to_32(&reg)),
                        );
                    }
                }
            }
            ICNFInner::If { cond_ssa, then_body, else_body, result_var } => {
                // The condition should already be computed (in eax from prior BinOp/Load).
                let cond_label = self.new_label();

                // Collect operand IDs for branch bodies to skip intermediate Load nodes.
                let mut then_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                for stmt in then_body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => { then_operand_ids.insert(*l); then_operand_ids.insert(*r); }
                        ICNFInner::UnOp(_, id) => { then_operand_ids.insert(*id); }
                        ICNFInner::Call(_, args) => { for &a in args { then_operand_ids.insert(a); } }
                        ICNFInner::Print(args) => { for &a in args { then_operand_ids.insert(a); } }
                        ICNFInner::If { cond_ssa: c, .. } => { then_operand_ids.insert(*c); }
                        _ => {}
                    }
                }
                let mut else_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                for stmt in else_body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => { else_operand_ids.insert(*l); else_operand_ids.insert(*r); }
                        ICNFInner::UnOp(_, id) => { else_operand_ids.insert(*id); }
                        ICNFInner::Call(_, args) => { for &a in args { else_operand_ids.insert(a); } }
                        ICNFInner::Print(args) => { for &a in args { else_operand_ids.insert(a); } }
                        ICNFInner::If { cond_ssa: c, .. } => { else_operand_ids.insert(*c); }
                        _ => {}
                    }
                }

                // Check condition.
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!(
                    "    je  {}", cond_label
                ));

                // Then branch — fall through (emit inline like While does).
                let then_start = format!("{}.then", result_var);
                let else_start = format!("{}.else", &result_var);
                let join_point = format!("{}.join", &result_var);

                self.asm_push_align();
                self.asm.push(format!("{}:", then_start));

                // Emit the 'then' branch statements inline. Clone local_vars for each branch scope.
                let mut then_local_vars = local_vars.clone();
                for stmt in then_body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *then_local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(&stmt, stmts, &mut then_local_vars, emitted_ids, &then_operand_ids);
                }

                // Jump over else branch.
                self.asm_push_align();
                self.asm.push(format!(
                    "    jmp {}", join_point
                ));

                // Else label (for false condition).
                self.asm_push_align();
                self.asm.push(format!("{}:", cond_label));
                self.asm_push_align();
                self.asm.push(format!("{}:", else_start));

                // Emit the 'else' branch statements inline. Clone local_vars for each branch scope.
                let mut else_local_vars = local_vars.clone();
                for stmt in else_body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *else_local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(&stmt, stmts, &mut else_local_vars, emitted_ids, &else_operand_ids);
                }

                // Join point (phi merge).
                self.asm_push_align();
                self.asm.push(format!("{}:", join_point));
            }

            ICNFInner::While { cond_ssa: _, body } => {
                let loop_start = format!(".while_{}", self.label_counter);
                let loop_end = format!(".wend_{}", self.label_counter);
                self.label_counter += 1;

                // Collect operand IDs for body to skip intermediate Load nodes.
                let mut while_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                for stmt in body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => { while_operand_ids.insert(*l); while_operand_ids.insert(*r); }
                        ICNFInner::UnOp(_, id) => { while_operand_ids.insert(*id); }
                        ICNFInner::Call(_, args) => { for &a in args { while_operand_ids.insert(a); } }
                        ICNFInner::Print(args) => { for &a in args { while_operand_ids.insert(a); } }
                        ICNFInner::If { cond_ssa: c, .. } => { while_operand_ids.insert(*c); }
                        _ => {}
                    }
                }

                self.asm_push_align();
                self.asm.push(format!("{}:", loop_start));

                // Condition check (result in eax).
                self.asm_push_align();
                self.asm.push("    test eax, eax".to_string());
                self.asm_push_align();
                self.asm.push(format!(
                    "    je  {}", loop_end
                ));

                // Body.
                let mut local_vars: HashMap<String, usize> = HashMap::new();
                for stmt in body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(stmt, stmts, &local_vars, emitted_ids, &while_operand_ids);
                }

                // Back jump.
                self.asm_push_align();
                self.asm.push(format!(
                    "    jmp {}", loop_start
                ));
                self.asm_push_align();
                self.asm.push(
                    format!("{}:", loop_end),
                );
            }

            ICNFInner::For { var_name: _, iter_ssa: _, body } => {
                let loop_start = format!(".for_{}", self.label_counter);
                let loop_end = format!(".fend_{}", self.label_counter);
                self.label_counter += 1;

                // Collect operand IDs for body to skip intermediate Load nodes.
                let mut for_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                for stmt in body {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => { for_operand_ids.insert(*l); for_operand_ids.insert(*r); }
                        ICNFInner::UnOp(_, id) => { for_operand_ids.insert(*id); }
                        ICNFInner::Call(_, args) => { for &a in args { for_operand_ids.insert(a); } }
                        ICNFInner::Print(args) => { for &a in args { for_operand_ids.insert(a); } }
                        ICNFInner::If { cond_ssa: c, .. } => { for_operand_ids.insert(*c); }
                        _ => {}
                    }
                }

                // For loops are desugared — emit as while for now.
                self.asm_push_align();
                self.asm.push(format!("{}:", loop_start));
                let mut local_vars: HashMap<String, usize> = HashMap::new();
                for stmt in body {
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(stmt, stmts, &local_vars, emitted_ids, &for_operand_ids);
                }
                self.asm_push_align();
                self.asm.push(format!(
                    "    jmp {}", loop_start
                ));
                self.asm_push_align();
                self.asm_push_align();
                self.asm.push(
                    format!("{}:", loop_end),
                );
            }

            ICNFInner::Print(args) => {
                if args.is_empty() { return; }

                // Helper to find a node by ID in stmts.
                let find_node = |id: usize| -> Option<&ICNFNode> {
                    stmts.iter().find(|n| n.id == id)
                };

                // Print each argument. Detect string vs int based on the node type.
                for &arg_id in args.iter() {
                    let is_string = match find_node(arg_id) {
                        Some(ICNFNode { node: ICNFInner::Const(Atom::Str(_)), .. }) => true,
                        _ => false,
                    };

                    if is_string {
                        // String argument — load pointer into rdi.
                        let reg = self.alloc_reg();
                        match find_node(arg_id) {
                            Some(ICNFNode { node: ICNFInner::Const(Atom::Str(s)), .. }) => {
                                let str_label = self.emit_string_literal(s);
                                self.asm_push_align();
                                self.asm.push(format!(
                                    "    lea rdi, [{}] ", str_label
                                ));
                            }
                            _ => {
                                // String loaded from memory — already in a register.
                                self.asm_push_align();
                                self.asm.push("    mov rdi, rax".to_string());
                            }
                        }

                        // Use %s format for strings.
                        let fmt_label = ".fmt_str";
                        if !self.asm.iter().any(|l| l.starts_with(fmt_label)) {
                            self.asm_push_align();
                            self.asm.push(format!("{}:", fmt_label));
                            self.asm.push(r#"    .string "%s\n""#.to_string());
                        }

                        self.asm_push_align();
                        self.asm.push(
                            "    xor eax, eax           # No xmm args to printf"
                                .to_string(),
                        );
                        self.asm_push_align();
                        self.asm.push("    call printf@plt".to_string());
                    } else {
                        // Integer argument — convert to string and print.
                        // Load the argument value into eax first.
                        self.emit_load_into(arg_id, "eax", stmts, local_vars);
                        let int_reg = "eax";  // Value should be in eax from prior computation.

                        // First, emit the integer-to-string conversion.
                        self.emit_int_to_str(int_reg);

                        // Now rax holds pointer to null-terminated string.
                        // Use %s format for printing.
                        let fmt_label = ".fmt_str";
                        if !self.asm.iter().any(|l| l.starts_with(fmt_label)) {
                            self.asm_push_align();
                            self.asm.push(format!("{}:", fmt_label));
                            self.asm.push(r#"    .string "%s\n""#.to_string());
                        }

                        // After int-to-str, rdi already points to the converted string.
                        
                        self.asm_push_align();
                        self.asm.push(
                            "    xor eax, eax           # No xmm args to printf"
                                .to_string(),
                        );
                        self.asm_push_align();
                        self.asm.push("    call printf@plt".to_string());
                    }
                }
            }

            ICNFInner::Call(name, args) => {
                // Function call — pass arguments in registers per System V ABI.
                let abi_regs = ["edi", "esi", "edx", "ecx", "r8d", "r9d"];
                
                for (i, &arg_id) in args.iter().enumerate() {
                    if i < 6 {
                        // Load argument value into the appropriate ABI register.
                        let reg = abi_regs[i];
                        self.emit_load_into(arg_id, reg, stmts, local_vars);
                    }
                }

                // User-defined functions use _ZYL_ prefix; skip libc calls.
                let fn_name = if name == "printf" || name == "exit" {
                    return;  // Skip — handled specially elsewhere.
                } else {
                    format!("_ZYL_{}", name)
                };

                self.asm_push_align();
                self.asm.push(format!(
                    "    call {}", fn_name
                ));
            }

            ICNFInner::Exit(_code_id) => {
                // Exit with status code using exit() from libc.
                self.asm_push_align();
                self.asm.push(
                    "    xor edi, edi           # exit(0)".to_string(),
                );
                self.asm_push_align();
                self.asm.push("    call exit@plt".to_string());
            }

            ICNFInner::Unit | ICNFInner::Closure(_) => {
                // No-op in assembly.
            }

            ICNFInner::Begin(stmts) => {
                let mut local_vars: HashMap<String, usize> = HashMap::new();
                // Collect operand IDs for body to skip intermediate Load nodes.
                let mut begin_operand_ids: std::collections::HashSet<usize> = HashSet::new();
                for stmt in stmts.iter() {
                    match &stmt.node {
                        ICNFInner::BinOp(_, l, r) => { begin_operand_ids.insert(*l); begin_operand_ids.insert(*r); }
                        ICNFInner::UnOp(_, id) => { begin_operand_ids.insert(*id); }
                        ICNFInner::Call(_, args) => { for &a in args { begin_operand_ids.insert(a); } }
                        ICNFInner::Print(args) => { for &a in args { begin_operand_ids.insert(a); } }
                        ICNFInner::If { cond_ssa: c, .. } => { begin_operand_ids.insert(*c); }
                        _ => {}
                    }
                    if let ICNFInner::Assign(name, _) = &stmt.node {
                        *local_vars.entry(name.clone()).or_insert(0) += 1;
                    }
                    self.emit_node(stmt, stmts, &local_vars, emitted_ids, &begin_operand_ids);
                }
            }

            _ => {
                // Unsupported/unimplemented nodes — emit a nop placeholder.
                self.asm_push_align();
                self.asm.push("    nop  # unimplemented".to_string());
            }
        }
    }

    /// Emit compare-and-set instruction for comparison operators.
    fn emit_cmp_and_set(
        &mut self,
        op: &BinOpKind,
        src1_reg: &str,   // first operand (already loaded)
        src2_reg: &str,   // second operand (already loaded)
        dest_reg: &str,   // destination for result (0 or 1).
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
        self.asm.push(format!(
            "    cmp {}, {}", src1_reg, src2_reg
        ));
        // Zero-extend the result byte into full register (e.g., al → eax).
        match op {
            BinOpKind::Eq | BinOpKind::Neq | BinOpKind::Lt
                | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge => {
                self.asm_push_align();
                self.asm.push(
                    format!("    {} al", set_instr),  // Sets al.
                );
                let dest_full = reg_to_32(dest_reg);
                self.asm_push_align();
                self.asm.push(format!(
                    "    movzx {}, al", dest_full
                ));
            }
            _ => {}
        }

        let _ = _comment;  // For debugging comments if needed later.
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
    fn alloc_xmm(&self) -> usize {
        static MAX_XMM: usize = 16;
        let idx = self.label_counter % MAX_XMM;
        idx
    }
}

// ─── Helpers ──────────────────────────────────────────────────────────────

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
        "eax" => "eax", "ecx" => "ecx", "edx" => "edx", "esi" => "esi",
        "edi" => "edi", "r8d" => "r8d", "r9d" => "r9d",
        // 64-bit to 32-bit.
        "rax" => "eax", "rcx" => "ecx", "rdx" => "edx", "rsi" => "esi",
        "rdi" => "edi", "r8" => "r8d", "r9" => "r9d", "r10" => "r10d",
        "r11" => "r11d", "r12" => "r12d", "r13" => "r13d", "r14" => "r14d",
        "r15" => "r15d",
        _ => name,
    }
}
