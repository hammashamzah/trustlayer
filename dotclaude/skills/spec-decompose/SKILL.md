---
name: spec-decompose
description: Decompose Gherkin specs into atomic McKinnon-style evals with judge types
keywords: [decompose, eval, gherkin, mckinnon, atomic, test, trustlayer]
---

# /spec-decompose — Gherkin to Atomic Evals

The bridge: decomposes human-written Gherkin into atomic, testable eval assertions.

## When to Use
- After writing a spec with /spec-write
- "Decompose this spec into evals"
- "Generate evals for auth-login.feature"

## Arguments
- $ARGUMENTS: path to .feature file, or scope name

## Behavior

### Step 1: Read the Feature File
Parse the Gherkin completely. Identify all scenarios, Given/When/Then steps, tags.

### Step 2: Decompose into Atomic Evals
For EACH meaningful assertion, create an eval entry.

Rules:
- One eval = one assertion = one test
- Each eval must be independently verifiable
- Prefer `algorithm` judge over `ai` judge over `human` judge
- Include implementation hints for test generation

Judge types:
- **algorithm**: Status code, DB state, DOM element, URL, response time — clear right/wrong
- **ai**: Message quality, content coherence — subjective but structured
- **human**: Visual, UX, accessibility — requires human eyes

### Step 3: Detect Test Framework
Read `.claude/trustlayer/config.json` (if exists) or scan project for:
- vitest/jest/pytest/go test configs
- playwright/cypress configs
- package manager (bun/npm/pnpm)

### Step 4: Write Eval YAML
Write to `specs/evals/<feature-name>.eval.yaml`

### Step 5: Present Summary Table
| ID | Name | Judge | Type | Scenario |
|----|------|-------|------|----------|

"Review these eval decompositions. Say 'approve' to set human_reviewed: true."

Set `human_reviewed: false` initially. Only `true` after explicit approval.

### Step 6: Generate Scope File
After approval, generate `.claude/current-task-scope.json` with allowed paths, test command, and eval IDs.
