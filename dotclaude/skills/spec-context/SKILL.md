---
name: spec-context
description: Extract patterns and structure from an existing codebase for TrustLayer integration
keywords: [context, brownfield, extract, patterns, conventions, trustlayer]
---

# /spec-context — Brownfield Context Extraction

Analyze an existing project to extract patterns for TrustLayer integration.

## When to Use
- First time using TrustLayer on an existing project
- "Analyze this codebase"
- Before /spec-init on a brownfield project

## Arguments
- $ARGUMENTS: optional path to focus on (defaults to project root)

## Behavior

### Step 1: Project Structure Analysis
Scan with Glob:
- `src/**/*.{ts,tsx,js,jsx,py,go,swift}` — source files
- `tests/**/*`, `__tests__/**/*` — existing tests
- `*.config.*`, `*.json` — configuration
- `.github/workflows/*.yml` — CI/CD

### Step 2: Pattern Discovery
Use Grep to find:
- Route definitions: `app.get`, `router.post`, `export default function Page`
- Test patterns: `describe(`, `test(`, `it(`, `func Test`
- Error handling: `try/catch`, `.catch(`, `if err != nil`
- Auth patterns: `jwt`, `token`, `session`, `auth`

Read 3-5 representative files to understand conventions.

### Step 3: Scope Discovery
Map the project into natural scopes:
- Next.js: each `app/` route group = scope
- Express: each `routes/` file = scope
- Swift: each feature module = scope
- Monorepo: each `packages/` entry = scope

### Step 4: Write Context File
Output to `.claude/trustlayer/project-context.md`:

```markdown
# Project Context for TrustLayer

## Project Type
[Framework, language, version]

## Directory Map
[Tree with annotations]

## Scopes Discovered
| Scope | Directories | Key Files | Existing Tests |
|-------|------------|-----------|----------------|

## Patterns
- Naming: [convention]
- File org: [pattern]
- Tests: [pattern]
- Errors: [pattern]

## Recommendations
- Spec first: [most critical scope to spec]
- Gaps: [areas with no tests]
```

### Step 5: Update Config
Update `.claude/trustlayer/config.json` with discovered `scope_patterns` mapping.
