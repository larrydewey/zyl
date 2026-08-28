# Research: ICNF Closure Call Bug

## Summary

When a lambda is stored in a `let` binding inside a function, the ICNF generator
drops the `Assign` node for that binding. Subsequent calls to the variable
generate **direct** calls (`call _ZYL_f`) instead of indirect calls through the
closure value, causing undefined reference linker errors.

## Symptoms

```
Error: Code generation failed: /usr/bin/ld: ... undefined reference to `_ZYL_f'
```

Example reproducer:
```lisp
(defn fact (n)
  (let ((f (lambda (x)
    (if (= x 0)
      1
      (* x (fact (- x 1)))))))
    (f n)))
```

Expected: indirect call through closure value in `f`.
Actual: direct call `call _ZYL_f` emitted.

## Root Cause

**File:** `src/icnf.rs`, line ~2612

The Call handler for `ExprInner::Call` always emits a direct call:
```rust
result.push(self.emit(ICNFInner::Call(func_name, arg_ids)));
```

It does not check whether `func_name` is a local variable (closure/function value)
in `current_scope` vs a top-level function. When it's a local variable, an
indirect call path should be used (load the variable, then call through it).

Additionally, the `ExprInner::Let` handler (line ~1878) creates an `Assign` node
but the body of functions that contain `let` bindings of lambdas may not
properly include that Assign in the emitted function body, causing the variable
slot to never be registered in `local_vars` during codegen.

## Affected Code Patterns

Any Zyl code that:
1. Stores a lambda in a `let` binding inside a function
2. Invokes that variable as a function

## Workaround

Avoid storing lambdas in `let` bindings when you need to invoke them.
For recursive lambdas, extract recursion into separate named helper functions
instead of using `map`/`fold-left` with self-referential lambdas.

Example fix:
```lisp
; Before (broken):
(defn subst-apply (s t)
  (match t
    (TFun args (map (lambda (a) (subst-apply s a)) args)))
    ...))

; After (works):
(defn subst-apply-type-list (s types)
  (match types
    (Nil Nil)
    ((Pair h t) (cons (subst-apply-type s h) (subst-apply-type-list s t)))))

(defn subst-apply-type (s t)
  (match t
    (TFun args (subst-apply-type-list s args))
    ...))

(defn subst-apply (s t)
  (subst-apply-type s t))
```

## Fix Location

`src/icnf.rs` `convert_expr_to_stmts` Call handler (~line 2612):
- Check if `func_name` is in `current_scope` before emitting direct call
- If in scope: emit `Load` of the variable, then an indirect call ICNF node
- If not in scope: emit direct call as current

`src/icnf.rs` `ExprInner::Let` handler (~line 1878):
- Verify that `Assign` nodes for lambda bindings are included in the function
  body's statement list, not dropped during scope/globals swapping.

`src/codegen.rs` `emit_call_direct` (~line 3528):
- Already handles indirect calls via `callee_slot` lookup in `local_vars`.
- The bug is upstream in ICNF: the `Assign` node never makes it to codegen,
  so `local_vars` never contains the closure variable.

## Verification

After fix, the reproducer should compile and run correctly:
```bash
cat > /tmp/test.zyl << 'EOF'
(defn fact (n)
  (let ((f (lambda (x)
    (if (= x 0)
      1
      (* x (fact (- x 1)))))))
    (f n)))
(test "fact"
  (assert-equal (fact 5) 120))
EOF
./target/debug/zyl /tmp/test.zyl
./a.out.bin  # should print 120
```

## Related

- ICNF `Call` node: `ICNFInner::Call(String, Vec<usize>)` — currently only
  supports direct calls. An `ICNFInner::CallIndirect(usize, Vec<usize>)`
  node might be cleaner for the indirect call path.
- Codegen indirect call path already exists at line ~3643-3778 of `codegen.rs`.
