# Diagnostics: the compiler's voice

The compiler talks to a person who is in the middle of writing a program.
Every message is a short lesson about that program, not a trace of what the
compiler was doing when it gave up. This file is the standard every
diagnostic is measured against; `tests/scripts/diagnostics-voice.sh` pins
the wording of the probe program below, so a change to the voice is a
change to that test.

## The standard

1. **The head line is under 80 characters** and says what is wrong in
   plain words, naming the user's own identifier and, where known, the
   value or type. `` `twice` takes an Int as its 1st argument (`n`), but this is a String ``
   beats `cannot unify Int with String`.
2. **One sentence of why**, and only when the reason is security or is
   not obvious from the head line.
3. **The fix is the exact line to write**, in a code span, in the
   imperative, whenever one can be stated: `` end its body with `0` ``,
   `` add `(use core/list)` ``.
4. **Point at the offending expression**, never at the enclosing `defn`
   head. A `main` that does not return an Int is reported at its last
   expression; a bad argument is reported at the argument.
5. **No internal vocabulary.** Never "unify", "ICNF", "lower", "catch-all",
   "poisoned", operator codes, pass names or node kinds. A bare spec
   section number is never the only help. `zyl explain CODE` is the one
   pointer to more.
6. **One message per root cause.** The same unbound name is reported once,
   at its first use, not at every use. A type error that is a consequence
   of an unbound name, or of an earlier mismatch in the same expression, is
   not reported: an expression that mentions an unbound name has no type,
   and nothing that depends on it is checked.
7. **Warnings concern only the user's own code.** A warning in a standard
   library module is not shown while compiling a program; `ZYL_WARN_ALL=1`
   shows them, and the compiler's own build (an internal entry) always
   sees them. Errors are never suppressed.
8. **The closing line counts, it does not lecture.** After more than one
   error the compiler ends with `N errors; fix the first one first`, with
   no code, no `PANIC:` and no restatement. After one error it says
   nothing more. In JSON mode there is no closing line at all: every error
   is already one object.
9. **Output order is truthful.** Whatever the program printed before it
   failed is flushed before the failure is reported, so a `PANIC:` line
   never appears above the output that preceded it.

## The probe

```lisp
(defn classify (o) (match o (Some x (+ x 1)) (None 0)))
(defn twice (n) (let n (+ n 1) (let n (* n 2) n)))
(defn main ()
  (let r (classify (Some 4))
    (print (string-append "r=" (int->string r)))
    (print (string-append "t=" (int->string (twice "x"))))))
```

Measured against the standard, this program has exactly four things wrong
with it and two things worth a word:

- `string-append` and `int->string` are not functions; the compiler says
  so once each and names the functions that do the job (`str-concat`,
  `show`), through a short table of the names other Lisps use for them.
- `(twice "x")` hands a String to a parameter that `twice` adds 1 to; the
  message names the parameter, both types, and points at `"x"`.
- `main` ends with a `print`, which is Unit, so it has no exit status; the
  message is at that last expression and the fix is `end its body with 0`.
- The two `let n` rebind the parameter: two shadowing warnings, in the
  user's own code, each pointing at its `let`.

Nothing else is said. In particular, the second `int->string` and the
second `string-append` are not reported again, nothing is faulted for
taking an argument of unknown type, and the type of `main` is not
reported twice.

## How the pieces meet the standard

- **Unbound names** (`E_UNBOUND_VARIABLE`, `type_annotate.zyl`,
  `ta-unbound`). Reported once per name per program; later uses are typed
  as an unknown that absorbs every constraint, so nothing downstream is
  reported (rule 6). The help is a *did you mean* over every name in scope:
  local bindings, the program's own definitions, every imported
  definition, constructors, operators and the built-in forms. Candidates
  are within edit distance 2, or differ only by a hyphen or by case; at
  most three are offered, ordered by distance and then alphabetically
  (`err-suggest-list`, `error_report.zyl`). A name another Lisp uses for a
  built-in (`string-append`, `number->string`, `string-length`, ...) is
  answered with Zyl's name through a fixed synonym table. A name that exists in a
  standard-library module the program has not imported is reported with
  the `(use ...)` line that adds it, found by scanning the installed
  `stdlib/` once, on demand, and only when an unbound name is reported.
  The note that `((params) body)` is not a lambda appears only when the
  call's head is itself a list, which is the one case it is about.
- **Type mismatches** (`E_TYPE_MISMATCH`). Each site that knows *why* a
  type is expected says so: the operator (`` the operands of `+` must have one type ``),
  the parameter (`` `twice` takes an Int as its 1st argument (`n`) ``),
  the condition (`` `if` needs a Bool condition ``), the return of `main`
  (`` main must return the exit status, an Int ``, at its last expression,
  with the fix `` end its body with 0 ``). Where no reason is known the
  message still names both types without compiler vocabulary:
  `` these must be the same type: `Int` here, `String` there ``.
- **The closing line** (`ta-fail-if-errors`, caught in `selfhost/driver.zyl`
  `drv-report-failure`). The type pass stops the compile by raising; the
  driver turns that into the count line of rule 8 instead of a `PANIC:`.
  The REPL and the language server already drop it.
- **Warnings** (`err-warn-at`, `error_report.zyl`). A warning whose file is
  under `stdlib/` is dropped unless `ZYL_WARN_ALL=1` or the compiler is
  building one of its own internal entries (`internal-mode-p`).
- **Order** (`runtime/rt/panic.zyl`). `pn-panic-test`, `zyl_f_error`, the
  deadlock report and the test runner's failure line flush stdout before
  writing to stderr; `zyl_rt_exit` flushes too.
- **`zyl explain`** (`stdlib/compiler/explain.zyl`). With a code: what it
  means in a sentence, a minimal wrong program, the corrected program, and
  where in the tree it is raised (copies under `build/` are skipped). With
  no code: every code with its one-line meaning, grouped by phase.
- **The catalog is exact.** `verify/error-codes.sh` (run in the `scripts`
  category of `run_regression_tests.sh`) fails when a code is defined in
  `error_codes.zyl` but raised nowhere, or raised but not defined. Spec
  §28 and `spec/15-error-model.md` list the same codes as the catalog.
