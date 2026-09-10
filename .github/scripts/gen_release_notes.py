"""Render GitHub release notes from a `git-cliff --context` JSON dump.

git-cliff splits a commit range into a separate "release" chunk at every merge
commit (this repo's cascade-merge automation creates one on nearly every dev/main
sync), which produces duplicate category headers when using git-cliff's own Jinja
body template. This script flattens all commits across those chunks and does the
grouping/rendering itself instead, reusing the same `group` value that git-cliff's
[tool.git-cliff.git] commit_parsers (in pyproject.toml) already assigned to each
commit, so the category taxonomy stays defined in exactly one place.

Usage: python3 gen_release_notes.py <context.json>
Requires GITHUB_REPOSITORY in the environment (set automatically by Actions).
"""

import json, os, sys

# Keep in sync with pyproject.toml's [tool.git-cliff.git] commit_parsers order.
CATEGORY_ORDER = [
    "✨ Features",
    "🐛 Bug Fixes",
    "📚 Documentation",
    "♻️ Refactoring",
    "🧪 Tests",
    "⚡ Performance",
    "🔧 Chores",
    "📝 Changes",
]

context_path = sys.argv[1]
repo = os.environ["GITHUB_REPOSITORY"]

with open(context_path) as f:
    releases = json.load(f)

commits = [commit for release in releases for commit in (release.get("commits") or []) if not commit.get("merge_commit")]

by_group = {}
for commit in commits:
    by_group.setdefault(commit["group"], []).append(commit)

for commits_in_group in by_group.values():
    commits_in_group.sort(key=lambda c: c["author"]["timestamp"], reverse=True)

order = [g for g in CATEGORY_ORDER if g in by_group]
order += [g for g in by_group if g not in order]

lines = []
for group in order:
    lines.append(f"### {group}")
    lines.append("")
    for commit in by_group[group]:
        message = commit["message"].strip()
        if message:
            message = message[0].upper() + message[1:]
        short_sha = commit["id"][:7]

        github = commit.get("github") or {}
        username = github.get("username")
        pr_number = github.get("pr_number")
        if username:
            attribution = f"by @{username}"
            if pr_number:
                attribution += f" in #{pr_number}"
        else:
            attribution = f"by {commit['author']['name']}"

        lines.append(f"- {message} {attribution} ([`{short_sha}`](https://github.com/{repo}/commit/{commit['id']}))")
    lines.append("")

print("\n".join(lines).rstrip() + "\n")
