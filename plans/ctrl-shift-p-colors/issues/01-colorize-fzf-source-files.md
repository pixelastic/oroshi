## TLDR

Add ANSI colorization to `fzf-source-files` so `ctrl-shift-p` displays colored results.

## What to build

Modify the `fzf-source-files` library so it sources the `fzf-colorize-path` helper and uses it in the file listing loop. For each item, call `fzf-colorize-path` with the relative display path and the absolute real path (for executable detection). Read the colorized result from `$REPLY` and emit it as the display column. Column 1 (the absolute path used by postprocess) must remain uncolorized.

The lib should be self-contained: source `fzf-colorize-path` at the top of the file, following the precedent set by `fzf-regexp-common`.

Create a new bats test file for `fzf-source-files` in the lib's `__tests__` directory. Mock `filetypes-load-definitions` and `colors-load-definitions` in `setup` (same pattern as `fzf-colorize-path.bats`). Tests use `bats_run_zsh` with an inline source prefix.

## Behavioral Tests

**Column colorization**
- column 2 contains ANSI escape sequences for a plain file with a known extension
- column 2 contains ANSI escape sequences for an executable file with no extension
- column 1 (absolute path) contains no ANSI escape sequences

**Display/real path split**
- directory segment of a nested file is colorized in directory color in column 2
- filename is colorized in its filetype color in column 2

## Acceptance criteria

- [ ] `fzf-source-files` sources `fzf-colorize-path` and uses it in the loop
- [ ] Column 2 output contains ANSI sequences for colored files
- [ ] Column 1 output is plain (no ANSI)
- [ ] `fzf-source-files.bats` exists and all tests pass
- [ ] `bats-lint` passes on `fzf-source-files.bats`
- [ ] `zsh-lint` passes on `fzf-source-files.zsh`
- [ ] `ctrl-shift-p --source` output is visually colorized end-to-end
