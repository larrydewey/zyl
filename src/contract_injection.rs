use crate::ast::{Expr, ExprInner};
use crate::error::ZylError;

/// Contract Injection (Phase 10, spec §23).
///
/// Injects preconditions, postconditions, invariants, recovery handlers,
/// checkpoints, and contracts-off regions into the AST before code generation.
pub struct ContractInjector;

impl ContractInjector {
    pub fn new() -> Self {
        Self
    }

    /// Inject contract checks into the AST.
    ///
    /// Transforms:
    /// - (requires cond)    → emits precondition check at function entry
    /// - (ensures cond)     → emits postcondition check at function exit
    /// - (invariant cond)   → emits invariant check at loop heads / critical points
    /// - (recover expr (ErrorType fallback)) → wraps expr with try/catch for ErrorType
    /// - (checkpoint expr)  → emits observable state checkpoint for debugging/verify
    /// - (contracts off expr) → disables contract checking in expr scope
    pub fn inject(&self, exprs: &mut [Expr]) -> Result<(), ZylError> {
        for expr in exprs {
            self.inject_expr(expr)?;
        }
        Ok(())
    }

    fn inject_expr(&self, expr: &mut Expr) -> Result<(), ZylError> {
        match &mut expr.inner {
            ExprInner::Defn(_, _, body) => {
                // Preconditions: inject at function entry
                // Postconditions: inject before returns
                self.inject_function_body(body)?;
            }
            ExprInner::Requires(inner) => {
                // Precondition: evaluate condition, trap on false
                *expr = self.make_precondition_check(inner.as_ref())?;
            }
            ExprInner::Ensures(inner) => {
                // Postcondition: will be handled at return sites
                *expr = self.make_postcondition_check(inner.as_ref())?;
            }
            ExprInner::Invariant(inner) => {
                // Invariant: emit check at this program point
                *expr = self.make_invariant_check(inner.as_ref())?;
            }
            ExprInner::Recover(expr, arms) => {
                // Recovery: transform to try/catch
                *expr = self.make_recovery(expr, arms)?;
            }
            ExprInner::Checkpoint(inner) => {
                // Checkpoint: emit observable state
                *expr = self.make_checkpoint(inner.as_ref())?;
            }
            ExprInner::ContractsOff(inner) => {
                // Contracts off: strip contract forms from inner
                *expr = self.strip_contracts(inner.as_ref())?;
            }
            _ => {
                self.walk_expr(expr)?;
            }
        }
        Ok(())
    }

    fn inject_function_body(&self, body: &mut Expr) -> Result<(), ZylError> {
        // Walk the function body and inject pre/post/invariant checks
        self.walk_expr(body)
    }

    fn make_precondition_check(&self, cond: &Expr) -> Result<Expr, ZylError> {
        // (requires cond) → (if cond Unit (error "precondition failed"))
        Ok(Expr {
            span: cond.span.clone(),
            inner: ExprInner::If(
                Box::new(cond.clone()),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Atom(crate::ast::Atom::Ident("Unit".into())),
                }),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Error("precondition failed".into()),
                }),
            ),
        })
    }

    fn make_postcondition_check(&self, cond: &Expr) -> Result<Expr, ZylError> {
        // (ensures cond) → (if cond Unit (error "postcondition failed"))
        // Note: actual injection at return sites happens in codegen or later pass
        Ok(Expr {
            span: cond.span.clone(),
            inner: ExprInner::If(
                Box::new(cond.clone()),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Atom(crate::ast::Atom::Ident("Unit".into())),
                }),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Error("postcondition failed".into()),
                }),
            ),
        })
    }

    fn make_invariant_check(&self, cond: &Expr) -> Result<Expr, ZylError> {
        // (invariant cond) → (if cond Unit (error "invariant violated"))
        Ok(Expr {
            span: cond.span.clone(),
            inner: ExprInner::If(
                Box::new(cond.clone()),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Atom(crate::ast::Atom::Ident("Unit".into())),
                }),
                Box::new(Expr {
                    span: cond.span.clone(),
                    inner: ExprInner::Error("invariant violated".into()),
                }),
            ),
        })
    }

    fn make_recovery(&self, expr: &Expr, arms: &[(String, Box<Expr>)]) -> Result<Box<Expr>, ZylError> {
        // (recover expr (ErrorType fallback) ...) → try/catch form
        // For now, transform to a try/catch with the first arm
        // Real implementation would chain multiple catch clauses
        if let Some((err_type, fallback)) = arms.first() {
            Ok(Box::new(Expr {
                span: expr.span.clone(),
                inner: ExprInner::TryCatch(
                    Box::new(expr.clone()),
                    err_type.clone(),
                    fallback.clone(),
                ),
            }))
        } else {
            Ok(Box::new(expr.clone()))
        }
    }

    fn make_checkpoint(&self, expr: &Expr) -> Result<Expr, ZylError> {
        // (checkpoint expr) → expr with side-effect of emitting state
        // For MVP, just evaluate expr and return it
        Ok(expr.clone())
    }

    fn strip_contracts(&self, expr: &Expr) -> Result<Expr, ZylError> {
        // (contracts off expr) → expr with all contract forms removed
        let mut result = expr.clone();
        self.strip_contracts_recursive(&mut result)?;
        Ok(result)
    }

    fn strip_contracts_recursive(&self, expr: &mut Expr) -> Result<(), ZylError> {
        match &mut expr.inner {
            ExprInner::Requires(_) | ExprInner::Ensures(_) | ExprInner::Invariant(_)
            | ExprInner::Recover(_, _) | ExprInner::Checkpoint(_) | ExprInner::ContractsOff(_) => {
                // Replace with Unit (no-op)
                expr.inner = ExprInner::Atom(crate::ast::Atom::Ident("Unit".into()));
            }
            _ => {
                self.walk_expr_mut(expr)?;
            }
        }
        Ok(())
    }

    fn walk_expr(&self, expr: &mut Expr) -> Result<(), ZylError> {
        self.walk_expr_mut(expr)
    }

    fn walk_expr_mut(&self, expr: &mut Expr) -> Result<(), ZylError> {
        match &mut expr.inner {
            ExprInner::Def(name, body) => self.walk_expr_mut(body),
            ExprInner::Defn(_, _, body) => self.walk_expr_mut(body),
            ExprInner::Let(_, value, body) => {
                self.walk_expr_mut(value)?;
                self.walk_expr_mut(body)
            }
            ExprInner::LetMut(_, value, body) => {
                self.walk_expr_mut(value)?;
                self.walk_expr_mut(body)
            }
            ExprInner::If(cond, then_e, else_e) => {
                self.walk_expr_mut(cond)?;
                self.walk_expr_mut(then_e)?;
                self.walk_expr_mut(else_e)
            }
            ExprInner::Begin(exprs) => {
                for e in exprs {
                    self.walk_expr_mut(e)?;
                }
                Ok(())
            }
            ExprInner::Call(f, args) => {
                self.walk_expr_mut(f)?;
                for a in args {
                    self.walk_expr_mut(a)?;
                }
                Ok(())
            }
            ExprInner::Lambda(_, _, body) => self.walk_expr_mut(body),
            ExprInner::Match(scrut, arms) => {
                self.walk_expr_mut(scrut)?;
                for arm in arms {
                    self.walk_expr_mut(&mut arm.body)?;
                }
                Ok(())
            }
            ExprInner::TryCatch(try_e, _, catch_e) => {
                self.walk_expr_mut(try_e)?;
                self.walk_expr_mut(catch_e)
            }
            ExprInner::Spawn(e) => self.walk_expr_mut(e),
            ExprInner::Send(e1, e2) => {
                self.walk_expr_mut(e1)?;
                self.walk_expr_mut(e2)
            }
            ExprInner::StructDef(_) | ExprInner::StructDefPlus(_) => Ok(()),
            ExprInner::AliasDecl(_, target) => self.walk_expr_mut(target),
            ExprInner::ImplBlock(_, _, bodies) => {
                for b in bodies {
                    self.walk_expr_mut(&mut b.defn.body)?;
                }
                Ok(())
            }
            ExprInner::Deftype(_, variants, _, _) => {
                for v in variants {
                    for field in &mut v.fields {
                        // No nested exprs in field types for now
                    }
                }
                Ok(())
            }
            ExprInner::TestSuite(_, tests, _) => {
                for t in tests {
                    match t {
                        crate::ast::TestOrSuite::Test(test) => self.walk_expr_mut(&mut test.body)?,
                        crate::ast::TestOrSuite::Suite(suite) => {
                            for st in &mut suite.tests {
                                if let crate::ast::TestOrSuite::Test(test) = st {
                                    self.walk_expr_mut(&mut test.body)?;
                                }
                            }
                        }
                    }
                }
                Ok(())
            }
            ExprInner::TestDecl(_, body, _) => self.walk_expr_mut(body),
            ExprInner::AssertEqual(a, b) => {
                self.walk_expr_mut(a)?;
                self.walk_expr_mut(b)
            }
            ExprInner::AssertFail(e, _) => self.walk_expr_mut(e),
            ExprInner::AssertTrue(e, _) => self.walk_expr_mut(e),
            ExprInner::AssertFalse(e, _) => self.walk_expr_mut(e),
            ExprInner::TestProperty(_, _, body) => self.walk_expr_mut(body),
            ExprInner::Setup(exprs) | ExprInner::Teardown(exprs) => {
                for e in exprs {
                    self.walk_expr_mut(e)?;
                }
                Ok(())
            }
            ExprInner::RunTests(_) => Ok(()),
            ExprInner::TestCompile(e, _) => self.walk_expr_mut(e),
            ExprInner::Apply(_, args) => {
                for a in args {
                    self.walk_expr_mut(a)?;
                }
                Ok(())
            }
            ExprInner::MacroDef(_, _, template) => self.walk_expr_mut(template),
            // Contract forms: transform in place during walk
            ExprInner::Requires(inner) => {
                *expr = self.make_precondition_check(inner.as_ref())?;
                Ok(())
            }
            ExprInner::Ensures(inner) => {
                *expr = self.make_postcondition_check(inner.as_ref())?;
                Ok(())
            }
            ExprInner::Invariant(inner) => {
                *expr = self.make_invariant_check(inner.as_ref())?;
                Ok(())
            }
            ExprInner::Recover(expr, arms) => {
                *expr = self.make_recovery(expr, arms)?;
                Ok(())
            }
            ExprInner::Checkpoint(inner) => {
                *expr = self.make_checkpoint(inner.as_ref())?;
                Ok(())
            }
            ExprInner::ContractsOff(inner) => {
                *expr = self.strip_contracts(inner.as_ref())?;
                Ok(())
            }
            _ => Ok(()),
        }
    }
}