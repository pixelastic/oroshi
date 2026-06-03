## TLDR

Migrate the commands/binaries search (Ctrl-B) to a FZF Script.

## What to build

Create `scripts/bin/fzf/ctrl-b` following the pattern established in issue 02.
The script lists all available commands, aliases, and functions from `$PATH` and the
current shell environment. The user selects one and it is inserted into the command line.

Update the Ctrl-B ZSH keybinding widget to call the new script.
Delete the legacy autoloads (`fzf-commands`, `fzf-commands-source`, `fzf-commands-options`).

## Behavioral Tests

**fzf-source**
- Outputs command names available in the current environment
- Each line contains exactly one command name

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the command name
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/ctrl-b` created as executable `#!/bin/zsh` script
- [ ] `ctrl-b --source` lists available commands
- [ ] `ctrl-b --options` outputs valid FZF flags
- [ ] `ctrl-b --postprocess` (stdin) returns clean command name
- [ ] `ctrl-b` (no args) runs the interactive search end-to-end
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Ctrl-B ZSH widget updated to call `scripts/bin/fzf/ctrl-b`
- [ ] Legacy autoloads `fzf-commands`, `fzf-commands-source`, `fzf-commands-options` deleted
- [ ] `zshlint` passes on all modified files
