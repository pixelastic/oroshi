## TLDR

Migrate directories-in-subdir search (Ctrl-Shift-O) to a FZF Script.

## What to build

Create `scripts/bin/fzf/ctrl-shift-o` following the pattern from issue 02, sourcing
`helpers/fs.zsh` and `helpers/prompt.zsh` established in issue 06.

The script searches for directories rooted at the current working directory.
Selected directory paths are returned as absolute paths.

Update the Ctrl-Shift-O ZSH keybinding widget to call the new script.
Delete legacy autoloads for `fs/directories/subdir/`.

## Behavioral Tests

**fzf-source**
- Given a directory, outputs subdirectory paths (not files)
- Respects `.gitignore` exclusions
- Does not include files, only directories

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the absolute directory path
- Given empty stdin, outputs nothing
- Handles paths with spaces correctly

## Acceptance criteria

- [ ] `scripts/bin/fzf/ctrl-shift-o` created as executable `#!/bin/zsh` script
- [ ] `ctrl-shift-o --source` lists directories in the current directory
- [ ] `ctrl-shift-o --options` outputs valid FZF flags
- [ ] `ctrl-shift-o --postprocess` (stdin) returns absolute directory path
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Ctrl-Shift-O ZSH widget updated to call new script
- [ ] Legacy autoloads for `fs/directories/subdir/` deleted
- [ ] `zsh-lint` passes on all modified files
