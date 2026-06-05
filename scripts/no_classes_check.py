#!/usr/bin/env python3
"""Pre-commit check that rejects Python class definitions in the codebase."""

import os, sys, ast

EXCLUDE_DIRS = {
    ".git",
    "venv",
    ".venv",
    "node_modules",
    "dist",
    "build",
    ".mypy_cache",
    ".pytest_cache",
    ".tox",
    "env",
}

EXCLUDE_FILES = {"test.py", "jc_api.py"}


def iter_py_files():
    """Yield paths to all Python files, skipping excluded directories and files."""
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for f in files:
            if f.endswith(".py") and f not in EXCLUDE_FILES:
                yield os.path.join(root, f)


def main():
    """Report class definitions found in the codebase and exit non-zero if any exist."""
    violations = []
    for path in iter_py_files():
        try:
            with open(path, "rb") as fh:
                tree = ast.parse(fh.read(), filename=path)
        except SyntaxError:
            # Skip files with syntax errors; flake8 will catch these anyway
            continue
        for n in ast.walk(tree):
            if isinstance(n, ast.ClassDef):
                violations.append(f"{path}:{n.lineno}:{n.col_offset+1}: class {n.name}")
    if violations:
        print("❌ Error: Class definitions found in the codebase!")
        print("\n".join(violations))
        sys.exit(1)
    print("✅ No classes found. All good!")


if __name__ == "__main__":
    main()
