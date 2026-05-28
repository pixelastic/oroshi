## Problem Statement

The ralph workflow generates files (PRD, issues, progress log, state) that
agents need to implement features iteratively. These files were previously
tracked in a `docs/` then `ralph/` directory, but the format has accumulated
debt:

- `issues.json` uses a flat structure where multiple entries share the same id (one per test case, not per issue), with a `passes` key that doesn't reflect its purpose
- `progress.md` mixes four concerns in one file: dependency graph, guidance, log, and session notes — all in markdown, hard to parse selectively
- The commit-writer skill is dead code, superseded by `git-commit-message.js`
- The directory is named `ralph/` (the tool) instead of reflecting its purpose (implementation plans)
- `ralph-directory` and `ralph-progress` reference the old directory name
- `.ralph-state.json` is a hidden file unnecessarily hard to edit
- The ralph skill picks issues with vague heuristics instead of deterministic script logic
- `prd-end` outputs paths referencing `ralph/` instead of `plans/`
- `git-worktree-is-ralph` checks for `ralph/<slug>/issues.json` instead of the new structure

## Solution

Restructure the ralph workspace into a clean separation of concerns:

```
plans/<slug>/
  PRD.md              write-once by to-prd
  GUIDANCE.md         created by to-issues, appended by ralph (discoveries)
  state.json          created by to-issues, updated by ralph (done + recap)
  review-log.md       created on-demand by ralph (skipped review feedback)
  ralph.json          gitignored, runtime state for ralph loop
  issues/
    01-slug.md        write-once by to-issues
    02-slug.md
    ...
```

state.json replaces issues.json with a new schema: one entry per issue (not per test case), `done` instead of `passes`, `blocked_by` for dependency graph, `recap` for post-implementation summary.

GUIDANCE.md replaces the guidance + discoveries sections of progress.md. Static guidance from to-issues at the top, discoveries appended by ralph after each issue.

review-log.md captures skipped review feedback with full context (code, problem, reason for skipping) for process improvement.

A new `ralph-start` script deterministically picks the next issue and outputs all paths the skill needs. `ralph-end` only manages ralph.json runtime state.

## User Stories

1. As a developer running ralph, I want the next issue picked deterministically (first by id, unblocked, not done), so that issue selection is predictable and reproducible
2. As a developer reading state.json, I want one entry per issue with a clear `done` boolean and `recap`, so that I can see plan progress at a glance
3. As a developer reviewing git history, I want `recap` in state.json to appear in diffs, so that `git-commit-message` generates meaningful commit messages from it
4. As a developer running ralph in loop mode, I want the session runtime state (ralph.json) separated from the plan state (state.json), so that gitignored runtime doesn't pollute tracked plan state
5. As a developer, I want discoveries appended to GUIDANCE.md after each issue, so that subsequent issues benefit from accumulated knowledge without scanning all completed issues
6. As a developer improving my review process, I want skipped review feedback logged in review-log.md with the code snippet, the problem, and the reason for skipping, so that I can identify recurring false positives
7. As a developer, I want the workspace directory called `plans/` instead of `ralph/`, so that the directory name reflects its content (implementation plans) not the tool that operates on it
8. As a developer, I want issue files in an `issues/` subdirectory with 2-digit ids (01, not 0001), so that the plan root stays clean and autocompletion doesn't conflict between `issues/` and other files
9. As a developer, I want `plans-directory` and `plans-progress` scripts, so that the prompt and other tools reference the renamed structure
10. As a developer, I want `ralph-start` to output absolute paths and the full issue object from state.json, so that the skill doesn't need to resolve paths or parse state itself
11. As a developer, I want the commit-writer skill deleted, so that there's a single path for commit message generation (git-commit-message.js)
12. As a developer, I want GUIDANCE.md and PRD.md in uppercase, so that important read-first files are visually distinct from working files

## Implementation Decisions

- `state.json` schema: array of `{ id, issue, done, blocked_by, recap }` — no `title`, no `steps`, no `description`. The issue markdown file is the source of truth for content.
- `recap` key appears only when `done: true`. It's the primary input for commit message generation.
- `blocked_by` is an array of id strings. An issue is eligible when all ids in `blocked_by` have `done: true`.
- `ralph-start` outputs JSON: `{ status: "next"|"done", issue: {...}, paths: {...} }`. Exit 0 for both next and done. Exit 1 only for deadlock (all issues blocked, none done).
- `ralph-end` only manages ralph.json: sets `done: true`, checks if all issues in state.json are done to set `prd_done: true`. Does NOT modify state.json.
- The ralph skill is responsible for updating state.json (done + recap), GUIDANCE.md (discoveries), and review-log.md (skips).
- Issue markdown files are write-once. No Results section, no checkbox updates post-creation.
- GUIDANCE.md has two sections: `## Guidance` (static, by to-issues) and `## Discoveries` (append-only, by ralph with H3 per issue).
- review-log.md entries include: H2 per issue, H3 per skip with code block, problem description, and reason for ignoring.
- `plans-progress` outputs `done▮total` format (UTF-8 separator), same as current ralph-progress but reads state.json `.done` instead of `.passes`.
- `git-worktree-is-ralph` renamed/updated to check `plans/<slug>/state.json` instead of `ralph/<slug>/issues.json`.
- `prd-end` updated to output `plans/<slug>/PRD.md` instead of `ralph/<slug>/PRD.md`.
- Issue files use 2-digit ids: `issues/01-slug.md`, matching `"id": "01"` in state.json.
- ralph.json (not hidden, gitignored) replaces .ralph-state.json. Same content: `{ mode, done, prd_done }`.

## Testing Decisions

- Shell scripts (`plans-directory`, `plans-progress`, `ralph-start`, `ralph-end`, `ralph-state`) are tested with bats. Prior art: `scripts/bin/ai/ralph/__tests__/ralph-progress.bats`.
- Skill files (SKILL.md) are not unit-tested — they are validated by running the workflow end-to-end.
- `git-worktree-is-ralph` update tested with bats. Prior art: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-is-ralph.bats`.
- state.json schema validated implicitly by `ralph-start` and `plans-progress` tests (they parse it).
- No tests for: skill markdown content, reference doc content, commit-writer deletion.

## Out of Scope

- Changes to git-commit-message.js — it already reads the diff which will now include state.json recap and GUIDANCE.md discoveries.
- Changes to the review skill — review-log.md is passive logging, not feedback into review.
- Automatic cleanup of plans/ after worktree deletion — existing manual workflow handles this.
- Changes to the to-prd skill beyond updating the output path in prd-end.
- Migration of existing ralph/ directories in other worktrees — they'll be recreated as needed.

## Further Notes

- This is a bootstrapping situation: the PRD itself uses the new structure (`plans/progress-json/`) while implementing the tooling that creates this structure. The first issues will need to reference both old and new paths.
- The rename from `ralph/` to `plans/` touches: `ralph-directory` (becomes `plans-directory`), `ralph-progress` (becomes `plans-progress`), `prd-end`, `git-worktree-is-ralph`, `ralph` (the main script), and the prompt integration in `git.zsh`.
- The to-issues and ralph skill reference templates need updating to match the new file names and schema.
