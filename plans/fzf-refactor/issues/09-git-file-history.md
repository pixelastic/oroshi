## TLDR

Migrate git file history search to a FZF Script (domain script, no keybinding).

## What to build

Create `scripts/bin/fzf/git-file-history` following the pattern from issue 02,
sourcing `helpers/git.zsh` from issue 08.

This is a domain FZF Script — it has no keybinding. It is called by git-related aliases
or functions when the user wants to browse the commit history for a specific file.
The file path is passed as an argument to `--source`.

The script presents commits that touched the file, with a preview showing the diff for
each commit. The postprocess returns the selected commit hash.

Update the git alias/function that previously called `fzf-git-file-history` to call
the new script.
Delete legacy autoloads for `git/file-history/`.

## Behavioral Tests

**fzf-source**
- Given a file path argument, outputs one commit hash + subject per line for commits that modified that file
- Outputs nothing if the file has no git history

**fzf-postprocess**
- Given a raw fzf selection on stdin, outputs the commit hash only
- Given empty stdin, outputs nothing

## Acceptance criteria

- [ ] `scripts/bin/fzf/git-file-history` created as executable `#!/bin/zsh` script
- [ ] `git-file-history --source <file>` outputs commits that modified the file
- [ ] `git-file-history --options` outputs valid FZF flags including preview
- [ ] `git-file-history --postprocess` (stdin) returns commit hash
- [ ] BATS tests for `fzf-source` and `fzf-postprocess` pass
- [ ] Git alias/function updated to call new script
- [ ] Legacy autoloads for `git/file-history/` deleted
- [ ] `zsh-lint` passes on all modified files
