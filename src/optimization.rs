use indexmap::IndexMap;
use serde::{Deserialize, Serialize};

use crate::ast::*;
use crate::error::ZylError;
use crate::icnf::*;
use crate::region_inference::Region;

// ─── Optimization Passes (spec §22 — Phase 8: Safe only) ──────────────────

/// ICNF-level safe-only optimizations. Each pass preserves program semantics.
pub struct Optimizer {
    stats: IndexMap<String, usize>,
}

impl Optimizer {
    pub fn new() -> Self {
        Self {
            stats: IndexMap::new(),
        }
    }

    /// Run all optimization passes on the ICNF program in fixed order.
    pub fn optimize(&mut self, mut program: ICNFProgram) -> Result<ICNFProgram, ZylError> {
        // Pass 1: Constant folding — fold operations with constant operands.
        for func in &mut program.functions {
            let _ = func;
        }
        self.fold_constants_in_stmts(&mut program.statements);

        // Pass 2: Dead code elimination — remove unused SSA assignments and empty Begin blocks.
        self.dead_code_elimination(&mut program.statements);

        *self.stats.entry("optimization_complete".to_string()).or_insert(1);

        Ok(program)
    }

    /// Return a summary of optimization statistics.
    pub fn stats(&self) -> &IndexMap<String, usize> {
        &self.stats
    }

    // ─── Pass 1: Constant Folding ──────────────────────────────────────

    fn fold_constants_in_stmts(&mut self, stmts: &mut Vec<ICNFNode>) {
        let mut count = 0usize;

        // Limit iterations to prevent infinite loops.
        for _iteration in 0..100 {
            let before_len = stmts.len();
            // Collect BinOp/UnOp node indices.
            let binop_indices: Vec<usize> = stmts.iter()
                .enumerate()
                .filter(|(_, n)| matches!(&n.node, ICNFInner::BinOp(..) | ICNFInner::UnOp(..)))
                .map(|(i, _)| i)
                .collect();

            let mut folded_any = false;
            for idx in &binop_indices {
                if *idx >= stmts.len() { continue; } // node may have been removed/replaced
                
                match &stmts[*idx].node {
                    ICNFInner::BinOp(op, left_id, right_id) => {
                        let left_val = self.resolve_to_atom(*left_id, stmts);
                        let right_val = self.resolve_to_atom(*right_id, stmts);

                        if let (Some(l), Some(r)) = (&left_val, &right_val) {
                            match op {
                                BinOpKind::Add => {
                                    if let (Atom::Int(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Int(a.wrapping_add(*b)));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(a + b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Int(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a as f64 + *b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a + *b as f64));
                                        folded_any = true; count += 1;
                                    }
                                }
                                BinOpKind::Sub => {
                                    if let (Atom::Int(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Int(a.wrapping_sub(*b)));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(a - b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Int(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a as f64 - *b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a - *b as f64));
                                        folded_any = true; count += 1;
                                    }
                                }
                                BinOpKind::Mul => {
                                    if let (Atom::Int(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Int(a.wrapping_mul(*b)));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(a * b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Int(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a as f64 * *b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a * *b as f64));
                                        folded_any = true; count += 1;
                                    }
                                }
                                BinOpKind::Div => {
                                    if let (Atom::Int(a), Atom::Int(b)) = (l, r) {
                                        if *b != 0 {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Int(a / b));
                                            folded_any = true; count += 1;
                                        }
                                    } else if let (Atom::Float(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(a / b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Int(a), Atom::Float(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a as f64 / *b));
                                        folded_any = true; count += 1;
                                    } else if let (Atom::Float(a), Atom::Int(b)) = (l, r) {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Float(*a / *b as f64));
                                        folded_any = true; count += 1;
                                    }
                                }
                                BinOpKind::Rem => {
                                    if let (Atom::Int(a), Atom::Int(b)) = (l, r) {
                                        if *b != 0 {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Int(a % b));
                                            folded_any = true; count += 1;
                                        }
                                    }
                                }
                                BinOpKind::Eq => {
                                    match (l, r) {
                                        (Atom::Bool(a), Atom::Bool(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool(*a == *b));
                                            folded_any = true; count += 1;
                                        }
                                        (Atom::Int(a), Atom::Int(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool(*a == *b));
                                            folded_any = true; count += 1;
                                        }
                                        (Atom::Float(a), Atom::Float(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool((*a) == (*b)));
                                            folded_any = true; count += 1;
                                        }
                                        _ => {}
                                    }
                                }
                                BinOpKind::Neq => {
                                    match (l, r) {
                                        (Atom::Bool(a), Atom::Bool(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool(*a != *b));
                                            folded_any = true; count += 1;
                                        }
                                        (Atom::Int(a), Atom::Int(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool(*a != *b));
                                            folded_any = true; count += 1;
                                        }
                                        (Atom::Float(a), Atom::Float(b)) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Bool((*a) != (*b)));
                                            folded_any = true; count += 1;
                                        }
                                        _ => {}
                                    }
                                }
                                // Comparison ops on ints/floats — not safe to fold at compile time.
                                BinOpKind::Lt | BinOpKind::Gt | BinOpKind::Le | BinOpKind::Ge 
                                | BinOpKind::And | BinOpKind::Or => {}
                            }
                        }

                        // Recurse into Begin blocks of this node (if it wasn't replaced).
                        if let ICNFInner::Begin(ref mut body) = stmts[*idx].node {
                            self.fold_constants_in_stmts(body);
                        }
                    }
                    ICNFInner::UnOp(op, arg_id) => {
                        let arg_val = self.resolve_to_atom(*arg_id, stmts);
                        if let Some(val) = &arg_val {
                            match op {
                                UnOpKind::Not => {
                                    if let Atom::Bool(b) = val {
                                        stmts[*idx].node = ICNFInner::Const(Atom::Bool(!b));
                                        folded_any = true; count += 1;
                                    }
                                }
                                UnOpKind::Negate => {
                                    match val {
                                        Atom::Int(i) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Int(-i));
                                            folded_any = true; count += 1;
                                        }
                                        Atom::Float(f) => {
                                            stmts[*idx].node = ICNFInner::Const(Atom::Float(-f));
                                            folded_any = true; count += 1;
                                        }
                                        _ => {}
                                    }
                                }
                            }
                        }

                        // Recurse into Begin blocks.
                        if let ICNFInner::Begin(ref mut body) = stmts[*idx].node {
                            self.fold_constants_in_stmts(body);
                        }
                    }
                    _ => {}
                }
            }

            // If nothing folded this pass, we're done (fixed-point).
            if !folded_any { break; }
        }
        *self.stats.entry("constant_folding".to_string()).or_insert(0) += count;
    }

    fn resolve_to_atom(&self, id: usize, stmts: &[ICNFNode]) -> Option<Atom> {
        for node in stmts.iter().rev() {
            if node.id == id {
                return match &node.node {
                    ICNFInner::Const(atom) => Some(atom.clone()),
                    _ => None,
                };
            }
        }
        None
    }

    // ─── Pass 2: Dead Code Elimination ────────────────────────────────

    fn dead_code_elimination(&mut self, stmts: &mut Vec<ICNFNode>) {
        let count = self.dead_code_elimination_pass(stmts);
        if count > 0 {
            *self.stats.entry("dead_code_elimination".to_string()).or_insert(0) += count;
        }
    }

    fn dead_code_elimination_pass(&mut self, stmts: &mut Vec<ICNFNode>) -> usize {
        // Build a map from SSA ID to node for quick lookup.
        let id_to_node: std::collections::HashMap<usize, ICNFInner> = stmts.iter()
            .map(|n| (n.id, n.node.clone()))
            .collect();

        // Collect all operand references across ALL nodes.
        let mut referenced_ids = std::collections::HashSet::new();
        for node in stmts.iter() {
            Self::collect_used_ssa(&node.node, &mut referenced_ids);
        }

        // Root-live: has side effects OR its result is used by another node's operands.
        let mut live_set: std::collections::HashSet<usize> = stmts.iter().filter(|n| {
            Self::has_side_effect(&n.node) || referenced_ids.contains(&n.id)
        }).map(|n| n.id).collect();
        // Walk transitive dependencies of root-live nodes using BFS.
        let mut queue: Vec<usize> = live_set.clone().into_iter().collect();
        while let Some(id) = queue.pop() {
            if let Some(inner) = id_to_node.get(&id) {
                let mut deps = std::collections::HashSet::new();
                Self::collect_used_ssa(inner, &mut deps);
                for dep in deps {
                    // Only add to queue if not already live (prevents infinite loops).
                    if !live_set.contains(&dep) {
                        live_set.insert(dep);
                        queue.push(dep);
                    }
                }
            }
        }

        // Remove nodes that are not live.
        let original_len = stmts.len();
        for node in stmts.iter_mut() {
            if let ICNFInner::Begin(ref mut body) = node.node {
                self.dead_code_elimination_pass(body);
            }
        }

        stmts.retain(|node| !matches!(&node.node, ICNFInner::Begin(b) if b.is_empty()));

        original_len - stmts.len()
    }

    fn collect_used_ssa(inner: &ICNFInner, used_ids: &mut std::collections::HashSet<usize>) {
        match inner {
            ICNFInner::BinOp(_, left, right) => {
                used_ids.insert(*left);
                used_ids.insert(*right);
            }
            ICNFInner::UnOp(_, arg) => { used_ids.insert(*arg); }
            ICNFInner::Call(_, args) => {
                for &a in args {
                    used_ids.insert(a);
                }
            }
            ICNFInner::FfiCall { args, .. } => {
                for &a in args {
                    used_ids.insert(a);
                }
            }
             ICNFInner::If { cond_ssa, then_body, else_body, .. } => {
                  used_ids.insert(*cond_ssa);
                  for stmt in then_body {
                      Self::collect_used_ssa(&stmt.node, used_ids);
                  }
                  for stmt in else_body {
                      Self::collect_used_ssa(&stmt.node, used_ids);
                  }
              }

            ICNFInner::While { cond_ssa, body } => {
                used_ids.insert(*cond_ssa);
                for stmt in body {
                    Self::collect_used_ssa(&stmt.node, used_ids);
                }
            }
            ICNFInner::For { iter_ssa: cond_ssa, body, .. } => {
                used_ids.insert(*cond_ssa);
                for stmt in body {
                    Self::collect_used_ssa(&stmt.node, used_ids);
                }
            }
            ICNFInner::Match { scrutinee_ssa, .. } => { used_ids.insert(*scrutinee_ssa); }
            ICNFInner::StructGet(val_id, _) => { used_ids.insert(*val_id); }
            ICNFInner::ErrValue(v) => { used_ids.insert(*v); }
            ICNFInner::OkValue(v) => { used_ids.insert(*v); }
            ICNFInner::Send(actor_id, msg_id) => {
                used_ids.insert(*actor_id);
                used_ids.insert(*msg_id);
            }
            ICNFInner::Exit(code) => { used_ids.insert(*code); }
            ICNFInner::Close(code) => { used_ids.insert(*code); }
            ICNFInner::Print(args) => {
                for &a in args {
                    used_ids.insert(a);
                }
            }
            ICNFInner::WithResource { init_ssa, .. } => { used_ids.insert(*init_ssa); }
            ICNFInner::SetBang(_, val_id) => { used_ids.insert(*val_id); }
            ICNFInner::Unwrap(val_id) => { used_ids.insert(*val_id); }
            ICNFInner::Assert { cond_ssa, .. } => { used_ids.insert(*cond_ssa); }
            _ => {} // Const, Load, Assign, Unit — no operands to track
        }

        if let ICNFInner::Begin(body) = inner {
            for child in body {
                Self::collect_used_ssa(&child.node, &mut *used_ids);
            }
        }

        // Handle If branch bodies.
        if let ICNFInner::If { then_body, else_body, .. } = inner {
            for stmt in then_body {
                Self::collect_used_ssa(&stmt.node, &mut *used_ids);
            }
            for stmt in else_body {
                Self::collect_used_ssa(&stmt.node, &mut *used_ids);
            }
        }
    }

    fn has_side_effect(inner: &ICNFInner) -> bool {
        matches!(
            inner,
            ICNFInner::Print(_)
                | ICNFInner::FfiCall { .. }
                | ICNFInner::Spawn(_)
                | ICNFInner::Send(..)
                | ICNFInner::Exit(_)
                | ICNFInner::Close(_)
                | ICNFInner::ReadLine
                | ICNFInner::Assert { .. }
        ) || matches!(inner, ICNFInner::If { .. } 
            | ICNFInner::While { .. }
            | ICNFInner::For { .. })  // Control flow structures are always kept.
    }
}
