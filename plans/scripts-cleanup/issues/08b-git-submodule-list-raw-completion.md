## TLDR

Create git-submodule-list-raw, refactor git-submodule-list to use it, rebranch complete-git-submodules on list-raw.

## What to build

1. **`git-submodule-list-raw`** — machine-readable output: `submoduleName▮commitHash▮branchName`
2. **Refactor `git-submodule-list`** — parse git-submodule-list-raw instead of `git submodule status` directly
3. **Refactor `complete-git-submodules`** — use git-submodule-list-raw instead of `git submodule status` directly
4. **compdef mapping** — map `git-commit-submodule` and `git-submodule-remove` to `_git-submodules`

## Acceptance criteria

- [ ] `git-submodule-list-raw` outputs `▮`-separated fields
- [ ] `git-submodule-list` delegates to `git-submodule-list-raw`
- [ ] `complete-git-submodules` delegates to `git-submodule-list-raw`
- [ ] `git-commit-submodule` and `git-submodule-remove` have compdef entries
- [ ] `zsh-lint` passes on all touched files
