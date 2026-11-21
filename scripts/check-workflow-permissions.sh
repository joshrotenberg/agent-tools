#!/usr/bin/env bash
# check-workflow-permissions.sh -- require a top-level `permissions:` block in
# every GitHub Actions workflow.
#
# Without an explicit block, workflows inherit the repo's default GITHUB_TOKEN
# scope, which is broader than needed for read-only CI. Job-level permissions
# do not satisfy this check: the top-level block is the least-privilege
# baseline, and per-job overrides can still narrow further where required.
#
# A workflow passes if a line matching `^permissions:` exists before the first
# `jobs:` key at column 0.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKFLOWS_DIR="$REPO_ROOT/.github/workflows"

checked=0
passed=0
failed=0

shopt -s nullglob
for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    checked=$((checked + 1))
    if awk '
        /^jobs:/ { exit }
        /^permissions:/ { found=1; exit }
        END { exit(found ? 0 : 1) }
    ' "$file"; then
        passed=$((passed + 1))
        printf 'ok   %s\n' "$(basename "$file")"
    else
        failed=$((failed + 1))
        printf 'FAIL %s -- no top-level permissions: block\n' "$(basename "$file")"
    fi
done

printf '\n%d workflows checked, %d passed, %d failed.\n' "$checked" "$passed" "$failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
