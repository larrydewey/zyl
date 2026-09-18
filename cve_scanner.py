#!/usr/bin/env python3
"""
CVE Pattern Detection Scanner for Zyl Codebase
Scans .zyl and .c files for security vulnerability patterns.
"""

import re
import os
import json
import sys
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional
from collections import defaultdict

@dataclass
class Finding:
    cve_id: str
    category: str
    severity: str
    pattern_name: str
    file_path: str
    line_number: int
    line_content: str
    description: str
    fix_hint: str

class CVEScanner:
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.findings: List[Finding] = []
        
        self.patterns = {
            # Memory Safety - match ONLY vulnerable patterns (without overflow checks)
            "arena_overflow_add": {
                "regex": rb"b->used\s*\+\s*need\s*>\s*b->cap|b->used\s*\+\s*size\s*>\s*b->cap",
                "cve": "CVE-2026-ZYL-005",
                "category": "Memory Safety",
                "severity": "HIGH",
                "desc": "Arena allocation integer overflow in bounds check",
                "fix": "Check `need > cap - used` instead of `used + need > cap`"
            },
            "arena_mul_overflow": {
                "regex": rb"qwords\s*\*\s*8\s*\+\s*8",
                "cve": "CVE-2026-ZYL-004",
                "category": "Memory Safety",
                "severity": "HIGH",
                "desc": "Heap allocation size multiplication overflow",
                "fix": "Use checked arithmetic: `__builtin_mul_overflow` or check before multiply"
            },
            "str_concat_overflow": {
                "regex": rb"la\s*\+\s*lb\s*\+\s*1|strlen\([^)]*\)\s*\+\s*strlen",
                "cve": "CVE-2026-ZYL-008",
                "category": "Memory Safety",
                "severity": "HIGH",
                "desc": "String concatenation length overflow",
                "fix": "Check `la > SIZE_MAX - lb - 1` before allocation"
            },
            
            # FFI & Capability - match ONLY vulnerable patterns
            "ffi_unconstrained_return": {
                "regex": rb"infer-expr-ffi-call[^)]*TCap\s+TCBox\s+\(inferer-return-var",
                "cve": "CVE-2026-ZYL-001",
                "category": "FFI/Capability",
                "severity": "CRITICAL",
                "desc": "FFI call returns unconstrained TCap TCBox type variable",
                "fix": "Require explicit return type annotation on ffi-call"
            },
            "ffi_pinnable_missing": {
                "regex": rb"infer-expr-ffi-pin[^)]*TCap\s+TCPin\s+[^)]*t\)",
                "cve": "CVE-2026-ZYL-002",
                "category": "FFI/Capability",
                "severity": "CRITICAL",
                "desc": "ffi-pin accepts any type without FFI_Pinnable check",
                "fix": "Add deep is-ffi-pinnable validation in infer-expr-ffi-pin"
            },
            "ffi_shallow_check": {
                "regex": rb"is-ffi-pinnable\s+\(t\)\s*\(match\s+t\s*\(TCap\s+kind\s+inner\s*\(is-ffi-pinnable\s+inner\)\)",
                "cve": "CVE-2026-ZYL-003",
                "category": "FFI/Capability",
                "severity": "HIGH",
                "desc": "is-ffi-pinnable doesn't reject TMut/TAtomic (vulnerable version)",
                "fix": "is-ffi-pinnable must reject TMut/TAtomic in TCap",
                "dotall": True
            },
            "send_shallow_check": {
                "regex": rb"is-sendable.*msg-type|captures-tmut",
                "cve": "CVE-2026-ZYL-010",
                "category": "Actor/Concurrency",
                "severity": "HIGH",
                "desc": "Actor send/spawn capability check only top-level",
                "fix": "Deep capability walk on sent values and captured env"
            },
            
            # Atomic
            "atomic_aba": {
                "regex": rb"zyl_atomic_cas.*expected_copy",
                "cve": "CVE-2026-ZYL-013",
                "category": "Atomic",
                "severity": "HIGH",
                "desc": "Atomic CAS vulnerable to ABA problem",
                "fix": "Versioned CAS (pack version in high bits) or document limitation"
            },
            "atomic_unaligned": {
                "regex": rb"__ATOMIC_SEQ_CST.*long long\*",
                "cve": "CVE-2026-ZYL-014",
                "category": "Atomic",
                "severity": "MEDIUM",
                "desc": "Atomic operations on potentially unaligned addresses",
                "fix": "Require alignment check before atomic ops"
            },

# Concurrency
            "mailbox_unbounded": {
                "regex": rb"zyl_actor_send.*malloc.*ZylMessage",
                "cve": "CVE-2026-ZYL-012",
                "category": "Actor/Concurrency",
                "severity": "MEDIUM",
                "desc": "Actor mailbox has no backpressure limit",
                "fix": "Add configurable mailbox capacity with blocking send"
            },
            
            # Type System - match ONLY vulnerable patterns
            # CVE-2026-ZYL-016 ("occurs check may infinite recurse on cyclic
            # types") was investigated and closed as not-applicable: this
            # codebase's `Type` is a plain immutable tree (subst-apply/unify
            # never introduce back-references), so a genuine cycle in the
            # DATA cannot occur and no visited-set is needed. See the
            # rationale comment directly above type-contains-var in
            # stdlib/compiler/type_system.zyl. No pattern here by design --
            # do not re-add a check for the "missing visited set" shape.
            # CVE-2026-ZYL-017 ("monomorphization cache key lacks function
            # name") was investigated and closed as not-applicable: the
            # real key (make-site-key, type_inference.zyl) is a String
            # built as "<fname>::<type1>,<type2>,...", which already
            # disambiguates by function name. The audit had assumed the
            # BodyCache's declared field type reflected the real key
            # shape; it didn't (see stdlib/compiler/type_system.zyl's
            # BodyCache comment). No pattern here by design.
            "trait_coherence": {
                "regex": rb"tc-register-impl.*Cons.*impl",
                "cve": "CVE-2026-ZYL-018",
                "category": "Type System",
                "severity": "HIGH",
                "desc": "Trait impl coherence not enforced - duplicate impls silently overwrite",
                "fix": "Check existing impls for same (Trait, Type) pair before registering"
            },
            
            # Parser/Lexer - match ONLY vulnerable patterns
            "lexer_mutual_recursion": {
                "regex": rb"lex-c1.*lex-loop|lex-loop.*lex-c1",
                "cve": "CVE-2026-ZYL-019",
                "category": "Parser/Lexer",
                "severity": "HIGH",
                "desc": "Lexer mutual recursion leaks stack frame per whitespace char",
                "fix": "Rewrite whitespace skipping as single tail-recursive loop"
            },
            "parser_unbounded_depth": {
                "regex": rb"read-forms.*read-form|read-form.*read-forms",
                "cve": "CVE-2026-ZYL-020",
                "category": "Parser/Lexer",
                "severity": "HIGH",
                "desc": "Parser unbounded recursion on nested parentheses",
                "fix": "Add depth limit (default 1000) to read-forms"
            },
            "int_literal_overflow": {
                "regex": rb"zyl_cstr_to_int\s*\([^)]*ptr\s*\)\s*\{[^}]*v\s*=\s*v\s*\*\s*10\s*\+\s*\(\*s\s*-\s*'0'\)",
                "cve": "CVE-2026-ZYL-021",
                "category": "Parser/Lexer",
                "severity": "MEDIUM",
                "desc": "Integer literal parsing may overflow silently (vulnerable: no overflow check)",
                "fix": "Use strtoll with errno check, report E_INTEGER_OVERFLOW"
            },
            
            # Codegen - match ONLY vulnerable patterns
            "stack_misalignment": {
                "regex": rb"let\s+fsz\s*\(\*\s*16\s*\(\+\s*1\s*\(\/\s*nslots\s*2\)\)\)",
                "cve": "CVE-2026-ZYL-022",
                "category": "Codegen",
                "severity": "HIGH",
                "desc": "Function prologue stack misalignment for SSE calls (vulnerable: fsz = 16*(1+nslots/2))",
                "fix": "fsz must be 16n+8 to compensate for push rbp"
            },
            "variant_tag_overflow": {
                "regex": rb"stag.*100000|ic-collect-vt-run.*100000",
                "cve": "CVE-2026-ZYL-023",
                "category": "Codegen",
                "severity": "LOW",
                "desc": "Struct variant tags may exceed imm32 range",
                "fix": "Use unsigned comparison or limit struct count"
            },
            
            # Region Inference
            "region_system_deleted": {
                "regex": rb"region inference had never affected|region inference.*deleted",
                "cve": "CVE-2026-ZYL-025",
                "category": "Region Inference",
                "severity": "CRITICAL",
                "desc": "Full region inference system deleted - only narrow IVariant->IStackVariant remains",
                "fix": "Re-implement full region inference per spec §9 (Stack/Heap/Global/Circular/Pin)"
            },
            "escape_analysis_incomplete": {
                "regex": rb"ri-name-safe-in.*IMatch|ri-name-safe-in.*IPrint|ri-name-safe-in.*ICall",
                "cve": "CVE-2026-ZYL-026",
                "category": "Region Inference",
                "severity": "HIGH",
                "desc": "Escape analysis only checks match/print/call - misses struct-get, closure capture, global store",
                "fix": "Comprehensive escape analysis tracking all value flows"
            },
            
            # Bootstrap
            "bootstrap_seed_trust": {
                "regex": rb"stage2\.s.*committed|stage2\.s.*seed",
                "cve": "CVE-2026-ZYL-027",
                "category": "Bootstrap",
                "severity": "HIGH",
                "desc": "Bootstrap trusts committed stage2.s without provenance verification",
                "fix": "Reproducible build from source; verify seed hash"
            },
            "assemble_order_nondet": {
                "regex": rb"os\.walk|os\.listdir.*stdlib",
                "cve": "CVE-2026-ZYL-028",
                "category": "Bootstrap",
                "severity": "HIGH",
                "desc": "assemble.py uses non-deterministic filesystem order",
                "fix": "Sort file list deterministically; verify against manifest"
            },
            "rust_bootstrap_unverified": {
                "regex": rb"rust-bootstrap.*target/release|target/release.*zyl",
                "cve": "CVE-2026-ZYL-029",
                "category": "Bootstrap",
                "severity": "MEDIUM",
                "desc": "Rust bootstrap binary not built from source in CI",
                "fix": "Build Rust bootstrap from source; pin Cargo.lock"
            },
            "fixed_point_no_crosscheck": {
                "regex": rb"stage2.*stage3.*identical|fixed point.*holds",
                "cve": "CVE-2026-ZYL-030",
                "category": "Bootstrap",
                "severity": "MEDIUM",
                "desc": "Fixed point verified but no cross-check with Rust bootstrap output",
                "fix": "Compare self-hosted vs Rust bootstrap output for same input"
            },
            
            # String/Buffer
            "str_append_cache_poison": {
                "regex": rb"size_t\s+idx\s*=\s*\(\(size_t\)dst\s*>>\s*4\)\s*%\s*ZSA_CACHE_SLOTS",
                "cve": "CVE-2026-ZYL-007",
                "category": "String/Buffer",
                "severity": "HIGH",
                "desc": "String append cache indexed by low address bits - collision across buffers",
                "fix": "Use full pointer hash (SipHash) for cache index"
            },
            # Note: heap alloc overflow is covered by "arena_mul_overflow" above
            # (same regex/CVE) -- removed duplicate that double-counted findings.
        }
        
        # File-type specific patterns
        self.zyl_patterns = {
            "unconstrained_typevar": rb"inferer-return-var|ti-next.*fresh",
            "match_non_exhaustive": rb"match.*d1.*d2",
            "wildcard_pattern": rb"_\s*\)",
            "bare_underscore": rb"^\s*_\s*$",
            "binop_two_calls": rb"IBinop.*ICall.*ICall|ICall.*IBinop.*ICall",
            "deep_nesting": rb"match.*match.*match",
        }
        
        self.c_patterns = {
            "use_after_free": rb"free\(.*\).*\1",
            "double_free": rb"free\(.*\).*free\(.*\1",
            "buffer_overflow": rb"memcpy.*dst.*src.*len.*cap",
            "format_string": rb"printf\(.*%.*\)",
            "integer_overflow": rb"size_t.*\*.*8|\+.*size_t",
        }

    def is_comment_line(self, line: bytes) -> bool:
        """Check if a line is a comment line."""
        stripped = line.strip()
        return stripped.startswith(b'//') or stripped.startswith(b'/*') or stripped.startswith(b'*') or stripped.startswith(b'#')

    def is_fixed_code(self, pattern_name: str, lines: List[bytes], line_idx: int) -> bool:
        """Check if the matched line is actually fixed code (has fix nearby).

        Uses a generous window (rather than a tight one) because the fix for
        a given vulnerable expression is frequently a guard clause several
        lines earlier or later in the same function -- e.g. an overflow
        check emitted right before the arithmetic it protects. A narrow
        window produced false positives on already-fixed code.
        """
        start = max(0, line_idx - 10)
        end = min(len(lines), line_idx + 11)
        check_lines = lines[start:end]
        combined = b' '.join(l.strip() for l in check_lines)
        
        # Fix patterns for each vulnerability (keyed by pattern_name above)
        fix_patterns = {
            "arena_mul_overflow": [
                rb'if\s*\(\s*qwords\s*>\s*\(',       # check before multiplication
                rb'SIZE_MAX\s*-\s*8',               # SIZE_MAX check
            ],
            "str_concat_overflow": [
                rb'la\s*>\s*SIZE_MAX\s*-\s*lb',     # SIZE_MAX check for concat
                rb'SIZE_MAX\s*-\s*lb\s*-\s*1',      # alternative check
            ],
            "stack_misalignment": [
                rb'let\s+fsz\s*\(\+\s*8\s*\(\*\s*16',  # fixed fsz = + 8 + 16*(...)
            ],
            "int_literal_overflow": [
                rb'if.*v\s*[<>].*LLONG_MAX',        # overflow check in zyl_cstr_to_int
                rb'if.*v\s*[<>].*LLONG_MIN',        # negative overflow check
                rb'errno\s*=\s*ERANGE',              # errno setting
            ],
            "str_append_cache_poison": [
                rb'zsa_cache_index',                 # SipHash index function
            ],
        }
        
        if pattern_name in fix_patterns:
            for fix_pattern in fix_patterns[pattern_name]:
                if re.search(fix_pattern, combined):
                    return True
        
        return False

    def scan_file(self, file_path: Path) -> List[Finding]:
        findings = []
        try:
            content = file_path.read_bytes()
            lines = content.split(b'\n')
            
            # Choose pattern set
            is_zyl = file_path.suffix == '.zyl'
            is_c = file_path.suffix in ('.c', '.h')
            
            patterns_to_check = self.patterns.copy()
            if is_zyl:
                patterns_to_check.update({k: v for k, v in self.zyl_patterns.items() 
                    if isinstance(v, dict)})
            if is_c:
                patterns_to_check.update({k: v for k, v in self.c_patterns.items() 
                    if isinstance(v, dict)})
            
            for pattern_name, pattern_info in patterns_to_check.items():
                if isinstance(pattern_info, dict) and 'regex' in pattern_info:
                    regex = pattern_info['regex']
                    # Support DOTALL flag for multi-line patterns
                    flags = 0
                    if pattern_info.get('dotall', False):
                        flags |= re.DOTALL
                    matches = list(re.finditer(regex, content, flags))
                    for match in matches:
                        # Find line number
                        match_pos = match.start()
                        line_num = content[:match_pos].count(b'\n') + 1
                        line_content = lines[line_num - 1].decode('utf-8', errors='replace').strip()
                        
                        # Skip comment lines
                        if self.is_comment_line(lines[line_num - 1]):
                            continue
                        
                        # Post-filter: check if this is fixed code (has fix on subsequent lines)
                        if self.is_fixed_code(pattern_name, lines, line_num - 1):
                            continue
                        
                        findings.append(Finding(
                            cve_id=pattern_info['cve'],
                            category=pattern_info['category'],
                            severity=pattern_info['severity'],
                            pattern_name=pattern_name,
                            file_path=str(file_path.relative_to(self.root_dir)),
                            line_number=line_num,
                            line_content=line_content,
                            description=pattern_info['desc'],
                            fix_hint=pattern_info['fix']
                        ))
                        
        except Exception as e:
            print(f"Error scanning {file_path}: {e}", file=sys.stderr)
            
        return findings

    def scan_directory(self, exclude_dirs: List[str] = None, exclude_files: List[str] = None) -> List[Finding]:
        if exclude_dirs is None:
            exclude_dirs = ['target', 'build', 'archive', '.git', '__pycache__']
        if exclude_files is None:
            exclude_files = ['zyl_selfhost_compiler.zyl']  # Assembled file - single line, false positives
            
        all_findings = []
        for ext in ('.zyl', '.c', '.h'):
            for file_path in self.root_dir.rglob(f'*{ext}'):
                if any(excl in file_path.parts for excl in exclude_dirs):
                    continue
                if file_path.name in exclude_files:
                    continue
                findings = self.scan_file(file_path)
                all_findings.extend(findings)
                
        self.findings = all_findings
        return all_findings

    def report(self, format: str = 'text') -> str:
        if format == 'json':
            return json.dumps([asdict(f) for f in self.findings], indent=2)
        
        # Group by severity
        by_severity = defaultdict(list)
        for f in self.findings:
            by_severity[f.severity].append(f)
            
        severity_order = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
        
        lines = []
        lines.append(f"# CVE Scan Report")
        lines.append(f"Scanned: {self.root_dir}")
        lines.append(f"Total findings: {len(self.findings)}")
        lines.append("")
        
        for sev in severity_order:
            if sev not in by_severity:
                continue
            findings = by_severity[sev]
            lines.append(f"## {sev} ({len(findings)})")
            lines.append("")
            
            # Group by CVE
            by_cve = defaultdict(list)
            for f in findings:
                by_cve[f.cve_id].append(f)
                
            for cve_id, cve_findings in sorted(by_cve.items()):
                lines.append(f"### {cve_id} ({len(cve_findings)} occurrences)")
                lines.append(f"*Category*: {cve_findings[0].category}")
                lines.append(f"*Description*: {cve_findings[0].description}")
                lines.append(f"*Fix*: {cve_findings[0].fix_hint}")
                lines.append("")
                
                for f in cve_findings[:10]:  # Limit display
                    lines.append(f"  - `{f.file_path}:{f.line_number}`")
                    lines.append(f"    ```")
                    lines.append(f"    {f.line_content}")
                    lines.append(f"    ```")
                if len(cve_findings) > 10:
                    lines.append(f"  ... and {len(cve_findings) - 10} more")
                lines.append("")
                
        return "\n".join(lines)

def main():
    import argparse
    parser = argparse.ArgumentParser(description="CVE Pattern Scanner for Zyl")
    parser.add_argument('path', nargs='?', default='.', help='Root directory to scan')
    parser.add_argument('--format', choices=['text', 'json'], default='text')
    parser.add_argument('--output', '-o', help='Output file')
    parser.add_argument('--severity', choices=['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'], 
                        help='Filter by minimum severity')
    args = parser.parse_args()
    
    scanner = CVEScanner(args.path)
    findings = scanner.scan_directory()
    
    if args.severity:
        severity_order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3}
        min_level = severity_order[args.severity]
        findings = [f for f in findings if severity_order[f.severity] <= min_level]
        scanner.findings = findings
    
    report = scanner.report(args.format)
    
    if args.output:
        Path(args.output).write_text(report)
        print(f"Report written to {args.output}")
    else:
        print(report)
    
    # Exit code based on findings
    if findings:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()