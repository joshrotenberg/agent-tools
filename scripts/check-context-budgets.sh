#!/usr/bin/env bash
# check-context-budgets.sh -- warn when skills/agents approach context size thresholds.
#
# Checks:
#   1. Per-skill body size (body = lines after frontmatter closing ---)
#      WARN >= 400 lines (80% of 500-line spec guidance)
#      ERROR >= 500 lines (spec hard limit)
#   2. Per-agent body size
#      WARN >= 160 lines (80% of 200-line convention)
#      ERROR >= 200 lines
#   3. Per-agent total preloaded context
#      Parse skills: frontmatter list, sum body line counts of those skills.
#      Estimate tokens at 12 tokens/line.
#      WARN >= 1700 body lines (~20k tokens, 80% of 25k compaction budget)
#      ERROR >= 2100 body lines (~25k tokens)
#
# Exit 0 on warnings-only; exit 1 on any errors.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

warnings=0
errors=0

# Count body lines (lines after the second --- frontmatter delimiter)
body_line_count() {
    local file="$1"
    local fm_end
    # Find line number of the closing --- (second occurrence of ^---$)
    fm_end="$(grep -n "^---$" "$file" | sed -n '2p' | cut -d: -f1)"
    if [ -z "$fm_end" ]; then
        # No frontmatter end found -- treat entire file as body
        wc -l < "$file"
    else
        local total
        total="$(wc -l < "$file")"
        echo $((total - fm_end))
    fi
}

# Print a result line with padding so columns align
print_result() {
    local level="$1"  # OK, WARN, ERROR
    local msg="$2"
    printf '%-5s %s\n' "$level" "$msg"
}

# Extract the skills: list from an agent's frontmatter.
# Returns one skill name per line.
parse_skills_list() {
    local file="$1"
    # Extract frontmatter block (between first and second ---)
    local fm
    fm="$(awk '/^---$/{if(found){exit}else{found=1;next}} found{print}' "$file")"

    # Find the skills: key; then collect subsequent "  - item" lines
    # until a non-indented (or empty-after-trim) line is hit.
    printf '%s\n' "$fm" | awk '
        /^skills:/ { in_skills=1; next }
        in_skills && /^[[:space:]]*-[[:space:]]/ {
            # Extract value after "- "
            sub(/^[[:space:]]*-[[:space:]]+/, "")
            print
            next
        }
        in_skills { in_skills=0 }
    '
}

# -- 1. Per-skill body size --------------------------------------------------

SKILL_WARN=400
SKILL_ERROR=500

while IFS= read -r -d '' file; do
    rel="${file#"$REPO_ROOT/"}"
    lines="$(body_line_count "$file")"

    if [ "$lines" -ge "$SKILL_ERROR" ]; then
        print_result "ERROR" "${rel}: ${lines} body lines (error threshold: ${SKILL_ERROR})"
        errors=$((errors + 1))
    elif [ "$lines" -ge "$SKILL_WARN" ]; then
        print_result "WARN" "${rel}: ${lines} body lines (warn threshold: ${SKILL_WARN})"
        warnings=$((warnings + 1))
    else
        print_result "OK" "${rel}: ${lines} body lines"
    fi
done < <(find "$REPO_ROOT/skills" -name "SKILL.md" -print0 | sort -z)

# -- 2. Per-agent body size --------------------------------------------------

AGENT_WARN=160
AGENT_ERROR=200

while IFS= read -r -d '' file; do
    rel="${file#"$REPO_ROOT/"}"
    lines="$(body_line_count "$file")"

    if [ "$lines" -ge "$AGENT_ERROR" ]; then
        print_result "ERROR" "${rel}: ${lines} body lines (error threshold: ${AGENT_ERROR})"
        errors=$((errors + 1))
    elif [ "$lines" -ge "$AGENT_WARN" ]; then
        print_result "WARN" "${rel}: ${lines} body lines (warn threshold: ${AGENT_WARN})"
        warnings=$((warnings + 1))
    else
        print_result "OK" "${rel}: ${lines} body lines"
    fi
done < <(find "$REPO_ROOT/agents" -maxdepth 1 -name "*.md" ! -name "README.md" -print0 | sort -z)

# -- 3. Per-agent preload total ----------------------------------------------

PRELOAD_WARN=1700    # ~20k tokens at 12 tokens/line
PRELOAD_ERROR=2100   # ~25k tokens

TOKENS_PER_LINE=12

while IFS= read -r -d '' agent_file; do
    agent_name="$(basename "$agent_file" .md)"

    # Read the skills list
    skill_names=()
    while IFS= read -r skill; do
        [ -n "$skill" ] && skill_names+=("$skill")
    done < <(parse_skills_list "$agent_file")

    if [ "${#skill_names[@]}" -eq 0 ]; then
        continue
    fi

    total_body_lines=0
    for skill_name in "${skill_names[@]}"; do
        skill_file="$REPO_ROOT/skills/${skill_name}/SKILL.md"
        if [ -f "$skill_file" ]; then
            skill_lines="$(body_line_count "$skill_file")"
            total_body_lines=$((total_body_lines + skill_lines))
        fi
    done

    total_tokens=$((total_body_lines * TOKENS_PER_LINE))

    if [ "$total_body_lines" -ge "$PRELOAD_ERROR" ]; then
        print_result "ERROR" "agents/${agent_name} preload total: ~${total_tokens} tokens / ${total_body_lines} lines (error threshold: ~$((PRELOAD_ERROR * TOKENS_PER_LINE)) tokens)"
        errors=$((errors + 1))
    elif [ "$total_body_lines" -ge "$PRELOAD_WARN" ]; then
        print_result "WARN" "agents/${agent_name} preload total: ~${total_tokens} tokens / ${total_body_lines} lines (warn threshold: ~$((PRELOAD_WARN * TOKENS_PER_LINE)) tokens)"
        warnings=$((warnings + 1))
    else
        print_result "OK" "agents/${agent_name} preload total: ~${total_tokens} tokens / ${total_body_lines} lines"
    fi
done < <(find "$REPO_ROOT/agents" -maxdepth 1 -name "*.md" ! -name "README.md" -print0 | sort -z)

# -- Summary -----------------------------------------------------------------

printf -- '---\n'
printf '%d warnings, %d errors\n' "$warnings" "$errors"

if [ "$errors" -gt 0 ]; then
    exit 1
fi
exit 0
