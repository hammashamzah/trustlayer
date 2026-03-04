#!/bin/bash
# TrustLayer Uninstaller
#
# Two modes:
#   bash uninstall.sh              → remove global (skills, agents from ~/.claude/)
#   bash uninstall.sh /path/to/app → remove from project (hook, config, workflows)
#
set -euo pipefail

SKILLS=(spec-init spec-context spec-write spec-decompose spec-freeze spec-build spec-review spec-break spec-pipeline spec-status spec-setup spec-doctor morning)
AGENTS=(spec-builder spec-reviewer spec-breaker)

uninstall_global() {
  echo "Removing TrustLayer from ~/.claude/ ..."

  for agent in "${AGENTS[@]}"; do
    rm -f ~/.claude/agents/"$agent".md
  done
  echo "  Agents: removed"

  for skill in "${SKILLS[@]}"; do
    rm -rf ~/.claude/skills/"$skill"
  done
  echo "  Skills: removed"

  rm -rf ~/.claude/trustlayer/templates
  echo "  Templates: removed"

  echo ""
  echo "Global uninstall complete."
  echo "Per-project files (hooks, specs, tests) are untouched."
}

uninstall_project() {
  TARGET="$(cd "$1" && pwd)"
  echo "Removing TrustLayer from project: $TARGET"

  # Remove hook
  rm -f "$TARGET/.claude/hooks/trustlayer-post-edit.sh"
  echo "  Hook: removed"

  # Remove hook registration from settings.json
  SETTINGS="$TARGET/.claude/settings.json"
  if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
    jq '.hooks.PostToolUse = [.hooks.PostToolUse[]? | select(.hooks[]?.command | test("trustlayer") | not)]' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "  Hook registration: removed from settings.json"
  fi

  # Remove trustlayer config (NOT reviews or breaker reports — that's your work)
  rm -rf "$TARGET/.claude/trustlayer"
  rm -f "$TARGET/.claude/current-task-scope.json"
  echo "  Config: removed"

  # Remove workflows
  rm -f "$TARGET/.github/workflows/trustlayer-ci.yml"
  rm -f "$TARGET/.github/workflows/trustlayer-preview.yml"
  echo "  GitHub Actions: removed"

  echo ""
  echo "Project uninstall complete."
  echo "Preserved: specs/, tests/, .claude/reviews/, .claude/breaker-reports/"
}

if [ $# -eq 0 ] || [ "${1:-}" = "global" ]; then
  uninstall_global
elif [ -d "$1" ]; then
  uninstall_project "$1"
else
  echo "Error: '$1' is not a directory"
  echo ""
  echo "Usage:"
  echo "  bash uninstall.sh              # remove global install"
  echo "  bash uninstall.sh /path/to/app # remove from project"
  exit 1
fi
