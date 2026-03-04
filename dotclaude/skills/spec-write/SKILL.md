---
name: spec-write
description: Write or edit Gherkin feature specifications with guided interview (Mode A)
keywords: [spec, gherkin, feature, bdd, write, create, trustlayer]
---

# /spec-write — Write Gherkin Specifications

Interactive spec writing for Mode A (spec-first) development.

## When to Use
- "Write a spec for user login"
- "Create a feature spec"
- "Spec out the payment flow"
- Mode A: you know what you want before building

## Arguments
- $ARGUMENTS: feature name or description, optionally --scope <name> --edit <path>

## Behavior

### Step 1: Interview
Ask targeted questions to understand the feature:
1. "What is the user trying to accomplish?"
2. "What are the success criteria?"
3. "What error cases matter?"
4. "What security concerns exist?"
5. "What's the scope tag?" (e.g., auth, payments, dashboard)

### Step 2: Generate Gherkin
Write the .feature file to `specs/<scope>-<feature-name>.feature`

Rules:
- Use `@scope()` tag matching project's scope patterns
- Use `@priority()` tag (high/medium/low)
- Tag scenarios with `@happy-path`, `@error-handling`, `@security`, `@edge-case`
- Use Background for shared setup
- Use Scenario Outline for parameterized tests
- Keep scenarios focused on one behavior each
- Write in business language, not implementation details

### Step 3: Present for Review
Show the complete spec and ask:
"Review this spec. When approved, run /spec-decompose to generate atomic evals."
