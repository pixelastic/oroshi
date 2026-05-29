## TLDR

Rename the `fzf-fs-directories-ralph-*` family to `fzf-fs-directories-plans-*`, delegate the source to `plan-list-raw`, and update `ctrl-o.zsh` accordingly.

## What to build

Rename the entire `fzf-fs-directories-ralph/` directory and all its files to `fzf-fs-directories-plans/`. Update every internal reference (source, prompt, options, entry point) to use the `plans` name.

Rewrite the `-source` function to consume `plan-list-raw` output and reformat each line into the two-column FZF format (`fullAbsolutePath   basename`) expected by `fzf-fs-directories-shared-postprocess`. The `-source` no longer calls `fzf-fs-shared-source` directly — depth control is now owned by `plan-list-raw`.

In `ctrl-o.zsh`, rename `oroshi-fzf-directories-ralph-selection` to `oroshi-fzf-directories-plans-selection` and update its comment.

Delete the old `fzf-fs-directories-ralph/` directory and its existing test (the `.bats` written on this branch). Replace with a `.scaffold.bats` file in the new `fzf-fs-directories-plans/__tests__/` directory that provides a red → green checkpoint during development. The scaffold test file must be deleted before merging.

## Acceptance criteria

- [ ] All `fzf-fs-directories-ralph-*` files are removed
- [ ] All `fzf-fs-directories-plans-*` files exist with correct internal references
- [ ] CTRL-O while typing `ralph` still opens the FZF plan picker
- [ ] FZF picker shows only direct subdirectories of `plans/` (not nested dirs)
- [ ] Selected plan inserts absolute path into the command line
- [ ] `ctrl-o.zsh` uses `oroshi-fzf-directories-plans-selection`
- [ ] `.scaffold.bats` present during development, deleted before merge
- [ ] `zshlint` passes on all modified files
