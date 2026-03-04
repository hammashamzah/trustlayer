---
name: spec-break
description: Orchestrate the red-team breaker agent to find gaps in implementation
keywords: [break, breaker, red-team, security, edge-case, trustlayer]
---

# /spec-break — Breaker Agent Orchestrator

Spawns the spec-breaker agent (sonnet) to red-team the implementation.

## When to Use
- After /spec-build completes (or parallel with /spec-review)
- "Try to break the auth feature"
- Part of /spec-pipeline

## Arguments
- $ARGUMENTS: scope name

## Critical Context Separation
The breaker MUST NOT see:
- Builder's tests (`tests/spec-generated/`)
- Builder's conversation or reasoning
- Reviewer's findings (`.claude/reviews/`)

The breaker sees ONLY:
- The .feature file
- The eval YAML
- Implementation source code

## Behavior

### Step 1: Load Context
Read only:
- The .feature file
- The eval YAML
- Identify source code files in the scope (for the prompt)

### Step 2: Spawn Breaker Agent
```
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
  You are the spec-breaker agent. Read .claude/agents/spec-breaker.md for your full instructions.

  Your job is to BREAK the implementation. Find bugs, security holes, edge cases.

  ## The Spec
  [paste .feature file content]

  ## The Evals
  [paste eval YAML content]

  ## Source Code Location
  [list the source files in scope]

  ## Your Constraints
  - Write ONLY to tests/red-team/<scope>/
  - Do NOT read tests/spec-generated/ (builder's tests)
  - Do NOT read .claude/reviews/ (reviewer's findings)
  - You CAN read source code

  Write adversarial tests. Report what breaks.
  Write report to .claude/breaker-reports/<scope>-breaker.md
  """,
  run_in_background=true
)
```

### Step 3: Read and Report
After completion, read `.claude/breaker-reports/<scope>-breaker.md` and present summary.
