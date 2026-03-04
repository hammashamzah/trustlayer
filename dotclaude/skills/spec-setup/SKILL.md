---
name: spec-setup
description: Interactive TrustLayer setup — install, configure, and verify everything works
keywords: [setup, install, configure, trustlayer, onboard]
---

# /spec-setup — Interactive Setup

Full interactive setup that installs TrustLayer, detects your stack, configures hooks, and verifies everything works.

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

If missing, tell user: "Global install not found. Run: bash ~/Projects/trustlayer/install.sh"

### Step 5: Verify Project Hook
Check that the hook is set up for this project:
1. `.claude/hooks/trustlayer-post-edit.sh` exists and is executable
2. `.claude/settings.json` has the PostToolUse hook registered

If missing, tell user: "Project not initialized. Run: bash ~/Projects/trustlayer/install.sh $(pwd)"
If hook exists but not registered, offer to add it to settings.json.

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

### Step 7: GitHub Actions (optional)
Ask: "Install GitHub Actions workflows for CI and preview deploys? (y/n)"

If yes:
- Create `.github/workflows/` if needed
- Copy `trustlayer-ci.yml` and `trustlayer-preview.yml`
- Warn about required secrets: `VERCEL_TOKEN`, `NETLIFY_AUTH_TOKEN` etc.

### Step 8: Install Playwright (if missing)
If no e2e framework detected:
"No E2E framework found. Install Playwright for TrustLayer verification? (recommended)"

If yes: run the appropriate install command for the detected package manager.

### Step 9: Update .gitignore
Append TrustLayer runtime entries if not present:
```
# TrustLayer runtime
.claude/trustlayer/builder-output.md
.claude/current-task-scope.json
```

### Step 10: Verification — Run /spec-doctor
After setup, automatically run the doctor checks (see /spec-doctor skill) to verify everything works.

### Step 11: Report
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
