## PRD

docs/git-commit-message/PRD.md

## What to build

Wire up Neovim to the new script and remove the now-obsolete files.

Three changes:
1. Update the Neovim `gitcommit.lua` filetype config to call `git-commit-message`
   instead of `git-commit-message-bin`
2. Delete `scripts/bin/git/commit/git-commit-message-bin` (the old thin zsh wrapper)
3. Delete `config/term/zsh/functions/autoload/git/commit/git-commit-message`
   (the old zsh autoload function)

## Acceptance criteria

- [ ] Neovim gitcommit buffer auto-populates with the generated message on `git commit`
- [ ] `git-commit-message-bin` no longer exists in the repo
- [ ] The zsh autoload function `git-commit-message` no longer exists in the repo
- [ ] No other file in the repo references the deleted paths

## Blocked by

- issue-0004-error-handling.md
- issue-0005-sound.md
