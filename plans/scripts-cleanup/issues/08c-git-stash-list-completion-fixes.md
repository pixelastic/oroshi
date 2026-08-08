## TLDR

Create git-stash-list/list-raw, add stash completion, fix deprecated save→push and apply→pop.

## What to build

1. **`git-stash-list-raw`** — machine-readable output: `stashIndex▮message▮relativeDate`
2. **`git-stash-list`** — formatted colorized table using git-stash-list-raw
3. **`complete-git-stash`** — completion source using git-stash-list-raw
4. **compdef mapping** — map `git-stash-apply` to `_git-stash`
5. **Fix `git-stash-create`** — replace deprecated `git stash save --include-untracked` with `git stash push --include-untracked`
6. **Fix `git-stash-apply`** — replace `git stash apply && git stash drop` with `git stash pop`. Accept optional stash index arg (default: latest)

## Acceptance criteria

- [ ] `git-stash-list-raw` outputs `▮`-separated fields
- [ ] `git-stash-list` displays formatted table
- [ ] `git-stash-apply` uses `git stash pop`, accepts optional stash selector
- [ ] `git-stash-create` uses `git stash push`
- [ ] Shift-Tab on `git-stash-apply ` suggests existing stashes
- [ ] `zsh-lint` passes on all touched files
