# PRD — Worktree Dirty Count in `vwl`

## Problem Statement

`vwl` (git-worktree-list) shows ahead/behind counts vs `main` and the last commit message, but gives no signal about whether a Worktree has uncommitted work in progress. Looking at the list, a Worktree with 5 modified files looks identical to a clean, finished one. The only way to check is to switch to the Worktree — which defeats the purpose of the list.

## Solution

Add a **Dirty Count** column to `vwl`: the number of files in each Worktree contributing to its dirty state (staged, unstaged, or untracked). Displayed with the `±` icon in violet (`COLOR_ALIAS_GIT_WORKTREE_DIRTY`), hidden when zero — consistent with how ahead/behind columns behave.

At the same time, refactor `git-worktree-list-raw` to output separate `ahead` and `behind` fields instead of a single `distance` string, so the raw output mirrors the display column order exactly.

## User Stories

1. As a developer, I want `vwl` to show the number of dirty files in each Worktree, so that I can see at a glance which ones have uncommitted work in progress.
2. As a developer, I want the dirty count column to be hidden when the Worktree is clean, so that the list stays scannable and uncluttered.
3. As a developer, I want the dirty count to use a distinct violet color (`±` icon), so that I can distinguish it from the green ahead and red behind columns.
4. As a developer, I want the dirty count to include staged, unstaged, and untracked files, so that I get a complete picture of in-progress work.
5. As a developer, I want `git-directory-dirty-count <path>` to be callable standalone from any path, so that other scripts can reuse it without reimplementing the count logic.
6. As a developer, I want `git-file-list-dirty-raw` to accept an optional path argument, so that dirty file inspection can target any Worktree, not just the current directory.

## Implementation Decisions

### Module 1 — `COLOR_ALIAS_GIT_WORKTREE_DIRTY` (theming)

New color token added to `theming/env/colors.zsh`. Value: `21` (violet, `#a78bfa`).

Named `WORKTREE_DIRTY` rather than reusing `MODIFIED` to give the display column a distinct, stable semantic identity — even though the visual value is the same today.

### Module 2 — `git-file-list-dirty-raw` (git/file, modified)

Add an optional path argument. When provided, git operations run against that path. When omitted, fall back to `git-directory-root` (current behaviour, unchanged).

Output format unchanged: one `STATUS:FILEPATH` line per dirty file.

### Module 3 — `git-directory-dirty-count` (git/directory, new)

New deep module. Interface: `git-directory-dirty-count [path]` → integer (0..N).

Implementation: calls `git-file-list-dirty-raw [path]`, counts output lines. Returns `0` when the Worktree is clean. Always succeeds (exits 0).

Placed in `git/directory/` alongside `git-directory-is-dirty` — both are scalar properties of a git directory, not Worktree-specific concepts.

### Module 4 — `git-worktree-list-raw` (git/worktree, modified)

New output format — one field per display column, in display order:

```
branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message
```

`distance` string ("ahead X, behind Y") is replaced by two separate integer fields `ahead` and `behind`. `dirtyCount` is inserted before them. `path` remains as a non-displayed field used for the current Worktree marker.

`git-worktree-list` is the only consumer — these two are intentionally coupled.

### Module 5 — `git-worktree-list` (git/worktree, modified)

Parses the new raw format. Field indices shift:

| Index | Field | Used for |
|---|---|---|
| 1 | branch | branch column |
| 2 | path | current marker detection |
| 3 | dirtyCount | dirty column |
| 4 | ahead | ahead column |
| 5 | behind | behind column |
| 6 | relativeDate | date column |
| 7 | message | message column |

Dirty column: colorize `${dirtyCount}±` with `COLOR_ALIAS_GIT_WORKTREE_DIRTY`, hidden when `dirtyCount == 0`. Column is inserted before ahead/behind.

Ahead/behind parsing simplifies: direct integer read, no string parsing of "ahead X, behind Y".

### Module 6 — `git-file-edit` (git/file, lower priority)

Once `git-file-list-dirty-raw` accepts a path argument, `git-file-edit` can be updated to accept and forward a path argument. Lower priority — current directory behaviour is unchanged and still correct without this update.

## Testing Decisions

Good tests verify observable behaviour — stdout, exit codes, filesystem side-effects. They do not assert on internal variable names or call sequences.

Prior art: bats files in `scripts/bin/__tests__/`, using `run_zsh_fn`, `bats_tmp`, temp git repos built with `git init` + `git worktree add`.

### `git-file-list-dirty-raw` (new bats file)

- Returns `M:filepath` for a modified tracked file
- Returns `A:filepath` for a new untracked file
- Returns `D:filepath` for a deleted tracked file
- Returns empty output for a clean directory
- Accepts a path argument and lists dirty files in that path (not `$PWD`)

### `git-directory-dirty-count` (new bats file)

- Returns `0` for a clean Worktree
- Returns the correct count when files are modified
- Counts staged files
- Counts untracked files
- Accepts a path argument targeting a different Worktree

### `git-worktree-list-raw` (update existing bats file)

- Update field-position assertions to match new format (`branch▮path▮dirtyCount▮ahead▮behind▮...`)
- Add: dirtyCount field is `0` for a fresh Worktree
- Add: dirtyCount field reflects actual dirty file count in a Worktree with uncommitted changes

### `git-worktree-list` (update existing bats file)

- Update tests that assert on field count or field order
- Add: dirty count appears in output when a Worktree has uncommitted files
- Add: dirty count is absent from output when all Worktrees are clean

## Out of Scope

- Updating `vfe`/`vft` to accept a path argument — `git-file-list-dirty-raw` gets the path support, but wiring it into `vfe`/`vft` is a separate PR.
- Showing dirty state in the shell prompt (the leaf icon already signals ahead/behind; adding dirty state there is a separate decision).
- Breaking `git-worktree-list-raw` into a public API — it remains intentionally coupled to `git-worktree-list`.
- Counting dirty files per-file-type or showing a breakdown (M/A/D split) — Dirty Count is a single integer.

## Further Notes

- Domain glossary updated: `docs/worktrees/CONTEXT.md` now defines **Dirty** and **Dirty Count**.
- Resolved naming: count function is `git-directory-dirty-count` (not `git-file-dirty-count` or `git-worktree-dirty-count`) — Dirty Count is a scalar property of a directory, raw listing is a file-domain concern.
- Color token name: `COLOR_ALIAS_GIT_WORKTREE_DIRTY` — worktree-scoped even though the value matches `COLOR_ALIAS_GIT_MODIFIED` today, to preserve semantic independence.
