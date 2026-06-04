#!/usr/bin/env bash
set -euo pipefail

# install.sh -- copies skills and agents into Claude Code's discovery dirs.
#
# Default destination: ~/.claude/skills/ and ~/.claude/agents/
# Override with --to PATH (applies to both; expects PATH/skills/ and PATH/agents/).
#
# By default, prompts before overwriting an existing entry on a TTY,
# skips silently with no TTY. --force overwrites without prompting.
# --skip skips without prompting.

DEST_BASE="${HOME}/.claude"
FORCE=0
SKIP=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --to)
            DEST_BASE="$2"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --skip)
            SKIP=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST_SKILLS="$DEST_BASE/skills"
DEST_AGENTS="$DEST_BASE/agents"

# Install one entry (a skill directory or an agent .md file) into dest_dir,
# honoring FORCE / SKIP / DRY_RUN.
install_entry() {
    local entry="$1"
    local dest_dir="$2"
    local kind_label="$3"
    local name target action
    name="$(basename "$entry")"
    target="$dest_dir/$name"

    if [[ -e "$target" ]]; then
        if [[ $FORCE -eq 1 ]]; then
            action="overwrite"
        elif [[ $SKIP -eq 1 ]]; then
            action="skip"
        elif [[ -t 0 ]]; then
            read -r -p "$kind_label '$name' exists. Overwrite? [y/N] " ans
            case "$ans" in
                y|Y|yes) action="overwrite" ;;
                *)       action="skip" ;;
            esac
        else
            action="skip"
        fi
    else
        action="install"
    fi

    case "$action" in
        install|overwrite)
            if [[ $DRY_RUN -eq 1 ]]; then
                echo "would $action $kind_label/$name -> $target"
            else
                rm -rf "$target"
                cp -R "$entry" "$target"
                echo "$action $kind_label/$name -> $target"
            fi
            ;;
        skip)
            echo "skip $kind_label/$name (already present)"
            ;;
    esac
}

# Skills are directories: skills/<name>/SKILL.md
install_skills() {
    local src_dir="$1" dest_dir="$2"
    [[ -d "$src_dir" ]] || return 0
    mkdir -p "$dest_dir"
    for entry in "$src_dir"/*/; do
        [[ -d "$entry" ]] || continue
        install_entry "$entry" "$dest_dir" skill
    done
}

# Agents are flat files: agents/<name>.md (README.md is not an agent).
install_agents() {
    local src_dir="$1" dest_dir="$2"
    [[ -d "$src_dir" ]] || return 0
    mkdir -p "$dest_dir"
    for entry in "$src_dir"/*.md; do
        [[ -f "$entry" ]] || continue
        if [[ "$(basename "$entry")" == "README.md" ]]; then
            continue
        fi
        install_entry "$entry" "$dest_dir" agent
    done
}

install_skills "$REPO_ROOT/skills" "$DEST_SKILLS"
install_agents "$REPO_ROOT/agents" "$DEST_AGENTS"
