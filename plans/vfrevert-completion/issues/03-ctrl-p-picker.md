## TLDR

Add a Ctrl-P fzf picker for `vfrevert` that lists all dirty files with color and diff preview.

## What to build

Two pieces wired together end-to-end:

1. **`fzf-git-files-dirty`** — new fzf picker script (in `scripts/bin/fzf/`) following the standard subcommand contract (`--source`, `--options`, `--preview`, `--postprocess`). Calls `git-file-list-dirty-raw` for its source. Colors files by status: red for deleted, yellow for modified, green for added. Preview uses `git diff HEAD` — same as the stageable picker.

   Prior art: `fzf-git-files-dirty-stageable` (copy and adapt — replace `git-file-list-dirty-stageable-raw` with `git-file-list-dirty-raw`, update self-references in `--preview` option and prompt label to "Dirty files").

2. **`ctrl-p.zsh`** — add `vfrevert fzf-git-files-dirty` to the `specialPickers` associative array. `git-file-revert` is not added — Ctrl-P matches on the last word of the buffer, which will always be the alias.

## Behavioral Tests

**`--source` subcommand**
- Returns empty output in a clean repo
- Lists a modified tracked file
- Lists a deleted tracked file
- Lists a staged-new file
- Lists an untracked file

Prior art: `fzf-git-files-dirty-stageable.bats`.

## Acceptance criteria

- [ ] Pressing Ctrl-P with `vfrevert` as the last word in the buffer opens the picker
- [ ] The picker lists all dirty files (modified, deleted, staged-new, untracked)
- [ ] Files are colored by status (red=deleted, yellow=modified, green=added)
- [ ] Selecting a file appends its path to the command line
- [ ] `fzf-git-files-dirty --source` returns the correct file list (verified by bats tests)
- [ ] All bats tests pass
- [ ] `zsh-lint` passes on all new/modified files
