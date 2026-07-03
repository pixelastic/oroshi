## TLDR

Pipe `fd` output through `sort-filepaths` in the `fzf-source-files` FZF Helper.

## What to build

In the `fzf-source-files` FZF Helper, sort the raw file list produced by `fd` through `sort-filepaths` before the colorization loop. `sort-filepaths` is an autoload function — no explicit sourcing needed.

The change is a single pipe step between the `fd` call and the `for` loop. No changes to `fzf-source`, `fzf-options`, or any Lifecycle Function in `ctrl-p` or `ctrl-shift-p`.

## Acceptance criteria

- [ ] `ctrl-p --source` output is ordered DFS files-first (root files before subdirectory files)
- [ ] `ctrl-shift-p --source` output is ordered DFS files-first
- [ ] Existing `fzf-source-files.bats` tests still pass (colorization behavior unchanged)
- [ ] `zsh-lint` passes on the modified file
