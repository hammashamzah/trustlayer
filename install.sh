#!/bin/bash
# TrustLayer Installer
#
# Two modes:
#   bash install.sh              → install global (skills, agents, templates to ~/.claude/)
#   bash install.sh /path/to/app → init project (hook, config, specs dirs, GitHub Actions)
#
set -euo pipefail

TRUSTLAYER_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── Global install (no args or explicit "global") ───
install_global() {
  echo "Installing TrustLayer globally to ~/.claude/ ..."

  # 1. Agents → ~/.claude/agents/
  mkdir -p ~/.claude/agents
  cp "$TRUSTLAYER_DIR/dotclaude/agents/"*.md ~/.claude/agents/
  echo "  Agents: 3 installed"

  # 2. Skills → ~/.claude/skills/
  mkdir -p ~/.claude/skills
  for skill_dir in "$TRUSTLAYER_DIR/dotclaude/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p ~/.claude/skills/"$skill_name"
    cp "$skill_dir"* ~/.claude/skills/"$skill_name"/
  done
  SKILL_COUNT=$(ls -d "$TRUSTLAYER_DIR/dotclaude/skills/"*/ | wc -l | tr -d ' ')
  echo "  Skills: $SKILL_COUNT installed"

  # 3. Templates → ~/.claude/trustlayer/templates/
  mkdir -p ~/.claude/trustlayer/templates
  cp "$TRUSTLAYER_DIR/templates/"* ~/.claude/trustlayer/templates/
  echo "  Templates: installed"

  echo ""
  echo "Global install complete!"
  echo ""
  echo "Next: run 'bash install.sh /path/to/your-project' to init a project,"
  echo "or open Claude Code in any project and run /spec-setup"
}

# ─── Per-project init ───
install_project() {
  TARGET="$1"
  TARGET="$(cd "$TARGET" && pwd)"
  echo "Initializing TrustLayer in project: $TARGET"

  # 1. Create project directories
  mkdir -p "$TARGET/specs/evals"
  mkdir -p "$TARGET/.claude/trustlayer"
  mkdir -p "$TARGET/.claude/reviews"
  mkdir -p "$TARGET/.claude/breaker-reports"
  mkdir -p "$TARGET/.claude/hooks"
  mkdir -p "$TARGET/tests/spec-generated"
  mkdir -p "$TARGET/tests/red-team"
  echo "  Directories: created"

  # 2. Copy hook (project-specific — reads project's scope file)
  cp "$TRUSTLAYER_DIR/dotclaude/hooks/trustlayer-post-edit.sh" "$TARGET/.claude/hooks/"
  chmod +x "$TARGET/.claude/hooks/trustlayer-post-edit.sh"
  echo "  Hook: installed"

  # 3. Register hook in project settings
  SETTINGS="$TARGET/.claude/settings.json"
  HOOK_CMD='bash $CLAUDE_PROJECT_DIR/.claude/hooks/trustlayer-post-edit.sh'

  if [ -f "$SETTINGS" ]; then
    # Check if hook already registered
    if grep -q "trustlayer-post-edit" "$SETTINGS" 2>/dev/null; then
      echo "  Hook registration: already present, skipping"
    else
      EXISTING=$(cat "$SETTINGS")
      TRUSTLAYER_HOOKS=$(cat "$TRUSTLAYER_DIR/dotclaude/settings.trustlayer.json")
      echo "$EXISTING" | jq --argjson new "$TRUSTLAYER_HOOKS" '
        .hooks.PostToolUse = (.hooks.PostToolUse // []) + $new.hooks.PostToolUse
      ' > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
      echo "  Hook registration: added to settings.json"
    fi
  else
    cp "$TRUSTLAYER_DIR/dotclaude/settings.trustlayer.json" "$SETTINGS"
    echo "  Hook registration: created settings.json"
  fi

  # 4. Copy spec templates (only if specs/ is empty)
  if [ ! -f "$TARGET/specs/example.feature" ]; then
    cp "$TRUSTLAYER_DIR/specs-template/"*.md "$TARGET/specs/" 2>/dev/null || true
    cp "$TRUSTLAYER_DIR/specs-template/"*.feature "$TARGET/specs/" 2>/dev/null || true
    cp "$TRUSTLAYER_DIR/specs-template/evals/"* "$TARGET/specs/evals/" 2>/dev/null || true
    echo "  Spec templates: copied"
  else
    echo "  Spec templates: skipped (specs/ not empty)"
  fi

  # 5. Copy GitHub Actions (if git repo)
  if [ -d "$TARGET/.git" ]; then
    mkdir -p "$TARGET/.github/workflows"
    cp "$TRUSTLAYER_DIR/github/workflows/"*.yml "$TARGET/.github/workflows/"
    echo "  GitHub Actions: installed"
  else
    echo "  GitHub Actions: skipped (not a git repo)"
  fi

  # 6. Add to .gitignore
  if [ -f "$TARGET/.gitignore" ]; then
    if ! grep -q "trustlayer" "$TARGET/.gitignore"; then
      cat >> "$TARGET/.gitignore" << 'GITIGNORE'

# TrustLayer runtime files
.claude/trustlayer/builder-output.md
.claude/current-task-scope.json
GITIGNORE
      echo "  .gitignore: updated"
    fi
  fi

  echo ""
  echo "Project initialized!"
  echo ""
  echo "Next: open Claude Code in this project and run /spec-setup or /spec-doctor"
}

# ─── Main ───
if [ $# -eq 0 ] || [ "${1:-}" = "global" ]; then
  install_global
else
  # If first arg is a directory, init that project
  if [ -d "$1" ]; then
    install_project "$1"
  else
    echo "Error: '$1' is not a directory"
    echo ""
    echo "Usage:"
    echo "  bash install.sh              # install globally to ~/.claude/"
    echo "  bash install.sh /path/to/app # init a specific project"
    exit 1
  fi
fi
