## TLDR

Migrate regexp-in-subdir search (Ctrl-Shift-G) to a FZF Script.

## What to build

Create `scripts/bin/fzf/ctrl-shift-g` sourcing `helpers/regexp.zsh` and `helpers/prompt.zsh`
established in previous issues. This is the subdir-scoped variant of `ctrl-g` — same live-reload
ripgrep pattern, but rooted at the current working directory instead of the git root.

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
- [ ] Ctrl-Shift-G ZSH widget updated to call new script
- [ ] Neovim Ctrl-Shift-G updated to use Neovim API
- [ ] Legacy autoloads for `regexp/subdir/` and `regexp/shared/` deleted
- [ ] `zshlint` passes on all modified files
