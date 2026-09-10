#!/usr/bin/env bash
# Runs zizmor with online audits, requiring a GitHub token instead of
# silently degrading to offline-only audits like the plain zizmor tox env
# does. Prefers GH_PAT, falling back to GH_TOKEN (same GH_PAT || github.token
# shape used in .github/workflows/cascade-merge.yml) since GH_PAT isn't
# subject to the default token's tighter cross-repo API limits. zizmor
# itself only reads GH_TOKEN, not GH_PAT, so GH_PAT is passed through as
# GH_TOKEN. Also sources a local .env file (gitignored) if present, so the
# token doesn't need to be exported in the shell for local runs.
set -e

if [[ -f .env ]]; then
    set -a
    # shellcheck disable=SC1091
    source ./.env
    set +a
fi

TOKEN="${GH_PAT:-$GH_TOKEN}"
if [[ -z "$TOKEN" ]]; then
    echo "zizmor-online requires GH_PAT or GH_TOKEN to be set (env var or .env)" >&2
    exit 1
fi

GH_TOKEN="$TOKEN" zizmor .
