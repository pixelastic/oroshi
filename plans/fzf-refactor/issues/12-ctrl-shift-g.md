## TLDR

Migrate regexp-in-subdir search (Ctrl-Shift-G) to a FZF Script.

## What to build

Create `scripts/bin/fzf/ctrl-shift-g` sourcing `helpers/regexp.zsh` and `helpers/prompt.zsh`
established in previous issues. This is the subdir-scoped variant of `ctrl-g` — same live-reload
ripgrep pattern, but rooted at the current working directory instead of the git root.

Add **fold-case toggle (F1)** to `__lib/regexp.zsh` — shared by both `ctrl-g` and `ctrl-shift-g`.
The legacy `fzf-regexp-shared-fold-toggle` toggled a `regexp-fold-mode` state (multi/single) and the
options bound `--bind=f1:execute-silent(fzf-regexp-shared-fold-toggle)+reload(...)`. Reproduce this
in the new scripts using the same `fzf-var-read`/`fzf-var-write` infrastructure. The fold toggle was
deliberately deferred from issue 11; it must land here before `regexp/shared/` is deleted.

Update the Ctrl-Shift-G ZSH keybinding widget.
Update Neovim's `disk.lua` Ctrl-Shift-G binding to use the Neovim API.
Delete legacy autoloads for `regexp/subdir/` and all remaining `regexp/shared/` autoloads.

## Behavioral Tests

**fzf-postprocess**
- Given a raw ripgrep line on stdin, outputs `file:line:col`
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/ctrl-shift-g` created as executable `#!/bin/zsh` script
- [ ] `ctrl-shift-g --options` scopes ripgrep to the current working directory
- [ ] `ctrl-shift-g --postprocess` (stdin) extracts `file:line:col`
- [ ] BATS tests for `fzf-postprocess` pass
- [ ] Fold-case toggle (F1) added to `__lib/regexp.zsh` and wired into both `ctrl-g` and `ctrl-shift-g` options
- [ ] Ctrl-Shift-G ZSH widget updated to call new script
- [ ] Neovim Ctrl-Shift-G updated to use Neovim API
- [ ] Legacy autoloads for `regexp/subdir/` and `regexp/shared/` deleted (including `fzf-regexp-shared-fold-toggle`)
- [ ] `zsh-lint` passes on all modified files
