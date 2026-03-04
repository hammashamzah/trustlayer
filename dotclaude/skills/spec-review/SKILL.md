---
name: spec-review
description: Orchestrate the read-only reviewer agent to verify spec coverage
keywords: [review, reviewer, verify, trustlayer]
---

# /spec-review — Reviewer Agent Orchestrator

Spawns the spec-reviewer agent (READ-ONLY, haiku) to verify implementation.

## When to Use
- After /spec-build completes
- "Review the auth implementation"
- Part of /spec-pipeline

## Arguments
- $ARGUMENTS: scope name

## Behavior

### Step 1: Load Context
Read:
- The eval YAML
- The original .feature file
- Do NOT load builder's conversation or reasoning

### Step 2: Spawn Reviewer Agent
```
Agent(
  subagent_type="general-purpose",
  model="haiku",
  prompt="""
  You are the spec-reviewer agent. Read .claude/agents/spec-reviewer.md for your full instructions.

  You are STRICTLY READ-ONLY. You verify that the implementation matches the spec.

  ## Spec (Source of Truth)
  [paste .feature file content]

  ## Evals (Acceptance Criteria)
  [paste eval YAML content]

  ## Your Constraints
  - READ-ONLY: use Read, Grep, Glob, Bash (for running tests only)
  - Do NOT modify any files except writing your review
  - Do NOT read tests/red-team/ (breaker's tests)

  For each eval: find test → assess validity → find impl → run test → grade.
  Write review to .claude/reviews/<scope>-review.md
  """,
  run_in_background=true
)
```

### Step 3: Read and Report
After completion, read `.claude/reviews/<scope>-review.md` and present summary.
