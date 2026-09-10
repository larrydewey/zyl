# Chapter 13: A Complete Project Walkthrough

Let's build a **concurrent log processor** — a realistic Zyl application that demonstrates the language's features working together.

## 13.1 Project Overview

**Goal**: Process log files concurrently, extract statistics, and output a summary.

**Features we'll use:**
- Structs and ADTs for data modeling
- Actors for concurrent file processing
- Pattern matching for log parsing
- Result/Option for error handling
- FFI for fast I/O (optional)
- Testing for correctness

## 13.2 Project Structure

```
log-processor/
├── src/
│   ├── main.zyl          # Entry point
│   ├── types.zyl         # Data types
│   ├── parser.zyl        # Log parsing
│   ├── processor.zyl     # Actor-based processing
│   └── stats.zyl         # Statistics computation
├── test/
│   └── log-processor-test.zyl
├── build.sh
└── sample.log
```

## 13.3 Step 1: Define Types (`types.zyl`)

```lisp
;; types.zyl — Core data types

;; Log entry with structured fields
(defstruct LogEntry
  (timestamp)
  (level)
  (service)
  (message))

;; Parse result
(deftype ParseResult
  (Parsed LogEntry)
  (Failed String))

;; Statistics aggregated across files
(defstruct+ Stats
  (total-lines)
  (error-count)
  (warn-count)
  (info-count)
  (debug-count)
  (by-service)
  (:derive [Eq Show]))

;; Messages for actor communication
(deftype ProcessorMsg
  (ProcessFile String (reply ActorRef))
  (Shutdown))
```

## 13.4 Step 2: Log Parser (`parser.zyl`)

```lisp
;; parser.zyl — Parse log lines

(use core { print string-split string-starts-with })

;; Parse a single log line
;; Format: "2024-01-15 10:30:45 [ERROR] auth: Failed login"
(defn parse-line (line)
  (let parts (string-split line " "))
    (if (>= (vec-len parts) 4)
      (let timestamp (vec-get parts 0)
        (let level-part (vec-get parts 1)
          (let service-msg (string-split (string-join (vec-slice parts 2 (vec-len parts)) " ") ": ")
            (if (== (vec-len service-msg) 2)
              (let service (vec-get service-msg 0)
                (let message (vec-get service-msg 1)
                  (let level (string-slice level-part 1 (- (string-len level-part) 1))
                    (Parsed (make-LogEntry timestamp level service message)))))
              (Failed "Invalid service:message format")))))
      (Failed "Not enough parts")))

;; Batch parse with statistics
(defn parse-lines (lines)
  (let-mut (parsed Nil)
    (let-mut (failed 0)
      (for (line lines)
        (match (parse-line line)
          (Parsed entry (set! parsed (Cons entry parsed)))
          (Failed _ (set! failed (+ failed 1)))))
      (tuple parsed failed))))
```

## 13.5 Step 3: Statistics (`stats.zyl`)

```lisp
;; stats.zyl — Compute statistics from parsed entries

(use core { print })
(use collections/map { map-create map-put map-get map-len })

(defn empty-stats ()
  (make-Stats 0 0 0 0 0 (map-create 0 10)))

(defn update-stats (stats entry)
  (let new-stats (make-Stats
    (+ (struct-get stats "total-lines") 1)
    (if (== (struct-get entry "level") "ERROR") (+ (struct-get stats "error-count") 1) (struct-get stats "error-count"))
    (if (== (struct-get entry "level") "WARN") (+ (struct-get stats "warn-count") 1) (struct-get stats "warn-count"))
    (if (== (struct-get entry "level") "INFO") (+ (struct-get stats "info-count") 1) (struct-get stats "info-count"))
    (if (== (struct-get entry "level") "DEBUG") (+ (struct-get stats "debug-count") 1) (struct-get stats "debug-count"))
    (struct-get stats "by-service")))
  
  ;; Update per-service count
  (let service (struct-get entry "service")
    (let current (map-get new-stats service 0)
      (set! new-stats (make-Stats
        (struct-get new-stats "total-lines")
        (struct-get new-stats "error-count")
        (struct-get new-stats "warn-count")
        (struct-get new-stats "info-count")
        (struct-get new-stats "debug-count")
        (map-put (struct-get new-stats "by-service") service (+ current 1)))))
  new-stats)

(defn merge-stats (s1 s2)
  (make-Stats
    (+ (struct-get s1 "total-lines") (struct-get s2 "total-lines"))
    (+ (struct-get s1 "error-count") (struct-get s2 "error-count"))
    (+ (struct-get s1 "warn-count") (struct-get s2 "warn-count"))
    (+ (struct-get s1 "info-count") (struct-get s2 "info-count"))
    (+ (struct-get s1 "debug-count") (struct-get s2 "debug-count"))
    (map-merge-with + (struct-get s1 "by-service") (struct-get s2 "by-service"))))
```

## 13.6 Step 4: File Processor Actor (`processor.zyl`)

```lisp
;; processor.zyl — Actor that processes log files

(use core { read-file-lines })  ; Hypothetical: read file → Result<Vec<String>, String>
(use actor { spawn send wait_all })

;; File processor actor
(defn make-file-processor (reply-to)
  (spawn
    (fn (msg)
      (match msg
        (ProcessFile path reply
          (match (read-file-lines path)
            (Ok lines
              (let parsed-failed (parse-lines lines)
                (let parsed (tuple-fst parsed-failed)
                  (let stats (fold update-stats empty-stats parsed)
                    (send reply (Ok stats)))))
            (Err err
              (send reply (Err err)))))
        (Shutdown unit))))

;; Process multiple files concurrently
(defn process-files (paths)
  (let-mut (workers Nil)
    (let-mut (replies Nil)
      ;; Spawn one worker per file
      (for (path paths)
        (let worker (make-file-processor (spawn (fn (reply) (set! replies (Cons reply replies)))))
          (set! workers (Cons worker workers))
          (send worker (ProcessFile path (tuple-snd (tuple worker))))))
      
      ;; Collect results
      (let-mut (combined-stats (empty-stats))
        (for (reply replies)
          (match (receive reply)
            (Ok stats (set! combined-stats (merge-stats combined-stats stats)))
            (Err err (print "File error: " err))))
        combined-stats))))
```

## 13.7 Step 5: Main Entry Point (`main.zyl`)

```lisp
;; main.zyl — Entry point

(use core { print read-line })
(use processor { process-files })

(defn main ()
  (print "=== Log Processor ===\n")
  
  ;; Get file paths from command line or stdin
  (print "Enter log file paths (one per line, empty to start):\n")
  
  (let-mut (paths Nil)
    (while true
      (match (read-line)
        (Ok line
          (if (== (string-len line) 0)
            (break)
            (set! paths (Cons line paths))))
        (Err _ (break))))
  
  (if (== (length paths) 0)
    (print "No files provided.\n")
    (let stats (process-files paths)
      (print "\n=== Results ===\n")
      (print "Total lines: " (struct-get stats "total-lines") "\n")
      (print "Errors: " (struct-get stats "error-count") "\n")
      (print "Warnings: " (struct-get stats "warn-count") "\n")
      (print "Info: " (struct-get stats "info-count") "\n")
      (print "Debug: " (struct-get stats "debug-count") "\n")
      (print "\nBy service:\n")
      (map-for-each (struct-get stats "by-service")
        (fn (service count)
          (print "  " service ": " count "\n"))))))
```

## 13.8 Step 6: Tests (`test/log-processor-test.zyl`)

```lisp
;; test/log-processor-test.zyl

(use testing { test-suite test assert-equal assert-true run-tests })
(use parser { parse-line })
(use stats { empty-stats update-stats merge-stats })
(use types { LogEntry ParseResult Stats })

(test-suite "log-parser"
  (test "parse-valid-line"
    (match (parse-line "2024-01-15 10:30:45 [ERROR] auth: Failed login")
      (Parsed entry
        (assert-equal (struct-get entry "timestamp") "2024-01-15")
        (assert-equal (struct-get entry "level") "ERROR")
        (assert-equal (struct-get entry "service") "auth")
        (assert-equal (struct-get entry "message") "Failed login"))
      (Failed _ (assert-fail "should parse"))))
  
  (test "parse-invalid-line"
    (assert-true (match (parse-line "not a log line") (Failed _ true) (Parsed _ false)))))

(test-suite "statistics"
  (test "empty-stats"
    (let s (empty-stats)
      (assert-equal (struct-get s "total-lines") 0)
      (assert-equal (struct-get s "error-count") 0)))
  
  (test "update-stats"
    (let entry (make-LogEntry "2024-01-15" "ERROR" "auth" "failed")
    (let s (update-stats (empty-stats) entry)
      (assert-equal (struct-get s "total-lines") 1)
      (assert-equal (struct-get s "error-count") 1))))
  
  (test "merge-stats"
    (let s1 (make-Stats 10 2 1 5 0 (map-create 0 5))
    (let s2 (make-Stats 5 1 0 3 1 (map-create 0 5))
    (let merged (merge-stats s1 s2)
      (assert-equal (struct-get merged "total-lines") 15)
      (assert-equal (struct-get merged "error-count") 3)))))

(run-tests)
```

## 13.9 Building and Running

```bash
# Build
zyl src/main.zyl

# Run
./main

# Or run tests
zyl test/log-processor-test.zyl
./log-processor-test
```

## 13.10 Sample Run

```
=== Log Processor ===
Enter log file paths (one per line, empty to start):
app.log
auth.log
db.log

=== Results ===
Total lines: 15420
Errors: 23
Warnings: 156
Info: 14200
Debug: 1041

By service:
  auth: 3420
  db: 5100
  api: 4200
  cache: 2700
```

## 13.11 Key Zyl Features Demonstrated

| Feature | Where Used |
|---------|------------|
| `defstruct` / `defstruct+` | `LogEntry`, `Stats` |
| `deftype` (ADT) | `ParseResult`, `ProcessorMsg` |
| Pattern matching (`match`) | Parser, actor message handling |
| `Result`/`Option` | File I/O, parsing |
| Actors (`spawn`/`send`) | Concurrent file processing |
| `let-mut`/`set!` | Mutable counters in actors |
| Traits (`derive`) | `Stats` gets `Eq`, `Show` |
| Collections (`Map`) | Per-service counting |
| Testing framework | `test-suite`, `test`, `assert-equal` |

## 13.12 Extending the Project

Ideas for enhancement:
1. **Add FFI** for faster file I/O (`mmap`, `pread`)
2. **Add contracts** for preconditions on stats functions
3. **Add macros** for generating parser variants
4. **Add configuration** via `def` constants
5. **Add benchmarking** with `test-property`

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