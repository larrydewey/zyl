//! Compiler Pipeline for Zyl
//! 
//! Per specification section 17:
//! Phases (strict order):
//! 1. Macro expansion
//! 2. Parsing
//! 3. Type inference
//! 4. Region inference
//! 5. Monomorphization
//! 6. ICNF generation
//! 7. Optimization (safe only)
//! 8. Code generation
//! 9. Linking
//! 10. Hash finalization

use crate::ast::*;
use crate::lexer;
use crate::parser;
use crate::typeck;
use crate::region;
use crate::macros;
use crate::ir;
use crate::codegen;
use crate::ast::Region;
use thiserror::Error;

// ============================================================================
// COMPILER ERRORS (Section 19)
// ============================================================================

#[derive(Debug, Error)]
pub enum CompilerError {
    #[error("Lexical error: {0}")]
    Lex(#[from] lexer::LexError),
    
    #[error("Parse error: {0}")]
    Parse(#[from] parser::ParseError),
    
    #[error("Type error: {0}")]
    Type(#[from] typeck::TypeError),
    
    #[error("Region error: {0}")]
    Region(#[from] region::RegionError),
    
    #[error("Macro error: {0}")]
    Macro(#[from] macros::MacroError),
    
    #[error("IR error: {0}")]
    Ir(#[from] ir::SsaError),
    
    #[error("Codegen error: {0}")]
    Codegen(#[from] codegen::CodegenError),
    
    #[error("Linking error: {msg}")]
    Link { msg: String },
    
    #[error("Phase violation: phase {phase} cannot depend on later phases")]
    PhaseViolation { phase: usize },
}

// ============================================================================
// COMPILATION RESULT
// ============================================================================

#[derive(Debug)]
pub struct CompilationResult {
    /// The compiled binary (object code)
    pub object_code: Vec<u8>,
    /// SHA-256 hash of the final binary (determinism contract - Section 18)
    pub hash: String,
    /// Warnings produced during compilation
    pub warnings: Vec<String>,
}

impl std::fmt::Display for CompilationResult {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "Compilation successful")?;
        writeln!(f, "  Object code size: {} bytes", self.object_code.len())?;
        writeln!(f, "  Binary hash: {}", self.hash)?;
        if !self.warnings.is_empty() {
            writeln!(f, "  Warnings: {}", self.warnings.len())?;
            for warning in &self.warnings {
                writeln!(f, "    - {}", warning)?;
            }
        }
        Ok(())
    }
}

// ============================================================================
// COMPILER (Section 17 Pipeline)
// ============================================================================

pub struct Compiler {
    /// Architecture target
    arch: codegen::Arch,
    /// Optimization level
    opt_level: usize,
    /// Warnings collector
    warnings: Vec<String>,
    /// Counter for generating unique lambda function names
    lambda_counter: std::cell::Cell<usize>,
}

impl Compiler {
    pub fn new(arch: codegen::Arch) -> Self {
        Self {
            arch,
            opt_level: 1, // Default: O1
            warnings: Vec::new(),
            lambda_counter: std::cell::Cell::new(0),
        }
    }
    
    /// Set optimization level (0-3)
    pub fn with_optimization(mut self, level: usize) -> Self {
        self.opt_level = level.min(3);
        self
    }
    
    /// Compile Zyl source code to native object code
    pub fn compile(&mut self, source: &str) -> Result<CompilationResult, CompilerError> {
        // Phase 1: Macro expansion (includes parsing)
        let program = self.phase_macro_expansion(source)?;
        
        // Phase 2: Parsing validation (already done in phase 1)
        // The program from macro expansion is already a valid parsed AST
        
        // Phase 3: Type inference
        let (_env, subst) = self.phase_type_inference(&program)?;
        
        // Phase 4: Region inference
        let _region_map = self.phase_region_inference(&program)?;
        
        // Phase 5: Monomorphization
        let program = self.phase_monomorphization(&program, &subst)?;
        
        // Phase 6: ICNF generation (with closure support)
        let icnf = self.phase_icnf_generation(&program)?;
        
        // Phase 7: Optimization (safe only)
        let icnf = self.phase_optimization(&icnf)?;
        
        // Phase 8: Code generation
        let object_code = self.phase_code_generation(&icnf)?;
        
        // Phase 9: Linking
        let linked = self.phase_linking(&object_code)?;
        
        // Phase 10: Hash finalization (determinism contract)
        let hash = self.phase_hash_finalization(&linked);
        
        Ok(CompilationResult {
            object_code: linked,
            hash,
            warnings: std::mem::take(&mut self.warnings),
        })
    }
    
    // ------------------------------------------------------------------------
    // PHASE 1: Macro Expansion
    // ------------------------------------------------------------------------
    
    fn phase_macro_expansion(&self, source: &str) -> Result<Program, CompilerError> {
        let program = parser::parse(source)?;
        let mut expander = macros::new_expander();
        let expanded = expander.expand_program(&program)?;
        Ok(expanded)
    }
    
    // ------------------------------------------------------------------------
    // PHASE 3: Type Inference
    // ------------------------------------------------------------------------
    
    fn phase_type_inference(&mut self, program: &Program) -> Result<(typeck::TypeEnv, typeck::Substitution), CompilerError> {
        let (env, subst) = typeck::check_program(program)?;
        if self.opt_level >= 2 {
            self.warnings.push("Type inference complete".to_string());
        }
        Ok((env, subst))
    }
    
    // ------------------------------------------------------------------------
    // PHASE 4: Region Inference
    // ------------------------------------------------------------------------
    
    fn phase_region_inference(&mut self, program: &Program) -> Result<region::RegionMap, CompilerError> {
        let region_map = region::infer_program_regions(program)?;
        if self.opt_level >= 2 {
            self.warnings.push("Region inference complete".to_string());
        }
        Ok(region_map)
    }
    
    // ------------------------------------------------------------------------
    // PHASE 5: Monomorphization (Section 13)
    // ------------------------------------------------------------------------
    
    fn phase_monomorphization(
        &self,
        program: &Program,
        _subst: &typeck::Substitution,
    ) -> Result<Program, CompilerError> {
        let mut new_defs = Vec::new();
        
        for def in &program.defs {
            match def {
                Expr::Defn { name, params, body, ret_type } => {
                    let specialized = self.monomorphize_def(name, params, body, ret_type)?;
                    new_defs.push(specialized);
                }
                other => {
                    new_defs.push(other.clone());
                }
            }
        }
        
        Ok(Program::new(new_defs, program.body.clone()))
    }
    
    fn monomorphize_def(
        &self,
        name: &str,
        params: &[String],
        body: &Expr,
        ret_type: &Option<TypeExpr>,
    ) -> Result<Expr, CompilerError> {
        let _ = (name, params, body, ret_type);
        // In a full implementation, this would instantiate generic types
        Ok(Expr::Defn {
            name: name.to_string(),
            params: params.to_vec(),
            body: Box::new(body.clone()),
            ret_type: ret_type.clone(),
        })
    }
    
    // ------------------------------------------------------------------------
    // PHASE 6: ICNF Generation (SSA IR)
    // ------------------------------------------------------------------------
    
    fn phase_icnf_generation(&self, program: &Program) -> Result<ir::IcnfProgram, CompilerError> {
        let mut icnf = ir::new_program();
        
        // Generate a main function from the program body
        let mut main_func = self.expr_to_icnf(program, &program.body)?;
        
        // Collect any lambda functions generated during main func creation
        let extra_funcs = std::mem::take(&mut main_func.extra_functions);
        icnf.functions.extend(extra_funcs);
        icnf.add_function(main_func);
        
        // Generate functions from definitions
        for def in &program.defs {
            if let Expr::Defn { name, params, body, ret_type } = def {
                let mut func = self.defn_to_icnf(program, name, params, body, ret_type)?;
                let extra_funcs = std::mem::take(&mut func.extra_functions);
                icnf.functions.extend(extra_funcs);
                icnf.add_function(func);
            }
        }
        
        Ok(icnf)
    }
    
    /// Generate a unique lambda function name
    fn fresh_lambda_name(&self) -> String {
        let id = self.lambda_counter.get();
        self.lambda_counter.set(id + 1);
        format!("lambda_{}", id)
    }
    
    fn expr_to_icnf(&self, program: &Program, expr: &Expr) -> Result<ir::Function, CompilerError> {
        let mut func = ir::Function::new(
            "main".to_string(),
            vec![],
            ir::IrType::Int,
        );
        
        self.expr_to_blocks(program, expr, &mut func)?;
        
        // Add return instruction with the last computed SSA value if available
        let ret_value = if func.current_block().instructions.is_empty() {
            None
        } else {
            Some(ir::SsaValue {
                id: ir::SsaId(func.current_block().instructions.len() - 1),
                region: crate::ast::Region::Stack,
            })
        };
        func.current_block_mut().add_instruction(ir::Instruction::Return { value: ret_value });
        
        Ok(func)
    }
    
    fn defn_to_icnf(
        &self,
        program: &Program,
        name: &str,
        params: &[String],
        body: &Expr,
        ret_type: &Option<TypeExpr>,
    ) -> Result<ir::Function, CompilerError> {
        let _ = program; // Program context available for function lookup
        let ret_ty = match ret_type {
            Some(TypeExpr::Prim(PrimType::Int)) => ir::IrType::Int,
            Some(TypeExpr::Prim(PrimType::Float)) => ir::IrType::Float,
            Some(TypeExpr::Prim(PrimType::Bool)) => ir::IrType::Bool,
            Some(TypeExpr::Prim(PrimType::String)) => ir::IrType::String,
            Some(TypeExpr::Prim(PrimType::Unit)) => ir::IrType::Unit,
            _ => ir::IrType::Int,
        };
        
        let param_tys: Vec<(String, ir::IrType)> = params.iter()
            .map(|p| (p.clone(), ir::IrType::Int))
            .collect();
        
        let mut func = ir::Function::new(name.to_string(), param_tys, ret_ty);
        self.expr_to_blocks(program, body, &mut func)?;
        
        // Return the last computed SSA value if available
        let ret_value = if func.current_block().instructions.is_empty() {
            None
        } else {
            Some(ir::SsaValue {
                id: ir::SsaId(func.current_block().instructions.len() - 1),
                region: crate::ast::Region::Stack,
            })
        };
        func.current_block_mut().add_instruction(ir::Instruction::Return { value: ret_value });
        
        Ok(func)
    }
    
    /// Helper: create an SSA value at the current instruction position
    fn ssa_val(&self, func: &ir::Function) -> ir::SsaValue {
        let id = ir::SsaId(func.current_block().instructions.len());
        ir::SsaValue { id, region: Region::Stack }
    }
    
    /// Helper: get the SSA value at a given instruction index
    fn ssa_at(&self, func: &ir::Function, idx: usize) -> ir::SsaValue {
        let _ = func; // func is available for future use (e.g., block info)
        ir::SsaValue { id: ir::SsaId(idx), region: Region::Stack }
    }
    
    fn expr_to_blocks(&self, program: &Program, expr: &Expr, func: &mut ir::Function) -> Result<(), CompilerError> {
        match expr {
            Expr::Atom(kind) => match kind {
                AtomKind::Int(v) => {
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Const { 
                        value: ir::IrValue::Int(*v), dest 
                    });
                }
                AtomKind::Float(v) => {
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Const { 
                        value: ir::IrValue::Float(*v), dest 
                    });
                }
                AtomKind::Bool(b) => {
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Const { 
                        value: ir::IrValue::Bool(*b), dest 
                    });
                }
                AtomKind::StringLit(s) => {
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Const { 
                        value: ir::IrValue::StringLit(s.clone()), dest 
                    });
                }
                AtomKind::Ident(name) => {
                    // Variable reference - load from stack slot
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Load { 
                        name: name.clone(), region: Region::Stack, dest 
                    });
                }
            }
            
            Expr::App(op, args) => {
                // Evaluate arguments left-to-right (strict)
                let arg_vals: Vec<ir::SsaValue> = args.iter()
                    .map(|a| {
                        self.expr_to_blocks(program, a, func)?;
                        Ok(self.ssa_at(func, func.current_block().instructions.len() - 1))
                    })
                    .collect::<Result<Vec<_>, CompilerError>>()?;
                
                let dest = self.ssa_val(func);
                
                if is_icnf_builtin(op) {
                    if arg_vals.len() == 2 {
                        let bin_op = match op.as_str() {
                            "+" => ir::BinOp::Add,
                            "-" => ir::BinOp::Sub,
                            "*" => ir::BinOp::Mul,
                            "/" => ir::BinOp::Div,
                            "==" => ir::BinOp::Eq,
                            "!=" => ir::BinOp::Ne,
                            "<" => ir::BinOp::Lt,
                            ">" => ir::BinOp::Gt,
                            _ => ir::BinOp::Add,
                        };
                        func.current_block_mut().add_instruction(ir::Instruction::BinOp {
                            op: bin_op, left: arg_vals[0], right: arg_vals[1], dest,
                        });
                    }
                } else {
                    // Direct call to a named function
                    let call_func = ir::IrValue::FuncRef(op.clone());
                    func.current_block_mut().add_instruction(ir::Instruction::Call {
                        func: call_func,
                        args: arg_vals, dest,
                    });
                }
            }
            
            Expr::AppExpr(operator, args) => {
                // Evaluate the operator expression first (higher-order function call)
                self.expr_to_blocks(program, operator, func)?;
                let func_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                // Evaluate arguments left-to-right
                let arg_vals: Vec<ir::SsaValue> = args.iter()
                    .map(|a| {
                        self.expr_to_blocks(program, a, func)?;
                        Ok(ir::SsaValue {
                            id: ir::SsaId(func.current_block().instructions.len() - 1),
                            region: Region::Stack,
                        })
                    })
                    .collect::<Result<Vec<_>, CompilerError>>()?;
                
                let dest = self.ssa_val(func);
                func.current_block_mut().add_instruction(ir::Instruction::CallIndirect {
                    func: func_val, args: arg_vals, dest,
                });
            }
            
            Expr::If { cond, then_branch, else_branch } => {
                self.expr_to_blocks(program, cond, func)?;
                let cond_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                let then_block = func.add_block();
                let else_block = func.add_block();
                let merge_block = func.add_block();
                
                func.current_block_mut().add_instruction(ir::Instruction::CondBranch {
                    cond: cond_val, then_block, else_block,
                });
                
                // Then branch
                func.blocks.last_mut().unwrap().id = then_block;
                self.expr_to_blocks(program, then_branch, func)?;
                let then_val = ir::SsaValue { id: ir::SsaId(func.current_block().instructions.len() - 1), region: Region::Stack };
                func.current_block_mut().add_instruction(ir::Instruction::Branch {
                    cond: then_val, then_block: merge_block, else_block: merge_block,
                });
                
                // Else branch
                let else_id = func.add_block();
                func.blocks.last_mut().unwrap().id = else_id;
                self.expr_to_blocks(program, else_branch, func)?;
                let else_val = ir::SsaValue { id: ir::SsaId(func.current_block().instructions.len() - 1), region: Region::Stack };
                func.current_block_mut().add_instruction(ir::Instruction::Branch {
                    cond: else_val, then_block: merge_block, else_block: merge_block,
                });
                
                // Merge block with phi
                func.blocks.last_mut().unwrap().id = merge_block;
                let phi_dest = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len()),
                    region: Region::Stack,
                };
                func.current_block_mut().add_instruction(ir::Instruction::Phi {
                    inputs: vec![
                        (then_block, then_val),
                        (else_block, else_val),
                    ],
                    dest: phi_dest,
                });
            }
            
            Expr::Defn { name, params, body: _, ret_type: _ } => {
                // When a def appears in the body (not just at top-level),
                // generate a call to invoke it with its parameters as arguments.
                // The function itself was already added to extra_functions during
                // phase_icnf_generation. Here we just need to call it.
                let arg_vals: Vec<ir::SsaValue> = (0..params.len())
                    .map(|i| {
                        let val = ir::IrValue::Int(i as i64);
                        let dest = self.ssa_val(func);
                        func.current_block_mut().add_instruction(ir::Instruction::Const { value: val, dest });
                        ir::SsaValue { id: dest.id, region: dest.region }
                    })
                    .collect();
                
                let dest = self.ssa_val(func);
                func.current_block_mut().add_instruction(ir::Instruction::Call {
                    func: ir::IrValue::FuncRef(name.clone()),
                    args: arg_vals,
                    dest,
                });
            }
            
            Expr::Let { name, value, body } => {
                self.expr_to_blocks(program, value, func)?;
                let val = self.ssa_at(func, func.current_block().instructions.len() - 1);
                
                func.current_block_mut().add_instruction(ir::Instruction::Store {
                    name: name.clone(), value: val, region: Region::Stack,
                });
                
                self.expr_to_blocks(program, body, func)?;
            }
            
            Expr::TryCatch { body, catch_var: _, handler } => {
                let try_block = func.add_block();
                let _catch_block = func.add_block();
                let merge_block = func.add_block();
                
                func.blocks.last_mut().unwrap().id = try_block;
                self.expr_to_blocks(program, body, func)?;
                let branch_dummy = ir::SsaValue { id: ir::SsaId(0), region: Region::Stack };
                func.current_block_mut().add_instruction(ir::Instruction::Branch {
                    cond: branch_dummy, then_block: merge_block, else_block: merge_block,
                });
                
                let catch_id = func.add_block();
                func.blocks.last_mut().unwrap().id = catch_id;
                self.expr_to_blocks(program, handler, func)?;
                let branch_dummy2 = ir::SsaValue { id: ir::SsaId(0), region: Region::Stack };
                func.current_block_mut().add_instruction(ir::Instruction::Branch {
                    cond: branch_dummy2, then_block: merge_block, else_block: merge_block,
                });
                
                func.blocks.last_mut().unwrap().id = merge_block;
            }
            
            Expr::Spawn(body) => {
                self.expr_to_blocks(program, body, func)?;
                let body_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                let dest = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len()),
                    region: Region::Stack,
                };
                func.current_block_mut().add_instruction(ir::Instruction::Spawn { body: body_val, dest });
            }
            
            Expr::Send { target, message } => {
                self.expr_to_blocks(program, target, func)?;
                let target_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                self.expr_to_blocks(program, message, func)?;
                let msg_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                func.current_block_mut().add_instruction(ir::Instruction::Send { target: target_val, message: msg_val });
            }
            
            Expr::FfiCall { name, args, timeout_ms } => {
                let arg_vals: Vec<ir::SsaValue> = args.iter()
                    .map(|a| {
                        self.expr_to_blocks(program, a, func)?;
                        Ok(ir::SsaValue {
                            id: ir::SsaId(func.current_block().instructions.len() - 1),
                            region: Region::Stack,
                        })
                    })
                    .collect::<Result<Vec<_>, CompilerError>>()?;
                
                let dest = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len()),
                    region: Region::Stack,
                };
                func.current_block_mut().add_instruction(ir::Instruction::FfiCall {
                    name: name.clone(), args: arg_vals, timeout_ms: *timeout_ms, dest,
                });
            }
            
            Expr::Assert { condition, message } => {
                self.expr_to_blocks(program, condition, func)?;
                let cond_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                func.current_block_mut().add_instruction(ir::Instruction::Assert {
                    condition: cond_val, message: message.clone(),
                });
            }
            
            // Closures (§7) - generate a proper closure with captured environment
            Expr::Fn { params, body } => {
                // Generate a unique function name for this lambda
                let func_name = self.fresh_lambda_name();
                
                // Determine return type from body (conservative: Int)
                let ret_type = ir::IrType::Int;
                
                // Create parameter types (all Int for now, will be refined by type inference)
                let param_types: Vec<(String, ir::IrType)> = params.iter()
                    .map(|p| (format!("arg_{}", p), ret_type.clone()))
                    .collect();
                
                // Generate the lambda's ICNF function
                let mut lambda_func = ir::Function::new(func_name.clone(), param_types, ret_type);
                self.expr_to_blocks(program, body, &mut lambda_func)?;
                // Add the generated function to this function's extra_functions
                let ret_value = if lambda_func.current_block().instructions.is_empty() {
                    None
                } else {
                    Some(ir::SsaValue {
                        id: ir::SsaId(lambda_func.current_block().instructions.len() - 1),
                        region: crate::ast::Region::Stack,
                    })
                };
                lambda_func.current_block_mut().add_instruction(ir::Instruction::Return { value: ret_value });

                // Add the generated function to this function's extra_functions
                func.extra_functions.push(lambda_func);
                
                // Create a closure instruction that captures the environment
                // For now, we create an empty closure (no captured vars)
                let dest = self.ssa_val(func);
                func.current_block_mut().add_instruction(ir::Instruction::ClosureCreate {
                    func_name: func_name.clone(),
                    env_values: Vec::new(),  // Captured variables will be added later
                    dest,
                });
            }
            
            // While loop (§12.5)
            Expr::While { condition, body } => {
                let loop_start = func.add_block();
                let loop_end = func.add_block();
                
                func.blocks.last_mut().unwrap().id = loop_start;
                self.expr_to_blocks(program, condition, func)?;
                let cond_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                // Branch to end if condition is false
                func.current_block_mut().add_instruction(ir::Instruction::CondBranch {
                    cond: cond_val,
                    then_block: loop_start,  // continue loop
                    else_block: loop_end,    // exit loop
                });
                
                // Body
                self.expr_to_blocks(program, body, func)?;
                let _dummy = ir::SsaValue { id: ir::SsaId(0), region: Region::Stack };
                func.current_block_mut().add_instruction(ir::Instruction::Branch {
                    cond: _dummy,
                    then_block: loop_start,
                    else_block: loop_end,
                });
                
                // End block
                let end_id = func.add_block();
                func.blocks.last_mut().unwrap().id = end_id;
            }
            
            // For loop (§12.6)
            Expr::For { name, iterator, body } => {
                self.expr_to_blocks(program, iterator, func)?;
                let iter_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                // Store iterator element in variable
                func.current_block_mut().add_instruction(ir::Instruction::Store {
                    name: name.clone(), value: iter_val, region: Region::Stack,
                });
                self.expr_to_blocks(program, body, func)?;
            }
            
            // Cond (§12.7)
            Expr::Cond(clauses) => {
                if clauses.is_empty() {
                    let dest = self.ssa_val(func);
                    func.current_block_mut().add_instruction(ir::Instruction::Const {
                        value: ir::IrValue::Unit, dest,
                    });
                    return Ok(());
                }
                
                let merge_block = func.add_block();
                for (i, (cond, body)) in clauses.iter().enumerate() {
                    self.expr_to_blocks(program, cond, func)?;
                    let cond_val = ir::SsaValue {
                        id: ir::SsaId(func.current_block().instructions.len() - 1),
                        region: Region::Stack,
                    };
                    
                    if i == clauses.len() - 1 {
                        // Last clause - fall through to merge
                        func.current_block_mut().add_instruction(ir::Instruction::CondBranch {
                            cond: cond_val,
                            then_block: merge_block,
                            else_block: merge_block,
                        });
                    } else {
                        let next_block = func.add_block();
                        func.current_block_mut().add_instruction(ir::Instruction::CondBranch {
                            cond: cond_val,
                            then_block: next_block,
                            else_block: merge_block,
                        });
                        
                        // Evaluate body
                        func.blocks.last_mut().unwrap().id = next_block;
                        self.expr_to_blocks(program, body, func)?;
                        let _dummy = ir::SsaValue { id: ir::SsaId(0), region: Region::Stack };
                        func.current_block_mut().add_instruction(ir::Instruction::Branch {
                            cond: _dummy,
                            then_block: merge_block,
                            else_block: merge_block,
                        });
                    }
                }
                
                let merge_id = func.add_block();
                func.blocks.last_mut().unwrap().id = merge_id;
            }
            
            // Match (§8.3)
            Expr::Match { scrutinee, clauses } => {
                self.expr_to_blocks(program, scrutinee, func)?;
                let scrut_val = ir::SsaValue {
                    id: ir::SsaId(func.current_block().instructions.len() - 1),
                    region: Region::Stack,
                };
                
                let merge_block = func.add_block();
                for (i, clause) in clauses.iter().enumerate() {
                    // For now, generate a simple branch (full pattern matching needs ADT support)
                    if i == clauses.len() - 1 {
                        func.current_block_mut().add_instruction(ir::Instruction::Branch {
                            cond: scrut_val,
                            then_block: merge_block,
                            else_block: merge_block,
                        });
                    } else {
                        let next_block = func.add_block();
                        func.current_block_mut().add_instruction(ir::Instruction::Branch {
                            cond: scrut_val,
                            then_block: next_block,
                            else_block: merge_block,
                        });
                        
                        func.blocks.last_mut().unwrap().id = next_block;
                        self.expr_to_blocks(program, clause.body.as_ref(), func)?;
                        let _dummy = ir::SsaValue { id: ir::SsaId(0), region: Region::Stack };
                        func.current_block_mut().add_instruction(ir::Instruction::Branch {
                            cond: _dummy,
                            then_block: merge_block,
                            else_block: merge_block,
                        });
                    }
                }
                
                let merge_id = func.add_block();
                func.blocks.last_mut().unwrap().id = merge_id;
            }
            
            // Deftype, TraitDecl, Impl - compile-time only
            Expr::Deftype { .. } | Expr::TraitDecl { .. } | Expr::Impl { .. } => {}
            
            // Use/Export/Pub
            Expr::Use { .. } => {}
            Expr::Export(body) => self.expr_to_blocks(program, body, func)?,
            Expr::Pub(body) => self.expr_to_blocks(program, body, func)?,
            
            // Contracts (§23)
            Expr::Requires(_) | Expr::Invariant(_) | Expr::Contracts(_) => {}
            Expr::Ensures { condition: _, body } => self.expr_to_blocks(program, body, func)?,
            Expr::Recover { handlers, body } => {
                let _ = handlers;
                self.expr_to_blocks(program, body, func)?;
            }
            Expr::Checkpoint(body) => self.expr_to_blocks(program, body, func)?,
            
            // Begin (§12.8)
            Expr::Begin(exprs) => {
                for expr in exprs {
                    self.expr_to_blocks(program, expr, func)?;
                }
            }
            
            _ => {
                let dest = self.ssa_val(func);
                func.current_block_mut().add_instruction(ir::Instruction::Const {
                    value: ir::IrValue::Unit, dest,
                });
            }
        }
        
        Ok(())
    }
    
    // ------------------------------------------------------------------------
    // PHASE 7: Optimization (safe only)
    // ------------------------------------------------------------------------
    
    fn phase_optimization(&mut self, program: &ir::IcnfProgram) -> Result<ir::IcnfProgram, CompilerError> {
        let mut optimized = program.clone();
        
        match self.opt_level {
            0 => {}
            1 => { self.opt_dead_code_elim(&mut optimized); }
            2 => { self.opt_dead_code_elim(&mut optimized); self.opt_inline(&mut optimized); }
            3 => { 
                self.opt_dead_code_elim(&mut optimized); 
                self.opt_inline(&mut optimized); 
                self.opt_loop_unroll(&mut optimized); 
            }
            _ => {}
        }
        
        Ok(optimized)
    }
    
    fn opt_dead_code_elim(&self, program: &mut ir::IcnfProgram) {
        for func in &mut program.functions {
            let mut live_blocks = std::collections::HashSet::new();
            live_blocks.insert(func.entry_block);
            
            let mut stack = vec![func.entry_block];
            while let Some(block_id) = stack.pop() {
                if let Some(block) = func.blocks.iter().find(|b| b.id == block_id) {
                    if let Some(instr) = block.instructions.last() {
                        match instr {
                            ir::Instruction::Branch { then_block: tb, .. } => {
                                stack.push(*tb);
                            }
                            ir::Instruction::CondBranch { then_block: tb, else_block: eb, .. } => {
                                stack.push(*tb);
                                stack.push(*eb);
                            }
                            ir::Instruction::Return { .. } => {}
                            _ => {}
                        }
                    }
                }
            }
            
            func.blocks.retain(|b| live_blocks.contains(&b.id));
        }
    }
    
    fn opt_inline(&self, _program: &mut ir::IcnfProgram) {
        // Inline small functions (placeholder)
    }
    
    fn opt_loop_unroll(&self, _program: &mut ir::IcnfProgram) {
        // Unroll small loops (placeholder)
    }
    
    // ------------------------------------------------------------------------
    // PHASE 8: Code Generation
    // ------------------------------------------------------------------------
    
    fn phase_code_generation(&self, program: &ir::IcnfProgram) -> Result<Vec<u8>, CompilerError> {
        Ok(codegen::compile(program, self.arch).map_err(|e| CompilerError::Codegen(e))?)
    }
    
    // ------------------------------------------------------------------------
    // PHASE 9: Linking
    // ------------------------------------------------------------------------
    
    fn phase_linking(&self, object_code: &[u8]) -> Result<Vec<u8>, CompilerError> {
        Ok(object_code.to_vec())
    }
    
    // ------------------------------------------------------------------------
    // PHASE 10: Hash Finalization (Determinism Contract - Section 18)
    // ------------------------------------------------------------------------
    
    fn phase_hash_finalization(&self, data: &[u8]) -> String {
        use sha2::{Sha256, Digest};
        let mut hasher = Sha256::new();
        hasher.update(data);
        let result = hasher.finalize();
        result.iter().map(|b| format!("{:02x}", b)).collect()
    }
}

/// Check if an operation maps to an ICNF builtin
fn is_icnf_builtin(op: &str) -> bool {
    matches!(op, "+" | "-" | "*" | "/" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "not" | "and" | "or")
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Compile Zyl source code to native object code
pub fn compile(source: &str) -> Result<CompilationResult, CompilerError> {
    let mut compiler = Compiler::new(codegen::Arch::X86_64);
    compiler.compile(source)
}

/// Compile with a specific architecture
pub fn compile_with_arch(source: &str, arch: codegen::Arch) -> Result<CompilationResult, CompilerError> {
    let mut compiler = Compiler::new(arch);
    compiler.compile(source)
}

/// Compile with optimization level
pub fn compile_optimized(source: &str, opt_level: usize) -> Result<CompilationResult, CompilerError> {
    let mut compiler = Compiler::new(codegen::Arch::X86_64);
    compiler = compiler.with_optimization(opt_level);
    compiler.compile(source)
}
