## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Upgrade `complete-git-worktrees` to output `name:description` pairs. The description compactly shows dirty count, ahead commits, behind commits, and last commit message — with zero values suppressed.

**`main` entry** (always first): fetch dirty count via `git-directory-dirty-count` on the main worktree path, and last message via `git log -1`. Ahead/behind are always 0 for main and are suppressed. If git commands fail (outside a repo), output `main` with no description.

**Linked worktrees**: parse fields from `git-worktree-list-raw` output — no additional git calls.

**Description format**: `~{dirty} ↑{ahead} ↓{behind}  {message}`, each counter suppressed when zero. The `:` separator between name and description is what zsh `_describe` uses to display the description column.

**Icon variables**: declare `iconDirty`, `iconAhead`, `iconBehind` as local variables at the top of the function.

Update `complete-git-worktrees.bats` to match the new output format.

## Acceptance criteria

- [ ] Output is in `name:description` format for each entry
- [ ] `main` is always the first entry
- [ ] Dirty count appears in description when non-zero, suppressed when zero
- [ ] Ahead count appears in description when non-zero, suppressed when zero
- [ ] Behind count appears in description when non-zero, suppressed when zero
- [ ] Last commit message appears in every description
- [ ] `iconDirty`, `iconAhead`, `iconBehind` are declared as local variables at the top of the function
- [ ] When outside a git repo, outputs `main` with no description and exits 0
- [ ] Worktrees from other repos are still excluded
- [ ] All updated `complete-git-worktrees.bats` tests pass

## Blocked by

- [issue-002](./issue-002-refactor-git-worktree-list-raw.md)
