# Evals

Atomic eval decompositions generated from Gherkin specs.

## Judge Types

| Type | When to Use | Example |
|------|------------|---------|
| `algorithm` | Clear right/wrong answer | Status code, DOM element exists, DB row count |
| `ai` | Subjective quality | "Is this error message helpful?" |
| `human` | Visual/UX judgment | "Does the flow feel smooth?" |

## Fields

- `id` — unique eval ID (scope-NNN)
- `name` — what is being tested
- `judge_type` — algorithm, ai, or human
- `assertion` — what must be true
- `test_type` — unit, integration, e2e, or manual
- `human_reviewed` — must be `true` before pipeline runs
