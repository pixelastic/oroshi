## Problem Statement

The `vfa` (git-file-add) and `vfrevert` ctrl-p pickers colorize dirty file paths with a single flat git-status color (purple for modified, green for added, red for deleted). This is confusing because those colors overlap with the extension-based and directory colors used in the normal ctrl-p picker — purple looks like a script file, green looks like a directory path.

## Solution

Replace the flat git-status coloring with two layered visual cues:
1. A colored status prefix symbol: `+` green (added), `~` purple (modified), `-` red (deleted)
2. The file path colorized like the normal ctrl-p picker: directory components in green, basename colored by file extension/type

## User Stories

1. As a developer using `vfa` ctrl-p, I want directory parts of dirty file paths displayed in green, so that I can visually parse deeply nested paths
2. As a developer using `vfa` ctrl-p, I want basenames colored by file extension, so that I can identify file types at a glance (e.g. `.js` vs `.png`)
3. As a developer using `vfa` ctrl-p, I want a colored prefix symbol showing git status (added/modified/deleted), so that I know what kind of change each file has without the color clashing with extension colors
4. As a developer using `vfrevert` ctrl-p, I want the same coloring behavior as `vfa` ctrl-p, since both show dirty file lists
5. As a developer, I want the coloring to work for deleted files even though they no longer exist on disk, so that I can stage deletions
6. As a developer, I want the first column (return value) unchanged, so that file selection and staging still works identically

## Implementation Decisions

- Create a new FZF Helper `fzf-colorize-git-status-path.zsh` that takes two arguments: `<filepath>` and `<gitStatus>`, writes result to `$REPLY`
- The helper sources `fzf-colorize-path.zsh` and calls `fzf-colorize-path` for the path portion
- Status prefix mapping: `A` → `+` in `git-added` color, `M` → `~` in `git-modified` color, `D` → `-` in `git-removed` color
- Single space between prefix and colorized path
- Use `colorize --reply` for the prefix (no subshell)
- `fzf-colorize-path` is called with only the filepath argument (no separate real path) — it defaults to using the filepath for filesystem checks, which works fine since extension-based lookup is string-only
- Both `fzf-git-files-dirty-stageable` and `fzf-git-files-dirty` source the new helper and use it in their `fzf-source` lifecycle function
- The `--delimiter=▮` / `--with-nth=2` pattern is preserved — first column is the raw filepath for postprocessing, second column is the decorated display

## Testing Decisions

- The new FZF Helper `fzf-colorize-git-status-path` is testable in isolation: given a filepath and git status, it should produce output containing the expected prefix symbol and the filepath components
- Tests should verify: correct prefix per status (M→~, A→+, D→-), filepath present in output, ANSI codes present (colored output)
- Prior art: `fzf-git-files-dirty.bats` already tests `--source` output for file presence — extend with prefix assertions
- `fzf-git-files-dirty-stageable.bats` can gain `--source` tests (currently only has `--preview` tests)

## Out of Scope

- Changing the preview pane rendering (already has its own coloring logic)
- Changing the `fzf-options` or prompt behavior
- Modifying `git-file-list-dirty-stageable-raw` or `git-file-list-dirty-raw` output format
- Adding git-status coloring to the normal ctrl-p picker

## Further Notes

- `fzf-colorize-path` handles extensionless files via `is-zsh-autoload-function` (path-pattern check) and `-x` executable check — both work with relative paths from git root
- The `fzf-git-files-dirty` picker is used by `vfrevert`, the `fzf-git-files-dirty-stageable` picker by `vfa`
