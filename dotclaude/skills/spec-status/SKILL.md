---
name: spec-status
description: Show the TrustLayer pipeline status for all specs in the project
keywords: [status, dashboard, progress, trustlayer, specs]
---

# /spec-status — Pipeline Dashboard

Shows the current state of all specs and their pipeline progress.

## When to Use
- "What's the spec status?"
- "Show pipeline progress"
- "Which specs need attention?"

## Behavior

### Step 1: Scan All Specs
Read all `.feature` files in `specs/`

### Step 2: Check Each Spec's State
For each feature file, check:
1. Does eval YAML exist in `specs/evals/`? (decomposed?)
2. Is `human_reviewed: true`? (approved?)
3. Does `.claude/trustlayer/builder-output.md` reference this scope? (built?)
4. Does a review exist in `.claude/reviews/`? (reviewed?)
5. Does a breaker report exist in `.claude/breaker-reports/`? (broken?)
6. Run scoped tests and get pass rate

### Step 3: Display Dashboard

```
## TrustLayer Pipeline Status

| Feature | Spec | Evals | Approved | Built | Reviewed | Broken | Tests |
|---------|------|-------|----------|-------|----------|--------|-------|
| auth    | Yes  | 10    | Yes      | Yes   | APPROVE  | 2 gaps | 9/10  |
| signup  | Yes  | 5     | No       | -     | -        | -      | -     |
| payment | No   | -     | -        | -     | -        | -      | -     |

### Needs Attention
- signup: Evals pending human review → run /spec-decompose
- payment: No spec → run /spec-freeze
- auth: 2 breaker gaps need addressing

### Ready to Merge
- [none / list of scopes with all checks passing]
```
