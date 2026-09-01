#!/usr/bin/env python3
"""Cascade merge: merge SOURCE_BRANCH into every other remote branch.

On success: push the merged branch.
On conflict: abort, then open a GitHub issue listing the conflicting files
             and assign it to whoever made the last commit on the target branch.
"""

import json, os, subprocess, sys, urllib.error, urllib.request
from datetime import datetime, timezone

SKIP_BRANCHES = {"main", "HEAD", "staging"}


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)


def run_check(cmd):
    r = run(cmd)
    if r.returncode != 0:
        print(r.stderr, file=sys.stderr)
        sys.exit(1)
    return r.stdout.strip()


def gh_api_get(path, token):
    req = urllib.request.Request(
        f"https://api.github.com{path}",
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
        },
    )
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError:
        return {}


def gh_api_post(path, token, payload):
    req = urllib.request.Request(
        f"https://api.github.com{path}",
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError:
        return {}


def ensure_label(token, repo):
    gh_api_post(
        f"/repos/{repo}/labels",
        token,
        {
            "name": "merge-conflict",
            "color": "e11d48",
            "description": "Cascade merge conflict requiring manual resolution",
        },
    )


def get_login_for_sha(sha, token, repo):
    data = gh_api_get(f"/repos/{repo}/commits/{sha}", token)
    return (data.get("author") or {}).get("login", "")


def open_conflict_issue(source, branch, conflicting, trigger_sha, token, repo, run_id, server_url):
    short_sha = trigger_sha[:7]
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    last_sha = run(["git", "log", "-1", "--format=%H", f"origin/{branch}"]).stdout.strip()
    login = get_login_for_sha(last_sha, token, repo)

    rows = "\n".join(f"| `{path}` | {ctype} |" for path, ctype in conflicting)
    conflict_table = f"| File | Conflict |\n|------|----------|\n{rows}"

    resolve_block = f"""```bash
git fetch origin
git checkout {branch}
git merge origin/{source}
# resolve the files listed above, then:
git add .
git commit
git push
```"""

    body = f"""## Cascade Merge Conflict: `{source}` → `{branch}`

A push to `{source}` triggered an automatic cascade merge into `{branch}`, \
but merge conflicts were detected. Manual resolution is required.

### Conflicting Files

{conflict_table}

### How to Resolve

{resolve_block}

### Details

| | |
|---|---|
| **Source branch** | `{source}` |
| **Target branch** | `{branch}` |
| **Trigger commit** | [`{short_sha}`]({server_url}/{repo}/commit/{trigger_sha}) |
| **Attempted at** | {now} |
| **Workflow run** | [View logs]({server_url}/{repo}/actions/runs/{run_id}) |
"""

    title = f"Merge conflict: `{source}` → `{branch}` ({short_sha})"
    assignees = [login] if login else []
    result = gh_api_post(
        f"/repos/{repo}/issues",
        token,
        {
            "title": title,
            "body": body,
            "assignees": assignees,
            "labels": ["merge-conflict"],
        },
    )
    url = result.get("html_url", "(unknown)")
    print(f"  ✗ Conflict — issue opened: {url}")
    if assignees:
        print(f"     Assigned to: {', '.join(assignees)}")


CONFLICT_TYPE = {
    "UU": "Both modified",
    "AA": "Added by both",
    "DD": "Deleted by both",
    "AU": "Added by us, deleted upstream",
    "UA": "Deleted by us, added upstream",
    "DU": "Deleted by us, modified upstream",
    "UD": "Modified by us, deleted upstream",
}


def collect_conflicts():
    status = run(["git", "status", "--porcelain"]).stdout.splitlines()
    result = []
    for line in status:
        if len(line) < 4:
            continue
        xy = line[:2]
        path = line[3:]
        if "U" in xy or xy in ("AA", "DD"):
            result.append((path, CONFLICT_TYPE.get(xy, xy)))
    return result


def main():
    source = os.environ["SOURCE_BRANCH"]
    token = os.environ["GH_TOKEN"]
    repo = os.environ["GITHUB_REPOSITORY"]
    server_url = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
    run_id = os.environ.get("GITHUB_RUN_ID", "")

    run_check(["git", "config", "user.name", "github-actions[bot]"])
    run_check(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"])
    run_check(["git", "fetch", "--all", "--prune"])

    raw = run(["git", "branch", "-r", "--format=%(refname:short)"]).stdout.splitlines()
    branches = []
    for b in raw:
        b = b.strip()
        if not b.startswith("origin/"):
            continue
        name = b[len("origin/") :]
        if name in SKIP_BRANCHES or name == source or name.endswith("/HEAD"):
            continue
        branches.append(name)

    if not branches:
        print("No branches to cascade into.")
        return

    ensure_label(token, repo)
    push_url = f"https://x-access-token:{token}@github.com/{repo}.git"
    trigger_sha = run(["git", "log", "-1", "--format=%H", f"origin/{source}"]).stdout.strip()

    for branch in branches:
        print(f"\n{'=' * 60}\nCascade: {source} → {branch}")

        # Skip if source is already an ancestor of branch
        if (
            run(
                [
                    "git",
                    "merge-base",
                    "--is-ancestor",
                    f"origin/{source}",
                    f"origin/{branch}",
                ]
            ).returncode
            == 0
        ):
            print("  ✓ Already up to date, skipping.")
            continue

        # Reset local branch to remote state
        run_check(["git", "checkout", "-B", branch, f"origin/{branch}"])

        merge = run(
            [
                "git",
                "merge",
                "--no-ff",
                f"origin/{source}",
                "-m",
                f"chore: cascade merge {source} into {branch}",
            ]
        )

        if merge.returncode == 0:
            push = run(["git", "push", push_url, branch])
            if push.returncode == 0:
                print("  ✓ Merged and pushed.")
            else:
                print(f"  ✗ Push failed: {push.stderr[:300]}")
            continue

        conflicting = collect_conflicts()
        run(["git", "merge", "--abort"])

        open_conflict_issue(source, branch, conflicting, trigger_sha, token, repo, run_id, server_url)


if __name__ == "__main__":
    main()
