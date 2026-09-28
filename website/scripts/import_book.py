#!/usr/bin/env python3
"""Import the book (book/src) into Starlight's content tree and sidebar.

Each chapter becomes website/src/content/docs/<topic>/<slug>.md with a
title taken from its first heading; links between chapters are rewritten
to site paths and `lisp` fences become `zyl`. The sidebar order, from
book/src/SUMMARY.md, is written to src/sidebar.json, and the old mdBook
URLs (/zyl/book/...) get redirect pages under public/book/. Everything it
writes is generated and ignored by git.

Usage: scripts/import_book.py
"""
import json, os, re, shutil, subprocess

site = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
root = os.path.dirname(site)
book = os.path.join(root, "book", "src")
docs = os.path.join(site, "src", "content", "docs")
base = "/zyl"
repo = "https://github.com/larrydewey/zyl/blob/master"
edit = "https://github.com/larrydewey/zyl/edit/master/book/src"

def last_commit_date(rel):
    try:
        out = subprocess.run(["git", "log", "-1", "--format=%cs", "--", os.path.join(book, rel)],
                             cwd=root, capture_output=True, text=True, check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        out = ""
    return out

# Part directory: (topic slug, topic label, sidebar icon).
topics = {
    "part1": ("learn", "Learn Zyl", "open-book"),
    "part2": ("reference", "Language Reference", "document"),
    "part3": ("internals", "Compiler Internals", "puzzle"),
    "part4": ("systems", "Low-Level & Crypto", "seti:lock"),
    "part5": ("tooling", "Tooling", "setting"),
    "appendix": ("appendix", "Appendices", "list-format"),
}

def slug_of(name):
    stem = name[:-3]
    return re.sub(r"^(ch\d+|appendix-[a-z])-", "", stem)

summary = open(os.path.join(book, "SUMMARY.md")).read()
entries = re.findall(r"^- \[([^\]]+)\]\(([^)]+)\)", summary, re.M)

pages = {}
for label, rel in entries:
    part, name = rel.split("/")
    topic = topics[part][0]
    pages[rel] = (topic, slug_of(name), label)

def site_path(rel):
    topic, slug, _ = pages[rel]
    return f"{base}/{topic}/{slug}/"

def rewrite_links(text, rel):
    here = os.path.dirname(rel)
    def fix(m):
        label, target = m.group(1), m.group(2)
        if re.match(r"^[a-z]+:", target) or target.startswith("#"):
            return m.group(0)
        path, _, frag = target.partition("#")
        frag = "#" + frag if frag else ""
        norm = os.path.normpath(os.path.join(here, path))
        if norm in pages:
            return f"[{label}]({site_path(norm)}{frag})"
        full = os.path.normpath(os.path.join("book/src", here, path))
        return f"[{label}]({repo}/{full}{frag})"
    return re.sub(r"\[([^\]]*)\]\(([^)\s]+)\)", fix, text)

def short_label(label):
    m = re.match(r"(Chapter|Appendix) ([0-9A-Z]+): (.*)", label)
    return f"{m.group(2)}. {m.group(3)}" if m else label

def yaml_str(s):
    return json.dumps(s, ensure_ascii=False)

for sub in set(t[0] for t in topics.values()):
    shutil.rmtree(os.path.join(docs, sub), ignore_errors=True)

sidebar = {}
for label, rel in entries:
    topic, slug, _ = pages[rel]
    text = open(os.path.join(book, rel)).read()
    lines = text.split("\n")
    title = label
    if lines and lines[0].startswith("# "):
        title = lines[0][2:].strip()
        lines = lines[1:]
    title = re.sub(r"^(Chapter|Appendix) [0-9A-Z]+: ", "", title)
    body = rewrite_links("\n".join(lines).lstrip("\n"), rel)
    body = re.sub(r"^```lisp\b", "```zyl", body, flags=re.M)
    date = last_commit_date(rel)
    front = (f"---\ntitle: {yaml_str(title)}\n"
             f"sidebar:\n  label: {yaml_str(short_label(label))}\n"
             f"editUrl: {yaml_str(edit + '/' + rel)}\n"
             + (f"lastUpdated: {date}\n" if date else "lastUpdated: false\n")
             + "---\n\n")
    out = os.path.join(docs, topic, slug + ".md")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "w").write(front + body)
    sidebar.setdefault(topic, []).append(f"{topic}/{slug}")

# The mdBook site lived under /zyl/book/: keep its links working.
old = os.path.join(site, "public", "book")
shutil.rmtree(old, ignore_errors=True)
def redirect(path, target):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w").write(
        f'<!doctype html><meta charset="utf-8"><title>Moved</title>'
        f'<link rel="canonical" href="{target}"><meta http-equiv="refresh" content="0; url={target}">'
        f'<p>This page moved to <a href="{target}">{target}</a>.</p>\n')
first = site_path(entries[0][1])
for name in ["index.html", "print.html"]:
    redirect(os.path.join(old, name), first)
for rel in pages:
    redirect(os.path.join(old, rel[:-3] + ".html"), site_path(rel))

order = []
for part, (topic, label, icon) in topics.items():
    items = sidebar.get(topic, [])
    if items:
        order.append({"label": label, "icon": icon, "link": f"/{items[0]}/", "items": items})
json.dump(order, open(os.path.join(site, "src", "sidebar.json"), "w"), indent=1)
print(f"imported {len(entries)} pages into {len(order)} topics")
