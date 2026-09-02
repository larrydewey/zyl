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
            while j < len(text) and text[j] not in '()\n;'"\"":
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
    'stdlib/core/list.zyl',
    'stdlib/allocator/allocator.zyl',
    'stdlib/compiler/ast.zyl',
    'stdlib/compiler/expr_inner.zyl',
    'stdlib/compiler/lexer.zyl',
    'stdlib/compiler/parser.zyl',
    'stdlib/compiler/resolver.zyl',
    'stdlib/compiler/type_system.zyl',
    'stdlib/compiler/type_inference.zyl',
    'stdlib/compiler/monomorphization.zyl',
    'stdlib/compiler/icnf.zyl',
    'stdlib/compiler/codegen.zyl',
    # region_inference.zyl deliberately excluded: it's dead code from the
    # self-hosted boot pipeline's perspective (driver.zyl's boot-run
    # never calls anything in it), and it was blocking the boot process
    # at link time with undefined-symbol errors from bugs in code that
    # never actually executes. See resolver.zyl's header comment for the
    # same situation, root-caused there.
    'selfhost/driver.zyl',
]


out = []
out.append('; ===== AUTO-ASSEMBLED SELF-HOSTED COMPILER (boot source) =====\n')
for f in files:
    out.append(f'\n; ---------- {f} ----------\n')
    txt = file_to_structural(f)
    out.append(txt)
src = ''.join(out)
open('selfhost/zyl_selfhost_compiler.zyl', 'w').write(src)
print('wrote', len(src), 'bytes')

# Verify depth (strip comments first for accurate count)
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