## Problem Statement

The `vws` command (worktree switch) has a functional but visually poor completion. It shows a flat list of branch names with no context, while the comparable `vbs` command (branch switch) shows colored names with a commit message description on the right. When switching worktrees, the developer has no at-a-glance information about the state of each worktree (dirty files, distance from main, last commit).

Additionally, the ahead/behind logic is duplicated across multiple functions (`git-worktree-list-raw`, `git-worktree-distance`, `git-worktree-is-ahead`, `git-worktree-is-behind`, `prompt/git.zsh`) with no shared primitive.

## Solution

Introduce `git-worktree-distance-raw` as the single primitive for computing ahead/behind counts (branch name in, `ahead▮behind` out). Consolidate all callers onto it, deleting the now-redundant `git-worktree-distance`.

Upgrade `complete-git-worktrees` to output `name:description` pairs compatible with zsh's `_describe`, where the description compactly shows dirty file count, ahead/behind commits, and last commit message — with zero values suppressed. Add a `zstyle` so worktree names are colored the same way as branches (`main` in blue, others in orange).

## User Stories

1. As a developer, I want worktree completion entries to show the number of dirty files, so I can see at a glance which worktrees have uncommitted work.
2. As a developer, I want worktree completion entries to show how many commits the branch is ahead of main, so I know which worktrees have unpushed work.
3. As a developer, I want worktree completion entries to show how many commits the branch is behind main, so I know which worktrees need rebasing.
4. As a developer, I want worktree completion entries to show the last commit message, so I can recall the context of each worktree.
5. As a developer, I want zero values for dirty/ahead/behind to be suppressed, so the description is not cluttered with zeroes when a worktree is clean and in sync.
6. As a developer, I want `main` to always appear first in the completion list, so the base worktree is always easy to reach.
7. As a developer, I want `main` to be colored blue and other worktrees to be colored orange, so the base worktree is visually distinct — consistent with branch completion.
8. As a developer, I want the icons for dirty, ahead, and behind to be defined as named variables at the top of the function, so they are easy to customize without hunting through logic.
9. As a developer, I want `git-worktree-distance-raw` to be a simple, testable function that takes a branch name and returns `ahead▮behind`, so other functions can delegate to it without duplicating `git rev-list` logic.
10. As a developer, I want `git-worktree-is-ahead` and `git-worktree-is-behind` to use `git-worktree-distance-raw` internally, so the distance logic lives in one place.
11. As a developer, I want the prompt's ahead/behind display to use `git-worktree-distance-raw` internally, so it benefits from the same consolidation.
12. As a developer, I want `git-worktree-list-raw` to use `git-worktree-distance-raw` internally, so its second-pass enrichment does not duplicate the rev-list logic.
13. As a developer, I want `git-worktree-distance` to be deleted once it has no callers, so the codebase has no dead code.

## Implementation Decisions

### New primitive: `git-worktree-distance-raw`

- **Signature**: takes a branch name as its sole argument; runs from the current directory (caller must be inside a git repo).
- **Output**: `ahead▮behind` using the standard `▮` field separator. Exits 1 if the branch cannot be resolved or `main` does not exist.
- **Mechanism**: `git rev-list --left-right --count "${branch}...main"`, split on tab into two integers.
- All callers that currently do this rev-list inline must be updated to use this function instead.

### Refactor: `git-worktree-list-raw`

- Second-pass enrichment replaces its inline `git rev-list` block with a call to `git-worktree-distance-raw "$entryBranch"`, splitting the `▮`-separated result into `ahead` and `behind`. Fallback to `0▮0` on failure.
- Output format is unchanged: `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message`.

### Refactor: `git-worktree-is-ahead` and `git-worktree-is-behind`

- Both accept an optional path argument (defaulting to `$PWD`).
- They resolve the branch via `git -C "$worktreePath" symbolic-ref --short HEAD`, then call `git-worktree-distance-raw "$branch"` from within that path's context (subshell `cd`).
- `is-ahead` checks field 1 > 0; `is-behind` checks field 2 > 0.
- External behavior is unchanged.

### Refactor: prompt (`git.zsh`)

- Replaces the call to `git-worktree-distance` and its string-parsing (`ahead N, behind M`) with a call to `git-worktree-distance-raw "$branch"` and `▮`-split parsing.
- The branch is already resolved in the prompt's context; no path lookup needed.

### Delete: `git-worktree-distance`

- After the above refactors, `git-worktree-distance` has no callers.
- Both the function file and its bats test file are deleted.

### Improve: `complete-git-worktrees`

- **`main` entry**: fetched inline — dirty count via `git-directory-dirty-count` on the main worktree path (resolved via `git-worktree-main`), last message via `git log -1 --format="%s" main`. Ahead/behind are always 0 for main and therefore suppressed.
- **Linked worktrees**: parsed from `git-worktree-list-raw` output (fields: branch, dirtyCount, ahead, behind, message). No additional git calls.
- **Description format**: `~{dirty} ↑{ahead} ↓{behind}  {message}`, where each counter is suppressed when zero. Examples:
  - dirty=3, ahead=2, behind=0 → `~3 ↑2  fix auth`
  - dirty=0, ahead=0, behind=0 → `fix auth`
  - dirty=0, ahead=1, behind=2 → `↑1 ↓2  fix auth`
- **Output format**: `name:description` — the `:` separator is what zsh `_describe` uses to separate the completion word from its displayed description.
- **Icon variables**: `iconDirty`, `iconAhead`, `iconBehind` declared as local variables at the top of the function for easy customization.
- **Ordering**: `main` always first; linked worktrees follow in the order returned by `git-worktree-list-raw`.
- **Fallback**: if outside a git repo, `git-worktree-list-raw` returns empty and git commands for main fail silently → output is just `main` (no description), consistent with current behavior.

### Modify: `styling.zsh`

- Add a `zstyle list-colors` entry for `git-worktree-switch` using the existing `listColorsGitBranch` palette. This colors `main` in blue and all other worktree names in orange, consistent with branch completion coloring.
- No new color palette needed — reuses the existing branch one.

## Testing Decisions

Good tests assert external behavior (output format, exit codes, side effects) — not internal implementation. A refactor that preserves behavior should leave existing tests green without modification.

### New tests: `git-worktree-distance-raw.bats`

- Returns `0▮0` for a branch with no divergence from main.
- Returns correct ahead count when the branch has commits not in main.
- Returns correct behind count when main has commits not in the branch.
- Exits 1 when the branch does not exist.

Prior art: `git-worktree-distance.bats` (same setup pattern with `bats_git_worktree`, `git commit --allow-empty`).

### Updated tests: `complete-git-worktrees.bats`

- "outputs only `main` when no linked worktrees exist" — update assertion to `[[ "$output" == "main"* ]]` (main now has an optional description).
- Add: linked worktree entries include description (dirty/ahead/behind/message fields present).
- Add: zero counters are suppressed in the description.
- Existing tests for repo scoping and `feat/x` exclusion remain valid and unchanged.

### Deleted tests: `git-worktree-distance.bats`

- Deleted alongside the function.

### Unchanged tests

- `git-worktree-is-ahead.bats`, `git-worktree-is-behind.bats`, `git-worktree-list-raw.bats` — internal refactors only, external behavior preserved, tests pass as-is.

## Out of Scope

- Adding worktree completion coloring for commands other than `git-worktree-switch`.
- Showing relative date in the completion description.
- Showing the worktree path in the completion description.
- Changing the `_describe` header text or color for the worktree section.
- Refactoring `git-worktree-is-ahead` / `git-worktree-is-behind` test files beyond what breaks.
- Any changes to `git-worktree-list` (the display command) — it already works correctly.
