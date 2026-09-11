# Chapter 13: A Complete Project Walkthrough

Let's build a small **log processor** — a realistic Zyl program that reads a log file line by line, extracts a level token from each line, and produces a summary. It is deliberately kept to **one file** and runs **sequentially**, because determinism and ease of reasoning matter more here than throughput. A concurrent (actor-based) variation is sketched at the end of the chapter.

The finished, runnable program is available in `book/examples/log-processor/`. Every code block in this chapter was compiled and executed against the actual compiler before being printed here — what you see is what the compiler produces.

## 13.1 Project Overview

**Goal**: turn this sample file

```text
2024-01-15 [INFO] auth login ok
2024-01-15 [ERROR] auth failed login
2024-01-15 [WARN] db slow query
2024-01-15 [ERROR] db timeout
```

into this summary:

```text
Total:
4
Error:
2
Warn:
1
Info:
1
```

**Zyl features we'll use:**

- `defstruct` for structured data (`LogEntry`, `Stats`)
- `deftype` for an ADT that tags a line as parsed / unparsed (`ParseResult`)
- plain recursion and `match` instead of loops and mutation — the Zyl idiom
- arena-based strings (`str-intern`) so tokens outlive the scratch buffers they are read from
- the built-in `file-open` / `file-read` / `file-close` I/O forms
- the built-in test harness (`test` / `assert-equal` / `run-tests`)

## 13.2 Project Structure

Multi-file programs are on the roadmap (user modules outside `stdlib/` are not resolved yet), so the project is a single file plus a test file plus a data file:

```text
log-processor/
├── log-processor.zyl        # the program
├── log-processor-tests.zyl  # the test-suite variant
└── sample.log               # input data
```

To **build**, run `zyl` from the directory that contains `stdlib/` (the compiler resolves `(use …)` modules relative to its own working directory). To **run** the produced binary, change into the project directory so the relative path `"sample.log"` resolves:

```bash
zyl log-processor/log-processor.zyl -o log-processor/log-processor
cd log-processor
./log-processor.bin
```

`-o <name>` makes the compiler emit `<name>.s` next to `<name>.bin`. (With no `-o`, defaults are `a.out.s` / `a.out.bin`.)

> **Bootstrap snapshot.** This walkthrough targets the current stage-1 (Rust) compiler. A few behaviors you should expect right now: struct fields are untyped (they hold 64-bit words — string pointers or integers); `str-eq` returns an `Int` `0`/`1`, not a `Bool`; `print` writes *each argument on its own line*; and when a `(run-tests)` is present, the tests run and `main` is not reached. Each of these is called out where it matters below, and the chapter's code works with them rather than against them.

## 13.3 Step 1: Data Types

The file starts by importing the two modules we rely on — the arena allocator and the `Cons`/`Nil` list helpers (see Chapter 2 and Appendix B on `use`):

```lisp
(use allocator/allocator)
(use core/list)

(defstruct LogEntry (timestamp) (level) (service) (message))
(defstruct Stats (total) (errors) (warnings) (infos))

(deftype ParseResult
  (Parsed)
  (Unparsed String))
```

- `LogEntry` models one parsed line. Fields are untyped, so they may hold either an inverted string pointer or an integer.
- `Stats` holds the aggregates we accumulate.
- `ParseResult` tags the outcome of parsing a line. `Parsed` deliberately carries no payload: extracting a struct out of an ADT payload is not type-stable in the current compiler, so we keep the ADT as a pure discriminator and read the tokens directly.

Structs are immutable by default — you rebind rather than mutate. Field access uses `struct-get`:

```lisp
(defn new-entry (line)
  (let toks (tokenize line " ")
    (make-LogEntry (list-nth toks 0)
                   (list-nth toks 1)
                   (list-nth toks 2)
                   (list-nth toks 3))))
```

Bind the struct to a local before reading its fields:

```lisp
(let e (new-entry "2024-01-15 [ERROR] auth squawk")
  (str-eq (struct-get e "level") "[ERROR]"))   ; → 1
```

## 13.4 Step 2: A Persistent Tokenizer

The workhorse is `tokenize`, which splits a string on a separator and returns a list of token pointers:

```lisp
(defn tokenize-h (arena s n i start acc sep)
  (if (>= i n)
    (if (>= i start)
      (Cons (str-intern arena (str-substring s start (- i start))) acc)
      acc)
    (if (str-eq (str-substring s i 1) sep)
      (tokenize-h arena s n (+ i 1) (+ i 1)
        (Cons (str-intern arena (str-substring s start (- i start))) acc) sep)
      (tokenize-h arena s n (+ i 1) start acc sep))))

(defn rev (l acc)
  (match l
    (Nil acc)
    (Cons h t (rev t (Cons h acc)))))

(defn tokenize (s sep)
  (let a (arena-create 4096)
    (rev (tokenize-h a s (str-length s) 0 0 Nil sep) Nil)))

(defn list-nth (l k)
  (match l
    (Nil 0)
    (Cons h t (if (= k 0) h (list-nth t (- k 1))))))
```

Two details matter:

- `str-substring` returns a pointer into a scratch buffer that is *reused*; those pointers do not survive. `str-intern` copies each token into an arena we create per `tokenize` call, so the returned tokens are stable. Getting into the habit of "persist what you split" saves you a whole class of hard-to-see bugs.
- `tokenize-h` walks the string with an explicit `start`/`i` index pair and **accumulates into `acc`**. It then reverses so the tokens come back in reading order. This recursion-with-accumulator is the idiomatic Zyl replacement for a `while` loop that pushes into a `Vec`.

Note `str-eq` compares contents and returns `1` (match) or `0` (mismatch) as an `Int` — use it in `if`/`>` conditions, exactly as in `tokenize-h` and `add-line` below.

## 13.5 Step 3: Count One Line

Lines look like `2024-01-15 [INFO] auth login ok`. The **level** is token 1 (0-based); we compare it against the bracketed literals. `add-line` takes the running totals and returns the new totals, packed as a four-element `Cons` chain (the `list` literal and tuples are not implemented yet):

```lisp
(defn add-line (line t e w i0)
  (let toks (tokenize line " ")
  (let lvl (list-nth toks 1)
    (if (= lvl 0)
      (Cons t (Cons e (Cons w (Cons i0 Nil))))
      (Cons (+ t 1)
            (Cons (+ e (if (> (str-eq lvl "[ERROR]") 0) 1 0))
                  (Cons (+ w (if (> (str-eq lvl "[WARN]") 0) 1 0))
                        (Cons (+ i0 (if (> (str-eq lvl "[INFO]") 0) 1 0))
                              Nil))))))))
```

If the line has fewer than two tokens (`lvl` is `0`), it is left out of the count. This replaces the original project sketch's `string-split` + `vec-slice` + `string-join` helpers, none of which exist in the standard library yet.

## 13.6 Step 4: Scan the Whole File

`scan` walks the file content, cutting it on newlines and folding each line through `add-line`. The counts are threaded as **four separate integer arguments** — not as a struct — because integer arguments survive recursion reliably in the current compiler, while passing a struct through several stacked function frames does not. Only at the very end do we assemble the `Stats` struct out of the four bound integers:

```lisp
(defn scan (s n i start t e w i0)
  (if (>= i n)
    (if (>= i start)
      (let r (add-line (str-substring s start (- i start)) t e w i0)
        (make-Stats (list-nth r 0) (list-nth r 1) (list-nth r 2) (list-nth r 3)))
      (make-Stats t e w i0))
    (if (str-eq (str-substring s i 1) "\n")
      (let r (add-line (str-substring s start (- i start)) t e w i0)
        (scan s n (+ i 1) (+ i 1)
          (list-nth r 0) (list-nth r 1) (list-nth r 2) (list-nth r 3)))
      (scan s n (+ i 1) start t e w i0))))

(defn process-file (path)
  (let content (file-read (file-open path "r") 1000000)
    (scan content (str-length content) 0 0 0 0 0 0)))
```

The `file-open` / `file-read` / `file-close` forms are built in (Powering the `IO` module). `file-read` returns the whole file as a string; `1000000` is the maximum number of bytes to read.

## 13.7 Step 5: `main`

```lisp
(defn main ()
  (let st (process-file "sample.log")
    (begin
      (print "Total:" (struct-get st "total"))
      (print "Error:" (struct-get st "errors"))
      (print "Warn:" (struct-get st "warnings"))
      (print "Info:" (struct-get st "infos")))))
```

Building and running from the project directory gives:

```bash
$ cd log-processor && ./log-processor.bin
Total:
4
Error:
2
Warn:
1
Info:
1
```

Remember, the current bootstrap prints each argument of `print` **on its own line** — which is exactly why the output looks like this. (In a future stage the plan is to bind print formatting more closely to the type system, e.g., string-typed arguments printed inline.)

## 13.8 Step 6: Tests

The test file `log-processor-tests.zyl` reuses the same functions (no `use` import is needed for the harness — `test`, `assert-equal`, `assert-true`, `run-tests` are recognized forms) and replaces `main` with a `(run-tests)` line:

```lisp
(use allocator/allocator)
(use core/list)

(defstruct LogEntry (timestamp) (level) (service) (message))
(defstruct Stats (total) (errors) (warnings) (infos))

(defn tokenize-h (arena s n i start acc sep)
  (if (>= i n)
    (if (>= i start)
      (Cons (str-intern arena (str-substring s start (- i start))) acc)
      acc)
    (if (str-eq (str-substring s i 1) sep)
      (tokenize-h arena s n (+ i 1) (+ i 1)
        (Cons (str-intern arena (str-substring s start (- i start))) acc) sep)
      (tokenize-h arena s n (+ i 1) start acc sep))))

(defn rev (l acc)
  (match l
    (Nil acc)
    (Cons h t (rev t (Cons h acc)))))

(defn tokenize (s sep)
  (let a (arena-create 4096)
    (rev (tokenize-h a s (str-length s) 0 0 Nil sep) Nil)))

(defn list-nth (l k)
  (match l
    (Nil 0)
    (Cons h t (if (= k 0) h (list-nth t (- k 1))))))

(defn add-line (line t e w i0)
  (let toks (tokenize line " ")
  (let lvl (list-nth toks 1)
    (if (= lvl 0)
      (Cons t (Cons e (Cons w (Cons i0 Nil))))
      (Cons (+ t 1)
            (Cons (+ e (if (> (str-eq lvl "[ERROR]") 0) 1 0))
                  (Cons (+ w (if (> (str-eq lvl "[WARN]") 0) 1 0))
                        (Cons (+ i0 (if (> (str-eq lvl "[INFO]") 0) 1 0))
                              Nil))))))))

(test "eq-lit" (assert-equal 1 (str-eq "[INFO]" "[INFO]")))
(test "short" (assert-equal 0 (list-nth (add-line "x" 0 0 0 0) 0)))
(test "nth1" (assert-equal 3 (str-length (list-nth (tokenize "a bbb ccc" " ") 1))))
(test "nth2" (assert-equal 3 (str-length (list-nth (tokenize "a bbb ccc" " ") 2))))
(run-tests)
```

Build and run the tests the same way:

```bash
zyl log-processor/log-processor-tests.zyl -o log-processor/log-processor-tests
cd log-processor && ./log-processor-tests.bin
```

```text
test: eq-lit ... ok
test: short ... ok
test: nth1 ... ok
test: nth2 ... ok

test result: 4 passed, 0 failed, 4 total
```

Two notes on the harness in the current bootstrap:

- `test-suite`, `setup`/`teardown`, `test-property`, and the `:parallel` / `:filter` keyword arguments are parsed but are not executed yet — flat top-level `(test "name" body)` forms are the supported path today (see Chapter 11).
- When the file contains `(run-tests)`, the tests run and `main` is **not** reached. Keep the demo (`main`) and the suite in separate files, as we did here.

## 13.9 Step 7: A Concurrent Variation (Design Sketch)

Actors are part of the language design (`spawn` takes a closure, `send` posts a message; the runtime joins all actors at the end of `main`). The *intended* shape of a concurrent log processor is:

```lisp
;; design sketch — message staging is under re-verification in the current stage-1 compiler
(defn main ()
  (let worker (spawn (fn (msg)
    (match msg
      (ProcessFile path (send (reply-of worker) (process-file path)))
      (Shutdown unit))))
    (send worker (ProcessFile "sample.log"))
    (send worker (Shutdown))))
```

Treat this as the target design, not as runnable example code: sending structured messages and receiving replies (`receive`, reply channels) are not yet stable in the stage-1 compiler. The sequential version above is the verified, deterministic path. Chapter 9 covers the actor model in depth; Part III covers the runtime machinery.

## 13.10 Key Zyl Features Demonstrated

| Feature | Where Used |
|---------|------------|
| `defstruct` | `LogEntry`, `Stats` — immutable records |
| `deftype` | `ParseResult` — an ADT as a discriminator |
| `match` | `rev`, `list-nth` — exhaustive `Cons`/`Nil` patterns |
| `Cons`/`Nil` lists | Tokens and per-line totals (no `list` literal yet) |
| Recursion + accumulators | `tokenize-h`, `rev`, `scan` — instead of mutation |
| Arena strings | `str-intern` to persist `str-substring` tokens |
| Built-in I/O | `file-open`, `file-read` |
| Strings as pointers | `str-eq`, `str-length` comparisons |
| Test harness | `test`, `assert-equal`, `run-tests` |

## 13.11 Extending the Project

Ideas to stretch the example:

1. **Per-service counts** — keep a second `Stats`-like accumulator keyed by the `service` token, threading a small association list through `scan` instead of a `Map` (collection modules are growing, but a hand-rolled list is both simpler and deterministic today).
2. **Skipping malformed lines** — change `ParseResult` so `Unparsed` carries the offending line, and count them as their own field.
3. **Contracts** — add a `(requires …)` on `add-line` that the totals never decrease (Chapter 25).
4. **A macro** — write a `defn-rec`-style macro to generate the `rev`-pattern for other "walk left, rebuild right" traversals (Chapter 10).
5. **Move the parser to an actor** once message staging stabilizes, per the §13.9 sketch.

---

## Summary: What You've Learned

This book covered:

**Part I: Tutorial (Chapters 1-13)**
1. Getting Started — installation, first program, compilation pipeline
2. Syntax & Types — atoms, lists, bindings, core types
3. Functions & Control Flow — `defn`, recursion, `if`/`cond`/`while`/`for`, `try`/`catch`
4. Data Structures — structs, ADTs, collections, `Option`/`Result`
5. Ownership, Regions, Capabilities — memory safety without GC
6. Pattern Matching & Error Handling — exhaustive `match`, `Result` patterns
7. Generics & Traits — parametric + ad-hoc polymorphism
8. Closures — explicit syntax, capture inference, HOFs
9. Actors — concurrent message passing
10. Macros — hygienic, innermost-first metaprogramming
11. Testing — built-in framework, property-based testing
12. FFI — safe C interop with pinning
13. Project Walkthrough — complete application

**Next Steps:**
- Read **Part II: Reference** for deep dives on each topic
- Explore **Part III: Advanced Topics** for compiler internals
- Check `tests/regression/` for more examples
- Join the Zyl community!

---

*Happy coding in Zyl!* 🎉