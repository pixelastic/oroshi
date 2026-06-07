## TLDR

Migrate regexp-in-project search (Ctrl-G) to a FZF Script — creates the regexp helper.

## What to build

Create `scripts/bin/fzf/ctrl-g` sourcing `helpers/git.zsh`, `helpers/prompt.zsh`, and a new
`helpers/regexp.zsh`.

`helpers/regexp.zsh` provides shared ripgrep invocation logic and fold-case toggle behaviour
reused by both `ctrl-g` and `ctrl-shift-g`.

Regexp search uses a live-reload pattern: fzf starts with `--disabled` and an empty source.
On each keystroke, a `change:reload` binding re-runs ripgrep with the current query. This
means `fzf-source` outputs nothing initially — the reload binding drives the results.

The postprocess extracts `file:line:col` from the ripgrep output format.

Update the Ctrl-G ZSH keybinding widget.
Update Neovim's `disk.lua` Ctrl-G binding to use the Neovim API.
Delete legacy autoloads for `regexp/project/` and shared regexp helpers that have no
remaining callers after `ctrl-shift-g` is migrated in issue 12.

## Behavioral Tests

**fzf-source**
- Outputs nothing when called directly (live search is driven by the reload binding)
- OR outputs results for a given initial query if one is passed

**fzf-postprocess**
- Given a raw ripgrep line `file:line:col:match` on stdin, outputs `file:line:col`
- Given multiple lines on stdin, outputs one `file:line:col` per line
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/helpers/regexp.zsh` created with shared ripgrep invocation logic
- [ ] `scripts/bin/fzf/ctrl-g` created as executable `#!/bin/zsh` script
- [ ] `ctrl-g --options` includes `--disabled` and `change:reload` ripgrep binding
- [ ] `ctrl-g --postprocess` (stdin) extracts `file:line:col`
- [ ] BATS tests for `fzf-postprocess` pass (source is trivially empty; test postprocess)
- [ ] Ctrl-G ZSH widget updated to call new script
- [ ] Neovim Ctrl-G updated to use Neovim API (`ctrl-g --source`, `ctrl-g --options`, `ctrl-g --postprocess`)
- [ ] Legacy autoloads for `regexp/project/` deleted
- [ ] `zsh-lint` passes on all modified files
