#!/usr/bin/env python3
"""The language server's memory stays flat across a long session.

Sends edits, hovers and open/close pairs to build/boot/zyl-lsp and reads its
resident set from /proc. A server that keeps something per message grows
linearly; this fails when the growth after warm-up passes a small bound.
"""

import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SERVER = os.path.join(ROOT, "build", "boot", "zyl-lsp")
URI = "file:///tmp/zyl-lsp-memory.zyl"
SAMPLE = """(use core/core)
(deftype Shape (Circle Int) (Square Int))
(defn area (s)
  (match s
    (Circle r (* 3 (* r r)))
    (Square w (* w w))))
(defn main ()
  (begin (print (area (Circle %d))) 0))
"""
WARM, N = 50, 400
LIMIT_KB_PER_OP = 0.5


def frame(o):
    b = json.dumps(o).encode()
    return b"Content-Length: %d\r\n\r\n" % len(b) + b


def main():
    p = subprocess.Popen([SERVER], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.DEVNULL)

    def send(o):
        p.stdin.write(frame(o))
        p.stdin.flush()

    def read():
        h = b""
        while not h.endswith(b"\r\n\r\n"):
            c = p.stdout.read(1)
            if not c:
                raise RuntimeError("server closed its output")
            h += c
        n = int([l for l in h.split(b"\r\n") if l.lower().startswith(b"content-length")][0].split(b":")[1])
        return json.loads(p.stdout.read(n))

    def rss():
        for l in open("/proc/%d/status" % p.pid):
            if l.startswith("VmRSS"):
                return int(l.split()[1])

    rid = [1]

    def step(kind, i):
        if kind == "change":
            send({"jsonrpc": "2.0", "method": "textDocument/didChange",
                  "params": {"textDocument": {"uri": URI, "version": i + 2},
                             "contentChanges": [{"text": SAMPLE % i}]}})
            read()
        elif kind == "hover":
            rid[0] += 1
            send({"jsonrpc": "2.0", "id": rid[0], "method": "textDocument/hover",
                  "params": {"textDocument": {"uri": URI}, "position": {"line": 2, "character": 7}}})
            read()
        else:
            u = URI + str(i)
            send({"jsonrpc": "2.0", "method": "textDocument/didOpen",
                  "params": {"textDocument": {"uri": u, "languageId": "zyl", "version": 1, "text": SAMPLE % i}}})
            read()
            send({"jsonrpc": "2.0", "method": "textDocument/didClose", "params": {"textDocument": {"uri": u}}})

    send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"capabilities": {}}})
    read()
    send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
    send({"jsonrpc": "2.0", "method": "textDocument/didOpen",
          "params": {"textDocument": {"uri": URI, "languageId": "zyl", "version": 1, "text": SAMPLE % 0}}})
    read()
    failures = []
    for kind in ("change", "hover", "openclose"):
        for i in range(WARM):
            step(kind, i)
        base = rss()
        for i in range(WARM, WARM + N):
            step(kind, i)
        per = (rss() - base) / N
        print(f"  {kind:>9}: {per:+.2f} kB per message")
        if per > LIMIT_KB_PER_OP:
            failures.append(f"{kind} grows {per:.2f} kB per message (limit {LIMIT_KB_PER_OP})")
    p.terminate()
    try:
        p.wait(5)
    except subprocess.TimeoutExpired:
        failures.append("SIGTERM ignored")
        p.kill()
    for f in failures:
        print("  ! " + f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
