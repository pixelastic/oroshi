## Problem Statement

`git-branch-list` (alias `vbl`) shows all local branches in a flat list with no visual distinction between branches that have an active linked worktree and those that do not. When working heavily with git worktrees, scanning the branch list to identify which branches are checked out somewhere on disk requires cross-referencing with `git-worktree-list` — there is no unified view. Additionally, when a branch is a worktree, the most useful signals (dirty count, distance vs main) are absent, and the date and commit columns are in the wrong order for quick scanning.

## Solution

Enhance `git-branch-list` so that:

1. Branches with an active linked worktree are rendered with an orange background, light text, and a closing powerline separator — the same visual language as the Worktree Segment in the Context Badge — making them immediately distinguishable in the list.
2. The column layout adapts per row: worktree branches show dirty count and ahead/behind distance vs main; non-worktree branches show ahead/behind distance vs their remote tracking branch and the remote name when non-default.
3. The date column moves before the commit hash column across all rows.
4. `git-branch-list-raw` is updated to emit ahead and behind as separate fields (consistent with `git-worktree-list-raw`), and all consumers are updated accordingly.

## User Stories

1. As a developer, I want worktree branches highlighted in orange in `vbl` so that I can instantly see which branches are checked out in a worktree without running a separate command.
2. As a developer, I want to see the dirty count for worktree branches in `vbl` so that I know which worktrees have uncommitted work.
3. As a developer, I want to see ahead/behind distance vs main for worktree branches so that I know how far each worktree has diverged.
4. As a developer, I want to see ahead/behind distance vs the remote tracking branch for non-worktree branches so that I know their push/pull status.
5. As a developer, I want the remote name to appear only for non-worktree branches where it is non-default so that the list stays uncluttered.
6. As a developer, I want the date column to appear before the commit hash in all rows so that I can scan recency at a glance.
7. As a developer, I want the powerline separator at the end of the branch name cell for worktree branches so that the visual style matches the Context Badge.
8. As a developer, I want the powerline separator defined as a variable (not inlined as a literal character) so that it survives file edits without being silently stripped.
9. As a developer, I want all rows to occupy the same column positions so that the table remains aligned regardless of whether a branch is a worktree.
10. As a developer, I want branch tab-completion to continue working correctly after the raw format change so that my workflow is uninterrupted.

## Implementation Decisions

### Column layout

All rows share the same column positions:

| # | Worktree branch | Non-worktree branch |
|---|---|---|
| 1 | pointer (``) or empty | same |
| 2 | branch name — orange bg + light text + separator | branch name — standard colorize |
| 3 | dirty count (`±N`) if non-zero, else empty | remote name if non-default, else empty |
| 4 | ahead vs main if non-zero, else empty | ahead vs remote tracking branch |
| 5 | behind vs main if non-zero, else empty | behind vs remote tracking branch |
| 6 | relative date | same |
| 7 | short commit hash | same |
| 8 | commit message | same |

Columns 3–5 are semantically different per row type but occupy the same positions, so the `table` aligner keeps everything flush. The visual difference in the branch name cell (col 2) is the primary cue that differentiates the two row types.

### `git-branch-list-raw` format change

The `%(upstream:track)` field (combined `[ahead N, behind M]` string) is replaced by two separate fields: `%(upstream:ahead)` and `%(upstream:behind)`. This makes the format consistent with `git-worktree-list-raw`, which already emits ahead before behind. The new field order is:

```
branch▮hash▮remoteName▮remoteBranchRef▮ahead▮behind▮date▮message
```

(8 fields, up from 7).

### `git-branch-colorize` — `--worktree` flag

A new `--worktree` flag is added. When passed, the function renders the branch name with orange background (`COLOR_ORANGE_7`), light foreground (`COLOR_ORANGE_1`), and a closing powerline separator (`COLOR_ORANGE_7` on transparent). The powerline character is stored in a local variable at the top of the function to prevent silent loss during file edits. The flag is explicit — the caller decides; there is no auto-detection inside the function.

`git-worktree-list` continues calling `git-branch-colorize` without `--worktree` and is unaffected.

### `git-branch-list` — worktree detection

At startup, `git-branch-list` calls `git-worktree-list-raw` and builds an associative array keyed by branch name, with values `dirty▮ahead▮behind`. For each branch in the loop, a lookup determines whether it is a worktree branch and which rendering path to take.

### Consumer update — `complete-git-branches-local`

This function reads `splitLine[1]` (branch name) and `splitLine[7]` (commit message). After the raw format change, the message moves to `splitLine[8]`. The index is updated accordingly; no other logic changes.

### UTF-8 / powerline character safety

The powerline right-arrow (U+E0B0) is invisible in `Read` tool output and is silently stripped by `Write`. Wherever this character is needed, it must be assigned to a named local variable at the top of the function using `Edit` (never `Write`), and all usages must reference that variable. This applies to `git-branch-colorize`.

## Testing Decisions

Good tests verify observable external behaviour (output text, exit code, field structure) and do not assert on implementation details like internal variable names or call order.

### `git-branch-list-raw` — permanent BATS tests

Written **before** the format change to lock down the current behaviour, then updated when the format changes. Tests verify:

- Output contains the expected number of `▮`-delimited fields per line
- Field 1 is a valid branch name
- Fields 5 and 6 (after the change) are numeric ahead/behind values, not the `[ahead N]` track string

Prior art: `git-branch-current.bats`, `git-branch-slug.bats` in the same `__tests__/` directory.

### `git-branch-colorize` — scaffold BATS (`.scaffold.bats`, deleted after implementation)

TDD red-green loop. Tests verify:

- `--worktree` flag produces ANSI output containing the branch name
- `--worktree` flag output differs from plain output (background codes present)
- Absence of `--worktree` produces unchanged plain output (regression guard)

### `git-branch-list` — scaffold BATS (`.scaffold.bats`, deleted after implementation)

TDD red-green loop. Tests verify:

- A branch that is a worktree produces a row with orange-highlighted branch name
- A branch that is not a worktree produces a row without orange highlight
- Column count per row is consistent across both row types

### `complete-git-branches-local` — scaffold BATS (`.scaffold.bats`, deleted after implementation)

TDD red-green loop. Tests verify:

- Output format is `branch:message` with the correct message field after the index update

Prior art: `git-branch-colorize.bats` for mock/stub patterns (`bats_mock`, `bats_run_function`).

## Out of Scope

- Changing the visual style of `git-worktree-list` (`vwl`) — it remains unchanged.
- Adding worktree detection to `git-branch-colorize` automatically — the flag is always explicit.
- Displaying the worktree path in `git-branch-list`.
- Showing worktree data for remote branches.
- Updating the `--zsh` rendering path in `git-branch-colorize` for the `--worktree` flag (prompt usage is not a current requirement).
