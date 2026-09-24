#!/usr/bin/env python3
"""Fails when a public declaration in a library target has no `///` doc comment.

DocC's `--warnings-as-errors` does not flag undocumented symbols, so this script
enforces the AGENTS.md rule that every public symbol is documented. It is a
line-based heuristic, not a Swift parser:

* A declaration counts as public when it is marked `public`/`open`, when it is an
  enum `case` inside a public enum, or when it is a member (without an explicit
  lower access level) of a `public extension` or `public protocol`.
* A declaration is documented when the nearest preceding line that is not blank,
  an attribute (`@MainActor`, `@ViewBuilder`, ...), or a compiler directive is a
  `///` line or closes a `/** ... */` block.
* Protocol witnesses whose documentation DocC inherits (`body`, `makeBody`,
  `sizeThatFits`, ...) are exempt.
"""

import re
import sys
from pathlib import Path

TARGETS = [Path("Sources/DesignSystem"), Path("Sources/Components")]

EXEMPT_NAMES = {
    "body",
    "makeBody",
    "sizeThatFits",
    "placeSubviews",
    "makeCoordinator",
    "hash",
    "description",
}

DECL_KEYWORDS = r"(?:struct|enum|class|actor|protocol|extension|func|var|let|init|subscript|typealias|associatedtype|case)"
MODIFIERS = r"(?:(?:public|open|internal|fileprivate|private|static|class|final|nonisolated|override|mutating|nonmutating|convenience|required|indirect|lazy|weak|unowned|dynamic|isolated)\s+)*"
DECL_RE = re.compile(r"^\s*" + MODIFIERS + DECL_KEYWORDS + r"\b")
NAME_RE = re.compile(
    r"\b(?:struct|enum|class|actor|protocol|func|var|let|typealias|associatedtype|case)\s+`?([A-Za-z_][A-Za-z0-9_]*)"
)
CONTAINER_RE = re.compile(r"\b(struct|enum|class|actor|protocol|extension)\b")
ATTRIBUTE_RE = re.compile(r"^\s*@[A-Za-z_]+(\(.*\))?\s*$")
DIRECTIVE_RE = re.compile(r"^\s*#(if|elseif|else|endif)\b")
STRING_RE = re.compile(r'"(?:[^"\\]|\\.)*"')
RESTRICTED_RE = re.compile(r"\b(private|fileprivate|internal)\b")


def strip_strings_and_comments(line):
    line = STRING_RE.sub('""', line)
    return line.split("//", 1)[0]


def is_documented(lines, index):
    cursor = index - 1
    while cursor >= 0:
        text = lines[cursor].strip()
        if not text or ATTRIBUTE_RE.match(lines[cursor]) or DIRECTIVE_RE.match(lines[cursor]):
            cursor -= 1
            continue
        return text.startswith("///") or text.endswith("*/")
    return False


def check_file(path):
    failures = []
    lines = path.read_text(encoding="utf-8").splitlines()
    # Each entry describes the scope a `{` opened:
    # "public-enum", "public-members" (public extension/protocol), "public-type", or "code".
    stack = []
    in_block_comment = False

    for index, raw in enumerate(lines):
        stripped = raw.strip()
        if in_block_comment:
            if "*/" in stripped:
                in_block_comment = False
            continue
        if stripped.startswith("/*") and "*/" not in stripped:
            in_block_comment = True
            continue
        if stripped.startswith("//") or stripped.startswith("#Preview"):
            # A #Preview body is code; its braces are still tracked below.
            if stripped.startswith("//"):
                continue

        code = strip_strings_and_comments(raw)
        scope = stack[-1] if stack else "file"
        in_code = "code" in stack

        is_decl = bool(DECL_RE.match(code)) and not in_code
        if is_decl:
            explicit_public = re.search(r"\b(public|open)\b", code) is not None
            restricted = RESTRICTED_RE.search(code) is not None
            is_case = re.match(r"^\s*(indirect\s+)?case\b", code) is not None
            implicitly_public = (
                (scope == "public-enum" and is_case)
                or (scope == "public-members" and not restricted)
            )
            name_match = NAME_RE.search(code)
            name = name_match.group(1) if name_match else ("init" if re.search(r"\binit\b", code) else "")
            is_extension = re.match(r"^\s*" + MODIFIERS + r"extension\b", code) is not None
            if (explicit_public or implicitly_public) and not is_extension:
                if name not in EXEMPT_NAMES and not is_documented(lines, index):
                    failures.append(f"{path}:{index + 1}: undocumented public declaration `{stripped}`")

        opens = code.count("{")
        closes = code.count("}")
        # Resolve closes before opens on lines like `} else {`.
        leading_closes = len(code) - len(code.lstrip("}")) if code.lstrip().startswith("}") else 0
        for _ in range(min(leading_closes, closes)):
            if stack:
                stack.pop()
        closes -= min(leading_closes, closes)

        if opens:
            kind = "code"
            container = CONTAINER_RE.search(code) if is_decl or re.match(r"^\s*(public\s+)?extension\b", code) else None
            if container and not in_code:
                keyword = container.group(1)
                public = re.search(r"\b(public|open)\b", code) is not None
                if keyword == "enum" and public:
                    kind = "public-enum"
                elif keyword in ("extension", "protocol") and public:
                    kind = "public-members"
                elif public:
                    kind = "public-type"
                else:
                    kind = "internal-type"
            stack.append(kind)
            for _ in range(opens - 1):
                stack.append("code")
        for _ in range(closes):
            if stack:
                stack.pop()

    return failures


def main():
    failures = []
    for target in TARGETS:
        for path in sorted(target.rglob("*.swift")):
            failures.extend(check_file(path))
    if failures:
        print("Doc comment check failed — every public symbol needs a `///` comment:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("Doc comment check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
