# Chapter 30: Compiler Internals — Writing Compiler Passes in Zyl

This chapter explains how to write compiler passes in Zyl, using the self-hosted compiler as a reference.

## 30.1 Compiler Pass Architecture

Each phase is a **function** transforming an AST/IR:

```lisp
;; Phase signature
(defn phase-name (input-ast) output-ast)
```

### Pass Composition

```lisp
(defn compile (source)
  (let ast (parse source)
    (let ast (macro-expand ast)
      (let ast (type-infer ast)
        (let ast (region-infer ast)
          (let ast (monomorphize ast)
            (let icnf (lower-to-icnf ast)
              (let icnf (optimize icnf)
                (let asm (codegen icnf)
                  asm))))))))
```

## 30.2 AST Representation (Phase 1-5)

### Core ADTs (in `ast.zyl`, `expr_inner.zyl`)

```lisp
(deftype Expr
  (EInt Int)
  (EFloat Float)
  (EBool Bool)
  (EString String)
  (EUnit)
  (EVar String)
  (ELet String Expr Expr)
  (ELetMut String Expr Expr)
  (EIf Expr Expr Expr)
  (ECall Expr (List Expr))
  (EFn (List String) Expr)
  (EMatch Expr (List MatchArm))
  ...)

(deftype MatchArm
  (MatchArm String (List String) Expr))
```

### Post-Processor Output (`expr_inner.zyl`)

```lisp
(deftype ExprInner
  (EInt Int)
  (EFloat Float)
  (EBool Bool)
  (EString String)
  (EUnit)
  (EVar String)
  (ELet String ExprInner ExprInner)
  (ELetMut String ExprInner ExprInner)
  (EIf ExprInner ExprInner ExprInner)
  (ECall String (List ExprInner))      ; Direct call
  (EApply ExprInner (List ExprInner))  ; Indirect call
  (EFn (List String) ExprInner)
  (EMatch ExprInner (List MatchArmInner))
  (EStructGet ExprInner String)
  (EMakeStruct String (List ExprInner))
  (EMakeVariant String String (List ExprInner))
  ...)
```

## 30.3 Writing a Pass: Type Inference

### Type ADT (`type_system.zyl`)

```lisp
(deftype Type
  (TInt)
  (TFloat)
  (TBool)
  (TString)
  (TUnit)
  (TFun (List Type) Type)
  (TCap Type)
  (TMut Type)
  (TAtomic Type)
  (TBox Type)
  (TPin Type)
  (TStruct String (List (String Type)))
  (TAdt String (List Type))
  (TVar Int))  ; Type variable
```

### Substitution

```lisp
(deftype Subst (List (Int Type)))  ; TVar → Type

(defn subst-apply (subst type) ...)
(defn subst-compose (s1 s2) ...)
(defn subst-empty () Nil)
```

### Type Environment

```lisp
(deftype TypeEnv (List (String Type)))

(defn env-extend (env name type) (Cons (name type) env))
(defn env-lookup (env name) ...)
```

### Inference Engine (`type_inference.zyl`)

```lisp
(deftype InferResult
  (IOk Type Subst)
  (IErr String))

(defn infer (env expr)
  (match expr
    (EInt _ (IOk TInt env))
    (EFloat _ (IOk TFloat env))
    (EVar name
      (match (env-lookup env name)
        (Some t (IOk t env))
        (None (IErr "unbound variable"))))
    (ELet name e1 e2
      (match (infer env e1)
        (IOk t1 subst1
          (let env1 (subst-apply-env subst1 env)
            (let env2 (env-extend env1 name t1)
              (match (infer env2 e2)
                (IOk t2 subst2
                  (IOk t2 (subst-compose subst2 subst1))))))))
    ...))
```

## 30.4 Writing a Pass: Region Inference

### Region ADT

```lisp
(deftype Region
  (RStack)
  (RHeap)
  (RGlobal)
  (RCircular)
  (RPin))
```

### Escape Analysis

```lisp
(defn analyze-escapes (expr)
  (match expr
    (EReturn e (mark-escapes e))
    (ECall fn args (forall mark-escapes args))
    (EFn params body
      (let captured (free-vars body params)
        (forall (if (escapes? closure) mark-escapes) captured)))
    ...))
```

### Region Assignment

```lisp
(defn assign-regions (expr escapes)
  (match expr
    (EInt _ (if (escapes expr) RHeap RStack))
    (EVar name (lookup-region name))
    (EFn _ _
      (if (escapes expr) RHeap RStack))
    ...))
```

## 30.5 Writing a Pass: Monomorphization

### Monomorphization State

```lisp
(deftype MonoState
  (MonoState
    (instantiations (Map String Type))  ; fn_name → concrete types
    (cache (Map String String))         ; key → specialized name
    (counter Int)))                     ; for unique names
```

### Specialization

```lisp
(defn monomorphize-fn (state fn-name type-args)
  (let key (canonical-name fn-name type-args)
    (match (map-lookup state.cache key)
      (Some existing existing)
      (None
        (let specialized (specialize-body fn-body type-args)
          (let new-name (generate-name key)
            (map-insert state.cache key new-name)
            (map-insert state.instantiations new-name type-args)
            new-name)))))
```

## 30.6 Writing a Pass: ICNF Lowering

### ICNF ADT (`icnf.zyl`)

```lisp
(deftype ICNF
  (IModule (List IFn))

(deftype IFn
  (IFn String (List IParam) IType Region (List IBlock)))

(deftype IBlock
  (IBlock String (List IInstr) ITerm))

(deftype IInstr
  (ILet Int IType Region IValue)
  ...)

(deftype IValue
  (IConst Int)
  (IVar Int)
  (ICall String (List Int))
  (ICallIndirect Int (List Int))
  (IBinOp IBinOp Int Int)
  (IMakeStruct String (List Int))
  (IStructGet Int String)
  ...)
```

### Lowering Function

```lisp
(defn lower-to-icnf (typed-ast)
  (let converter (make-converter typed-ast.type-info)
    (convert-module converter typed-ast)))
```

## 30.7 Testing Compiler Passes

### Unit Tests for Passes

```lisp
(test "type-inference-let"
  (let ast (parse "(let (x 42) x)")
    (let typed (type-infer ast)
      (assert-equal (get-type typed "x") TInt))))

(test "region-inference-escape"
  (let ast (parse "(fn (x) (fn () x))")
    (let regioned (region-infer ast)
      (assert-equal (get-region regioned "x") RHeap))))
```

### Property-Based Tests

```lisp
(test-property "type-inference-deterministic"
  (gen-expression)
  (fn (expr)
    (let t1 (type-infer expr)
      (let t2 (type-infer expr)
        (assert-equal t1 t2)))))
```

## 30.8 Debugging Compiler Passes

### Print Intermediate AST

```lisp
(defn debug-pass (name pass input)
  (print "=== " name " INPUT ===")
  (print (ast-to-string input))
  (let output (pass input)
    (print "=== " name " OUTPUT ===")
    (print (ast-to-string output))
    output))
```

### REPL Integration

```lisp
zyl> :type (let (x 42) x)
Int

zyl> :region (fn (x) (fn () x))
x : Heap
closure : Heap
```

## 30.9 Adding a New Pass

1. **Define input/output types** in appropriate `.zyl` file
2. **Implement pass function** with clear signature
3. **Add to pipeline** in `driver.zyl`
4. **Add tests** in `tests/regression/compiler.zyl`
5. **Verify fixed point** with `./boot.sh`

## 30.10 Common Patterns

### Visitor Pattern

```lisp
(defn visit-expr (visitor expr)
  (match expr
    (EInt n (visitor.visit-int n))
    (ECall fn args
      (visitor.visit-call fn (map (visitor.visit-expr) args)))
    ...))
```

### State Threading

```lisp
(defn pass-with-state (state expr)
  (match expr
    (ELet name e1 e2
      (let (state1 result1) (pass-with-state state e1)
        (let (state2 result2) (pass-with-state state1 e2)
          (state2 (ELet name result1 result2)))))
    ...))
```

## 30.11 Performance Considerations

- **Avoid deep recursion** — use tail recursion or explicit stack
- **Use `IndexMap`** — deterministic iteration
- **Minimize allocations** — reuse data structures
- **Profile with `--emit-icnf`** — check pass output size