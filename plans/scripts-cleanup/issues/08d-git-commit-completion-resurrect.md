## TLDR

Create git-commit-list-raw, fzf-powered commit completion with reload pattern, make git-file-resurrect robust.

## What to build

### Commit completion
1. **`git-commit-list-raw`** — machine-readable output: `commitHash▮relativeDate▮authorName▮subject`
2. **`complete-git-commits`** — fzf completion using `--disabled` + `change:reload` pattern:
   - Empty input → `git log --oneline -200` (last 200)
   - Non-empty input → `git log --all --oneline --grep={q}` (search all history)
   - Preview: `git show --color=always {hash}`
   - Display: hash, date, message colorized
3. **compdef mapping** — map `git-commit-remove` and `git-commit-remove-all` to `_git-commits`

### git-file-resurrect improvements
4. **Accept absolute and relative paths** — normalize to repo-relative
5. **Handle uncommitted deletions** — if file deleted in working dir but not committed, `git checkout -- file`
6. **Guard empty arg** — error if no path provided
7. **Guard empty commitHash** — error if file was never deleted in history

### Deleted files completion
8. **`complete-git-files-deleted`** — list files deleted in last 3 months: `git log --diff-filter=D --since="3 months ago" --name-only --format=""`
9. **compdef mapping** — map `git-file-resurrect` to `_git-files-deleted`

## Acceptance criteria

- [ ] `git-commit-list-raw` outputs `▮`-separated fields
- [ ] Shift-Tab on `git-commit-remove ` opens fzf with commit list and preview
- [ ] Typing in fzf reloads results via git log search
- [ ] `git-file-resurrect` works with absolute paths
- [ ] `git-file-resurrect` restores uncommitted deletions
- [ ] `git-file-resurrect` errors on missing arg or unknown file
- [ ] Shift-Tab on `git-file-resurrect ` suggests recently deleted files
- [ ] `zsh-lint` passes on all touched files
