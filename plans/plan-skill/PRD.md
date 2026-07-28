## Problem Statement

The user always runs `/prd` followed by `/issues` — never one without the other. The handoff is manual: PRD finishes, asks "ready for /issues?", user invokes `/issues`, the issues skill re-reads the PRD and re-explores the codebase. Two invocations, one redundant context-gathering step, and a prompt gap in between.

## Solution

Create a `/plan` skill that merges PRD and Issues into one continuous workflow. The user invokes `/plan` once. The agent explores the codebase, drafts and writes a PRD (with user approval), then immediately drafts vertical-slice issues (with user approval), writes all artifacts, and asks permission to commit. No second invocation, no re-exploration.

## User Stories

1. As a developer, I want to invoke `/plan` once and get both a PRD and issue breakdown, so that I don't have to manually chain two skills
2. As a developer, I want the agent to ask me to approve the PRD before writing it to disk, so that I can course-correct early
3. As a developer, I want the PRD written to disk before issues are drafted, so that I have a durable artifact and can free context
4. As a developer, I want the agent to draft issues silently after PRD approval and only interrupt me to approve the issue breakdown, so that I'm not interrupted unnecessarily
5. As a developer, I want the agent to ask permission before committing plan artifacts, so that I control when commits happen
6. As a developer, I want a clear "stop here, run ralph" message after the commit, so that I know the next step
7. As a developer, I want `plan-start` to output a simple `{ worktreePath, branch, planDir }` JSON, so that all paths are derived from one directory
8. As a developer, I want `plan-end` to commit all plan artifacts via `git-commit-message`, so that the commit message follows repo conventions
9. As a developer, I want `/grill-me` to offer `/plan` as an exit option, so that the skill chain reflects the new workflow
10. As a developer, I want the old `/prd` and `/issues` skills deleted, so that there's no confusion about which skill to use

## Implementation Decisions

- **Merged skill**: Single `tools/ai/claude/config/skills/plan/SKILL.md` with 7 steps:
  1. Explore codebase + glossary
  2. Sketch modules, get user confirmation (modules + test scope)
  3. Write PRD.md + COMMIT_HINT.md to disk (after user approves PRD content)
  4. Draft vertical slices (no re-exploration — context already loaded)
  5. Confirm slices with user
  6. Write issues/, state.json, GUIDANCE.md
  7. Ask user permission, then commit via `plan-end`; tell user to stop and run ralph

- **Scripts**: Two scripts in `scripts/bin/ai/plan/`:
  - `plan-start` — worktree creation + simplified JSON output (`worktreePath`, `branch`, `planDir`). Renamed from `prd-end`, same core logic.
  - `plan-end` — minimal: `git add plans/<slug>/ && git commit` with message from `git-commit-message`

- **References**: All reference templates copied into `plan/references/`: `prd-md.md`, `issues-XX-slug.md`, `state-json.md`, `guidance-md.md`. Commit-hint reference stays in ralph (shared concern).

- **Cleanup**: Delete `skills/prd/`, `skills/issues/`, `scripts/bin/ai/prd/` entirely

- **Downstream updates**: `grill-me/SKILL.md` updated — `/plan` replaces `/prd`, reordered to first position. Ralph untouched (derives paths from plan directory, no skill references).

## Testing Decisions

- `plan-start`: Bats tests migrated from `prd-end.bats`, updated for new output shape (3 fields instead of 4). Tests: planDir path correct, exit 1 without branch when not in worktree, worktreePath and branch fields present.
- `plan-end`: Bats tests for the commit behavior. Tests: calls git-commit-message, stages plan directory, creates commit.
- The SKILL.md is a prompt — not testable by automated tests.

## Out of Scope

- Changes to ralph or ralph-start (already derives paths from plan directory)
- Any interactive "what do you want to do next?" prompts between phases
- Validation of plan artifact completeness in `plan-end` (decided: minimal)
- Keeping `/prd` or `/issues` as standalone skills
