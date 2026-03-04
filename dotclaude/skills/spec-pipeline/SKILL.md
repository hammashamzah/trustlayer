---
name: spec-pipeline
description: Run the full TrustLayer pipeline — build, review, break, merge gate
keywords: [pipeline, full, orchestrate, trustlayer, end-to-end]
---

# /spec-pipeline — Full Pipeline

Orchestrates the entire TrustLayer verification pipeline.

## When to Use
- "Run the full pipeline for auth"
- "Verify the checkout feature"
- After /spec-freeze and human approval of evals

## Arguments
- $ARGUMENTS: scope name
- Optional flags in arguments: --skip-build (if already built), --skip-review, --skip-break

## Pipeline Flow

```
[Approved evals] → BUILD → REVIEW + BREAK (parallel) → MERGE GATE → Human
```

## Behavior

### Stage 1: Validate Prerequisites
Check:
- `specs/<scope>.feature` exists
- `specs/evals/<scope>.eval.yaml` exists with `human_reviewed: true`
- `.claude/current-task-scope.json` exists

If missing, tell user what's needed and stop.

### Stage 2: Builder (skip if --skip-build)
Run /spec-build for the scope.
- Wait for builder to complete (background agent, file-based coordination)
- Read `.claude/trustlayer/builder-output.md`
- If BLOCKED: stop pipeline, report to user
- If SUCCESS: continue

### Stage 3: Reviewer + Breaker (parallel)
Spawn BOTH agents simultaneously using `run_in_background=true`:

1. /spec-review — reads implementation + evals, writes to `.claude/reviews/`
2. /spec-break — reads implementation + spec, writes to `.claude/breaker-reports/`

Context isolation enforced:
- Reviewer does NOT see breaker's tests
- Breaker does NOT see reviewer's findings
- Neither sees builder's reasoning

Wait for both to complete by checking for output files.

### Stage 4: Merge Gate
Read all outputs and present unified verdict:

```markdown
## Merge Gate: <scope>

### Builder
- Evals: X/Y passing
- Tests: N total

### Reviewer Verdict: APPROVE / REQUEST_CHANGES
- Critical: [count]
- Concerns: [count]

### Breaker Findings
- Vulnerabilities: [count]
- Gaps: [count]
- Edge cases: [count]

### Blocking Issues
1. [Critical from reviewer]
2. [Critical from breaker]

### Non-Blocking
1. [Concerns from reviewer]
2. [Gaps from breaker]

### Recommendation: MERGE / FIX_REQUIRED / DISCUSS
```

### Stage 5: If FIX_REQUIRED
User can say "fix the blocking issues". The pipeline:
1. Re-runs builder with findings injected as additional context
2. Re-runs reviewer + breaker
3. Presents new merge gate

### Stage 6: Create PR
If MERGE recommended and user approves:
1. Create a git branch if not already on one
2. Commit all changes
3. Create PR with merge gate summary as PR body
4. Include checklist of all evals as PR description
