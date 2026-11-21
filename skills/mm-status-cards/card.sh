#!/usr/bin/env bash
# card.sh: render the machine lines of a status card (status-cards skill).
#
# usage: card.sh issue <number> [owner/repo]
#        card.sh pr <number> [owner/repo]
#
# Prints lines 1-3 of the card. The caller adds the final "next:" line;
# that judgment is deliberately not this script's job. The [repo] tag is
# printed only when owner/repo is passed, matching the skill's rule that
# the tag appears only in cross-repo contexts.
set -euo pipefail

usage="usage: card.sh <issue|pr> <number> [owner/repo]"
kind=${1:?$usage}
num=${2:?$usage}
repo=${3:-}

command -v jq >/dev/null || { echo "card.sh: jq required" >&2; exit 1; }

rflag=()
tag=""
if [[ -n $repo ]]; then
  rflag=(-R "$repo")
  tag="  [${repo##*/}]"
fi

case $kind in
  issue)
    gh issue view "$num" "${rflag[@]}" \
      --json number,title,labels,assignees,createdAt |
    jq -r --arg tag "$tag" '
      def age: ((now - (.createdAt | fromdate)) / 86400 | floor);
      "#\(.number)  \(.title)\($tag)",
      ([.labels[].name]
        + ["open \(age)d"]
        + [if (.assignees | length) == 0 then "unassigned"
           else (.assignees | map(.login) | join(", ")) end]
        | join(" · ")),
      "linked PR: ?"
    '
    ;;
  pr)
    gh pr view "$num" "${rflag[@]}" \
      --json number,title,isDraft,statusCheckRollup,reviewDecision,additions,deletions,changedFiles,closingIssuesReferences,updatedAt |
    jq -r --arg tag "$tag" '
      def st: (.conclusion // .status // .state // "");
      def bad: ["FAILURE","ERROR","TIMED_OUT","CANCELLED","STARTUP_FAILURE"];
      def ci:
        (.statusCheckRollup // []) as $c
        | if ($c | length) == 0 then "CI none"
          elif any($c[]; st as $s | bad | index($s)) then
            "CI red (" + ([$c[] | select(st as $s | bad | index($s))
                           | .name // .context] | unique | join(", ")) + ")"
          elif any($c[]; st as $s | ["SUCCESS","COMPLETED","NEUTRAL","SKIPPED"] | index($s) | not)
            then "CI running"
          else "CI green" end;
      def review:
        {APPROVED: "approved", CHANGES_REQUESTED: "changes requested",
         REVIEW_REQUIRED: "required"}[.reviewDecision // ""] // "none";
      def ago:
        (now - (.updatedAt | fromdate)) as $s
        | if $s < 3600 then "\(($s / 60) | floor)m ago"
          elif $s < 86400 then "\(($s / 3600) | floor)h ago"
          else "\(($s / 86400) | floor)d ago" end;
      def issueref:
        (.closingIssuesReferences // []) as $i
        | if ($i | length) == 0 then "none"
          else ($i | map("#\(.number)") | join(", ")) end;
      "#\(.number)  \(.title)\($tag)",
      ([(if .isDraft then "draft" else "ready" end), ci,
        "review: \(review)",
        "+\(.additions) -\(.deletions) · \(.changedFiles) files"]
        | join(" · ")),
      "issue: \(issueref) · updated \(ago)"
    '
    ;;
  *)
    echo "$usage" >&2
    exit 1
    ;;
esac
