//! Intermediate Canonical Normal Form (ICNF) - SSA-based IR
//! 
//! Per specification section 14:
//! - Strict SSA
//! - Dominance correctness enforced
//! - Phi required at control merges
//! - Each value: (SSA_ID, Region)
//! - All IR is region-annotated and SSA-unique

use crate::ast::Region;
use std::collections::HashMap;
use thiserror::Error;

// ============================================================================
// SSA VALUES (Section 14)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct SsaId(pub usize);

impl std::fmt::Display for SsaId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "%{}", self.0)
    }
}

/// An SSA value: (SSA_ID, Region)
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SsaValue {
    pub id: SsaId,
    pub region: Region,
}

impl std::fmt::Display for SsaValue {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}@{}", self.id, self.region)
    }
}

// ============================================================================
// IR INSTRUCTIONS (Section 14)
// ============================================================================

#[derive(Debug, Clone)]
pub enum Instruction {
    /// Load a constant value
    Const { value: IrValue, dest: SsaValue },
    
    /// Binary operation
    BinOp { op: BinOp, left: SsaValue, right: SsaValue, dest: SsaValue },
    
    /// Unary operation
    UnaryOp { op: UnaryOp, operand: SsaValue, dest: SsaValue },
    
    /// Function call (direct by name)
    Call { func: IrValue, args: Vec<SsaValue>, dest: SsaValue },
    
    /// Indirect function call through a closure value
    CallIndirect { func: SsaValue, args: Vec<SsaValue>, dest: SsaValue },
    
    /// Load from variable
    Load { name: String, region: Region, dest: SsaValue },
    
    /// Store to variable
    Store { name: String, value: SsaValue, region: Region },
    
    /// Phi node (for SSA merges): inputs are (predecessor_block_id, value_from_that_block)
    Phi { inputs: Vec<(BlockId, SsaValue)>, dest: SsaValue },
    
    /// Branch instruction
    Branch { cond: SsaValue, then_block: BlockId, else_block: BlockId },
    
    /// Conditional branch
    CondBranch { cond: SsaValue, then_block: BlockId, else_block: BlockId },
    
    /// Return from function
    Return { value: Option<SsaValue> },
    
    /// Allocate on region
    Alloc { ty: IrType, region: Region, dest: SsaValue },
    
    /// Cast/convert type
    Cast { from: SsaValue, to: IrType, dest: SsaValue },
    
    /// Create a closure value (function pointer + captured environment)
    ClosureCreate {
        func_name: String,
        env_values: Vec<SsaValue>,  // Captured variables
        dest: SsaValue,
    },
    
    /// Actor spawn
    Spawn { body: SsaValue, dest: SsaValue },
    
    /// Send message to actor
    Send { target: SsaValue, message: SsaValue },
    
    /// FFI call
    FfiCall { name: String, args: Vec<SsaValue>, timeout_ms: i64, dest: SsaValue },
    
    /// Assert
    Assert { condition: SsaValue, message: String },
    
    /// No-op (for padding/optimization)
    Nop,
}

impl std::fmt::Display for Instruction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Instruction::Const { value, dest } => write!(f, "{} = const {}", dest, value),
            Instruction::BinOp { op, left, right, dest } => {
                write!(f, "{} = {} {} {}", dest, op, left, right)
            }
            Instruction::UnaryOp { op, operand, dest } => {
                write!(f, "{} = {} {}", dest, op, operand)
            }
            Instruction::Call { func, args, dest } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "{} = call {}({})", dest, func, args_str.join(", "))
            }
            Instruction::CallIndirect { func, args, dest } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "{} = call-indirect {}({})", dest, func, args_str.join(", "))
            }
            Instruction::ClosureCreate { func_name, env_values, dest } => {
                let env_str: Vec<String> = env_values.iter().map(|v| v.to_string()).collect();
                write!(f, "{} = closure @{}, [{}]", dest, func_name, env_str.join(", "))
            }
            Instruction::Load { name, region, dest } => {
                write!(f, "{} = load {}@{}", dest, name, region)
            }
            Instruction::Store { name, value, region } => {
                write!(f, "store {}@{} = {}", name, region, value)
            }
            Instruction::Phi { inputs, dest } => {
                let inputs_str: Vec<String> = inputs.iter()
                    .map(|(id, val)| format!("{}:{}", id, val))
                    .collect();
                write!(f, "{} = phi [{}]", dest, inputs_str.join(", "))
            }
            Instruction::Branch { cond, then_block, else_block } => {
                write!(f, "br {} -> {}, {}", cond, then_block, else_block)
            }
            Instruction::CondBranch { cond, then_block, else_block } => {
                write!(f, "cbr {} -> {}, {}", cond, then_block, else_block)
            }
            Instruction::Return { value } => {
                match value {
                    Some(v) => write!(f, "ret {}", v),
                    None => write!(f, "ret"),
                }
            }
            Instruction::Alloc { ty, region, dest } => {
                write!(f, "{} = alloc {}@{}", dest, ty, region)
            }
            Instruction::Cast { from, to, dest } => {
                write!(f, "{} = cast {} -> {}", dest, from, to)
            }
            Instruction::Spawn { body, dest } => {
                write!(f, "{} = spawn {}", dest, body)
            }
            Instruction::Send { target, message } => {
                write!(f, "send {} {}", target, message)
            }
            Instruction::FfiCall { name, args, timeout_ms, dest } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "{} = ffi-call \"{}\"({}) [{}ms]", dest, name, args_str.join(", "), timeout_ms)
            }
            Instruction::Assert { condition, message } => {
                write!(f, "assert {} \"{}\"", condition, message)
            }
            Instruction::Nop => write!(f, "nop"),
        }
    }
}

// ============================================================================
// IR VALUES (runtime values in IR)
// ============================================================================

#[derive(Debug, Clone)]
pub enum IrValue {
    Int(i64),
    Float(f64),
    Bool(bool),
    StringLit(String),
    Unit,
    FuncRef(String), // Function name reference (for direct calls)
}

impl std::fmt::Display for IrValue {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            IrValue::Int(v) => write!(f, "{}", v),
            IrValue::Float(v) => write!(f, "{}", v),
            IrValue::Bool(v) => write!(f, "{}", v),
            IrValue::StringLit(v) => write!(f, "\"{}\"", v),
            IrValue::Unit => write!(f, "unit"),
            IrValue::FuncRef(name) => write!(f, "@{}", name),
        }
    }
}

// ============================================================================
// IR TYPES
// ============================================================================

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum IrType {
    Int,
    Float,
    Bool,
    String,
    Unit,
    Fun(Vec<IrType>, Box<IrType>),
    Tuple(Vec<IrType>),
    ActorRef,
    Ptr(Region), // Pointer to region
}

impl std::fmt::Display for IrType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            IrType::Int => write!(f, "Int"),
            IrType::Float => write!(f, "Float"),
            IrType::Bool => write!(f, "Bool"),
            IrType::String => write!(f, "String"),
            IrType::Unit => write!(f, "Unit"),
            IrType::Fun(args, ret) => {
                let args_str: Vec<String> = args.iter().map(|t| t.to_string()).collect();
                write!(f, "TFun([{}], {})", args_str.join(", "), ret)
            }
            IrType::Tuple(types) => {
                let types_str: Vec<String> = types.iter().map(|t| t.to_string()).collect();
                write!(f, "({})", types_str.join(", "))
            }
            IrType::ActorRef => write!(f, "ActorRef"),
            IrType::Ptr(region) => write!(f, "*{}", region),
        }
    }
}

// ============================================================================
// BINARY AND UNARY OPERATORS
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    Add, Sub, Mul, Div, Mod,
    Eq, Ne, Lt, Le, Gt, Ge,
    And, Or,
}

impl std::fmt::Display for BinOp {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            BinOp::Add => write!(f, "+"),
            BinOp::Sub => write!(f, "-"),
            BinOp::Mul => write!(f, "*"),
            BinOp::Div => write!(f, "/"),
            BinOp::Mod => write!(f, "%"),
            BinOp::Eq => write!(f, "=="),
            BinOp::Ne => write!(f, "!="),
            BinOp::Lt => write!(f, "<"),
            BinOp::Le => write!(f, "<="),
            BinOp::Gt => write!(f, ">"),
            BinOp::Ge => write!(f, ">="),
            BinOp::And => write!(f, "&&"),
            BinOp::Or => write!(f, "||"),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnaryOp {
    Neg, Not, AddrOf, Deref,
}

impl std::fmt::Display for UnaryOp {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            UnaryOp::Neg => write!(f, "-"),
            UnaryOp::Not => write!(f, "!"),
            UnaryOp::AddrOf => write!(f, "&"),
            UnaryOp::Deref => write!(f, "*"),
        }
    }
}

// ============================================================================
// BLOCKS AND FUNCTIONS (Section 14)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct BlockId(pub usize);

impl std::fmt::Display for BlockId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "bb{}", self.0)
    }
}

#[derive(Debug, Clone)]
pub struct Block {
    pub id: BlockId,
    pub instructions: Vec<Instruction>,
    /// Dominator (for dominance verification)
    pub dominator: Option<BlockId>,
}

impl Block {
    pub fn new(id: BlockId) -> Self {
        Self {
            id,
            instructions: Vec::new(),
            dominator: None,
        }
    }
    
    pub fn add_instruction(&mut self, instr: Instruction) {
        self.instructions.push(instr);
    }
}

#[derive(Debug, Clone)]
pub struct Function {
    pub name: String,
    pub params: Vec<(String, IrType)>,
    pub ret_type: IrType,
    pub blocks: Vec<Block>,
    /// Entry block ID
    pub entry_block: BlockId,
    /// Successor relationships (for CFG analysis)
    pub successors: HashMap<BlockId, Vec<BlockId>>,
    /// Extra functions generated for closures (lambdas defined inside this function)
    pub extra_functions: Vec<Function>,
}

impl Function {
    pub fn new(name: String, params: Vec<(String, IrType)>, ret_type: IrType) -> Self {
        let entry = BlockId(0);
        Self {
            name,
            params,
            ret_type,
            blocks: vec![Block::new(entry)],
            entry_block: entry,
            successors: HashMap::new(),
            extra_functions: Vec::new(),
        }
    }
    
    pub fn add_block(&mut self) -> BlockId {
        let id = BlockId(self.blocks.len());
        self.blocks.push(Block::new(id));
        id
    }
    
    pub fn current_block(&self) -> &Block {
        self.blocks.last().unwrap()
    }
    
    pub fn current_block_mut(&mut self) -> &mut Block {
        self.blocks.last_mut().unwrap()
    }
}

// ============================================================================
// ICNF PROGRAM
// ============================================================================

#[derive(Debug, Clone)]
pub struct IcnfProgram {
    pub functions: Vec<Function>,
    pub globals: Vec<(String, IrType, IrValue)>,
}

impl IcnfProgram {
    pub fn new() -> Self {
        Self {
            functions: Vec::new(),
            globals: Vec::new(),
        }
    }
    
    pub fn add_function(&mut self, func: Function) {
        self.functions.push(func);
    }
}

impl std::fmt::Display for IcnfProgram {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for global in &self.globals {
            writeln!(f, "global {} {} = {}", global.0, global.1, global.2)?;
        }
        for func in &self.functions {
            writeln!(f, "\nfn {}({}): {}", 
                     func.name,
                     func.params.iter().map(|(n, t)| format!("{}: {}", n, t)).collect::<Vec<_>>().join(", "),
                     func.ret_type)?;
            for block in &func.blocks {
                writeln!(f, "\n  {}:", block.id)?;
                for instr in &block.instructions {
                    writeln!(f, "    {}", instr)?;
                }
            }
        }
        Ok(())
    }
}

// ============================================================================
// SSA CONSTRUCTION
// ============================================================================

#[derive(Debug, Error)]
pub enum SsaError {
    #[error("Undefined SSA variable: {id}")]
    UndefinedVar { id: SsaId },
    
    #[error("Phi node requires inputs from all predecessors")]
    PhiMissingPredecessor,
    
    #[error("Dominance violation at block {block}")]
    DominanceViolation { block: BlockId },
    
    #[error("Multiple definitions of SSA variable {id}")]
    MultipleDefinitions { id: SsaId },
}

/// Build SSA form for a function
pub struct SsaBuilder {
    next_id: usize,
    /// Current definition of each variable name -> (SsaId, region)
    defns: HashMap<String, SsaValue>,
    /// Phi mappings at each block: var_name -> [(predecessor_block, value)]
    phi_map: HashMap<BlockId, HashMap<String, Vec<(BlockId, SsaValue)>>>,
}

impl SsaBuilder {
    pub fn new() -> Self {
        Self {
            next_id: 0,
            defns: HashMap::new(),
            phi_map: HashMap::new(),
        }
    }
    
    /// Generate a fresh SSA ID
    fn fresh_id(&mut self) -> SsaId {
        let id = SsaId(self.next_id);
        self.next_id += 1;
        id
    }
    
    /// Create an SSA value with a given region
    pub fn make_value(&mut self, region: Region) -> SsaValue {
        SsaValue {
            id: self.fresh_id(),
            region,
        }
    }
    
    /// Define a variable in the current scope
    pub fn define(&mut self, name: &str, value: SsaValue) {
        self.defns.insert(name.to_string(), value);
    }
    
    /// Load a variable (returns its current SSA value)
    pub fn load(&self, name: &str) -> Option<SsaValue> {
        self.defns.get(name).copied()
    }
    
    /// Add a phi node at a block merge point
    pub fn add_phi(&mut self, block: BlockId, var_name: &str, pred: BlockId, value: SsaValue) {
        self.phi_map
            .entry(block)
            .or_default()
            .entry(var_name.to_string())
            .or_default()
            .push((pred, value));
    }
    
    /// Get phi nodes for a block
    pub fn get_phis(&self, block: BlockId) -> HashMap<String, Vec<(BlockId, SsaValue)>> {
        self.phi_map.get(&block).cloned().unwrap_or_default()
    }
}

// ============================================================================
// DOMINANCE ANALYSIS (for SSA correctness)
// ============================================================================

/// Compute dominators for a function's CFG
pub fn compute_dominators(func: &Function) -> HashMap<BlockId, Option<BlockId>> {
    let mut dominators: HashMap<BlockId, Option<BlockId>> = HashMap::new();
    
    // Entry block is dominated by nothing
    dominators.insert(func.entry_block, None);
    
    // Iterative dominance computation
    let mut changed = true;
    while changed {
        changed = false;
        for block in &func.blocks {
            if block.id == func.entry_block {
                continue;
            }
            
            // Find predecessors (blocks that can reach this one)
            let predecessors: Vec<BlockId> = func.successors.iter()
                .flat_map(|(src, dsts)| dsts.iter().map(move |d| (*src, *d)))
                .filter(|(_, dst)| *dst == block.id)
                .map(|(src, _)| src)
                .collect();
            
            if predecessors.is_empty() {
                continue;
            }
            
            let new_dom = if let Some(first_pred) = predecessors.first() {
                // Intersection of all predecessor dominators
                let mut dom = *dominators.get(first_pred).unwrap_or(&None);
                for pred in &predecessors[1..] {
                    dom = intersect_dominators(&dominators, dom, *pred);
                }
                Some(block.id) // A block dominates itself
            } else {
                None
            };
            
            if dominators.get(&block.id) != Some(&new_dom) {
                dominators.insert(block.id, new_dom);
                changed = true;
            }
        }
    }
    
    dominators
}

/// Intersect dominator paths
fn intersect_dominators(dominators: &HashMap<BlockId, Option<BlockId>>, mut a: Option<BlockId>, b: BlockId) -> Option<BlockId> {
    while let Some(a_id) = a {
        if is_dom(dominators, a_id, b) {
            return Some(a_id);
        }
        a = dominators.get(&a_id).copied().flatten();
    }
    None
}

fn is_dom(dominators: &HashMap<BlockId, Option<BlockId>>, dom: BlockId, node: BlockId) -> bool {
    let mut current = Some(node);
    while let Some(id) = current {
        if id == dom {
            return true;
        }
        current = dominators.get(&id).copied().flatten();
    }
    false
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Create a new ICNF program
pub fn new_program() -> IcnfProgram {
    IcnfProgram::new()
}

/// Create a new function in the program
pub fn new_function(name: &str, params: Vec<(String, IrType)>, ret_type: IrType) -> Function {
    Function::new(name.to_string(), params, ret_type)
}
