#!/usr/bin/env bash
# count-tokens.sh -- Count exact tokens for all skills and agents using
# the Anthropic count_tokens API (POST /v1/messages/count_tokens).
#
# This script costs API credits; run it on a schedule or manually, not on
# every push. See .github/workflows/token-budget.yml for the scheduled job.
#
# Thresholds:
#   Per-skill body:          WARN >= 4000 tokens, ERROR >= 5000 tokens
#   Per-agent body:          WARN >= 2500 tokens, ERROR >= 3000 tokens
#   Per-agent preload total: WARN >= 20000 tokens, ERROR >= 25000 tokens
#
# Writes a markdown table to $GITHUB_STEP_SUMMARY (if set).
# Also prints the table to stdout for local runs.
# Exits 0 on warnings-only; exits 1 on any errors.
#
# Requires: ANTHROPIC_API_KEY env var, curl, jq

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL="claude-3-5-sonnet-20241022"
API_URL="https://api.anthropic.com/v1/messages/count_tokens"

# -- Validate prerequisites --------------------------------------------------

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo "ERROR: ANTHROPIC_API_KEY env var is required but not set." >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required but not found in PATH." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not found in PATH." >&2
    exit 1
fi

warnings=0
errors=0

# Associative array: absolute file path -> token count (avoids duplicate API calls)
declare -A token_cache

# Collected table rows for deferred write to GITHUB_STEP_SUMMARY
table_rows=()

# -- Helpers -----------------------------------------------------------------

# Count tokens for a file by calling the Anthropic count_tokens API.
# Prints the integer token count to stdout.
count_tokens() {
    local file="$1"

    local raw http_code response
    raw="$(
        jq -n \
            --arg model "$MODEL" \
            --rawfile content "$file" \
            '{model: $model, messages: [{role: "user", content: $content}]}' \
        | curl --silent \
            -w "\n%{http_code}" \
            -X POST "$API_URL" \
            -H "x-api-key: ${ANTHROPIC_API_KEY}" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -H "anthropic-beta: token-counting-2024-11-01" \
            --data @-
    )"
    http_code="$(printf '%s' "$raw" | tail -1)"
    response="$(printf '%s' "$raw" | head -n -1)"

    if [ "$http_code" != "200" ]; then
        # API unavailable (quota, model access, key tier) -- fall back to line-count estimate
        if [ "${API_WARNED:-}" != "1" ]; then
            printf 'WARN: API returned HTTP %s -- falling back to line-count estimates (~12 tokens/line)\n' "$http_code" >&2
            printf 'WARN: Response: %s\n' "$response" >&2
            printf 'WARN: (subsequent API errors suppressed)\n' >&2
            API_WARNED=1
            export API_WARNED
        fi
        local lines
        lines="$(wc -l < "$file")"
        printf '%s' "$((lines * 12))"
        return
    fi

    local tokens
    tokens="$(printf '%s' "$response" | jq '.input_tokens')"
    if [ -z "$tokens" ] || [ "$tokens" = "null" ]; then
        local lines
        lines="$(wc -l < "$file")"
        printf '%s' "$((lines * 12))"
        return
    fi
    printf '%s' "$tokens"
}

# Format an integer with comma separators (e.g. 12345 -> 12,345).
# Handles negative numbers for cases where headroom goes below zero.
format_number() {
    local n="$1"
    local sign=""
    if [ "$n" -lt 0 ]; then
        sign="-"
        n=$((-n))
    fi
    local result=""
    local i=0
    while [ "$n" -gt 0 ]; do
        if [ "$i" -gt 0 ] && [ "$((i % 3))" -eq 0 ]; then
            result=",${result}"
        fi
        result="$((n % 10))${result}"
        n=$((n / 10))
        i=$((i + 1))
    done
    printf '%s' "${sign}${result:-0}"
}

# Record a result row: append to table_rows and print to stdout immediately.
add_row() {
    local label="$1"
    local tokens="$2"
    local status="$3"
    local formatted
    formatted="$(format_number "$tokens")"
    local row="| ${label} | ${formatted} | ${status} |"
    table_rows+=("$row")
    printf '%s\n' "$row"
}

# Extract the skills: list from an agent's frontmatter.
# Returns one skill name per line.
parse_skills_list() {
    local file="$1"
    local fm
    fm="$(awk '/^---$/{if(found){exit}else{found=1;next}} found{print}' "$file")"

    printf '%s\n' "$fm" | awk '
        /^skills:/ { in_skills=1; next }
        in_skills && /^[[:space:]]*-[[:space:]]/ {
            sub(/^[[:space:]]*-[[:space:]]+/, "")
            print
            next
        }
        in_skills { in_skills=0 }
    '
}

# -- Thresholds --------------------------------------------------------------

SKILL_WARN=4000
SKILL_ERROR=5000

AGENT_WARN=2500
AGENT_ERROR=3000

PRELOAD_WARN=20000
PRELOAD_ERROR=25000

# -- Table header (stdout) ---------------------------------------------------

DATE="$(date -u '+%Y-%m-%d')"

printf '## Token Budget Report -- %s\n\n' "$DATE"
printf '| File | Tokens | Status |\n'
printf '|---|---|---|\n'

# -- 1. Per-skill token count ------------------------------------------------

while IFS= read -r -d '' file; do
    skill_dir="$(basename "$(dirname "$file")")"
    label="skills/${skill_dir}"

    tokens="$(count_tokens "$file")"
    token_cache["$file"]="$tokens"

    if [ "$tokens" -ge "$SKILL_ERROR" ]; then
        add_row "$label" "$tokens" "ERROR (>= ${SKILL_ERROR})"
        errors=$((errors + 1))
    elif [ "$tokens" -ge "$SKILL_WARN" ]; then
        add_row "$label" "$tokens" "WARN (>= ${SKILL_WARN})"
        warnings=$((warnings + 1))
    else
        add_row "$label" "$tokens" "OK"
    fi
done < <(find "$REPO_ROOT/skills" -name "SKILL.md" -print0 | sort -z)

# -- 2. Per-agent body token count -------------------------------------------

while IFS= read -r -d '' file; do
    agent_name="$(basename "$file" .md)"
    label="agents/${agent_name}"

    tokens="$(count_tokens "$file")"
    token_cache["$file"]="$tokens"

    if [ "$tokens" -ge "$AGENT_ERROR" ]; then
        add_row "$label" "$tokens" "ERROR (>= ${AGENT_ERROR})"
        errors=$((errors + 1))
    elif [ "$tokens" -ge "$AGENT_WARN" ]; then
        add_row "$label" "$tokens" "WARN (>= ${AGENT_WARN})"
        warnings=$((warnings + 1))
    else
        add_row "$label" "$tokens" "OK"
    fi
done < <(find "$REPO_ROOT/agents" -maxdepth 1 -name "*.md" ! -name "README.md" -print0 | sort -z)

# -- 3. Per-agent preload totals ---------------------------------------------

max_preload=0

while IFS= read -r -d '' agent_file; do
    agent_name="$(basename "$agent_file" .md)"

    skill_names=()
    while IFS= read -r skill; do
        [ -n "$skill" ] && skill_names+=("$skill")
    done < <(parse_skills_list "$agent_file")

    if [ "${#skill_names[@]}" -eq 0 ]; then
        continue
    fi

    total_tokens=0
    for skill_name in "${skill_names[@]}"; do
        skill_file="$REPO_ROOT/skills/${skill_name}/SKILL.md"
        if [ -f "$skill_file" ]; then
            if [ -n "${token_cache["$skill_file"]:-}" ]; then
                skill_tokens="${token_cache["$skill_file"]}"
            else
                skill_tokens="$(count_tokens "$skill_file")"
                token_cache["$skill_file"]="$skill_tokens"
            fi
            total_tokens=$((total_tokens + skill_tokens))
        fi
    done

    label="agents/${agent_name} preload total"

    if [ "$total_tokens" -ge "$PRELOAD_ERROR" ]; then
        add_row "$label" "$total_tokens" "ERROR (>= ${PRELOAD_ERROR})"
        errors=$((errors + 1))
    elif [ "$total_tokens" -ge "$PRELOAD_WARN" ]; then
        add_row "$label" "$total_tokens" "WARN (>= ${PRELOAD_WARN})"
        warnings=$((warnings + 1))
    else
        add_row "$label" "$total_tokens" "OK"
    fi

    if [ "$total_tokens" -gt "$max_preload" ]; then
        max_preload=$total_tokens
    fi
done < <(find "$REPO_ROOT/agents" -maxdepth 1 -name "*.md" ! -name "README.md" -print0 | sort -z)

# -- Summary -----------------------------------------------------------------

headroom=$((PRELOAD_ERROR - max_preload))

printf '\n%d warnings, %d errors. Budget headroom: %s tokens.\n' \
    "$warnings" "$errors" "$(format_number "$headroom")"

# -- Write to $GITHUB_STEP_SUMMARY -------------------------------------------

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    {
        printf '## Token Budget Report -- %s\n\n' "$DATE"
        printf '| File | Tokens | Status |\n'
        printf '|---|---|---|\n'
        for row in "${table_rows[@]}"; do
            printf '%s\n' "$row"
        done
        printf '\n%d warnings, %d errors. Budget headroom: %s tokens.\n' \
            "$warnings" "$errors" "$(format_number "$headroom")"
    } >> "$GITHUB_STEP_SUMMARY"
fi

# -- Exit --------------------------------------------------------------------

if [ "$errors" -gt 0 ]; then
    exit 1
fi
exit 0
