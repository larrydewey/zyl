#!/usr/bin/env python3
"""Assemble the self-hosted compiler into one Zyl source file (boot build).

Outputs source in STRUCTURAL FORM: every ( and ) on its own line,
indented by nesting depth. This prevents the parenthesis-imbalance bug
that occurs when compact-form modules are concatenated — the structured
format makes the expression tree explicit and verifiable.

KEY PRINCIPLE (from Zyl skill §2 structural form):
1. Opening ( stands alone on its own line — never inline
2. Closing ) stands alone on its own line — never inline, aligned with opening
3. Operator/keyword goes on the line AFTER the opening (
4. Arguments go on subsequent lines, indented one level deeper
5. Nested expressions get their own scope block ( ) + content + )
6. NEVER output compact form

The depth-increment problem from concatenation is solved by ensuring
each file's parentheses are explicitly structural before joining.
"""
import re


def strip_zyl_comments(text):
    """Remove Zyl comments (;...) preserving paren structure outside comments."""
    lines = text.split('\n')
    out = []
    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith(';'):
            # Entire line is comment — skip (don't add to output paren count)
            out.append('')  # preserve line number
            continue
        # Find ; that starts a comment (even quotes before it)
        pos = None
        for i, ch in enumerate(stripped):
            if ch == ';':
                before = stripped[:i]
                if before.count('"') % 2 == 0:
                    pos = i
                    break
        if pos is not None:
            code = stripped[:pos].rstrip()
            out.append(code)
        else:
            out.append(stripped)
    return '\n'.join(out)


def compact_to_structural(text):
    """Convert Zyl S-expression from compact to structural form.

    Every ( and ) is placed on its own line, indented by nesting depth.
    This is the working representation that makes the expression tree
    verifiable. Based on Zyl skill §2 rules.

    Approach: tokenize the S-expression and re-output with parens on own lines.
    """
    # Remove comments
    text = strip_zyl_comments(text)

    # Tokenize: extract parens and atoms
    tokens = []
    i = 0
    while i < len(text):
        c = text[i]
        if c in '()':
            tokens.append(c)
            i += 1
        elif c == ';':
            # skip to end of line
            while i < len(text) and text[i] != '\n':
                i += 1
        elif c in '"':
            # string literal
            j = i + 1
            while j < len(text) and text[j] != c:
                if text[j] == '\\' and j + 1 < len(text):
                    j += 2
                else:
                    j += 1
            tokens.append(text[i:j+1])
            i = j + 1
        elif c.isspace():
            i += 1
        else:
            # atom
            j = i
            while j < len(text) and text[j] not in '()\n;"':
                j += 1
            atom = text[i:j].strip()
            if atom:
                tokens.append(atom)
            i = j

    # Now reconstruct in structural form using a stack
    # We process tokens and emit structural form
    output_lines = []
    depth = 0
    i = 0

    while i < len(tokens):
        tok = tokens[i]
        i += 1

        if tok == '(':
            # Emit opening paren at current depth, then increase depth
            output_lines.append(' ' * (depth * 2) + '(')
            depth += 1
        elif tok == ')':
            # Decrease depth first, then emit at new depth
            depth = max(0, depth - 1)
            output_lines.append(' ' * (depth * 2) + ')')
        else:
            # Atom — output at current depth
            # If depth is 0, output at indent 0; otherwise indent
            indent = ' ' * max(0, depth * 2)
            output_lines.append(indent + tok)

    # Flush remaining depth
    while depth > 0:
        depth -= 1
        output_lines.append(' ' * (depth * 2) + ')')

    return '\n'.join(output_lines)


def strip_named_defn(text, name):
    """Remove every top-level `(defn <name> ...)` block from text entirely.

    Used for library modules (e.g. sexp_balance.zyl) that define their own
    standalone-CLI `main` for when they're compiled alone -- bundling them
    ahead of selfhost/driver.zyl (the bundle's real entry point, always
    last in `files`) let deduplicate_defns's first-occurrence-wins rule
    silently keep the LIBRARY's `main` and drop driver.zyl's real one, so
    a from-source rebuild produced a binary whose entire CLI was
    sexp_balance's `usage: sexp_balance <file.zyl>` demo instead of the
    compiler. Stripping the name from every non-driver file up front means
    only driver.zyl's `main` ever reaches deduplicate_defns.
    """
    lines = text.split('\n')
    out = []
    i = 0
    depth = 0
    while i < len(lines):
        line = lines[i]
        for ch in line:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
        stripped = line.strip()
        if stripped == f'defn {name}' or stripped.startswith(f'defn {name} '):
            if out and out[-1].strip() == '(':
                out.pop()
            target_depth = depth - 1
            i += 1
            while i < len(lines):
                l = lines[i]
                for ch in l:
                    if ch == '(':
                        depth += 1
                    elif ch == ')':
                        depth -= 1
                if depth == target_depth:
                    i += 1
                    break
                i += 1
            continue
        out.append(line)
        i += 1
    return '\n'.join(out)


def deduplicate_defns(text, seen_defns):
    """Remove duplicate defn definitions, keeping the first occurrence."""
    lines = text.split('\n')
    out = []
    i = 0
    global_depth = 0
    while i < len(lines):
        line = lines[i]
        for ch in line:
            if ch == '(':
                global_depth += 1
            elif ch == ')':
                global_depth -= 1
        stripped = line.strip()
        if stripped.startswith('defn '):
            parts = stripped.split()
            if len(parts) >= 2:
                fn_name = parts[1]
                if fn_name in seen_defns:
                    # Skip this defn and its outer wrapper.
                    # The outer '(' is the previous output line (at depth-1).
                    # Remove it from output if it's a lone '('.
                    if out and out[-1].strip() == '(':
                        out.pop()
                    target_depth = global_depth - 1
                    i += 1
                    while i < len(lines):
                        l = lines[i]
                        for ch in l:
                            if ch == '(':
                                global_depth += 1
                            elif ch == ')':
                                global_depth -= 1
                        if global_depth == target_depth:
                            i += 1
                            break
                        i += 1
                    continue
                seen_defns.add(fn_name)
        out.append(line)
        i += 1
    return '\n'.join(out)


def file_to_structural(filepath):
    """Read a Zyl file, strip use lines, convert to structural form."""
    txt = open(filepath).read()
    # Strip use lines
    txt = re.sub(r'^\(use [^)]*\)\s*$', '', txt, flags=re.M)
    # Convert to structural form
    txt = compact_to_structural(txt)
    return txt


files = [
    'stdlib/core/option.zyl',
    # `Result`/`Ok`/`Err` (type_inference.zyl's catch-error/infer-expr-body
    # match on these) used to be entirely absent from this bundle — with no
    # deftype declaring them, vt-tag-of returned -1 for BOTH `Ok` and `Err`,
    # so cg-arm-match's wildcard handling (tag == -1) treated both match
    # arms as unconditional wildcards and only the FIRST ("Ok") ever fired,
    # regardless of the actual value. Every catch-error call site blindly
    # read field+8 off of whatever catch-error returned as if it were
    # always `Ok`, segfaulting the instant an `Err` (or anything else) came
    # back.
    'stdlib/core/result.zyl',
    'stdlib/core/list.zyl',
    'stdlib/collections/collections.zyl',
    'stdlib/allocator/allocator.zyl',
    'stdlib/compiler/ast.zyl',
    'stdlib/compiler/expr_inner.zyl',
    'stdlib/compiler/lexer.zyl',
    'stdlib/compiler/parser.zyl',
    'stdlib/compiler/module_resolver.zyl',
    'stdlib/compiler/macro_expand.zyl',
    'stdlib/compiler/resolver.zyl',
    'stdlib/compiler/type_system.zyl',
    'stdlib/compiler/type_inference.zyl',
    'stdlib/compiler/monomorphization.zyl',
    'stdlib/compiler/icnf.zyl',
    'stdlib/compiler/trait_dispatch.zyl',
    'stdlib/compiler/closure_inline.zyl',
    'stdlib/compiler/assert_lowering.zyl',
    'stdlib/compiler/codegen.zyl',
    'stdlib/compiler/region_inference.zyl',
    'stdlib/compiler/optimization.zyl',
    # Error system (native Zyl): balance validation, error codes, reporting
    'stdlib/compiler/sexp_balance.zyl',
    'stdlib/compiler/error_codes.zyl',
    'stdlib/compiler/error_report.zyl',
    # region_inference/optimization were previously excluded as "dead code"
    # with link errors; tools/repl.zyl (the self-hosted REPL) calls them,
    # so they now ship in the boot source.
    'selfhost/driver.zyl',
]


def collapse_whitespace(text):
    """Collapse every run of whitespace (spaces/tabs/newlines) down to a
    single space, preserving string-literal contents untouched.

    assemble.py deliberately emits one paren/token per line (structural
    form) so the depth-verification pass below can catch imbalances
    reliably -- but shipping that structural form AS THE ACTUAL BOOT
    SOURCE turned out to make stage1.bin (the self-hosted binary built
    from this file) crash while parsing its own ~690KB source, once the
    file grew past a certain size. Root cause: stdlib/compiler/lexer.zyl's
    whitespace-skipping path is mutually recursive between lex-loop and
    lex-c1 (one call each per character) rather than a single self-
    recursive loop -- the Rust bootstrap's tail-call optimization only
    reliably eliminates a restricted set of tail-position call shapes,
    and this mutual hop leaks a real (non-eliminated) stack frame per
    whitespace character skipped. Structural form's one-token-per-line
    style has vastly more whitespace (indentation + newlines) than
    compact form for the exact same token stream, so it needs far more
    of these leaking hops -- for a large enough file this genuinely
    exhausts even the 64GB worker-thread stack set up in
    zyl_call_on_big_stack (confirmed via gdb: rbp had descended to
    within ~64KB of the very bottom of that mapped 64GB region).
    Collapsing every whitespace run down to one space after verification
    keeps the exact same token stream (so nothing about program meaning
    changes) while cutting the character-count driving this recursion by
    roughly 2.5x -- comfortably below where it was observed to crash.
    The real, root-level fix (making lexer.zyl's whitespace-skip path
    genuinely O(1) stack via true self-tail-recursion, or teaching the
    Rust bootstrap's TCO to eliminate this mutual-hop shape) is tracked
    as follow-up work; this is the safe, low-risk mitigation for now.
    """
    out = []
    i = 0
    n = len(text)
    in_str = False
    last_was_space = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == '\\' and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            last_was_space = False
            continue
        if c in ' \t\n\r':
            if not last_was_space:
                out.append(' ')
            last_was_space = True
            i += 1
            continue
        out.append(c)
        last_was_space = False
        i += 1
    return ''.join(out)


out = []
out.append('; ===== AUTO-ASSEMBLED SELF-HOSTED COMPILER (boot source) =====\n')
seen_defns = set()
for f in files:
    out.append(f'\n; ---------- {f} ----------\n')
    txt = file_to_structural(f)
    if f != files[-1]:
        txt = strip_named_defn(txt, 'main')
    txt = deduplicate_defns(txt, seen_defns)
    out.append(txt)
src = ''.join(out)

# Verify depth on the structural form first (strip comments for an
# accurate count) -- this is the reliable, easy-to-eyeball check the
# structural form exists for in the first place.
def strip_comments(t):
    lines = t.split('\n')
    out = []
    for l in lines:
        idx = l.find(';')
        if idx >= 0:
            before = l[:idx]
            if before.count('"') % 2 == 0:
                out.append(l[:idx])
            else:
                out.append(l)
        else:
            out.append(l)
    return '\n'.join(out)

txt = strip_comments(src)
d = 0
for c in txt:
    if c == '(': d += 1
    elif c == ')': d -= 1
print('Final depth (comments stripped):', d, '(should be 0)')

# Collapse whitespace for the actual written boot source -- see
# collapse_whitespace's docstring above for why. Re-verify depth on the
# collapsed output too (comments are gone by construction: collapsing
# would otherwise merge a ";..." comment with following code onto one
# line, so strip comments before collapsing, not after).
src_nocomments = strip_comments(src)
collapsed = collapse_whitespace(src_nocomments)
d2 = 0
in_str = False
i = 0
while i < len(collapsed):
    c = collapsed[i]
    if in_str:
        if c == '\\':
            i += 2
            continue
        if c == '"':
            in_str = False
        i += 1
        continue
    if c == '"':
        in_str = True
    elif c == '(':
        d2 += 1
    elif c == ')':
        d2 -= 1
    i += 1
print('Collapsed depth:', d2, '(should be 0)')

open('selfhost/zyl_selfhost_compiler.zyl', 'w').write(collapsed)
print('wrote', len(collapsed), 'bytes (collapsed from', len(src), ')')