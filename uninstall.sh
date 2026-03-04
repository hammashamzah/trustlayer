#!/bin/bash
# TrustLayer Uninstaller
set -euo pipefail

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

echo "Uninstalling TrustLayer from: $TARGET"

# Remove agents
rm -f "$TARGET/.claude/agents/spec-builder.md"
rm -f "$TARGET/.claude/agents/spec-reviewer.md"
rm -f "$TARGET/.claude/agents/spec-breaker.md"

# Remove skills
for skill in spec-init spec-context spec-write spec-decompose spec-freeze spec-build spec-review spec-break spec-pipeline spec-status; do
  rm -rf "$TARGET/.claude/skills/$skill"
done

# Remove hooks
rm -f "$TARGET/.claude/hooks/trustlayer-post-edit.sh"

# Remove trustlayer config
rm -rf "$TARGET/.claude/trustlayer"

# Remove workflows
rm -f "$TARGET/.github/workflows/trustlayer-ci.yml"
rm -f "$TARGET/.github/workflows/trustlayer-preview.yml"

# Note: NOT removing specs/, tests/spec-generated/, tests/red-team/,
# .claude/reviews/, .claude/breaker-reports/ — those contain your work

echo "TrustLayer uninstalled. Specs and test files preserved."
