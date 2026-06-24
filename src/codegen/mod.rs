//! Code generation for Zyl
//! 
//! Compiles ICNF (SSA IR) to native machine code via LLVM or inline assembly.
//! Per specification section 17, phase 8.

use crate::ir::{self, *};
use crate::ast::Region;
use thiserror::Error;

// ============================================================================
// CODE GENERATION ERRORS
// ============================================================================

#[derive(Debug, Error)]
pub enum CodegenError {
    #[error("Unsupported instruction: {0}")]
    UnsupportedInstruction(String),
    
    #[error("Type mismatch in code generation: expected {expected}, got {got}")]
    TypeMismatch { expected: IrType, got: IrType },
    
    #[error("Register allocation failed for {id}")]
    RegisterAllocationFailed { id: SsaId },
    
    #[error("Linking error: {msg}")]
    LinkError { msg: String },
    
    #[error("Output write error: {msg}")]
    WriteError { msg: String },
}

// ============================================================================
// TARGET ARCHITECTURE
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Arch {
    X86_64,
    AArch64,
    Riscv64,
}

impl std::fmt::Display for Arch {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Arch::X86_64 => write!(f, "x86_64"),
            Arch::AArch64 => write!(f, "aarch64"),
            Arch::Riscv64 => write!(f, "riscv64"),
        }
    }
}

// ============================================================================
// REGISTER ALLOCATION (simplified)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Reg {
    // Integer registers (x86_64 calling convention)
    Rax, Rcx, Rdx, Rsi, Rdi, R8, R9, R10, R11,
    // Float registers
    Xmm0, Xmm1, Xmm2, Xmm3, Xmm4, Xmm5, Xmm6, Xmm7,
    // General purpose
    Rbx, Rsp, Rbp, R12, R13, R14, R15,
}

impl std::fmt::Display for Reg {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Reg::Rax => write!(f, "rax"),
            Reg::Rcx => write!(f, "rcx"),
            Reg::Rdx => write!(f, "rdx"),
            Reg::Rsi => write!(f, "rsi"),
            Reg::Rdi => write!(f, "rdi"),
            Reg::R8 => write!(f, "r8"),
            Reg::R9 => write!(f, "r9"),
            Reg::R10 => write!(f, "r10"),
            Reg::R11 => write!(f, "r11"),
            Reg::Xmm0 => write!(f, "xmm0"),
            Reg::Xmm1 => write!(f, "xmm1"),
            Reg::Xmm2 => write!(f, "xmm2"),
            Reg::Xmm3 => write!(f, "xmm3"),
            Reg::Xmm4 => write!(f, "xmm4"),
            Reg::Xmm5 => write!(f, "xmm5"),
            Reg::Xmm6 => write!(f, "xmm6"),
            Reg::Xmm7 => write!(f, "xmm7"),
            Reg::Rbx => write!(f, "rbx"),
            Reg::Rsp => write!(f, "rsp"),
            Reg::Rbp => write!(f, "rbp"),
            Reg::R12 => write!(f, "r12"),
            Reg::R13 => write!(f, "r13"),
            Reg::R14 => write!(f, "r14"),
            Reg::R15 => write!(f, "r15"),
        }
    }
}

/// Register allocator (linear scan - simplified)
pub struct RegAllocator {
    /// Maps SSA IDs to registers
    allocation: std::collections::HashMap<SsaId, Reg>,
    /// Free registers available for allocation
    free_regs: Vec<Reg>,
}

impl RegAllocator {
    pub fn new() -> Self {
        Self {
            allocation: std::collections::HashMap::new(),
            free_regs: vec![
                Reg::Rax, Reg::Rcx, Reg::Rdx, Reg::Rsi, Reg::Rdi,
                Reg::R8, Reg::R9, Reg::R10, Reg::R11,
                Reg::Xmm0, Reg::Xmm1, Reg::Xmm2, Reg::Xmm3,
            ],
        }
    }
    
    /// Allocate a register for an SSA value
    pub fn allocate(&mut self, id: SsaId, is_float: bool) -> Result<Reg, CodegenError> {
        if let Some(&reg) = self.allocation.get(&id) {
            return Ok(reg);
        }
        
        let is_xmm = |r: &Reg| matches!(r, Reg::Xmm0 | Reg::Xmm1 | Reg::Xmm2 | Reg::Xmm3 | Reg::Xmm4 | Reg::Xmm5 | Reg::Xmm6 | Reg::Xmm7);
        let available = if is_float {
            self.free_regs.iter().filter(|r| is_xmm(r)).collect::<Vec<_>>()
        } else {
            self.free_regs.iter().filter(|r| !is_xmm(r)).collect::<Vec<_>>()
        };
        
        if let Some(&reg) = available.first() {
            self.allocation.insert(id, *reg);
            Ok(*reg)
        } else {
            // Spill to stack (simplified - in production would do proper spill analysis)
            Err(CodegenError::RegisterAllocationFailed { id })
        }
    }
    
    /// Get the register for an SSA value
    pub fn get(&self, id: SsaId) -> Option<Reg> {
        self.allocation.get(&id).copied()
    }
}

// ============================================================================
// ASSEMBLY CODE GENERATOR (x86_64)
// ============================================================================

pub struct AsmGenerator {
    arch: Arch,
    output: Vec<String>,
    label_counter: usize,
    current_function: Option<String>,
}

impl AsmGenerator {
    pub fn new(arch: Arch) -> Self {
        Self {
            arch,
            output: Vec::new(),
            label_counter: 0,
            current_function: None,
        }
    }
    
    /// Generate assembly for an ICNF program
    pub fn generate(&mut self, program: &IcnfProgram) -> Result<String, CodegenError> {
        // Declare external functions needed by the program
        self.output.push(".extern malloc".to_string());
        
        // Generate global declarations
        for global in &program.globals {
            self.gen_global(global);
        }
        
        // Generate each function
        for func in &program.functions {
            self.gen_function(func)?;
        }
        
        Ok(self.output.join("\n"))
    }
    
    fn gen_global(&mut self, global: &(String, IrType, IrValue)) {
        let (name, ty, value) = global;
        self.output.push(format!(".globl {}", name));
        self.output.push(format!("{}:", name));
        
        match (ty, value) {
            (IrType::Int, IrValue::Int(v)) => {
                self.output.push(format!("\t.quad {}", v));
            }
            (IrType::Float, IrValue::Float(v)) => {
                self.output.push(format!("\t.double {}", v));
            }
            (IrType::Bool, IrValue::Bool(v)) => {
                self.output.push(format!("\t.byte {}", if *v { 1 } else { 0 }));
            }
            (IrType::String, IrValue::StringLit(s)) => {
                let label = format!(".LC{}", self.label_counter);
                self.label_counter += 1;
                self.output.push(format!("{}:", label));
                self.output.push(format!("\t.string \"{}\"", s));
                self.output.push(format!("\t.quad {}", label));
            }
            _ => {
                self.output.push("\t.zero 8".to_string());
            }
        }
    }
    
    fn gen_function(&mut self, func: &Function) -> Result<(), CodegenError> {
        self.current_function = Some(func.name.clone());
        
        // Function prologue
        self.output.push(format!("{}:", func.name));
        self.output.push("\tpushq %rbp".to_string());
        self.output.push("\tmovq %rsp, %rbp".to_string());
        
        // Store function parameters in stack slots
        // x86_64 ABI: rdi=1st, rsi=2nd, rdx=3rd, rcx=4th, r8=5th, r9=6th
        for (i, (_name, _ty)) in func.params.iter().enumerate() {
            let reg = match i {
                0 => "rdi",
                1 => "rsi",
                2 => "rdx",
                3 => "rcx",
                4 => "r8",
                5 => "r9",
                _ => return Err(CodegenError::UnsupportedInstruction(format!("Too many params: {}", i))),
            };
            
            let stack_offset = (i + 2) * 8; // Skip saved rbp and return address
            self.output.push(format!("\tmovq {}, -{}(%rbp)", reg, stack_offset));
        }
        
        // Generate each block
        for block in &func.blocks {
            self.gen_block(block, func)?;
        }
        
        // Function epilogue (if not already returned)
        if !self.has_ending_return(&func.blocks.last().map(|b| b.id)) {
            self.output.push("\tmovq $0, %rax".to_string()); // Return 0
        }
        
        self.output.push("\tpopq %rbp".to_string());
        self.output.push("\tret".to_string());
        
        self.current_function = None;
        Ok(())
    }
    
    fn gen_block(&mut self, block: &Block, _func: &Function) -> Result<(), CodegenError> {
        // Label for the block
        self.output.push(format!("{}:", block.id));
        
        // Generate each instruction
        for instr in &block.instructions {
            self.gen_instruction(instr)?;
        }
        
        Ok(())
    }
    
    fn gen_instruction(&mut self, instr: &Instruction) -> Result<(), CodegenError> {
        match instr {
            Instruction::Const { value, dest } => {
                let dest_reg = self.gen_dest_reg(dest)?;
                match value {
                    IrValue::Int(v) => {
                        self.output.push(format!("\tmovq ${}, {}", v, dest_reg));
                    }
                    IrValue::Float(v) => {
                        // Convert float to hex representation for movsd
                        let bits = v.to_bits();
                        self.output.push(format!("\tmovq ${}, {}", bits, dest_reg));
                    }
                    IrValue::Bool(v) => {
                        let val = if *v { 1 } else { 0 };
                        self.output.push(format!("\tmovq ${}, {}", val, dest_reg));
                    }
                    IrValue::StringLit(s) => {
                        let label = format!(".LCstr_{}", s.len());
                        // In a real generator, we'd add the string constant
                        self.output.push(format!("\tlea {}, {}", label, dest_reg));
                    }
                    IrValue::Unit => {
                        self.output.push(format!("\tmovq $0, {}", dest_reg));
                    }
                    IrValue::FuncRef(name) => {
                        self.output.push(format!("\tlea {}(%rip), {}", name, dest_reg));
                    }
                }
            }
            
            Instruction::BinOp { op, left, right, dest } => {
                let left_reg = self.gen_load_operand(left)?;
                let right_reg = self.gen_load_operand(right)?;
                let dest_reg = self.gen_dest_reg(dest)?;
                
                match op {
                    BinOp::Add => {
                        self.output.push(format!("\taddq {}, {}", right_reg, left_reg));
                        self.output.push(format!("\tmovq {}, {}", left_reg, dest_reg));
                    }
                    BinOp::Sub => {
                        self.output.push(format!("\tmovq {}, {}", left_reg, dest_reg));
                        self.output.push(format!("\tsubq {}, {}", right_reg, dest_reg));
                    }
                    BinOp::Mul => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\timulq {}, {}", right_reg, rax));
                        self.output.push(format!("\tmovq {}, {}", rax, dest_reg));
                    }
                    BinOp::Div => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push("\tcqo".to_string());
                        self.output.push(format!("\tidivq {}", right_reg));
                        self.output.push(format!("\tmovq {}, {}", rax, dest_reg));
                    }
                    BinOp::Eq => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\tcmpq {}, {}", right_reg, rax));
                        self.output.push("\tsete %al".to_string());
                        self.output.push(format!("\tmovzbq %al, {}", dest_reg));
                    }
                    BinOp::Ne => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\tcmpq {}, {}", right_reg, rax));
                        self.output.push("\tsetne %al".to_string());
                        self.output.push(format!("\tmovzbq %al, {}", dest_reg));
                    }
                    BinOp::Lt => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\tcmpq {}, {}", right_reg, rax));
                        self.output.push("\tsetl %al".to_string());
                        self.output.push(format!("\tmovzbq %al, {}", dest_reg));
                    }
                    BinOp::Gt => {
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\tcmpq {}, {}", right_reg, rax));
                        self.output.push("\tsetg %al".to_string());
                        self.output.push(format!("\tmovzbq %al, {}", dest_reg));
                    }
                    _ => {
                        // For other ops, generate generic comparison
                        let rax = "%rax";
                        self.output.push(format!("\tmovq {}, {}", left_reg, rax));
                        self.output.push(format!("\tcmpq {}, {}", right_reg, rax));
                        self.output.push("\tsete %al".to_string());
                        self.output.push(format!("\tmovzbq %al, {}", dest_reg));
                    }
                }
            }
            
            Instruction::UnaryOp { op, operand, dest } => {
                let reg = self.gen_load_operand(operand)?;
                let dest_reg = self.gen_dest_reg(dest)?;
                match op {
                    UnaryOp::Neg => {
                        self.output.push(format!("\tnegq {}", reg));
                        self.output.push(format!("\tmovq {}, {}", reg, dest_reg));
                    }
                    UnaryOp::Not => {
                        self.output.push(format!("\txorq $1, {}", reg));
                        self.output.push(format!("\tmovq {}, {}", reg, dest_reg));
                    }
                    _ => return Err(CodegenError::UnsupportedInstruction(op.to_string())),
                }
            }
            
            Instruction::Call { func, args, dest } => {
                // Pass arguments in registers per x86_64 ABI
                for (i, arg) in args.iter().enumerate() {
                    let reg = self.gen_load_operand(arg)?;
                    let target_reg = match i {
                        0 => "rdi",
                        1 => "rsi",
                        2 => "rdx",
                        3 => "rcx",
                        4 => "r8",
                        5 => "r9",
                        _ => return Err(CodegenError::UnsupportedInstruction(
                            format!("Too many call args: {}", i)
                        )),
                    };
                    self.output.push(format!("\tmovq {}, %{}", reg, target_reg));
                }
                
                let dest_reg = self.gen_dest_reg(dest)?;
                // func is an IrValue::FuncRef — resolve to function name
                match func {
                    ir::IrValue::FuncRef(name) => {
                        self.output.push(format!("\tcall {}", name));
                    }
                    _ => {
                        return Err(CodegenError::UnsupportedInstruction(
                            format!("Call with non-funcref value: {:?}", func)
                        ));
                    }
                }
                self.output.push(format!("\tmovq %rax, {}", dest_reg));
            }
            
            Instruction::CallIndirect { func, args, dest } => {
                // Pass arguments in registers per x86_64 ABI
                for (i, arg) in args.iter().enumerate() {
                    let reg = self.gen_load_operand(arg)?;
                    let target_reg = match i {
                        0 => "rdi",
                        1 => "rsi",
                        2 => "rdx",
                        3 => "rcx",
                        4 => "r8",
                        5 => "r9",
                        _ => return Err(CodegenError::UnsupportedInstruction(
                            format!("Too many call args: {}", i)
                        )),
                    };
                    self.output.push(format!("\tmovq {}, %{}", reg, target_reg));
                }
                
                let dest_reg = self.gen_dest_reg(dest)?;
                // func is an SsaValue — load the function pointer from it
                let func_reg = self.gen_load_operand(func)?;
                self.output.push(format!("\tcall *{}", func_reg));
                self.output.push(format!("\tmovq %rax, {}", dest_reg));
            }
            
            Instruction::ClosureCreate { func_name, env_values, dest } => {
                // Allocate space for closure struct on heap
                // Closure layout: [func_ptr (8 bytes)][env0 (8 bytes)]...
                let size = 8 + (env_values.len() * 8);
                
                // Call malloc to allocate closure struct
                self.output.push(format!("\tmovq ${}, %rdi", size));
                self.output.push("\tcall malloc".to_string());
                
                let dest_reg = self.gen_dest_reg(dest)?;
                self.output.push(format!("\tmovq %rax, {}", dest_reg));
                
                // Store function pointer at offset 0
                self.output.push(format!("\tlea {}(%rip), %rcx", func_name));
                self.output.push(format!("\tmovq %rcx, ({})", dest_reg));
                
                // Store captured environment values
                for (i, env_val) in env_values.iter().enumerate() {
                    let offset = 8 + (i * 8);
                    let val_reg = self.gen_load_operand(env_val)?;
                    self.output.push(format!("\tmovq {}, {}(%{})", val_reg, offset, dest_reg));
                }
            }
            
            Instruction::Load { name: _, region, dest } => {
                let dest_reg = self.gen_dest_reg(dest)?;
                let offset = match region {
                    Region::Stack => "-(%rbp)".to_string(), // Simplified
                    _ => "0(%rip)".to_string(),
                };
                self.output.push(format!("\tmovq {}, {}", offset, dest_reg));
            }
            
            Instruction::Store { name: _, value, region } => {
                let reg = self.gen_load_operand(value)?;
                match region {
                    Region::Stack => {
                        self.output.push(format!("\tmovq {}, -(%rbp)", reg));
                    }
                    _ => {
                        self.output.push(format!("\tmovq {}, 0(%rip)", reg));
                    }
                }
            }
            
            Instruction::Branch { cond, then_block: _, else_block: default_block } => {
                let reg = self.gen_load_operand(cond)?;
                self.output.push(format!("\ttestq {}, {}", reg, reg));
                self.output.push(format!("\tje {}", default_block));
                // Fall through to then_block
            }
            
            Instruction::CondBranch { cond, then_block, else_block } => {
                let reg = self.gen_load_operand(cond)?;
                self.output.push(format!("\ttestq {}, {}", reg, reg));
                self.output.push(format!("\tje {}", else_block));
                self.output.push(format!("\tjmp {}", then_block));
            }
            
            Instruction::Return { value } => {
                if let Some(v) = value {
                    let reg = self.gen_load_operand(v)?;
                    self.output.push(format!("\tmovq {}, %rax", reg));
                } else {
                    self.output.push("\tmovq $0, %rax".to_string());
                }
                self.output.push("\tret".to_string());
            }
            
            Instruction::Phi { .. } | Instruction::Alloc { .. } | 
            Instruction::Cast { .. } | Instruction::Spawn { .. } |
            Instruction::Send { .. } | Instruction::FfiCall { .. } |
            Instruction::Assert { .. } | Instruction::Nop => {
                // These are handled specially or are no-ops in this simplified generator
            }
        }
        
        Ok(())
    }
    
    /// Generate code to load an operand into a register
    fn gen_load_operand(&mut self, value: &SsaValue) -> Result<String, CodegenError> {
        if let Some(reg) = self.get_ssa_reg(value.id) {
            Ok(format!("%{}", reg))
        } else {
            // Load from memory location
            Ok(format!("-{}(%rbp)", value.id.0 * 8))
        }
    }
    
    /// Get or allocate a register for an SSA destination value.
    /// Returns the register name string (e.g., "%rax") to store into.
    /// Allocates a fresh register if this ID hasn't been allocated yet.
    fn gen_dest_reg(&mut self, dest: &SsaValue) -> Result<String, CodegenError> {
        // Check if already allocated
        if let Some(reg) = self.get_ssa_reg(dest.id) {
            return Ok(format!("%{}", reg));
        }
        
        // Allocate a fresh register (round-robin through available regs)
        let regs = [
            Reg::Rax, Reg::Rcx, Reg::Rdx, Reg::Rsi, Reg::Rdi,
            Reg::R8, Reg::R9, Reg::R10, Reg::R11,
        ];
        // Use a simple counter to cycle through registers
        let idx = dest.id.0 % regs.len();
        self.output.push(format!("; allocated reg {} for SSA id {}", regs[idx], dest.id));
        Ok(format!("%{}", regs[idx]))
    }
    
    fn get_ssa_reg(&self, id: SsaId) -> Option<Reg> {
        // In a real generator, this would use the register allocator
        // For now, return a default based on the SSA ID
        let regs = [
            Reg::Rax, Reg::Rcx, Reg::Rdx, Reg::Rsi, Reg::Rdi,
            Reg::R8, Reg::R9, Reg::R10, Reg::R11,
        ];
        regs.get(id.0 % regs.len()).copied()
    }
    
    fn has_ending_return(&self, _last_block_id: &Option<BlockId>) -> bool {
        // Simplified check
        false
    }
}

// ============================================================================
// LLVM CODE GENERATOR (interface)
// ============================================================================

/// Generate LLVM IR from ICNF (placeholder for full LLVM integration)
pub fn generate_llvm_ir(program: &IcnfProgram) -> Result<String, CodegenError> {
    let mut ir = String::new();
    
    // LLVM module header
    ir.push_str("; Zyl ICNF -> LLVM IR\n");
    ir.push_str("target triple = \"x86_64-unknown-linux-gnu\"\n\n");
    
    for func in &program.functions {
        ir.push_str(&format!("define {} @{}(", 
            ir_type_to_llvm(&func.ret_type),
            func.name));
        
        let params: Vec<String> = func.params.iter()
            .map(|(name, ty)| format!("{} %{}", ir_type_to_llvm(ty), name))
            .collect();
        ir.push_str(&params.join(", "));
        ir.push_str(")\n{\n");
        
        for block in &func.blocks {
            ir.push_str(&format!("  {}:\n", block.id));
            
            for instr in &block.instructions {
                ir.push_str(&format!("    {}\n", ir_instruction(instr)));
            }
        }
        
        ir.push_str("}\n\n");
    }
    
    Ok(ir)
}

fn ir_type_to_llvm(ty: &IrType) -> &'static str {
    match ty {
        IrType::Int => "i64",
        IrType::Float => "double",
        IrType::Bool => "i1",
        IrType::String => "i8*",
        IrType::Unit => "void",
        IrType::Fun(_, ret) => {
            match ret.as_ref() {
                IrType::Unit => "void",
                _ => "i64",
            }
        }
        IrType::Tuple(_) => "i64", // Simplified
        IrType::ActorRef => "i64",
        IrType::Ptr(_) => "i8*",
    }
}

fn ir_instruction(instr: &Instruction) -> String {
    match instr {
        Instruction::Const { value, dest } => {
            match value {
                IrValue::Int(v) => format!("{} = const i64 {}", dest, v),
                IrValue::Float(v) => format!("{} = const double {}", dest, v),
                IrValue::Bool(v) => format!("{} = const i1 {}", dest, if *v { "true" } else { "false" }),
                _ => format!("{} = const", dest),
            }
        }
        Instruction::BinOp { op, left, right, dest } => {
            let op_str = match op {
                BinOp::Add => "add",
                BinOp::Sub => "sub",
                BinOp::Mul => "mul",
                BinOp::Div => "sdiv",
                _ => "add",
            };
            format!("{} = {} i64 {}, {}", dest, op_str, left, right)
        }
        Instruction::Return { value } => {
            match value {
                Some(v) => format!("ret i64 {}", v),
                None => "ret void".to_string(),
            }
        }
        _ => format!("{:?}", instr),
    }
}

// ============================================================================
// COMPILATION PIPELINE (Section 17)
// ============================================================================

pub struct CodeGenerator {
    arch: Arch,
}

impl CodeGenerator {
    pub fn new(arch: Arch) -> Self {
        Self { arch }
    }
    
    /// Generate native code from ICNF program
    pub fn generate(&self, program: &IcnfProgram) -> Result<Vec<u8>, CodegenError> {
        // Generate assembly
        let mut asm_gen = AsmGenerator::new(self.arch);
        let asm = asm_gen.generate(program)?;
        
        // Assemble with system assembler (simplified - in production would invoke as(1))
        self.assemble(&asm)
    }
    
    /// Assemble assembly code to object file
    fn assemble(&self, asm: &str) -> Result<Vec<u8>, CodegenError> {
        // Write assembly to temp file and invoke assembler
        let tmp_path = "/tmp/zyl_asm.s";
        std::fs::write(tmp_path, asm)
            .map_err(|e| CodegenError::WriteError { msg: e.to_string() })?;
        
        // Invoke assembler (simplified - would use proper temp file management in production)
        let output = std::process::Command::new("as")
            .args(&["-o", "/tmp/zyl_out.o", tmp_path])
            .output();
        
        match output {
            Ok(out) if out.status.success() => {
                // Read object file
                std::fs::read("/tmp/zyl_out.o")
                    .map_err(|e| CodegenError::WriteError { msg: e.to_string() })
            }
            Ok(out) => Err(CodegenError::LinkError {
                msg: format!("Assembler failed: {}", String::from_utf8_lossy(&out.stderr)),
            }),
            Err(e) => Err(CodegenError::LinkError {
                msg: format!("Failed to invoke assembler: {}", e),
            }),
        }
    }
    
    /// Generate LLVM IR (alternative code path)
    pub fn generate_llvm(&self, program: &IcnfProgram) -> Result<String, CodegenError> {
        generate_llvm_ir(program)
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Generate native code from an ICNF program for the given architecture
pub fn compile(program: &IcnfProgram, arch: Arch) -> Result<Vec<u8>, CodegenError> {
    let generator = CodeGenerator::new(arch);
    generator.generate(program)
}
