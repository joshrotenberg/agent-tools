#!/usr/bin/env bash
# bootstrap-labels.sh -- provision the issue-pr-conventions label set into a repo.
#
# The standard is defined in skills/issue-pr-conventions/SKILL.md: four axes,
# capped. This script covers the three that are repo-independent.
#
#   priority  p1 / p2 / p3
#   status    status/in-progress / status/blocked / status/needs-review
#   size      size/small / size/medium / size/large
#   plus      field-feedback (the one sanctioned exception)
#
# The fourth axis, area/*, is repo-specific and is NOT created here. Add up to
# six by hand after running this.
#
# The script creates what is missing and leaves what already exists. It never
# deletes and never renames, so it is safe to re-run. Labels the repo carries
# beyond the standard are reported, not touched: retiring those is a judgment
# call (see "Adopting a repo that already has labels" in the skill).
#
# Usage:
#   ./scripts/bootstrap-labels.sh --repo owner/name           # report only
#   ./scripts/bootstrap-labels.sh --repo owner/name --apply   # create labels

set -euo pipefail

REPO=""
APPLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --repo) REPO="${2:-}"; shift 2 ;;
        --apply) APPLY=1; shift ;;
        -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: gh is not on PATH." >&2
    exit 1
fi

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
    if [ -z "$REPO" ]; then
        echo "ERROR: no --repo given and the cwd is not a GitHub repo." >&2
        exit 2
    fi
    echo "No --repo given, using the current repo: $REPO"
fi

# Pre-standard names for standard labels. Renaming preserves every existing
# assignment; deleting loses it. Reported as rename targets, never auto-applied.
RENAME=(
    "blocked|status/blocked"
    "no-auto-merge|status/needs-review"
    "needs-review|status/needs-review"
    "in-progress|status/in-progress"
    "wip|status/in-progress"
    "priority: p1|p1"
    "priority: p2|p2"
    "priority: p3|p3"
    "priority: high|p1"
    "priority: medium|p2"
    "priority: low|p3"
    "priority:high|p1"
    "priority:medium|p2"
    "priority:low|p3"
)

# name|color|description
STANDARD=(
    "p1|b60205|Blocking or high-impact"
    "p2|fbca04|Standard queue"
    "p3|bfd4f2|Nice-to-have / deferred"
    "status/in-progress|0e8a16|Claimed; work is underway"
    "status/blocked|f97316|Waiting on another issue or PR"
    "status/needs-review|e11d48|No auto-merge; a human decides"
    "size/small|bbf7d0|1-3 files changed"
    "size/medium|fef08a|4-10 files changed"
    "size/large|fca5a5|10+ files changed"
    "field-feedback|f9d0c4|Filed by an agent during dispatch"
)

# Labels that duplicate the conventional-commit prefix in the title. The
# taxonomy has no type axis, so these are reported as retirement candidates.
RETIRED_TYPES="feat fix docs chore ci test refactor perf enhancement bug documentation"

# GitHub stock labels. Not area candidates; prune once unused.
DEFAULTS="duplicate invalid question wontfix"

# Never applied, and never created by this script. See the skill.
NEVER="good first issue|help wanted"

echo "Repo: $REPO"
if [ "$APPLY" -eq 0 ]; then
    echo "Mode: report only (pass --apply to create labels)"
else
    echo "Mode: apply"
fi
echo

existing="$(gh label list --repo "$REPO" --limit 200 --json name -q '.[].name')"

created=0
present=0
deferred=0

echo "Standard set"
echo "------------"
for entry in "${STANDARD[@]}"; do
    IFS='|' read -r name color desc <<< "$entry"
    if printf '%s\n' "$existing" | grep -qxF "$name"; then
        echo "  ok       $name"
        present=$((present + 1))
        continue
    fi
    # A pending rename will produce this name. Creating it now makes the
    # rename collide, and the rename is what preserves existing assignments.
    pending=""
    for entry in "${RENAME[@]}"; do
        [ "${entry##*|}" = "$name" ] || continue
        printf '%s\n' "$existing" | grep -qxF "${entry%%|*}" || continue
        pending="${entry%%|*}"
        break
    done
    if [ -n "$pending" ]; then
        echo "  defer    $name (rename \"$pending\" into it instead)"
        deferred=$((deferred + 1))
        continue
    fi

    if [ "$APPLY" -eq 1 ]; then
        if gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" >/dev/null 2>&1; then
            echo "  created  $name"
            created=$((created + 1))
        else
            echo "  FAILED   $name" >&2
        fi
    else
        echo "  missing  $name"
        created=$((created + 1))
    fi
done

echo
echo "Beyond the standard"
echo "-------------------"
extra=0
retire=0
rename=0
while IFS= read -r name; do
    [ -z "$name" ] && continue

    # Already part of the standard set?
    skip=0
    for entry in "${STANDARD[@]}"; do
        [ "${entry%%|*}" = "$name" ] && skip=1 && break
    done
    [ "$skip" -eq 1 ] && continue

    # Repo-defined area labels are expected.
    case "$name" in
        area/*) echo "  area     $name"; extra=$((extra + 1)); continue ;;
        autorelease:*|dependencies|release) echo "  tooling  $name"; continue ;;
    esac

    if printf '%s\n' "$NEVER" | tr '|' '\n' | grep -qxF "$name"; then
        echo "  NEVER    $name (never apply; delete only if unused)"
        continue
    fi

    target=""
    for entry in "${RENAME[@]}"; do
        [ "${entry%%|*}" = "$name" ] && target="${entry##*|}" && break
    done
    if [ -n "$target" ]; then
        echo "  rename   $name -> $target"
        rename=$((rename + 1))
        continue
    fi

    if printf '%s ' $RETIRED_TYPES | grep -qw -- "$name"; then
        echo "  retire   $name (type is in the title prefix)"
        retire=$((retire + 1))
        continue
    fi

    if printf '%s ' $DEFAULTS | grep -qw -- "$name"; then
        echo "  default  $name (GitHub stock; prune once unused)"
        continue
    fi

    echo "  review   $name (collapse into an area/* label, or drop)"
    extra=$((extra + 1))
done <<< "$existing"

area_count="$(printf '%s\n' "$existing" | grep -c '^area/' || true)"

echo
echo "Summary"
echo "-------"
if [ "$APPLY" -eq 1 ]; then
    echo "  standard labels created:  $created"
else
    echo "  standard labels missing:  $created"
fi
echo "  standard labels present:  $present"
echo "  deferred to a rename:     $deferred"
echo "  labels to rename:         $rename"
echo "  type labels to retire:    $retire"
echo "  area/* labels defined:    $area_count (cap 6)"

if [ "$rename" -gt 0 ]; then
    echo
    echo "Rename before relabeling; renaming preserves existing assignments:"
    for entry in "${RENAME[@]}"; do
        from="${entry%%|*}"; to="${entry##*|}"
        printf '%s\n' "$existing" | grep -qxF "$from" || continue
        echo "  gh label edit \"$from\" --repo $REPO --name \"$to\""
    done
fi

if [ "$area_count" -gt 6 ]; then
    echo
    echo "WARN: $area_count area labels exceeds the cap of 6. Collapse the set."
fi

if [ "$area_count" -eq 0 ]; then
    echo
    echo "No area/* labels yet. Add up to six, for example:"
    echo "  gh label create \"area/cli\" --repo $REPO --color 1d76db --description \"Where the change lands\""
fi

if [ "$deferred" -gt 0 ]; then
    echo
    echo "Run the renames above before --apply; $deferred standard label(s) are"
    echo "deferred so the rename can carry its existing assignments over."
fi

if [ "$APPLY" -eq 0 ] && [ "$created" -gt 0 ]; then
    echo
    echo "Re-run with --apply to create the $created missing label(s)."
fi
