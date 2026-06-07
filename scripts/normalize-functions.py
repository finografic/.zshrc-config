#!/usr/bin/env python3
"""Normalize zsh functions: function keyword + kebab-case names."""

from __future__ import annotations

import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SKIP_DIRS = {".git", ".claude", "vendor", "node_modules"}
SKIP_FILES = {"scripts/.iterm2_shell_integration.zsh", "scripts/normalize-functions.py"}
SKIP_PREFIXES = (
    "themes/p10k/$HOME.cache/",
    "plugins/.zsh_plugins.generated",
)

# zsh hook / widget names that must not be renamed
PROTECTED_NAMES = frozenset(
    {
        "precmd",
        "preexec",
        "chpwd",
        "periodic",
        "up-line-or-history-substring-search-up",
        "down-line-or-history-substring-search-down",
        "expand-or-complete-with-dots",
    }
)

DEF_RE = re.compile(
    r"^(\s*)(?:function\s+)?([a-zA-Z_][-a-zA-Z0-9_]*)\s*\(\)\s*(\{.*)$"
)


def skip_path(path: Path) -> bool:
    rel = path.relative_to(ROOT).as_posix()
    if rel in SKIP_FILES:
        return True
    if any(rel.startswith(p) for p in SKIP_PREFIXES):
        return True
    if "p10k-dump" in rel:
        return True
    return False


def to_kebab(name: str) -> str:
    if "_" not in name:
        return name
    lead = ""
    rest = name
    while rest.startswith("_"):
        lead += "_"
        rest = rest[1:]
    parts = [p for p in rest.split("_") if p]
    return lead + "-".join(p.lower() for p in parts)


def collect_function_names() -> set[str]:
    names: set[str] = set()
    for path in ROOT.rglob("*.zsh"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if skip_path(path):
            continue
        for line in path.read_text(errors="replace").splitlines():
            m = DEF_RE.match(line)
            if m:
                names.add(m.group(2))
    return names


def build_renames(names: set[str]) -> dict[str, str]:
    renames: dict[str, str] = {}
    for name in names:
        if name in PROTECTED_NAMES:
            continue
        new = to_kebab(name)
        if new != name:
            renames[name] = new
    return renames


def normalize_def_line(line: str, renames: dict[str, str]) -> str:
    m = DEF_RE.match(line)
    if not m:
        return line
    indent, name, tail = m.group(1), m.group(2), m.group(3)
    if name in PROTECTED_NAMES:
        if re.match(r"^\s*function\s+", line):
            return line
        return f"{indent}function {name}(){tail}"
    new_name = renames.get(name, name)
    return f"{indent}function {new_name}(){tail}"


def apply_renames(text: str, renames: dict[str, str]) -> str:
    if not renames:
        return text
    for old, new in sorted(renames.items(), key=lambda kv: len(kv[0]), reverse=True):
        pattern = re.compile(rf"(?<![a-zA-Z0-9_-]){re.escape(old)}(?![a-zA-Z0-9_-])")
        text = pattern.sub(new, text)
    return text


def process_file(path: Path, renames: dict[str, str]) -> bool:
    original = path.read_text(errors="replace")
    lines = original.splitlines()
    new_lines = [normalize_def_line(line, renames) for line in lines]
    text = "\n".join(new_lines)
    if original.endswith("\n"):
        text += "\n"
    updated = apply_renames(text, renames)
    if updated != original:
        path.write_text(updated)
        return True
    return False


def main() -> None:
    os.chdir(ROOT)
    names = collect_function_names()
    renames = build_renames(names)
    changed_files: list[str] = []

    for path in sorted(ROOT.rglob("*.zsh")):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if skip_path(path):
            continue
        if process_file(path, renames):
            changed_files.append(path.relative_to(ROOT).as_posix())

    print(f"Renamed {len(renames)} functions across {len(changed_files)} files")
    for f in changed_files:
        print(f"  {f}")


if __name__ == "__main__":
    main()
