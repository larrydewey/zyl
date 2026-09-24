# Chapter 13: A Complete Project Walkthrough

Let's build a small **log processor**: a Zyl program that reads a log file, parses each line into a structured entry, and prints a summary. It is split into a library module, a program, and a test file, and it runs **sequentially**, because determinism and ease of reasoning matter more here than throughput. §13.9 explains why a concurrent version is not practical yet.

The finished program is in `book/examples/log-processor/`. Every code block in this chapter is taken from those files, which were compiled and run with the current self-hosted compiler; the output shown is what they print.

## 13.1 Project Overview

**Goal**: turn this sample file

```text
2024-01-15 [INFO] auth login ok
2024-01-15 [ERROR] auth failed login
2024-01-15 [WARN] db slow query
2024-01-15 [ERROR] db timeout
corrupted entry
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
Skipped:
1
```

The last line of the sample is deliberately malformed: it has too few fields, so it is counted as skipped rather than as an entry.

**Zyl features we'll use:**

- a user module, imported with `(use logstats)`
- `defstruct` for structured data (`LogEntry`, `Stats`)
- `deftype` for an ADT that carries a parsed entry or the unparsable line (`ParseResult`)
- recursion and exhaustive `match` instead of loops and mutation
- the built-in `file-open` / `file-read` / `file-close` forms
- the built-in test harness (`test` / `assert-equal` / `run-tests`)

## 13.2 Project Structure

```text
log-processor/
├── logstats.zyl             # the library: types, parsing, counting
├── log-processor.zyl        # the program: (use logstats) + main
├── log-processor-tests.zyl  # the tests: (use logstats) + tests
└── sample.log               # input data
```

`(use logstats)` finds `logstats.zyl` next to the file being compiled; a subdirectory works the same way (`(use util/strings)` loads `util/strings.zyl`). Two rules for a module you `use`:

- **It must not define `main`.** A `use`d file's top-level forms are spliced into the program that uses it, so its `main` would collide with the program's own. It would also make every test file that uses it fail with `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`, because a file may not contain both tests and a `main`. That is why the program and the tests are separate files that share one library.
- **It must `use` what it constructs.** `logstats.zyl` builds `Cons`/`Nil` lists, so it starts with `(use core/list)`. Without that line, `Nil` is not known as a constructor inside the module, and `match` reports `E_UNREACHABLE_MATCH_ARM` for the arms that follow it.

To build and run, from the project directory:

```bash
cd book/examples/log-processor
zyl log-processor.zyl -o log-processor
./log-processor
```

`-o log-processor` writes the executable `log-processor` and its assembly `log-processor.s`. (With no `-o`, the executable is named after the source file.) Run the program from the project directory so the relative path `"sample.log"` resolves.

> **Things to know about the current compiler.** `print` writes *each argument on its own line*; `str-eq` returns an `Int`, `1` for equal and `0` for different; and struct fields declared without a type (as here) hold one 64-bit word, a string pointer or an integer. The chapter's code works with these, and each is pointed out where it matters.

## 13.3 Step 1: Data Types

`logstats.zyl` starts with its import and its types:

```lisp
(use core/list)

(defstruct LogEntry (timestamp) (level) (service) (message))
(defstruct Stats (total) (errors) (warnings) (infos) (skipped))

(deftype ParseResult
  (Parsed LogEntry)
  (Unparsed String))
```

- `LogEntry` models one parsed line.
- `Stats` holds the counts we accumulate, including lines we could not parse.
- `ParseResult` is the outcome of parsing one line: either a `Parsed` entry or the `Unparsed` line itself.

Structs are immutable: you build a new one instead of changing fields. `make-LogEntry` is the generated constructor and `struct-get` reads a field by name:

```lisp
(struct-get entry "level")     ; "[ERROR]"
```

## 13.4 Step 2: A Tokenizer

The workhorse splits a string on a one-character separator and returns a list of tokens:

```lisp
(defn tokenize-h (s n i start acc sep)
  (if (>= i n)
    (if (> i start)
      (Cons (str-substring s start (- i start)) acc)
      acc)
    (if (> (str-eq (str-substring s i 1) sep) 0)
      (tokenize-h s n (+ i 1) (+ i 1)
        (Cons (str-substring s start (- i start)) acc) sep)
      (tokenize-h s n (+ i 1) start acc sep))))

(defn tokenize (s sep)
  (list-reverse (tokenize-h s (str-length s) 0 0 Nil sep)))

(defn list-nth (l k)
  (match l
    (Nil 0)
    (Cons h t (if (= k 0) h (list-nth t (- k 1))))))
```

- `tokenize-h` walks the string with an index pair (`start`, `i`) and **accumulates into `acc`**; `tokenize` then reverses the list with `core/list`'s `list-reverse` so the tokens come back in reading order. Recursion with an accumulator is the idiomatic Zyl replacement for a loop that pushes into a growing vector.
- `str-substring` returns a fresh heap copy of the slice, so each token stays valid after the call.
- `str-eq` compares contents and returns `1` or `0`, so it is used as `(> (str-eq a b) 0)` in a condition.
- `list-nth` returns `0` past the end of the list, which is enough for this program.

## 13.5 Step 3: Parse One Line

A line is `<timestamp> <level> <service> <message...>`. A line with fewer than four tokens is not a log line:

```lisp
(defn parse-line (line)
  (let toks (tokenize line " ")
    (if (< (list-length toks) 4)
      (Unparsed line)
      (make-entry line toks))))

(defn make-entry (line toks)
  (let ts (list-nth toks 0)
    (let lvl (list-nth toks 1)
      (let svc (list-nth toks 2)
        (let off (message-offset ts lvl svc)
          (Parsed (make-LogEntry ts lvl svc
                    (str-substring line off (- (str-length line) off)))))))))

(defn message-offset (ts lvl svc)
  (let a (str-length ts)
    (let b (str-length lvl)
      (let c (str-length svc)
        (+ a b c 3)))))
```

The message is not a single token: it is everything after the third space, so `"slow query"` stays whole. `message-offset` adds up the three field lengths plus one space after each.

Note the style of `message-offset`: each call is bound with `let` before the results are combined. Arithmetic over several calls, such as `(+ (str-length ts) (str-length lvl) ...)`, is legal Zyl, but inside a `match` arm the current compiler rejects an arm that mixes a constant with several calls (`E_MATCH_ARM_COMPLEX`), and short `let` chains keep every function clear of that rule.

## 13.6 Step 4: Count Lines

Counting takes the running `Stats` and returns a new one:

```lisp
(defn empty-stats () (make-Stats 0 0 0 0 0))

(defn level-is (e lvl)
  (if (> (str-eq (struct-get e "level") lvl) 0) 1 0))

(defn count-entry (st e)
  (make-Stats (+ (struct-get st "total") 1)
              (+ (struct-get st "errors") (level-is e "[ERROR]"))
              (+ (struct-get st "warnings") (level-is e "[WARN]"))
              (+ (struct-get st "infos") (level-is e "[INFO]"))
              (struct-get st "skipped")))

(defn count-skipped (st)
  (make-Stats (struct-get st "total")
              (struct-get st "errors")
              (struct-get st "warnings")
              (struct-get st "infos")
              (+ (struct-get st "skipped") 1)))

(defn count-line (st line)
  (match (parse-line line)
    (Parsed e (count-entry st e))
    (Unparsed _ (count-skipped st))))
```

`count-line` is where the ADT pays off: the `match` must handle both outcomes (a missing arm is a compile-time `E_NON_EXHAUSTIVE_MATCH`), and the `Parsed` arm receives the whole `LogEntry`. `_` discards the unparsed line, which only the count needs.

## 13.7 Step 5: Scan the Whole File

`scan` cuts the file's contents on newlines and folds each non-empty line into the `Stats`, threading the struct through the recursion:

```lisp
(defn scan (st s n i start)
  (if (>= i n)
    (finish-line st s start i)
    (if (> (str-eq (str-substring s i 1) "\n") 0)
      (scan (finish-line st s start i) s n (+ i 1) (+ i 1))
      (scan st s n (+ i 1) start))))

(defn finish-line (st s start end)
  (if (> end start)
    (count-line st (str-substring s start (- end start)))
    st))

(defn scan-text (s)
  (scan (empty-stats) s (str-length s) 0 0))

; A file that cannot be opened reads as an empty log, after saying so.
(defn process-file (path)
  (let fd (file-open path "r")
    (if (< fd 1)
      (begin
        (print "log-processor: cannot open the log file")
        (empty-stats))
      (let content (file-read fd 1000000)
        (let _ (file-close fd)
          (scan-text content))))))
```

- `finish-line` skips empty lines, so the file's trailing newline does not produce a skipped entry.
- `scan-text` works on any string, which makes the counting testable without a file (§13.9).
- `file-open` returns a file descriptor, or a negative number when the file cannot be opened. `file-read` returns up to the given number of bytes as a string; `1000000` is the maximum read here.

## 13.8 Step 6: `main`

`log-processor.zyl` is short:

```lisp
(use logstats)

(defn report (st)
  (begin
    (print "Total:" (struct-get st "total"))
    (print "Error:" (struct-get st "errors"))
    (print "Warn:" (struct-get st "warnings"))
    (print "Info:" (struct-get st "infos"))
    (print "Skipped:" (struct-get st "skipped"))))

(defn main ()
  (begin
    (report (process-file "sample.log"))
    0))
```

`main`'s value is the process exit status, so it ends with an explicit `0`. Building and running from the project directory gives:

```bash
$ zyl log-processor.zyl -o log-processor
$ ./log-processor
Total:
4
Error:
2
Warn:
1
Info:
1
Skipped:
1
```

Each label and its value are on separate lines because `print` writes every argument on a line of its own. Run it from another directory and it reports `log-processor: cannot open the log file` followed by zero counts.

## 13.9 Step 7: Tests

`log-processor-tests.zyl` uses the same library. `test`, `assert-equal`, and `run-tests` are built-in forms, so no import is needed for the harness:

```lisp
(use logstats)

; Helpers keep each test body to a single comparison.
(defn level-of (line)
  (match (parse-line line)
    (Parsed e (struct-get e "level"))
    (Unparsed _ "")))

(defn message-of (line)
  (match (parse-line line)
    (Parsed e (struct-get e "message"))
    (Unparsed _ "")))

(defn is-unparsed (line)
  (match (parse-line line)
    (Parsed _ 0)
    (Unparsed _ 1)))

(test "tokenize-counts-tokens"
  (assert-equal (list-length (tokenize "a bbb ccc" " ")) 3))

(test "tokenize-keeps-order"
  (assert-equal (str-eq (list-nth (tokenize "a bbb ccc" " ") 1) "bbb") 1))

(test "parse-reads-level"
  (assert-equal (str-eq (level-of "2024-01-15 [WARN] db slow query") "[WARN]") 1))

(test "parse-keeps-whole-message"
  (assert-equal (str-eq (message-of "2024-01-15 [WARN] db slow query") "slow query") 1))

(test "short-line-is-unparsed"
  (assert-equal (is-unparsed "garbage") 1))

(test "scan-counts-levels"
  (let st (scan-text "d [ERROR] a x\nd [INFO] b y\nd [ERROR] c z\n")
    (begin
      (assert-equal (struct-get st "total") 3)
      (assert-equal (struct-get st "errors") 2)
      (assert-equal (struct-get st "infos") 1))))

(test "scan-skips-malformed-lines"
  (let st (scan-text "d [INFO] a x\ntruncated line\n")
    (begin
      (assert-equal (struct-get st "total") 1)
      (assert-equal (struct-get st "skipped") 1))))

(run-tests)
```

Build and run the tests the same way:

```bash
$ zyl log-processor-tests.zyl -o log-processor-tests
$ ./log-processor-tests
test: tokenize-counts-tokens ... ok
test: tokenize-keeps-order ... ok
test: parse-reads-level ... ok
test: parse-keeps-whole-message ... ok
test: short-line-is-unparsed ... ok
test: scan-counts-levels ... ok
test: scan-skips-malformed-lines ... ok

test result: 7 passed, 0 failed, 7 total
```

Notes on the harness (Chapter 11 has the details):

- The file has no `main`; the compiler generates one. A file with both tests and its own `main` is rejected with `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`.
- Only flat top-level `(test "name" body)` forms run. `test-suite`, `setup`/`teardown`, `test-property`, and keyword options such as `:filter` are accepted but do nothing yet.
- Read the summary line: the program's exit status is 0 even when a test fails.

## 13.10 A Concurrent Variation?

The natural concurrent design gives each file to a worker actor, which parses it and sends its `Stats` back to a collector. With `receive` and `actor-self` (Chapter 21, §21.3) that design works: main sends each worker a message carrying a file name and its own id, the worker parses the file and `send`s its `Stats` back, and main `receive`s one reply per worker. For a single sample file it adds nothing over calling `report` directly, so the sequential version is the one shown here.

## 13.11 Key Zyl Features Demonstrated

| Feature | Where Used |
|---------|------------|
| User modules | `(use logstats)` in the program and the tests |
| `defstruct` | `LogEntry`, `Stats`: immutable records, rebuilt instead of mutated |
| `deftype` | `ParseResult`: an ADT that carries data |
| Exhaustive `match` | `count-line`, `list-nth`, the test helpers |
| `Cons`/`Nil` lists | Tokens, reversed with `list-reverse` |
| Recursion + accumulators | `tokenize-h`, `scan` |
| Strings | `str-substring`, `str-length`, `str-eq` |
| Built-in I/O | `file-open`, `file-read`, `file-close` |
| Test harness | `test`, `assert-equal`, `run-tests` |

## 13.12 Extending the Project

Ideas to stretch the example:

1. **Per-service counts**: keep an association list of `(service, count)` pairs in `Stats`, or use `core/map`'s `map-insert` / `map-get-or`.
2. **Report the skipped lines**: `Unparsed` already carries the line; collect those lines in a list instead of only counting them.
3. **Contracts**: add a `requires` clause to `count-entry` (Chapter 24). Contracts are an optional overlay and do not change what the program computes.
4. **A macro**: write a `defmacro` that expands to one of the `count-*` field updates (Chapter 10). Keep the macro call out of `match` arms, where the current expander does not look.
5. **A package**: add a `zyl.pkg` with `(capabilities io)` (the program opens files) and build it with `zyl build` (Chapter 25).

---

## Summary: What You've Learned

This part of the book covered:

**Part I: Tutorial (Chapters 1-13)**
1. Getting Started: installation, first program, compilation pipeline
2. Syntax & Types: atoms, lists, bindings, core types
3. Functions & Control Flow: `defn`, recursion, `if`/`cond`/`while`/`for`, `try`/`catch`
4. Data Structures: structs, ADTs, collections, `Option`/`Result`
5. Ownership, Regions, Capabilities: memory safety without GC
6. Pattern Matching & Error Handling: exhaustive `match`, `Result` patterns
7. Generics & Traits: parametric and ad-hoc polymorphism
8. Closures: explicit syntax, capture by value, higher-order functions
9. Actors: spawning, sending, and waiting
10. Macros: template macros, expansion order, current limits
11. Testing: the built-in framework and assertions
12. FFI: calling C, pinning, native package dependencies
13. Project Walkthrough: a complete multi-file application

**Next Steps:**
- Read **Part II: Reference** for deep dives on each topic
- Explore **Part III: Advanced Topics** for compiler internals
- Browse `tests/regression/` for more examples, every one of which compiles and runs
