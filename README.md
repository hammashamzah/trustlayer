# TrustLayer

Spec-driven development pipeline for [Claude Code](https://claude.ai/code) with layered trust verification.

**The problem:** AI writes code faster than humans can review it. Teams produce 98% more PRs but review time increases 91%. Manual code review can't keep up.

**The solution:** Move the human checkpoint upstream. Humans define *what* (specs), AI handles *how* (code + tests), then isolated agents verify the work — builder, reviewer, breaker — each with separated context so they can't cheat.

Based on the ideas from ["How to Kill the Code Review"](https://www.latent.space/p/kill-code-review) and ["Show, Don't Tell: A Llama PM's Guide to Writing GenAI Evals"](https://www.ddmckinnon.com/2025/03/30/show-dont-tell-a-llama-pms-guide-to-writing-genai-evals/).

## How It Works

```
You build (Mode B)  →  /spec-freeze  →  AI decomposes into atomic evals
                                              ↓
                                    You review a table, not code
                                              ↓
                                    /spec-pipeline runs:
                                      Builder (Opus, TDD)
                                      Reviewer (Haiku, read-only)  ← parallel
                                      Breaker (Sonnet, red-team)   ← parallel
                                              ↓
                                    Merge gate with verdicts
                                              ↓
                                    You read 3 short reports, merge or fix
```

### The Gherkin → McKinnon Bridge

You write natural Gherkin (5 minutes):

```gherkin
Scenario: Failed payment preserves cart
  Given a cart with 2 items
  When user submits expired card
  Then user sees clear error
  And cart is preserved
```

AI decomposes into atomic evals with judge types:

| ID | Name | Judge | Type |
|----|------|-------|------|
| checkout-001 | Error message visible | algorithm | e2e |
| checkout-002 | Error message helpful | ai | integration |
| checkout-003 | Cart preserved | algorithm | integration |

You review the table — not test code, not implementation.

## Components

### Agents (3)

| Agent | Model | Role | Context |
|-------|-------|------|---------|
| **spec-builder** | Opus | TDD implementation against evals | Sees evals + scope. Does NOT see reviewer/breaker. |
| **spec-reviewer** | Haiku | Read-only verification checklist | Sees spec + evals + code. Does NOT see builder reasoning or breaker tests. |
| **spec-breaker** | Sonnet | Red-team adversarial testing | Sees spec + source code. Does NOT see builder tests or reviewer findings. |

### Skills (11)

| Skill | Description |
|-------|-------------|
| `/spec-init` | Detect project stack, configure TrustLayer |
| `/spec-context` | Extract patterns from brownfield codebase |
| `/spec-write` | Write Gherkin specs (Mode A: spec-first) |
| `/spec-decompose` | Gherkin → atomic evals with judge types |
| `/spec-freeze` | Mode B: freeze existing code into retroactive spec |
| `/spec-build` | Orchestrate builder agent |
| `/spec-review` | Orchestrate reviewer agent |
| `/spec-break` | Orchestrate breaker agent |
| `/spec-pipeline` | Full pipeline: build → review + break → merge gate |
| `/spec-status` | Dashboard of all specs and pipeline state |
| `/morning` | ClickUp morning check-in with priorities |

### Hook

**`trustlayer-post-edit.sh`** — PostToolUse hook that auto-runs scoped tests after every file edit. If tests fail, feedback is injected into Claude's context so it self-corrects. Zero manual effort.

### GitHub Actions (2)

**`trustlayer-ci.yml`** — Runs on every PR:
- Spec coverage gate (rejects PRs without frozen specs for modified scopes)
- Unit tests + spec-generated tests
- Red-team tests (informational)
- E2E tests with Playwright
- PR summary comment with checklist

**`trustlayer-preview.yml`** — Per-PR preview deployment:
- Auto-detects Vercel/Netlify
- Deploys preview environment
- Runs Playwright against preview with trace + video recording
- Uploads recordings as artifacts

## Installation

```bash
# Clone
git clone https://github.com/hammashamzah/trustlayer.git ~/Projects/trustlayer

# Install into any project
bash ~/Projects/trustlayer/install.sh /path/to/your-project

# In Claude Code (inside that project)
/spec-init
```

This copies agents, skills, hooks, templates, and GitHub Actions into your project's `.claude/` directory.

To remove:

```bash
bash ~/Projects/trustlayer/uninstall.sh /path/to/your-project
```

## Usage

### Mode B: Build First, Spec Later (recommended for solo devs)

```
1. Open Claude Code, start building your feature
2. When happy with the result:
   /spec-freeze checkout
3. Review the eval decomposition table
4. Say "approve"
5. /spec-pipeline checkout
6. Read the merge gate verdict
7. Merge or "fix the blocking issues"
```

### Mode A: Spec First

```
1. /spec-write "user login with email and password"
2. Review the Gherkin spec
3. /spec-decompose specs/auth-login.feature
4. Review eval table, approve
5. /spec-pipeline auth-login
```

### Morning Routine

```
1. Open Claude Code
2. /morning
3. See ClickUp priorities across all projects
4. Pick a task, start working
```

## Layered Trust Model

| Layer | What | How |
|-------|------|-----|
| **Layer 2: Deterministic Guardrails** | Auto-test after every edit | PostToolUse hook runs scoped tests, feeds failures back to Claude |
| **Layer 3: Human Acceptance Criteria** | Gherkin specs → atomic evals | Human writes behavior, AI decomposes into measurable assertions |
| **Layer 4: Permission Scoping** | File access per task | Scope file limits which directories each agent can touch |
| **Layer 5: Adversarial Verification** | Builder / Reviewer / Breaker | Three agents with isolated contexts — can't see each other's work |

## Eval Judge Types

Following McKinnon's framework, each eval has a judge type:

| Judge | When | Example |
|-------|------|---------|
| `algorithm` | Clear right/wrong | Status code, DOM element exists, DB row count |
| `ai` | Subjective quality | "Is this error message helpful?" |
| `human` | Visual/UX judgment | "Does the flow feel smooth?" |

## Token Cost

Per-feature pipeline run:

| Agent | Model | Tokens |
|-------|-------|--------|
| Builder | Opus | ~50-80k |
| Reviewer | Haiku | ~10-15k |
| Breaker | Sonnet | ~20-30k |
| Hook | None (bash) | 0 |
| **Total** | | **~80-125k** |

## Project Structure

```
trustlayer/
├── install.sh / uninstall.sh
├── trustlayer.json
├── dotclaude/
│   ├── agents/          # Builder, Reviewer, Breaker
│   ├── skills/          # 11 slash commands
│   ├── hooks/           # Auto-test hook
│   └── settings.trustlayer.json
├── specs-template/      # Example specs + evals
├── github/workflows/    # CI + Preview deploy
└── templates/           # Report and config templates
```

When installed into a project:

```
your-project/
├── specs/
│   ├── checkout.feature          # Gherkin specs
│   └── evals/
│       └── checkout.eval.yaml    # Atomic evals
├── tests/
│   ├── spec-generated/           # Builder's tests
│   └── red-team/                 # Breaker's tests
├── .claude/
│   ├── agents/                   # Agent definitions
│   ├── skills/                   # Slash commands
│   ├── hooks/                    # Auto-test hook
│   ├── reviews/                  # Reviewer reports
│   ├── breaker-reports/          # Breaker reports
│   └── trustlayer/               # Config + builder output
└── .github/workflows/            # CI + Preview
```

## License

MIT
