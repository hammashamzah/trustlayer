---
name: spec-build
description: Orchestrate the builder agent to implement code against approved specs using TDD
keywords: [build, implement, builder, agent, trustlayer]
---

# /spec-build — Builder Agent Orchestrator

Spawns the spec-builder agent to implement against approved evals.

## When to Use
- After evals are approved (human_reviewed: true)
- "Build the auth feature"
- "Implement against the login spec"
- Part of /spec-pipeline

## Arguments
- $ARGUMENTS: scope name or path to eval YAML

## Prerequisites
Check before proceeding:
1. Eval file exists at `specs/evals/<scope>.eval.yaml`
2. Eval has `human_reviewed: true`
3. Scope file `.claude/current-task-scope.json` exists

If any missing, tell the user what's needed and stop.

## Behavior

### Step 1: Load Context
Read:
- `.claude/current-task-scope.json`
- The eval YAML
- The original .feature file

### Step 2: Generate Test Stubs
Before spawning builder, create test file stubs from evals:
- For each eval with `judge_type: algorithm`, create a `test.todo()` stub in `tests/spec-generated/<scope>/`
- For playwright evals, create stubs in `tests/spec-generated/<scope>/e2e/`
- Stubs contain the eval assertion as a comment

### Step 3: Spawn Builder Agent
Use the Agent tool:
```
Agent(
  subagent_type="general-purpose",
  model="opus",
  prompt="""
  You are the spec-builder agent. Read .claude/agents/spec-builder.md for your full instructions.

  ## Your Task
  Implement the evals in specs/evals/<scope>.eval.yaml using TDD.

  ## Scope
  [paste current-task-scope.json content]

  ## Evals
  [paste eval YAML content]

  ## Test Stubs
  Test stubs are in tests/spec-generated/<scope>/. Convert each from .todo() to real tests.

  Follow the RED → GREEN process for each eval. Write output to .claude/trustlayer/builder-output.md
  """,
  run_in_background=true
)
```

### Step 4: Monitor
After builder completes (system reminder notification):
1. Read `.claude/trustlayer/builder-output.md`
2. Report: "Builder completed. X/Y evals passing. Ready for /spec-review and /spec-break"

### Step 5: Handle Failures
If builder output shows blockers:
- Present to user
- Options: retry, skip eval, modify spec
