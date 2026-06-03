## Problem Statement

The TDD skill's behavioral test reference doesn't account for code categories that structurally cannot have automated behavioral tests. An agent following the pivot question ("would this test survive a rewrite?") may answer "yes" for install scripts or pre-commit hooks, then propose behavioral tests that are impossible to run — requiring human correction.

## Solution

Add an `## Exceptions` section to `behavioral-tests.md`, placed as a short-circuit right after the pivot question. When the issue falls into a listed exception category, the agent skips behavioral tests entirely and uses scaffolding tests instead.

## User Stories

1. As an agent running the TDD skill on an install script issue, I want to recognize it as an exception category, so that I skip behavioral tests and propose scaffolding tests without human correction.
2. As an agent running the TDD skill on a pre-commit/lint-staged wiring issue, I want to recognize it as an exception category, so that I skip behavioral tests and propose scaffolding tests without human correction.
3. As a user reviewing agent-generated test plans, I want the agent to have already excluded untestable categories, so that I don't have to manually correct test sections.

## Implementation Decisions

- Single file change: `behavioral-tests.md` only (not SKILL.md, not issue template)
- New `## Exceptions` section placed immediately after the pivot question block, before `## Definition` — acts as a short-circuit
- Two named exception categories:
  - **Installation scripts** (apt, wget, mv to ~/local/bin/) — network, sudo, disk writes are unmockable
  - **Pre-commit / lint-staged wiring** — triggered only during real `git commit`, unrealistic to simulate
- When an exception matches: skip behavioral tests, use scaffolding tests exclusively
- No general principle added — the pivot question already serves as the general principle; these are specific exclusions to it

## Testing Decisions

No tests. This is a skill reference document (markdown), not executable code.

## Out of Scope

- Modifying `SKILL.md` Step 1 checklist
- Modifying the issue template (`issues-XX-slug.md`)
- Adding a general "unmockable side effects" principle (the pivot question already covers the general case)
- Other potential exception categories (will be added as they emerge)
