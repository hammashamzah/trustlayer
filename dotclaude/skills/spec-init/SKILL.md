---
name: spec-init
description: Initialize TrustLayer in the current project — detect stack and configure
keywords: [trustlayer, init, setup, bdd, gherkin, initialize]
---

# /spec-init — Initialize TrustLayer

Detects your project stack and sets up TrustLayer configuration.

## When to Use
- First time using TrustLayer in a project
- "Set up TrustLayer"
- "Initialize spec-driven development"

## Behavior

### Step 1: Detect Project Type
Scan the project to determine:
- **Language/framework**: Check package.json (Next.js, Express), go.mod, requirements.txt, Package.swift
- **Test framework**: vitest.config, jest.config, pytest.ini, XCTestCase files
- **E2E framework**: playwright.config, cypress.config
- **Package manager**: bun.lockb → bun, pnpm-lock.yaml → pnpm, package-lock.json → npm
- **Deployment**: vercel.json → Vercel, netlify.toml → Netlify, Dockerfile → Docker/Coolify

### Step 2: Verify Directories
Check that TrustLayer directories exist (created by install.sh):
- `specs/` and `specs/evals/`
- `.claude/trustlayer/`
- `.claude/reviews/` and `.claude/breaker-reports/`
- `tests/spec-generated/` and `tests/red-team/`

Create any missing ones.

### Step 3: Write Configuration
Create `.claude/trustlayer/config.json`:
```json
{
  "project_type": "<detected framework>",
  "test_framework": "<detected>",
  "e2e_framework": "<detected or null>",
  "package_manager": "<detected>",
  "deployment": "<detected>",
  "test_command": "<detected test command>",
  "build_command": "<detected build command>",
  "scope_patterns": {}
}
```

### Step 4: Install E2E (if needed)
If no e2e framework detected, ask:
"No E2E framework detected. Should I install Playwright? (Recommended for TrustLayer verification)"

If yes and using bun: `bun add -d @playwright/test && bunx playwright install`

### Step 5: Report
"TrustLayer initialized. Detected: [framework] with [test framework].
Next: build your feature, then run /spec-freeze to create a spec."
