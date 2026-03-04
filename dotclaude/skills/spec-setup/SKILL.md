---
name: spec-setup
description: Interactive TrustLayer setup — install, configure, and verify everything works
keywords: [setup, install, configure, trustlayer, onboard]
---

# /spec-setup — Interactive Setup

Full interactive setup that installs TrustLayer into the current project. Handles everything: global install (if needed), project hook, config, spec templates, GitHub Actions, and verification. No need to run install.sh manually — this skill IS the installer.

## When to Use
- First time setting up TrustLayer in a project
- "Set up TrustLayer"
- "Install TrustLayer"
- Preferred over running install.sh manually

## Arguments
- $ARGUMENTS: optional — path to trustlayer source (defaults to ~/Projects/trustlayer)

## Behavior

### Step 1: Pre-flight Checks
Verify the environment:

```bash
# Required tools
jq --version        # needed by hook
git --version       # needed for PR workflow
```

Check for optional tools and note what's missing:
- `bun` / `npm` / `pnpm` — package manager
- `playwright` — e2e testing
- `yq` — YAML parsing (nice to have, not required)
- `gh` — GitHub CLI for PR creation

Report:
```
Pre-flight:
  jq: v1.7 ✓
  git: v2.43 ✓
  bun: v1.1.38 ✓
  playwright: not installed (will prompt later)
  gh: v2.62 ✓
  yq: not installed (optional)
```

### Step 2: Detect Project Stack
Same as /spec-init step 1 — detect framework, test runner, e2e, package manager, deployment target.

### Step 3: Create Directory Structure
```bash
mkdir -p specs/evals
mkdir -p .claude/trustlayer
mkdir -p .claude/reviews
mkdir -p .claude/breaker-reports
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p .claude/hooks
mkdir -p tests/spec-generated
mkdir -p tests/red-team
```

### Step 4: Verify Global Install
Check that agents and skills exist in `~/.claude/`:
- `~/.claude/agents/spec-builder.md`, `spec-reviewer.md`, `spec-breaker.md`
- `~/.claude/skills/spec-freeze/SKILL.md` (and all other skills)

If missing, run the global install automatically:
```bash
bash ~/Projects/trustlayer/install.sh
```
If `~/Projects/trustlayer` doesn't exist either, tell user: "TrustLayer source not found. Run: git clone https://github.com/hammashamzah/trustlayer.git ~/Projects/trustlayer"

### Step 5: Install Project Hook
Set up the hook for this project. Do this directly (do NOT tell the user to run install.sh):

1. Copy hook script:
```bash
cp ~/Projects/trustlayer/dotclaude/hooks/trustlayer-post-edit.sh .claude/hooks/
chmod +x .claude/hooks/trustlayer-post-edit.sh
```

2. Register hook in `.claude/settings.json`:
   - If file exists and already has `trustlayer-post-edit` → skip
   - If file exists but no trustlayer hook → merge this into `.hooks.PostToolUse`:
     ```json
     {
       "matcher": "Edit|Write",
       "hooks": [{
         "type": "command",
         "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/trustlayer-post-edit.sh",
         "timeout": 30
       }]
     }
     ```
   - If file doesn't exist → create it with the hook config

### Step 5b: Copy Spec Templates (if specs/ is empty)
If no `.feature` files exist in `specs/`:
```bash
cp ~/Projects/trustlayer/specs-template/*.md specs/
cp ~/Projects/trustlayer/specs-template/*.feature specs/
cp ~/Projects/trustlayer/specs-template/evals/* specs/evals/
```

### Step 5c: Copy GitHub Actions
If this is a git repo and `.github/workflows/trustlayer-ci.yml` doesn't exist:
```bash
mkdir -p .github/workflows
cp ~/Projects/trustlayer/github/workflows/*.yml .github/workflows/
```

### Step 6: Write TrustLayer Config
Create `.claude/trustlayer/config.json` with detected project info:
```json
{
  "project_type": "<detected>",
  "test_framework": "<detected>",
  "e2e_framework": "<detected or null>",
  "package_manager": "<detected>",
  "deployment": "<detected>",
  "test_command": "<detected>",
  "build_command": "<detected>",
  "scope_patterns": {},
  "installed_at": "<ISO timestamp>",
  "trustlayer_version": "0.1.0"
}
```

### Step 7: Install Playwright (if missing)
If no e2e framework detected:
"No E2E framework found. Install Playwright for TrustLayer verification? (recommended)"

If yes: run the appropriate install command for the detected package manager.

### Step 8: Update .gitignore
Append TrustLayer runtime entries if not present:
```
# TrustLayer runtime (per-session, not shared across worktrees)
.claude/trustlayer/builder-output.md
.claude/trustlayer/config.json
.claude/current-task-scope.json
```

Note: The hook, settings.json, specs, and workflows should be **committed** so worktrees get them automatically. Only runtime/session files are gitignored.

### Step 9: Verification — Run /spec-doctor
After setup, automatically run the doctor checks (see /spec-doctor skill) to verify everything works.

### Step 10: Report
```
TrustLayer setup complete!

  Project: Next.js (detected)
  Tests: vitest ✓
  E2E: playwright ✓
  Hook: installed ✓
  Agents: 3 installed ✓
  Skills: 11 installed ✓
  GitHub Actions: installed ✓

  Next: build something, then /spec-freeze to create your first spec.
```
