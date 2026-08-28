#!/usr/bin/env python3
"""Assemble the self-hosted compiler into one Zyl source file (boot build)."""
import re

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
    'stdlib/compiler/icnf.zyl',
    'stdlib/compiler/codegen.zyl',
    'stdlib/compiler/region_inference.zyl',
    'selfhost/driver.zyl',
]

out = []
out.append('; ===== AUTO-ASSEMBLED SELF-HOSTED COMPILER (boot source) =====\n')
seen_defs = {}
for f in files:
    out.append(f'\n; ---------- {f} ----------\n')
    txt = open(f).read()
    # strip use lines
    txt = re.sub(r'^\(use [^)]*\)\s*$', '', txt, flags=re.M)
    out.append(txt)
src = ''.join(out)
open('selfhost/zyl_selfhost_compiler.zyl', 'w').write(src)
print('wrote', len(src), 'bytes')
