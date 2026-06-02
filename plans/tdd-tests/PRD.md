## Problem Statement

When Claude uses the `ralph` skill to implement an issue, the RED step instructs it to write "at least one test per acceptance criterion." This produces tests that are structurally mapped to spec bullets rather than observable behaviors — test names like `"AC1: ..."` or `"AC3+AC8: ..."`, and comments like `# Issue 04`. These tests are fragile, redundant, and don't communicate intent. The underlying concept of "Permanent Tests" is also poorly named: it describes lifespan, not purpose.

## Solution

Rename "Permanent Tests" to "Behavioral Tests" across all skills and templates. Split the existing `test-types.md` reference into two dedicated files — `behavioral-tests.md` and `scaffolding-tests.md` — each containing the pivot question, definition, and specific rules for that test type. Update `ralph` to reference behavioral-tests.md with explicit naming and grouping rules. Update `to-issues` to use the new terminology in the issue template.

## User Stories

1. As Claude running `ralph`, I want to read a clear behavioral-tests reference so that I write tests named after scenarios, not AC numbers.
2. As Claude running `ralph`, I want explicit rules that prohibit AC numbers in test names so that I never produce `"AC1: ..."` style names.
3. As Claude running `ralph`, I want to know that one test can cover multiple ACs so that I group by behavior, not by spec bullet.
4. As Claude running `ralph`, I want to know which edge cases deserve their own test so that I don't write tests for corrupt state or missing env vars unless they are distinct user-visible behaviors.
5. As Claude running `tdd`, I want the pivot question available in both reference files so that each file is self-contained and I understand why I'm in that file.
6. As Claude running `to-issues`, I want the issue template to use `## Behavioral Tests` so that the section name matches the concept.
7. As a developer reading an issue file, I want the section named `## Behavioral Tests` so that it communicates purpose (observable behavior) not lifespan (permanent).
8. As Claude running any skill, I want cross-skill references to use markdown links with an explicit `Read` instruction so that I know when and why to load a reference file.

## Implementation Decisions

- **Rename "Permanent Tests" → "Behavioral Tests"** everywhere: `tdd/SKILL.md`, `ralph/SKILL.md`, `to-issues/SKILL.md`, `to-issues/references/issues-XX-slug.md`.
- **Split `tdd/references/test-types.md`** into two files: `behavioral-tests.md` and `scaffolding-tests.md`. Delete `test-types.md`.
- **`behavioral-tests.md`** contains: pivot question (restated for context), definition (verifies observable behavior through public API, survives any internal rewrite), naming rules (sentences not AC numbers, group by scenario), scope rules (edge cases only if distinct user-visible behavior).
- **`scaffolding-tests.md`** contains: pivot question (restated), definition (verifies structural transformation, ephemeral), location rule (`plans/<slug>/scaffold/<issue-filename>.bats`), deletion rule (removed when plan is archived).
- **Pivot question** appears in both reference files (duplication is intentional — each file is self-contained) and remains as a decision gate in `tdd/SKILL.md` Step 1.
- **Cross-skill links** from `ralph` to `tdd` references use the pattern `[behavioral-tests.md](../tdd/references/behavioral-tests.md)` with an explicit `Read` instruction. Same pattern replaces the `@../tdd/test-types.md` annotation in `to-issues`.
- All skills are siblings in the same parent directory — relative paths like `../tdd/references/` are valid.
- No new scripts, CLI tools, or runtime code introduced — all changes are to skill/config markdown files.

## Testing Decisions

No tests. Changes are limited to skill and template markdown files — these are the artifacts themselves, not code with testable behavior. Per project convention, config/skill file changes do not get bats or vitest coverage.

## Out of Scope

- Migrating existing issue files in `plans/` — none of them currently use `## Permanent Tests` sections, so no migration is needed.
- Updating `zsh-writer/references/testing.md` — the behavioral naming rules belong in `tdd`, not in a language-specific skill.
- Changing how scaffolding tests work — only the reference documentation is updated, not the behavior.
- Updating the `tdd` skill's red-green-refactor loop mechanics.

## Further Notes

- The issue that triggered this: `plans/claude-always/issues/04-hook-session-state-ask-escalate.md` (in the `claude-always` worktree).
- Example of correct behavioral tests: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats` lines 29–95 in this worktree.
- The `test-driven-development` skill has been deleted — `tdd` is the canonical TDD skill.
