#!/usr/bin/env bash
# validate-frontmatter.sh -- check SKILL.md and AGENT.md files for spec compliance.
#
# Rules per file:
#   0. Frontmatter parses as valid YAML (real parse via PyYAML or Ruby)
#   1. YAML frontmatter is present (file starts with --- on line 1)
#   2. name: field is present and non-empty
#   3. name: value matches parent directory name exactly
#   4. description: field is present and non-empty
#   5. description: value is under 1024 chars

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

checked=0
passed=0
failed=0

# A real YAML parse catches invalid frontmatter the regex checks miss (e.g. an
# unquoted ": " in a description, which drops all metadata at load time). Uses
# PyYAML if present, else Ruby's stdlib psych -- no install needed, and both are
# present on ubuntu-latest CI. Skipped with a warning only if neither is found.
yaml_parser=""
if python3 -c "import yaml" 2>/dev/null; then
    yaml_parser="python"
elif command -v ruby >/dev/null 2>&1; then
    yaml_parser="ruby"
else
    echo "WARN: no YAML parser (python3+PyYAML or ruby) -- skipping YAML-syntax check."
fi

# Reads a YAML document on stdin; exits non-zero if it does not parse.
yaml_parses() {
    case "$yaml_parser" in
        python) python3 -c "import sys, yaml; yaml.safe_load(sys.stdin.read())" ;;
        ruby)   ruby -ryaml -e "YAML.safe_load(STDIN.read)" ;;
        *)      return 0 ;;
    esac
}

check_file() {
    local file="$1"
    local expected_name="$2"
    local errors=()

    # 1. Frontmatter must be present (line 1 must be exactly ---)
    local first_line
    first_line="$(head -n 1 "$file")"
    if [ "$first_line" != "---" ]; then
        errors+=("  [frontmatter] file does not start with --- (got: ${first_line})")
    else
        # Extract the frontmatter block (between the first and second ---)
        local fm
        fm="$(awk '/^---$/{if(found){exit}else{found=1;next}} found{print}' "$file")"

        # 0. Frontmatter must parse as valid YAML (real parse, not just regex)
        if ! printf '%s\n' "$fm" | yaml_parses 2>/dev/null; then
            errors+=("  [yaml] frontmatter is not valid YAML (parse failed)")
        fi

        # 2. name: field present and non-empty
        local name_line
        name_line="$(printf '%s\n' "$fm" | grep -E '^name:[[:space:]]*' | head -n 1 || true)"
        if [ -z "$name_line" ]; then
            errors+=("  [name] field is missing")
        else
            local name_value
            name_value="$(printf '%s\n' "$name_line" | sed 's/^name:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
            if [ -z "$name_value" ]; then
                errors+=("  [name] field is present but empty")
            else
                # 3. name: must match expected (skill dir name / agent file stem)
                if [ "$name_value" != "$expected_name" ]; then
                    errors+=("  [name] value '${name_value}' does not match expected name '${expected_name}'")
                fi
            fi
        fi

        # 4. description: field present and non-empty
        local desc_line
        desc_line="$(printf '%s\n' "$fm" | grep -E '^description:[[:space:]]*' | head -n 1 || true)"
        if [ -z "$desc_line" ]; then
            errors+=("  [description] field is missing")
        else
            local desc_value
            desc_value="$(printf '%s\n' "$desc_line" | sed 's/^description:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
            if [ -z "$desc_value" ]; then
                errors+=("  [description] field is present but empty")
            else
                # 5. description under 1024 chars
                local desc_len
                desc_len="${#desc_value}"
                if [ "$desc_len" -ge 1024 ]; then
                    errors+=("  [description] value is ${desc_len} chars (max 1023)")
                fi
            fi
        fi
    fi

    checked=$((checked + 1))

    if [ "${#errors[@]}" -gt 0 ]; then
        failed=$((failed + 1))
        printf 'FAIL %s\n' "$file"
        for err in "${errors[@]}"; do
            printf '%s\n' "$err"
        done
    else
        passed=$((passed + 1))
        printf 'ok   %s\n' "$file"
    fi
}

# Collect files
while IFS= read -r -d '' file; do
    check_file "$file" "$(basename "$(dirname "$file")")"
done < <(find "$REPO_ROOT/skills" -name "SKILL.md" -print0 | sort -z)

while IFS= read -r -d '' file; do
    check_file "$file" "$(basename "$file" .md)"
done < <(find "$REPO_ROOT/agents" -maxdepth 1 -name "*.md" ! -name "README.md" -print0 | sort -z)

printf '\n%d files checked, %d passed, %d failed.\n' "$checked" "$passed" "$failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
