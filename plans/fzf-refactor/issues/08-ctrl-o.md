## TLDR

Migrate directories-in-project search (Ctrl-O) to a FZF Script — creates the git helper.

## What to build

Create `scripts/bin/fzf/ctrl-o` following the pattern from issue 02, sourcing
`helpers/fs.zsh`, `helpers/prompt.zsh`, and a new `helpers/git.zsh`.

`helpers/git.zsh` provides shared git utilities used by project-scoped scripts:
resolving the git repository root, detecting whether the current directory is inside a repo, etc.

The script searches for directories rooted at the git repository root.
The current context-aware behaviour for `ralph`/plans directories (Ctrl-O currently
switches to a plans-directory picker when the buffer contains `ralph`) is preserved
unless the plans picker has already been removed as part of issue 01 cleanup.

Selected directory paths are returned as absolute paths.

Update the Ctrl-O ZSH keybinding widget to call the new script.
Delete legacy autoloads for `fs/directories/project/` and `fs/directories/plans/`.

## Behavioral Tests

**fzf-source**
- Given a git repository, outputs directory paths under the git root
- Does not include the `.git` directory itself
- Respects `.gitignore` exclusions

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the absolute directory path
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/helpers/git.zsh` created with shared git utility functions
- [ ] `scripts/bin/fzf/ctrl-o` created as executable `#!/bin/zsh` script
- [ ] `ctrl-o --source` lists directories from the git root
- [ ] `ctrl-o --options` outputs valid FZF flags
- [ ] `ctrl-o --postprocess` (stdin) returns absolute directory path
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Ctrl-O ZSH widget updated to call new script
- [ ] Legacy autoloads for `fs/directories/project/` and `fs/directories/plans/` deleted
- [ ] `zsh-lint` passes on all modified files
