#!/bin/bash
# TrustLayer Installer
# Usage: bash ~/Projects/trustlayer/install.sh [target-project-dir]
set -euo pipefail

TRUSTLAYER_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

echo "Installing TrustLayer into: $TARGET"

# 1. Create directories
mkdir -p "$TARGET/specs/evals"
mkdir -p "$TARGET/.claude/trustlayer"
mkdir -p "$TARGET/.claude/reviews"
mkdir -p "$TARGET/.claude/breaker-reports"
mkdir -p "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude/skills"
mkdir -p "$TARGET/.claude/hooks"
mkdir -p "$TARGET/tests/spec-generated"
mkdir -p "$TARGET/tests/red-team"

# 2. Copy agents
cp "$TRUSTLAYER_DIR/dotclaude/agents/"*.md "$TARGET/.claude/agents/"

# 3. Copy skills
for skill_dir in "$TRUSTLAYER_DIR/dotclaude/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/.claude/skills/$skill_name"
  cp "$skill_dir"* "$TARGET/.claude/skills/$skill_name/"
done

# 4. Copy hooks
cp "$TRUSTLAYER_DIR/dotclaude/hooks/"* "$TARGET/.claude/hooks/"

# 5. Copy templates
cp -r "$TRUSTLAYER_DIR/templates" "$TARGET/.claude/trustlayer/templates"

# 6. Copy spec templates
cp "$TRUSTLAYER_DIR/specs-template/"*.md "$TARGET/specs/" 2>/dev/null || true
cp "$TRUSTLAYER_DIR/specs-template/"*.feature "$TARGET/specs/" 2>/dev/null || true
cp "$TRUSTLAYER_DIR/specs-template/evals/"* "$TARGET/specs/evals/" 2>/dev/null || true

# 7. Copy GitHub Actions (if git repo)
if [ -d "$TARGET/.git" ]; then
  mkdir -p "$TARGET/.github/workflows"
  cp "$TRUSTLAYER_DIR/github/workflows/"*.yml "$TARGET/.github/workflows/"
fi

# 8. Merge hook configuration into settings.json
SETTINGS="$TARGET/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  EXISTING=$(cat "$SETTINGS")
  TRUSTLAYER_HOOKS=$(cat "$TRUSTLAYER_DIR/dotclaude/settings.trustlayer.json")
  echo "$EXISTING" | jq --argjson new "$TRUSTLAYER_HOOKS" '
    .hooks.PostToolUse = (.hooks.PostToolUse // []) + $new.hooks.PostToolUse
  ' > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
else
  cp "$TRUSTLAYER_DIR/dotclaude/settings.trustlayer.json" "$SETTINGS"
fi

# 9. Add to .gitignore
if [ -f "$TARGET/.gitignore" ]; then
  if ! grep -q "trustlayer" "$TARGET/.gitignore"; then
    cat >> "$TARGET/.gitignore" << 'EOF'

# TrustLayer runtime files
.claude/trustlayer/builder-output.md
.claude/current-task-scope.json
EOF
  fi
fi

echo ""
echo "TrustLayer installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Run /spec-init in Claude Code to detect your project"
echo "  2. Build a feature (Mode B: just start building)"
echo "  3. Run /spec-freeze to create retroactive spec"
echo "  4. Run /spec-pipeline to verify with reviewer + breaker"
