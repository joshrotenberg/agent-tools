#!/usr/bin/env bash
# smoke.sh -- smoke tests for dispatcher and runner agents
#
# Runs minimal prompts against live Claude to verify each agent loads and
# produces a coherent response.
#
# Usage: ./tests/smoke.sh
#
# NOTE: This script calls live Claude and costs real tokens.
#       It is NOT wired to CI; run it explicitly as a developer sanity check.
#       Requires the claude CLI to be installed and authenticated.

set -euo pipefail

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------

if ! command -v claude &>/dev/null; then
    echo "ERROR: claude CLI not found. Install it before running smoke tests."
    exit 1
fi

if ! claude --version &>/dev/null; then
    echo "ERROR: claude --version failed. The CLI may be broken or not on PATH."
    exit 1
fi

if ! claude config list &>/dev/null; then
    echo "ERROR: claude config list failed -- you may not be authenticated."
    echo "Run: claude auth login"
    exit 1
fi

# ---------------------------------------------------------------------------
# Test harness
# ---------------------------------------------------------------------------

PASS=0
FAIL=0

run_test() {
    local agent="$1"
    local prompt="$2"

    local output
    local exit_code=0

    output=$(echo "$prompt" | claude -p --agent "$agent" --print 2>&1) || exit_code=$?

    if [ "$exit_code" -ne 0 ]; then
        echo "[FAIL] $agent: claude exited with code $exit_code"
        FAIL=$((FAIL + 1))
        return
    fi

    if [ -z "$output" ]; then
        echo "[FAIL] $agent: response was empty"
        FAIL=$((FAIL + 1))
        return
    fi

    local length=${#output}
    if [ "$length" -le 50 ]; then
        echo "[FAIL] $agent: response too short (${length} chars)"
        FAIL=$((FAIL + 1))
        return
    fi

    echo "[PASS] $agent"
    PASS=$((PASS + 1))
}

# ---------------------------------------------------------------------------
# Test 1: dispatcher smoke
# ---------------------------------------------------------------------------

run_test "dispatcher" \
    "What context would you gather before dispatching work on a directive to implement a small new feature?"

# ---------------------------------------------------------------------------
# Test 2: runner smoke
# ---------------------------------------------------------------------------

run_test "runner" \
    "What are the first three steps you would take when dispatched to implement issue #99?"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

TOTAL=$((PASS + FAIL))
echo ""
echo "${PASS}/${TOTAL} tests passed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0
