## TLDR

Migrate files-in-subdir search (Ctrl-Shift-P) to a FZF Script — creates the fs and prompt helpers.

## What to build

Create `scripts/bin/fzf/ctrl-shift-p` following the pattern from issue 02.
This is the first filesystem FZF Script and establishes two new FZF Helpers:

- `helpers/fs.zsh` — shared file/directory source logic (fd invocation, gitignore handling,
  color output, path formatting). All subsequent filesystem scripts source this.
- `helpers/prompt.zsh` — shared prompt formatting with colored context badges.

The script sources the relevant helpers and implements a file search rooted at the current
working directory. Selected file paths are returned as absolute paths.

Update the Ctrl-Shift-P ZSH keybinding widget to call the new script.
Delete legacy autoloads for `fs/files/subdir/` and shared fs helpers that have no remaining callers.

## Behavioral Tests

**fzf-source**
- Given a directory, outputs relative file paths under that directory
- Respects `.gitignore` exclusions
- Does not include directories, only files

**fzf-postprocess**
- Given a raw two-column fzf line (absolute path + display path) on stdin, outputs the absolute path
- Given empty stdin, outputs nothing
- Handles paths with spaces correctly

## Acceptance criteria

- [ ] `scripts/bin/fzf/helpers/fs.zsh` created with shared file/directory source functions
- [ ] `scripts/bin/fzf/helpers/prompt.zsh` created with shared prompt formatting
- [ ] `scripts/bin/fzf/ctrl-shift-p` created as executable `#!/bin/zsh` script
- [ ] `ctrl-shift-p --source` lists files in the current directory
- [ ] `ctrl-shift-p --options` outputs valid FZF flags including preview
- [ ] `ctrl-shift-p --postprocess` (stdin) returns absolute file path
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Ctrl-Shift-P ZSH widget updated to call new script
- [ ] Legacy autoloads for `fs/files/subdir/` deleted
- [ ] `zshlint` passes on all modified files
