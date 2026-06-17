## TLDR

Create `fzf-plans` FZF Script and `CTRL_O_PICKERS` registry to restore the ralph → plans-directory picker lost in issue 08.

## What to build

**`scripts/bin/fzf/fzf-plans`** — standalone FZF Script (same level as `fzf-docker-images`) that
searches subdirectories of `${git-root}/plans/`. Uses `plan-list-raw` as its source, which provides
plan metadata beyond plain directory names.

**`CTRL_O_PICKERS` registry** in `ctrl-o.zsh` — a global ZSH associative array that maps command
names to FZF Scripts. The widget extracts the last word of `$LBUFFER`, looks it up in the registry,
and dispatches to the matching script (falling back to `ctrl-o` if no match).

Register `ralph` and `raplh` (typo alias) → `fzf-plans`.

## Behavioral Tests

**fzf-plans fzf-source**
- Given a git repository with a `plans/` directory containing subdirectories, outputs plan paths
- Given no `plans/` directory, outputs nothing

**fzf-plans fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the absolute directory path
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/fzf-plans` created as executable FZF Script
- [ ] `fzf-plans --source` lists subdirectories of `${git-root}/plans/`
- [ ] `fzf-plans --postprocess` returns absolute directory path
- [ ] `CTRL_O_PICKERS` associative array declared in `ctrl-o.zsh`
- [ ] Widget dispatches to `fzf-plans` when `ralph` or `raplh` is the last word in `$LBUFFER`
- [ ] Widget falls back to `ctrl-o` for unknown commands
- [ ] BATS tests for `fzf-plans` source and postprocess pass
- [ ] `zsh-lint` passes on all modified files
