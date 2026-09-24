#!/usr/bin/env python3
"""End-to-end protocol tests for the Zyl language server.

Drives build/boot/zyl-lsp over real JSON-RPC on stdio -- the same
transport an editor uses -- and asserts on the responses. Nothing here
reaches into the server's internals; if a test passes, an editor
talking to this binary sees the same thing.

Run it directly, or through `./run_regression_tests.sh --filter lsp`.
"""

import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SERVER = os.path.join(ROOT, "build", "boot", "zyl-lsp")
URI = "file:///tmp/zyl-lsp-test.zyl"

SAMPLE = """(use core/core)
(use core/list)

(deftype Shape
  (Circle Int)
  (Square Int))

(defstruct Point
  (x Int)
  (y Int))

(defn area (s)
  (match s
    (Circle r (* 3 (* r r)))
    (Square w (* w w))))

(defn mask (k v)
  (bit-xor k (shl v 3)))

(defn main ()
  (print (area (Circle 4))))
"""

FAILURES = []
CHECKS = 0


def check(name, condition, detail=""):
    global CHECKS
    CHECKS += 1
    if not condition:
        FAILURES.append(f"{name}: {detail}")


def frame(obj):
    body = json.dumps(obj).encode()
    return b"Content-Length: %d\r\n\r\n" % len(body) + body


def converse(messages, timeout=120):
    """Send every message, then read the whole reply stream back."""
    proc = subprocess.Popen(
        [SERVER], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    out, err = proc.communicate(b"".join(frame(m) for m in messages), timeout=timeout)
    responses, notifications = {}, []
    data = out
    while b"Content-Length:" in data:
        head = data.index(b"Content-Length:")
        gap = data.index(b"\r\n\r\n", head)
        length = int(data[head + len("Content-Length:"): gap])
        body = data[gap + 4: gap + 4 + length]
        data = data[gap + 4 + length:]
        message = json.loads(body)
        if "id" in message and "method" not in message:
            responses[message["id"]] = message.get("result")
        else:
            notifications.append(message)
    return responses, notifications, err.decode()


def session(*requests, text=SAMPLE):
    """An initialize/didOpen/.../shutdown session around `requests`."""
    messages = [
        {"jsonrpc": "2.0", "id": 1, "method": "initialize",
         "params": {"processId": None, "rootUri": None, "capabilities": {}}},
        {"jsonrpc": "2.0", "method": "initialized", "params": {}},
        {"jsonrpc": "2.0", "method": "textDocument/didOpen",
         "params": {"textDocument": {"uri": URI, "languageId": "zyl",
                                     "version": 1, "text": text}}},
    ]
    messages.extend(requests)
    messages.append({"jsonrpc": "2.0", "id": 999, "method": "shutdown", "params": {}})
    messages.append({"jsonrpc": "2.0", "method": "exit", "params": {}})
    return converse(messages)


def request(rid, method, **params):
    params.setdefault("textDocument", {"uri": URI})
    return {"jsonrpc": "2.0", "id": rid, "method": method, "params": params}


def at(line, character):
    return {"line": line, "character": character}


# ---------------------------------------------------------------------------
# Capabilities
# ---------------------------------------------------------------------------

def test_capabilities():
    responses, _, _ = session()
    caps = (responses.get(1) or {}).get("capabilities", {})
    for provider in ("hoverProvider", "definitionProvider", "referencesProvider",
                     "documentHighlightProvider", "typeDefinitionProvider",
                     "implementationProvider", "signatureHelpProvider",
                     "documentSymbolProvider", "completionProvider",
                     "semanticTokensProvider", "renameProvider",
                     "foldingRangeProvider", "selectionRangeProvider",
                     "callHierarchyProvider", "inlayHintProvider",
                     "workspaceSymbolProvider", "documentFormattingProvider"):
        check("capabilities", provider in caps, f"missing {provider}")
    tokens = caps.get("semanticTokensProvider", {})
    check("capabilities", tokens.get("range") is True, "semantic tokens range not advertised")
    legend = tokens.get("legend", {})
    check("capabilities", "keyword" in legend.get("tokenTypes", []), "legend lacks keyword")
    check("capabilities", "enumMember" in legend.get("tokenTypes", []), "legend lacks enumMember")


# ---------------------------------------------------------------------------
# Hover: built-ins, variants, structs, fields, functions
# ---------------------------------------------------------------------------

def test_hover():
    responses, _, _ = session(
        request(10, "textDocument/hover", position=at(17, 4)),   # bit-xor
        request(11, "textDocument/hover", position=at(13, 6)),   # Circle
        request(12, "textDocument/hover", position=at(11, 7)),   # area
        request(13, "textDocument/hover", position=at(7, 12)),   # Point
        request(14, "textDocument/hover", position=at(8, 4)),    # x
        request(15, "textDocument/hover", position=at(3, 10)),   # Shape
    )

    def value(rid):
        result = responses.get(rid)
        return "" if not result else result.get("contents", {}).get("value", "")

    check("hover/builtin", "Bitwise XOR" in value(10), value(10))
    check("hover/builtin", "markdown" == (responses.get(10) or {}).get("contents", {}).get("kind"),
          "hover contents must be MarkupContent")
    check("hover/variant", "Variant of `Shape`" in value(11), value(11))
    check("hover/function", "(defn area (s)" in value(12), value(12))
    check("hover/struct", "defstruct Point" in value(13), value(13))
    check("hover/field", "Field `x` of struct `Point`" in value(14), value(14))
    check("hover/adt", "(deftype Shape" in value(15), value(15))
    check("hover/range", (responses.get(10) or {}).get("range") is not None,
          "hover should report the identifier's range")


# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------

def test_navigation():
    responses, _, _ = session(
        request(20, "textDocument/definition", position=at(20, 11)),      # area call
        request(21, "textDocument/definition", position=at(20, 18)),      # Circle -> deftype
        request(22, "textDocument/typeDefinition", position=at(20, 18)),  # Circle -> Shape
        request(30, "textDocument/references", position=at(11, 7),
                context={"includeDeclaration": True}),
        request(31, "textDocument/documentHighlight", position=at(11, 7)),
        request(32, "textDocument/references", position=at(11, 7),
                context={"includeDeclaration": False}),
        request(33, "textDocument/implementation", position=at(11, 7)),
    )
    definition = responses.get(20) or {}
    check("definition", definition.get("range", {}).get("start", {}).get("line") == 11,
          json.dumps(definition))
    variant = responses.get(21) or {}
    check("definition/variant", variant.get("range", {}).get("start", {}).get("line") == 3,
          "a variant should resolve to its deftype")
    check("typeDefinition", (responses.get(22) or {}).get("range", {}).get("start", {}).get("line") == 3,
          json.dumps(responses.get(22)))
    references = responses.get(30) or []
    check("references", len(references) == 2, f"expected declaration + call site, got {len(references)}")
    highlights = responses.get(31) or []
    check("documentHighlight", len(highlights) == 2, f"got {len(highlights)}")
    uses = responses.get(32) or []
    check("references/excludeDeclaration", len(uses) == 1,
          f"without the declaration only the call site remains, got {len(uses)}")
    check("references/excludeDeclaration",
          uses and uses[0]["range"]["start"]["line"] == 20, json.dumps(uses))
    check("implementation", responses.get(33) == [],
          "nothing implements a function, so the list is empty")


# ---------------------------------------------------------------------------
# Symbols, folding, selection
# ---------------------------------------------------------------------------

def test_symbols():
    responses, _, _ = session(
        request(40, "textDocument/documentSymbol"),
        request(41, "textDocument/foldingRange"),
        request(42, "textDocument/selectionRange", positions=[at(13, 6)]),
    )
    symbols = responses.get(40) or []
    names = [s["name"] for s in symbols]
    for expected in ("Shape", "Point", "area", "mask", "main"):
        check("documentSymbol", expected in names, f"{expected} missing from {names}")
    shape = next((s for s in symbols if s["name"] == "Shape"), {})
    check("documentSymbol/range", shape.get("range", {}).get("end", {}).get("line") == 5,
          "a symbol's range should span the whole form")
    check("documentSymbol/selection",
          shape.get("selectionRange", {}).get("start", {}).get("character") == 9,
          "selectionRange should cover the name only")
    folds = responses.get(41) or []
    check("foldingRange", any(f["startLine"] == 3 and f["endLine"] == 5 for f in folds),
          json.dumps(folds))
    selection = responses.get(42) or []
    check("selectionRange", len(selection) == 1 and "parent" not in json.dumps(selection[:0]),
          "one selection range per requested position")


# ---------------------------------------------------------------------------
# Completion and signature help
# ---------------------------------------------------------------------------

def test_completion():
    responses, _, _ = session(
        request(50, "textDocument/completion", position=at(19, 8)),
        request(51, "textDocument/completion", position=at(1, 5)),
        request(60, "textDocument/signatureHelp", position=at(17, 13)),
    )
    general = responses.get(50) or []
    labels = {item["label"] for item in general}
    for expected in ("defn", "match", "bit-xor", "ffi-pin", "Secret", "Pin",
                     "area", "Shape", "Circle", "Point"):
        check("completion", expected in labels, f"{expected} not offered")
    documented = [i for i in general if i["label"] == "bit-xor"]
    check("completion/detail", documented and documented[0].get("detail"),
          "built-in completions should carry a signature")
    check("completion/docs", documented and documented[0].get("documentation"),
          "built-in completions should carry documentation")

    modules = responses.get(51) or []
    module_labels = {item["label"] for item in modules}
    check("completion/use", "math/hash/sha2" in module_labels,
          "inside (use ...) the candidates should be module paths")
    check("completion/use", "defn" not in module_labels,
          "inside (use ...) keywords should not be offered")

    signature = responses.get(60) or {}
    signatures = signature.get("signatures", [])
    check("signatureHelp", signatures and signatures[0]["label"] == "(bit-xor a b)",
          json.dumps(signature))
    check("signatureHelp", signature.get("activeParameter") == 1,
          "the cursor sits on the second argument")


# ---------------------------------------------------------------------------
# Semantic tokens
# ---------------------------------------------------------------------------

def test_semantic_tokens():
    responses, _, _ = session(
        request(70, "textDocument/semanticTokens/full"),
        request(71, "textDocument/semanticTokens/range",
                range={"start": at(16, 0), "end": at(17, 0)}),
    )
    full = (responses.get(70) or {}).get("data")
    check("semanticTokens", full and len(full) % 5 == 0, "data must be a multiple of five")
    check("semanticTokens", len(full) > 50, "the sample should produce many tokens")
    partial = (responses.get(71) or {}).get("data")
    check("semanticTokens/range", partial and len(partial) < len(full),
          "a range request should return fewer tokens than the whole file")


# ---------------------------------------------------------------------------
# Rename
# ---------------------------------------------------------------------------

def test_rename():
    responses, _, _ = session(
        request(80, "textDocument/prepareRename", position=at(11, 7)),
        request(81, "textDocument/rename", position=at(11, 7), newName="surface"),
    )
    check("prepareRename", responses.get(80) is not None, "prepareRename should return a range")
    edits = ((responses.get(81) or {}).get("changes") or {}).get(URI, [])
    check("rename", len(edits) == 2, f"declaration and call site, got {len(edits)}")
    check("rename", all(e["newText"] == "surface" for e in edits), json.dumps(edits))


# ---------------------------------------------------------------------------
# Diagnostics -- one case per compiler check the server runs
# ---------------------------------------------------------------------------

DIAGNOSTIC_CASES = [
    ("arity", "E_ARITY_MISMATCH",
     "(defn add (a b) (+ a b))\n(defn main ()\n  (print (add 1)))\n"),
    ("exhaustiveness", "E_NON_EXHAUSTIVE_MATCH",
     "(deftype Color (Red) (Green) (Blue))\n(defn name (c)\n  (match c\n"
     "    (Red 1)\n    (Green 2)))\n(defn main () (print (name Red)))\n"),
    ("duplicate", "E_DUPLICATE_DEFINITION",
     "(defn twice (x) (* x 2))\n(defn twice (x) (+ x x))\n(defn main () (print (twice 2)))\n"),
    ("secret", "E_SECRET_DEBUG",
     "(defn leak ((k Secret))\n  (print k))\n(defn main () (leak 7))\n"),
    ("balance", "E_UNBALANCED_UNCLOSED",
     "(defn oops (x)\n  (+ x 1)\n"),
]


def diagnostics_for(source):
    uri = "file:///tmp/zyl-lsp-diagnostic.zyl"
    _, notifications, _ = converse([
        {"jsonrpc": "2.0", "id": 1, "method": "initialize",
         "params": {"processId": None, "rootUri": None, "capabilities": {}}},
        {"jsonrpc": "2.0", "method": "initialized", "params": {}},
        {"jsonrpc": "2.0", "method": "textDocument/didOpen",
         "params": {"textDocument": {"uri": uri, "languageId": "zyl",
                                     "version": 1, "text": source}}},
        {"jsonrpc": "2.0", "id": 2, "method": "shutdown", "params": {}},
        {"jsonrpc": "2.0", "method": "exit", "params": {}},
    ])
    for message in notifications:
        if message.get("method") == "textDocument/publishDiagnostics":
            return message["params"]["diagnostics"]
    return None


def test_diagnostics():
    for name, code, source in DIAGNOSTIC_CASES:
        diagnostics = diagnostics_for(source)
        check(f"diagnostics/{name}", diagnostics, "no diagnostics published")
        if not diagnostics:
            continue
        first = diagnostics[0]
        check(f"diagnostics/{name}", first.get("code") == code,
              f"expected {code}, got {first.get('code')}")
        check(f"diagnostics/{name}", first.get("severity") == 1, "should be an error")
        check(f"diagnostics/{name}", first.get("range") is not None, "should carry a range")

    clean = diagnostics_for("(defn add (a b) (+ a b))\n(defn main () (print (add 1 2)))\n")
    check("diagnostics/clean", clean == [], f"a valid program should be clean, got {clean}")

    # unused_check's warnings are published as Warning diagnostics, located.
    warned = diagnostics_for("(defn main ()\n  (let unused 1\n    (begin (print 2) 0)))\n") or []
    unused = [d for d in warned if d.get("code") == "W_UNUSED_VARIABLE"]
    check("diagnostics/unused-warning", len(unused) == 1, f"expected one W_UNUSED_VARIABLE, got {warned}")
    if unused:
        check("diagnostics/unused-warning", unused[0].get("severity") == 2, "should be a warning")
        check("diagnostics/unused-warning", unused[0]["range"]["start"]["line"] == 1,
              f"should point at the let on line 2, got {unused[0]['range']}")


# ---------------------------------------------------------------------------
# Package forms (§31.2 visibility, §31.10 features)
# ---------------------------------------------------------------------------

PACKAGE_SAMPLE = """(pub defn base (n) (+ n 1))

(feature-gate simd (pub defn fast (n) (* n 8)))

(feature-gate utf16
  (defn wide (n) (* n 16)))

(defn helper (n) (base n))
"""


def test_package_forms():
    responses, _, _ = session(
        request(60, "textDocument/documentSymbol"),
        request(61, "textDocument/hover", position=at(0, 2)),
        request(62, "textDocument/hover", position=at(2, 4)),
        request(63, "textDocument/definition", position=at(7, 19)),
        text=PACKAGE_SAMPLE,
    )
    names = [s["name"] for s in responses.get(60) or []]
    for expected in ("base", "fast", "wide", "helper"):
        check("package/documentSymbol", expected in names, f"{expected} missing from {names}")
    wide = next((s for s in responses.get(60) or [] if s["name"] == "wide"), {})
    check("package/range", wide.get("range", {}).get("end", {}).get("line") == 5,
          "a gated definition's range should span the whole feature-gate form")
    for rid, word in ((61, "pub"), (62, "feature-gate")):
        hover = json.dumps(responses.get(rid) or {}, ensure_ascii=False)
        check(f"package/hover/{word}", word in hover and "§31" in hover, hover[:200])
    target = responses.get(63)
    target = target[0] if isinstance(target, list) and target else (target or {})
    check("package/definition", target.get("range", {}).get("start", {}).get("line") == 0,
          json.dumps(target))


# ---------------------------------------------------------------------------

TESTS = [
    ("capabilities", test_capabilities),
    ("hover", test_hover),
    ("navigation", test_navigation),
    ("symbols", test_symbols),
    ("completion", test_completion),
    ("semantic tokens", test_semantic_tokens),
    ("rename", test_rename),
    ("diagnostics", test_diagnostics),
    ("package forms", test_package_forms),
]


def main():
    if not os.path.exists(SERVER):
        print(f"zyl-lsp not built at {SERVER} -- run ./boot.sh first", file=sys.stderr)
        return 2
    for name, test in TESTS:
        before = len(FAILURES)
        try:
            test()
        except Exception as exc:  # a crashed server should fail, not traceback
            FAILURES.append(f"{name}: raised {exc!r}")
        status = "ok" if len(FAILURES) == before else "FAILED"
        print(f"  {status:>6}  {name}")
    print(f"\n{CHECKS - len(FAILURES)}/{CHECKS} checks passed")
    for failure in FAILURES:
        print(f"  ! {failure}")
    return 1 if FAILURES else 0


if __name__ == "__main__":
    sys.exit(main())
