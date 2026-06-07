## TLDR

First FZF Script — establishes the pattern, creates the scripts/bin/fzf/ structure, migrates history search.

## What to build

Create `scripts/bin/fzf/ctrl-r` as the first FZF Script. This issue establishes the full
scaffolding that all subsequent issues reuse: the `scripts/bin/fzf/` directory, the `helpers/`
subdirectory, and an initial `helpers/options.zsh` with shared FZF options (colors, layout,
keybindings common to all scripts).

The `ctrl-r` script itself reads `$HISTFILE`, pipes through fzf, and returns the selected command.
It is deliberately the simplest possible FZF Script — no preview, no git context, no path
manipulation — so the pattern is clear before adding complexity.

After the script is working and tested, the ZSH Ctrl-R keybinding widget is updated to call
`ctrl-r` instead of the Legacy FZF `fzf-history` autoload. The legacy autoloads (`fzf-history`,
`fzf-history-source`, `fzf-history-options`) are then deleted.

**Pattern established by this issue (followed by all subsequent issues):**
- `#!/bin/zsh` shebang, no autoload
- Four Lifecycle Functions: `fzf-source`, `fzf-options`, `fzf-postprocess`, `fzf-main`
- `fzf-postprocess` reads from stdin
- `case "$1"` dispatch at bottom: `--source` / `--options` / `--postprocess` / default→`fzf-main`
- BATS tests in `__tests__/` adjacent to the script

## Behavioral Tests

**fzf-source**
- Outputs one history entry per line
- Reads from $HISTFILE (or the correct history source for the ZSH configuration)
- Does not output empty lines

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the command string stripped of any leading
  timestamp or line-number prefix
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/` directory created
- [ ] `scripts/bin/fzf/helpers/options.zsh` created with shared base FZF options
- [ ] `scripts/bin/fzf/ctrl-r` created as executable `#!/bin/zsh` script
- [ ] `ctrl-r --source` outputs history entries
- [ ] `ctrl-r --options` outputs valid FZF flags
- [ ] `ctrl-r --postprocess` (stdin) returns clean command string
- [ ] `ctrl-r` (no args) runs the interactive search end-to-end
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Ctrl-R ZSH widget updated to call `scripts/bin/fzf/ctrl-r`
- [ ] Legacy autoloads `fzf-history`, `fzf-history-source`, `fzf-history-options` deleted
- [ ] `zsh-lint` passes on all modified files
