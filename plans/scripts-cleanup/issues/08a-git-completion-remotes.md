## TLDR

Wire remote completion to git-remote-remove, git-remote-rename, git-remote-switch.

## What to build

`complete-git-remotes` already exists and uses `git-remote-list-raw`. Just need to map it in compdef.zsh:
- `git-remote-remove` → `_git-remotes`
- `git-remote-rename` → `_git-remotes` (first arg only — second is free text)
- `git-remote-switch` → `_git-remotes`

## Acceptance criteria

- [ ] All three remote functions have compdef entries
- [ ] Shift-Tab on `git-remote-remove ` suggests existing remotes
- [ ] `zsh-lint` passes on all touched files
