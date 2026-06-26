from pathlib import Path
import sys


TEXT_SUFFIXES = {
    ".css",
    ".html",
    ".js",
    ".json",
    ".md",
    ".plist",
    ".sh",
    ".svg",
    ".swift",
    ".txt",
    ".xml",
    ".yml",
    ".yaml",
}

SKIP_DIRS = {
    ".git",
    ".github",
    "node_modules",
}

# Common mojibake markers produced when UTF-8 Cyrillic is read as Windows-1251.
MOJIBAKE_MARKERS = [
    "\u0420\u045f",
    "\u0420\u00a0",
    "\u0420\u00b5",
    "\u0421\u0453",
    "\u0421\u201a",
    "\u0432\u0402",
]


def should_check(path: Path) -> bool:
    if any(part in SKIP_DIRS for part in path.parts):
        return False
    return path.suffix.lower() in TEXT_SUFFIXES


def main() -> int:
    failed = False
    for path in sorted(Path(".").rglob("*")):
        if not path.is_file() or not should_check(path):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError as exc:
            print(f"{path}: not valid UTF-8: {exc}", file=sys.stderr)
            failed = True
            continue
        if any(marker in text for marker in MOJIBAKE_MARKERS):
            print(f"{path}: likely mojibake in text", file=sys.stderr)
            failed = True
    if failed:
        return 1
    print("text encoding check passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
