# Specs

This directory contains Gherkin feature specs and their eval decompositions.

## Workflow

1. Build your feature (Mode B — just start building)
2. Run `/spec-freeze` to generate a retroactive spec from your code
3. Review the eval decomposition table — approve or request changes
4. Run `/spec-pipeline` to verify with reviewer + breaker agents

## Structure

```
specs/
├── <scope>.feature          # Gherkin spec (human-readable behavior)
└── evals/
    └── <scope>.eval.yaml    # Atomic evals (machine-testable assertions)
```

## Tags

- `@scope(name)` — maps to source directories
- `@priority(high|medium|low)` — importance
- `@retroactive` — generated from existing code via /spec-freeze
- `@happy-path`, `@error-handling`, `@security`, `@edge-case` — scenario types
