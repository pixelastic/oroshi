## TLDR

Bind Shift-Tab to fzf-based completion using fzf-tab, leaving native Tab unchanged.

## What to build

Add `ICONS[fzf-completion]` (bidirectional arrows glyph, temporary) to the fzf section of the icons definitions file.

Create a new keybinding file for Shift-Tab that:
- Sources fzf-tab from `~/local/etc/fzf-tab/fzf-tab.zsh` (fzf-tab auto-runs `enable-fzf-tab` on source, which hijacks `^I`)
- Immediately reverts `^I` back to `oroshi-tab-widget` to restore native Tab behavior
- Sources the `fzf-options-prompt-label` helper and computes a static prompt badge (icon: `fzf-completion`, label: "Completion", colors: `teal` / `teal-dark`) at startup
- Configures the badge via `zstyle ':fzf-tab:*' fzf-flags` with `--color=prompt::regular` and the computed `--prompt`
- Defines `oroshi-shift-tab-widget`: wraps `fzf-tab-complete` with `PROMPT_PREVENT_REFRESH=1/0` (same pattern as `oroshi-tab-widget` and other oroshi fzf widgets)
- Binds `^[[Z` (Shift-Tab ANSI sequence) to `oroshi-shift-tab-widget`

Wire the new file into the keybindings index (sourced after `tab.zsh`) and remove the existing TODO comment referencing fzf-tab.

## Behavioral Tests

None — config artifacts per project convention.

## Acceptance criteria

- [ ] Pressing Tab still uses native ZSH completion (unchanged behavior)
- [ ] Pressing Shift-Tab opens an fzf picker with completion candidates
- [ ] Shift-Tab works for all completion types (files, command args, git branches, etc.)
- [ ] The fzf prompt shows a teal badge with the `fzf-completion` icon and label "Completion"
- [ ] The TODO comment in `keybindings/index.zsh` is removed
