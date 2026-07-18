You are refactoring the documentation architecture of the Zyl compiler project to make it more effective for AI-assisted development.

## Objective

Reorganize the project's documentation so that an AI coding agent can efficiently load:
- permanent project rules
- current project state
- formal language semantics
- architectural decisions
- implementation history

The goal is improved context efficiency without losing information.

## Critical Constraints

- Do not modify compiler source code.
- Do not modify language semantics.
- Do not change the behavior or meaning of the Zyl specification.
- Do not remove technical details.
- Do not replace formal definitions with summaries.
- Preserve all existing knowledge.
- Treat `zyl_specification.txt` as the canonical authority for language semantics.
- Treat source code as the authority for implemented behavior.
- If information conflicts, do not resolve it silently; document the conflict.

## Step 1: Analyze Before Editing

Before making changes:
1. Inspect the repository structure.
2. Read:
   - `AGENTS.md`
   - `PROGRESS.md`
   - `zyl_specification.txt`
   - existing documentation files
3. Identify:
   - information that must always be loaded by an agent
   - information that should only be loaded when relevant
   - historical information
   - architectural decisions
   - duplicated or stale information

Do not edit files until this analysis is complete.

## Step 2: Refactor AGENTS.md

Convert `AGENTS.md` into a concise always-loaded instruction file.

It should contain only:

- Project identity and short vision
- Authoritative source order
- Session workflow rules
- Development rules
- Compiler invariants
- Non-negotiable architectural constraints

Keep information such as:

- deterministic compilation requirements
- strict compilation phase ordering
- evaluation order rules
- region/capability rules
- FFI safety rules
- immutability rules
- contract behavior

Remove large reference sections.

Move detailed information into appropriate documentation files.

`AGENTS.md` should act as the project's constitution, not its encyclopedia.

## Step 3: Refactor PROGRESS.md

Convert `PROGRESS.md` into a current-state tracker.

Keep:

- current implementation state
- completed phases
- active work
- known issues
- next priorities

Move out:

- detailed implementation history
- large file summaries
- line counts
- exhaustive regression test descriptions
- historical debugging notes

Do not lose this information; move it into dedicated documentation.

## Step 4: Create Documentation Structure

Create:

docs/
├── architecture-decisions.md
├── implementation-status.md
├── compiler-pipeline.md
├── regression-tests.md
├── codebase-map.md
└── design-rationale.md

Use these files as follows:

### architecture-decisions.md
Document decisions that should not be accidentally changed:
- no-dispatch parsing
- macro expansion ordering
- determinism requirements
- phase separation
- IR design decisions
- ownership and memory model decisions

### implementation-status.md
Move detailed phase-by-phase implementation history here:
- completed features
- implementation notes
- files involved
- important fixes

### compiler-pipeline.md
Document:
- all compiler phases
- inputs and outputs
- invariants between phases
- dependencies between phases

### regression-tests.md
Move:
- struct regression tests
- feature test suites
- commands required before modifying sensitive areas

### codebase-map.md
Document:
- major source files
- module responsibilities
- relationships between components

### design-rationale.md
Document:
- why architectural choices were made
- tradeoffs considered
- rejected alternatives
- constraints future developers should understand

## Step 5: Refactor the Formal Specification

Keep:

`zyl_specification.txt`

as the canonical specification.

Do not replace it.

Create a structured reference copy organized by semantic domain:

spec/
├── 00-language-overview.md
├── 01-lexing-and-tokens.md
├── 02-syntax-and-forms.md
├── 03-macros-and-hygiene.md
├── 04-evaluation-semantics.md
├── 05-types-and-inference.md
├── 06-capability-types.md
├── 07-region-memory-model.md
├── 08-actors-and-concurrency.md
├── 09-ffi-contracts.md
├── 10-structs-and-data-types.md
├── 11-icnf-ir.md
├── 12-optimization-rules.md
├── 13-code-generation.md
├── 14-determinism-and-hashing.md
└── 15-error-model.md

Each specification section must:

- preserve formal definitions
- preserve examples
- reference original section numbers from `zyl_specification.txt`
- identify related compiler source files
- identify related specification sections

The split specification is a navigation and retrieval aid, not a replacement authority.

## Step 6: Add Cross-References

Documentation should create a clear relationship:

Concept
→ Specification section
→ Design rationale
→ Implementation files
→ Tests

For example:

Language feature:
  Capability types

References:
  spec/06-capability-types.md
  docs/design-rationale.md
  src/type_system.rs
  src/type_inference.rs

## Step 7: Validation

After restructuring:

Verify:

- No technical information was lost.
- No formal rules were removed.
- `AGENTS.md` is concise.
- `PROGRESS.md` focuses on current state.
- Historical details still exist in documentation.
- Specification sections are traceable to the canonical specification.
- Documentation references are accurate.
- No compiler source files were changed.

The final result should allow an AI coding agent to work using:

1. `AGENTS.md` for permanent rules
2. `PROGRESS.md` for current status
3. Relevant `spec/` sections for language semantics
4. Relevant `docs/` files for architecture and history
5. Relevant source files for implementation

