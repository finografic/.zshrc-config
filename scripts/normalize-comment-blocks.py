#!/usr/bin/env python3
"""Normalize zsh comment block separators to canonical boxed style."""

from __future__ import annotations

import re
import sys
from pathlib import Path

CANONICAL = "# ============================================================================ #"


def is_separator_line(line: str) -> bool:
    stripped = line.rstrip("\n")
    if not stripped.startswith("#"):
        return False
    rest = stripped[1:].strip()
    if not rest:
        return False
    core = rest.rstrip("#").strip()
    if not core:
        return False
    return all(c == "=" for c in core) or all(c == "-" for c in core)


def is_hash_only_line(line: str) -> bool:
    stripped = line.rstrip("\n")
    if not stripped.startswith("#"):
        return False
    content = stripped[1:].replace(" ", "")
    return bool(content) and all(c == "#" for c in content)


def is_hash_title_line(line: str) -> bool:
    stripped = line.rstrip("\n")
    if not stripped.startswith("#"):
        return False
    if is_hash_only_line(line) or is_separator_line(line):
        return False
    inner = stripped[1:]
    text = inner.replace("#", "").strip()
    return bool(text) and "#" in inner


def extract_hash_title(line: str) -> str:
    return " ".join(line.replace("#", " ").split())


def is_title_line(line: str) -> bool:
    stripped = line.rstrip("\n")
    if not stripped.startswith("#"):
        return False
    if is_separator_line(line) or is_hash_only_line(line):
        return False
    rest = stripped[1:]
    if re.match(r"^\s*-\s", rest):
        return False
    return bool(rest.strip())


def is_section_title_line(line: str) -> bool:
    if not is_title_line(line):
        return False
    content = line.rstrip("\n")[1:].strip()
    if content.startswith("NOTE:"):
        return True
    prose_starts = (
        "This ",
        "These ",
        "The ",
        "For ",
        "When ",
        "If ",
        "Loads ",
        "Installs ",
        "Usage:",
    )
    if any(content.startswith(prefix) for prefix in prose_starts):
        return False
    return True


def extract_inline_title(line: str) -> str | None:
    match = re.match(r"^#\s+(.+?)\s+=+$", line.rstrip("\n"))
    return match.group(1).strip() if match else None


def make_block(title: str) -> list[str]:
    return [CANONICAL, f"# {title}", CANONICAL]


def normalize_lines(lines: list[str]) -> list[str]:
    out: list[str] = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 3-line hash block
        if (
            i + 2 < n
            and is_hash_only_line(line)
            and is_hash_title_line(lines[i + 1])
            and is_hash_only_line(lines[i + 2])
        ):
            title = extract_hash_title(lines[i + 1])
            out.extend(make_block(title))
            if i + 3 < n and lines[i + 3].strip():
                out.append("")
            i += 3
            continue

        # 3-line equals/dash block
        if (
            i + 2 < n
            and is_separator_line(line)
            and is_section_title_line(lines[i + 1])
            and is_separator_line(lines[i + 2])
        ):
            title = lines[i + 1].rstrip("\n")[1:].strip()
            out.extend(make_block(title))
            if i + 3 < n and lines[i + 3].strip():
                out.append("")
            i += 3
            continue

        # Inline trailing equals: # Title =====
        inline_title = extract_inline_title(line)
        if inline_title is not None:
            out.extend(make_block(inline_title))
            if i + 1 < n and lines[i + 1].strip():
                out.append("")
            i += 1
            continue

        # Malformed 2-line block: separator + title, missing bottom
        if i + 1 < n and is_separator_line(line) and is_section_title_line(lines[i + 1]):
            title = lines[i + 1].rstrip("\n")[1:].strip()
            out.extend(make_block(title))
            if i + 2 < n and lines[i + 2].strip():
                out.append("")
            i += 2
            continue

        # Lone separator line
        if is_separator_line(line):
            out.append(CANONICAL)
            i += 1
            continue

        out.append(line.rstrip("\n"))
        i += 1

    return out


def normalize_file(path: Path) -> bool:
    original = path.read_text()
    if not original:
        return False

    newline = "\n" if original.endswith("\n") else ""
    lines = original.splitlines(keepends=True)
    normalized = normalize_lines(lines)
    result = "\n".join(normalized) + newline

    if result == original:
        return False

    path.write_text(result)
    return True


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    changed: list[str] = []

    for path in sorted(root.rglob("*.zsh")):
        if ".claude" in path.parts:
            continue
        if normalize_file(path):
            changed.append(str(path.relative_to(root)))

    print(f"Updated {len(changed)} files")
    for name in changed:
        print(f"  {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
