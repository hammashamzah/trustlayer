---
name: spec-doctor
description: Diagnose TrustLayer installation issues and auto-fix them
keywords: [doctor, diagnose, fix, audit, health, trustlayer]
---

# /spec-doctor — Diagnose & Auto-Fix

Checks every TrustLayer component, reports issues, and offers to fix them.

## When to Use
- "Something's not working with TrustLayer"
- "Run doctor"
- "Check TrustLayer health"
- After setup to verify
- Periodically to catch drift

## Arguments
- $ARGUMENTS: optional — `--fix` to auto-fix all issues without prompting

## Behavior

Run ALL checks below. For each, report status and offer fixes.

### Check 1: Directory Structure
Verify these directories exist:
```
specs/                    → stores Gherkin feature files
specs/evals/              → stores eval YAML decompositions
.claude/trustlayer/       → TrustLayer config and runtime files
.claude/reviews/          → reviewer agent output
.claude/breaker-reports/  → breaker agent output
.claude/agents/           → agent definition files
.claude/skills/           → skill definition files
.claude/hooks/            → hook scripts
tests/spec-generated/     → builder's test output
tests/red-team/           → breaker's test output
```

**Fix:** Create any missing directories with `mkdir -p`.

### Check 2: Agent Files
Verify these files exist and are non-empty:
```
.claude/agents/spec-builder.md
.claude/agents/spec-reviewer.md
.claude/agents/spec-breaker.md
```

Check each has the correct `model:` line:
- spec-builder → `model: opus`
- spec-reviewer → `model: haiku`
- spec-breaker → `model: sonnet`

**Fix:** Copy from trustlayer source if missing. If model is wrong, offer to correct it.

### Check 3: Skills
Verify each skill directory has a `SKILL.md`:
```
.claude/skills/spec-init/SKILL.md
.claude/skills/spec-context/SKILL.md
.claude/skills/spec-write/SKILL.md
.claude/skills/spec-decompose/SKILL.md
.claude/skills/spec-freeze/SKILL.md
.claude/skills/spec-build/SKILL.md
.claude/skills/spec-review/SKILL.md
.claude/skills/spec-break/SKILL.md
.claude/skills/spec-pipeline/SKILL.md
.claude/skills/spec-status/SKILL.md
.claude/skills/spec-setup/SKILL.md
.claude/skills/spec-doctor/SKILL.md
.claude/skills/morning/SKILL.md
```

**Fix:** Copy missing skills from trustlayer source.

### Check 4: Hook Script
Verify:
1. `.claude/hooks/trustlayer-post-edit.sh` exists
2. It is executable (`-x` permission)
3. It contains the expected shebang (`#!/bin/bash`)
4. `jq` is available on PATH (required by hook)

**Fix:**
- Copy hook from source if missing
- `chmod +x` if not executable
- Warn if `jq` not installed: "Install jq: brew install jq"

### Check 5: Hook Registration
Read `.claude/settings.json` (or `.claude/settings.local.json`). Verify:
1. `hooks.PostToolUse` array exists
2. It contains an entry with `trustlayer-post-edit.sh`
3. The matcher is `Edit|Write`
4. The timeout is reasonable (>= 15 seconds)

**Fix:** Add the hook entry if missing. Do NOT overwrite existing hooks — append to the array.

### Check 6: Hook Execution Test
Create a temporary scope file and simulate a hook run:
```bash
# Create temporary scope
echo '{"test_command":"echo TRUSTLAYER_HOOK_OK","allowed_paths":["test/**"],"forbidden_paths":[]}' > .claude/current-task-scope.json

# Simulate hook input
echo '{"tool_input":{"file_path":"test/dummy.ts"}}' | bash .claude/hooks/trustlayer-post-edit.sh

# Clean up
rm .claude/current-task-scope.json
```

Expected output should contain `TRUSTLAYER_HOOK_OK` or `additionalContext`.

**Fix:** If hook fails, check:
- Is `jq` installed?
- Is the script executable?
- Does `$CLAUDE_PROJECT_DIR` resolve correctly?
- Are there syntax errors? Run `bash -n .claude/hooks/trustlayer-post-edit.sh`

### Check 7: TrustLayer Config
Verify `.claude/trustlayer/config.json`:
1. File exists
2. Valid JSON (parse with jq)
3. Has required fields: `project_type`, `test_framework`, `test_command`, `package_manager`
4. `test_command` actually works: run it and check exit code

**Fix:** If missing, offer to run /spec-init to regenerate. If test_command fails, ask user for correct command.

### Check 8: Git & GitHub
Check:
1. Project is a git repo
2. `gh` CLI is authenticated (`gh auth status`)
3. GitHub Actions workflows exist in `.github/workflows/`

**Fix:**
- `git init` if not a repo
- Suggest `gh auth login` if not authenticated
- Copy workflow files if missing

### Check 9: Test Framework
Verify the detected test framework actually works:
```bash
# Try running the test command from config
<test_command> --help  # or equivalent check
```

Check if `tests/spec-generated/` has any test files (if specs have been built).

**Fix:** If test framework not installed, offer to install it.

### Check 10: Templates
Verify `.claude/trustlayer/templates/` directory has:
- `scope.template.json`
- `eval.template.yaml`
- `feature.template.gherkin`
- `review-report.template.md`
- `breaker-report.template.md`

**Fix:** Copy from trustlayer source if missing.

### Check 11: Spec Integrity
For each `.feature` file in `specs/`:
1. Check if corresponding eval YAML exists in `specs/evals/`
2. If eval exists, verify `human_reviewed` field is present
3. Check if eval IDs are unique (no duplicates across files)

Report orphaned specs (no evals) and orphaned evals (no spec).

**Fix:** Suggest running `/spec-decompose` for specs without evals.

### Check 12: Stale Reports
Check for stale review/breaker reports:
- Reports older than the latest commit touching the scope's source files
- Reports referencing eval IDs that no longer exist

**Fix:** Suggest re-running `/spec-pipeline` for stale scopes.

---

## Output Format

```
TrustLayer Doctor — Health Check

  Directories:       12/12 ✓
  Agents:            3/3 ✓
  Skills:            13/13 ✓
  Hook script:       ✓ (executable, jq available)
  Hook registered:   ✓ (in settings.json)
  Hook execution:    ✓ (test passed)
  Config:            ✓ (valid, test_command works)
  Git & GitHub:      ✓ (repo, gh authenticated)
  Test framework:    ✓ (vitest working)
  Templates:         5/5 ✓
  Spec integrity:    3 specs, 2 with evals, 1 needs decompose
  Stale reports:     1 stale review (auth — source changed since review)

  Issues found: 2
    1. specs/payment.feature has no eval YAML
       → Fix: run /spec-decompose specs/payment.feature
    2. .claude/reviews/auth-review.md is stale
       → Fix: run /spec-pipeline auth

  Auto-fixable: 0
  Manual action needed: 2
```

If `--fix` flag was passed, auto-fix everything possible and report what was fixed.
