## TLDR

Migrate `fzf-git-files-stageable-options` from `$COLOR_ALIAS_*` to `$COLORS[key]` to fix broken colors in the `vfa` ctrl-p picker.

## What to build

Replace the three legacy color variables in `fzf-git-files-stageable-options` with their
`$COLORS` equivalents:

- `$COLOR_BLACK` → `$COLORS[black]`
- `$COLOR_ALIAS_GIT_MODIFIED` → `$COLORS[git-modified]`
- `$COLOR_ALIAS_TERMINAL` → `$COLORS[terminal]`

Add `colors-load-definitions` near the top of the file (after `setopt local_options err_return`),
alongside the existing `icons-load-definitions` call.

## Acceptance criteria

- [ ] `fzf-git-files-stageable-options` uses no `$COLOR_ALIAS_*` or `$COLOR_*` variables
- [ ] `colors-load-definitions` is called before any `$COLORS[...]` reference
- [ ] Running `vfa` + ctrl-p renders the prompt with correct modified-file and terminal colors
- [ ] `zsh-lint` passes on the file
