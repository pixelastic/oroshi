## Problem Statement

`vfrevert` (alias for `git-file-revert`) has no Tab completion and no Ctrl-P fzf picker. Users must type file paths manually, with no discovery aid. By contrast, `vfa` (`git-file-add`) already provides both — Tab completes stageable files and Ctrl-P opens an fzf picker. `vfrevert` deserves the same DX. Additionally, `git-file-revert` uses `git checkout --` unconditionally, which silently fails on newly created files (staged-new or untracked) that have no HEAD version to restore.

## Solution

Give `vfrevert` the same Tab + Ctrl-P experience as `vfa`, sourced from the full set of dirty files (staged and unstaged). Fix `git-file-revert` to handle all three revert cases: restore from HEAD for modified/deleted files, `git rm -f` for staged-new files, and `rm` for untracked files.

## User Stories

1. As a developer, I want Tab after `vfrevert` to list all dirty files, so that I can discover what can be reverted without leaving the terminal.
2. As a developer, I want the Tab completion list to show each file's git status (modified, deleted, new), so that I understand what reverting will do.
3. As a developer, I want files closest to my working directory to appear first in Tab completion, so that the most relevant choices are at the top.
4. As a developer, I want Ctrl-P after typing `vfrevert` to open an fzf picker with all dirty files, so that I can fuzzy-search and select files interactively.
5. As a developer, I want the fzf picker to color files by status (red=deleted, yellow=modified, green=added), so that I can visually distinguish file states.
6. As a developer, I want the fzf picker to show a diff preview for modified files, so that I can confirm which changes will be reverted.
7. As a developer, I want `vfrevert` on a newly staged file to delete it from the index and disk, so that the repo returns to a clean state as if the file was never added.
8. As a developer, I want `vfrevert` on an untracked file to delete it from disk, so that the file is gone without any git errors.
9. As a developer, I want `vfrevert` on a modified or deleted tracked file to restore the HEAD version, so that working-tree changes are discarded.
10. As a developer, I want `vfrevert` to handle multiple files in a single call, so that I can revert several files at once from the fzf picker.

## Implementation Decisions

- **Revert logic** — `git-file-revert` iterates over each argument and dispatches to one of three strategies:
  1. `git cat-file -e HEAD:"$file"` succeeds → `git checkout -- "$file"` (tracked, has HEAD version)
  2. File not in HEAD but in index (`git ls-files --error-unmatch`) → `git rm -f "$file"` (staged-new)
  3. Otherwise → `rm "$file"` (untracked)

- **Data source** — both the fzf picker and the Tab compdef draw from `git-file-list-dirty-raw`, which returns all dirty files (staged + unstaged) in `STATUS:FILEPATH` format. This function already exists and handles M, A, D for all staging states.

- **fzf picker** — new script `fzf-git-files-dirty` follows the standard picker subcommand contract (`--source`, `--options`, `--preview`, `--postprocess`). Preview reuses `git diff HEAD` (same as the stageable picker) — for staged files this shows the full diff vs HEAD.

- **Tab completion data transform** — new autoload function `complete-git-files-dirty` wraps `git-file-list-dirty-raw`, sorts by proximity (via `sort-filepaths`), and outputs `filepath:status-label` pairs for `_describe`. Label strings: `- Deleted`, `~ Modified`, `+ New file` (matching existing convention).

- **Compdef** — new `_git-files-dirty` function calls `complete-git-files-dirty` and renders a colored header labeled "Dirty files". Registered for `git-file-revert` only (ZSH alias expansion makes explicit registration of `vfrevert` unnecessary).

- **Ctrl-P** — `vfrevert` added to `specialPickers` mapping, pointing to `fzf-git-files-dirty`. `git-file-revert` is not added (Ctrl-P is triggered by the last word in the buffer, which will always be the alias).

## Testing Decisions

Good tests verify observable behavior through the public interface — they do not assert on internal implementation details or intermediate state.

**`fzf-git-files-dirty --source`** (bats):
- Real git repo created in `setup()` via `bats_git_dir`
- Tests cover: empty repo returns no output, modified file appears with `M:` prefix, deleted file appears with `D:` prefix, staged-new file appears, untracked file appears
- Prior art: `fzf-git-files-dirty-stageable.bats` (same directory), `git-file-list-dirty-raw.bats`

**`git-file-revert`** (bats):
- Real git repo created in `setup()` via `bats_git_dir` with an initial commit
- Tests cover:
  - Modified tracked file is restored to HEAD content
  - Deleted tracked file is restored to disk
  - Staged-new file is removed from disk and unstaged from index
  - Untracked file is removed from disk
  - Multiple files reverted in a single call
- Assertions check filesystem state and `git status` output, not internal git commands
- Prior art: `git-file-list-dirty-raw.bats` for git repo setup pattern

## Out of Scope

- Renaming `git-file-revert` or changing its CLI interface beyond the revert-logic fix
- Adding a `--source` flag or any new CLI surface to `git-file-revert`
- Handling rename conflicts (`old -> new` format) in the revert logic
- Tab completion or Ctrl-P for `git-file-revert` called from inside a git submodule
- Testing `complete-git-files-dirty` in isolation
- Testing `_git-files-dirty` (thin compdef wrapper, no meaningful isolated behavior)
