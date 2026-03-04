---
name: spec-freeze
description: Mode B - Freeze existing implementation into a retroactive Gherkin spec with atomic evals
keywords: [freeze, explore, mode-b, retroactive, spec, trustlayer]
---

# /spec-freeze — Freeze Exploration into Spec

For Mode B development: you built first, now freeze what exists into a spec + evals.

## When to Use
- After building a feature and being happy with it
- "Freeze this into a spec"
- "Create a spec for what I just built"
- Before creating a PR (required by TrustLayer CI)

## Arguments
- $ARGUMENTS: scope name or directory path of the implementation (e.g., "auth", "src/checkout/")

## Behavior

### Step 1: Analyze Existing Code
Read all source files in the scope. Identify:
- Public functions, API endpoints, route handlers
- Component behaviors and UI states
- Error handling paths
- Existing tests (if any)
- Database interactions
- External API calls

Use Glob and Grep to discover files. Use Read to understand them.

### Step 2: Discover Scope Boundaries
Map the implementation to directories:
- Find all files related to the scope
- Identify test files that already exist
- Determine the test framework (look for vitest/jest/pytest/go test configs)
- Determine the e2e framework (look for playwright/cypress configs)

### Step 3: Generate Retroactive Gherkin
From the code analysis, generate a `.feature` file that describes what the code ACTUALLY DOES.

Rules:
- Tag with `@retroactive` to indicate this was generated from code
- Tag with `@scope(<scope-name>)`
- Use `@happy-path`, `@error-handling`, `@security`, `@edge-case` tags on scenarios
- Write in business language, not implementation details
- One scenario per distinct behavior

Write to: `specs/<scope>.feature`

### Step 4: Decompose into Atomic Evals
For EACH meaningful behavior in the spec, create an eval entry.

Rules for decomposition:
- One eval = one assertion = one test
- Each eval must be independently verifiable
- Prefer `algorithm` judge (deterministic) over `ai` judge
- Use `ai` judge ONLY when output quality is subjective (error message helpfulness, email content)
- Use `human` judge ONLY for visual/UX assessment
- Mark evals matching existing tests with `has_existing_test: true`
- Mark evals without tests with `has_existing_test: false, gap: true`

Judge type selection:
- **algorithm**: Return value, status code, DB state, DOM element presence, redirect URL, response time
- **ai**: Error message quality, generated text coherence, email content — subjective quality
- **human**: Visual appearance, UX flow smoothness, accessibility

Write to: `specs/evals/<scope>.eval.yaml`

### Step 5: Present for Human Review
Display a summary table:

```
## Spec Freeze: <scope>

### Gherkin Scenarios
| # | Scenario | Type | Tags |
|---|----------|------|------|

### Eval Decomposition
| ID | Name | Judge | Test Type | Has Test? |
|----|------|-------|-----------|-----------|

### Gaps Found
- [evals without existing tests]

Review these. Say 'approve' to set human_reviewed: true, or request changes.
```

IMPORTANT: Set `human_reviewed: false` initially. Only set to `true` when user explicitly approves.

### Step 6: Generate Scope File
After approval, generate `.claude/current-task-scope.json`:
1. Read eval YAML for scope tag
2. Set allowed_paths based on discovered directories
3. Set forbidden_paths: `specs/**, .claude/reviews/**, .claude/breaker-reports/**, tests/red-team/**`
4. Set test_command for the scoped test directory
5. Set eval_ids from the eval YAML

### Step 7: Save Decision to Specs
The frozen spec becomes the source of truth. Any future changes to this feature should start from updating the spec.
