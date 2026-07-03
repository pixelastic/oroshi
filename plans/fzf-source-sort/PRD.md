## Problem Statement

When using `ctrl-shift-p` or `ctrl-p` to search files, candidates are listed in raw alphabetical order by full path. Because `_` (0x5F) sorts before `c` (0x63) in ASCII, directories prefixed with `__` (e.g. `__lib/`, `__tests__/`) float above root-level files like `ctrl-b`. This makes the list feel like "folders first, files second" and buries the most immediately relevant files at the top of a deeply nested tree.

## Solution

Replace the candidate ordering produced by `fzf-source` in both `ctrl-p` and `ctrl-shift-p` with a **DFS files-first** order: root files appear first, then for each immediate subdirectory (alphabetically), all its direct files appear before recursing into its own subdirectories. This matches the natural mental model of "proximity" — the closer a file is to the root, the earlier it appears.

The ordering is implemented in `sort-filepaths`, the existing autoload utility for path sorting, so all callers benefit from the improved ordering.

## User Stories

1. As a developer using `ctrl-p`, I want root-level files to appear at the top of the candidate list, so that the most directly accessible files are immediately visible.
2. As a developer using `ctrl-shift-p`, I want files within a subdirectory to appear before that subdirectory's own nested subdirectories, so that I can navigate the tree in a predictable depth-first order.
3. As a developer, I want `__lib/` and `__tests__/` directories to appear after root files, not before them, so that utility directories don't obscure the main entry points.
4. As a developer, I want files within `__lib/` to appear grouped together before `__lib/__tests__/`, so that related files are clustered and easy to scan.
5. As a developer using git completion (`complete-git-files-dirty-stageable`, `complete-git-files-staged`), I want staged or dirty files sorted with root files first and deeper files after, so that the most relevant changes appear first in tab completion.
6. As a developer using `git-submodule-list`, I want submodules sorted by proximity (root-level submodules first), so that the listing reflects the project's structure intuitively.
7. As a developer, I want upward paths (`../`) to continue sorting after all downward paths, so that files outside the current scope don't interfere with the primary listing.

## Implementation Decisions

- **`sort-filepaths` is the single sorting module.** Its current weight-based logic (weight 1 = root, weight 2 = downward, weight 3 = `../`) is replaced with a DFS files-first algorithm. The public interface (stdin or args → stdout) is unchanged.
- **DFS files-first algorithm:** For each filepath, a sort key is constructed by traversing path segments. Each directory segment is prefixed to sort after files at the same level; the final filename segment sorts before any directory segment at that level. This encodes the "files before subdirs" invariant at every level of the tree.
- **`../` paths preserved as last.** Upward paths retain weight 3 behavior — they sort after all downward paths. No callers currently pass `../` paths; this is a safety measure.
- **`fzf-source-files` FZF Helper is the integration point.** After `fd` produces the raw file list, the output is piped through `sort-filepaths` before the colorization loop. No change to `fzf-source`, `fzf-options`, or any other Lifecycle Function.
- **No change to `ctrl-p` or `ctrl-shift-p`.** Both FZF Scripts already delegate to `fzf-source-files` — the sort is transparent to them.

## Testing Decisions

Good tests assert observable output behavior given controlled input — not internal data structures or intermediate states. For `sort-filepaths`, the input is a list of relative paths (as strings) and the output is the reordered list. No filesystem setup is required.

**`sort-filepaths` gets a new bats test file** in the `misc/__tests__/` directory, following the same pattern as `simplify-path.bats` and `slugify.bats`. Tests cover:
- Root files appear before any subdirectory files
- Files in a subdirectory appear before that subdirectory's own nested subdirectories
- Alphabetical ordering within the same level
- `../` paths sort after all downward paths
- Single-file and empty input edge cases

**`fzf-source-files.bats` is not extended.** The existing tests cover colorization output. Ordering is now a responsibility of `sort-filepaths`, which is tested in isolation.

Prior art: `tools/term/zsh/config/functions/autoload/misc/__tests__/simplify-path.bats` — uses `bats_run_zsh "function-name args"` with no filesystem mocking.

## Out of Scope

- Changing the sort order for directory candidates (`fzf-source-directories`, `ctrl-shift-o`, etc.)
- Sorting by modification time, file size, or any criterion other than path structure
- Changing the colorization logic in `fzf-colorize-path`
- Updating the FZF glossary

## Further Notes

`sort-filepaths` is an autoload ZSH function available via `$fpath` — it does not need to be explicitly sourced in `fzf-source-files.zsh`. Tests invoke it via `bats_run_zsh "sort-filepaths ..."` which picks it up from the worktree's autoload path.
