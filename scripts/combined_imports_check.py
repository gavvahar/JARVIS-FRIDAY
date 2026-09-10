#!/usr/bin/env python3
"""Pre-commit check that flags a file with more than one top-level bare
`import x` statement, since they should all be combined onto a single line
(`import x, y as z, ...`) regardless of aliases or blank-line grouping.
`from x import y` statements are left untouched wherever they are. Only
top-level statements are checked, so guarded imports (try/except,
TYPE_CHECKING) are untouched.

Pass --fix to rewrite violations in place instead of just reporting them.
"""

import ast, os, sys

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


def iter_py_files():
    """Yield paths to all Python files, skipping excluded directories."""
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for f in files:
            if f.endswith(".py"):
                yield os.path.join(root, f)


def plain_imports(tree):
    """Return all top-level `import x` statements in a module body, in source order."""
    return [n for n in tree.body if isinstance(n, ast.Import)]


def alias_text(alias):
    """Render a single import alias as it should appear in source (`x` or `x as y`)."""
    return f"{alias.name} as {alias.asname}" if alias.asname else alias.name


def fix_file(path, imports):
    """Rewrite path so all its top-level bare imports are merged onto one line."""
    with open(path) as fh:
        lines = fh.readlines()
    names = ", ".join(alias_text(a) for n in imports for a in n.names)
    for node in sorted(imports[1:], key=lambda n: n.lineno, reverse=True):
        del lines[node.lineno - 1 : node.end_lineno]
    first = imports[0]
    lines[first.lineno - 1 : first.end_lineno] = [f"import {names}\n"]
    with open(path, "w") as fh:
        fh.writelines(lines)


def main():
    """Report files with multiple bare imports, or fix them with --fix."""
    fix = "--fix" in sys.argv
    violations = []
    fixed_files = []
    for path in iter_py_files():
        try:
            with open(path, "rb") as fh:
                tree = ast.parse(fh.read(), filename=path)
        except SyntaxError:
            continue
        imports = plain_imports(tree)
        if len(imports) <= 1:
            continue
        if fix:
            fix_file(path, imports)
            fixed_files.append(path)
        else:
            names = ", ".join(alias_text(a) for n in imports for a in n.names)
            violations.append(f"{path}:{imports[0].lineno}: combine into one line: import {names}")
    if fix:
        if fixed_files:
            print(f"✅ Combined imports in {len(fixed_files)} file(s):")
            print("\n".join(fixed_files))
        else:
            print("✅ No combinable imports found. All good!")
        return
    if violations:
        print("❌ Error: files with multiple bare imports that should be combined onto one line!")
        print("\n".join(violations))
        sys.exit(1)
    print("✅ No combinable imports found. All good!")


if __name__ == "__main__":
    main()
