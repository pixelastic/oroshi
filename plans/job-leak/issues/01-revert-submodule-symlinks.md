## TLDR

Revert submodule symlinks in worktrees back to proper `git submodule update`.

## What to build

Undo the symlink approach introduced in f822aac. Four files to change:

**`git-worktree-create`**: Remove the symlink block (the loop over `git-submodule-list-raw` that calls `rmdir` + `ln -s`). Restore the comment to "Sync all dependencies (node, ruby, submodules)".

**`git-dependencies-update`**: Restore `git-submodule-update-all "$repoPath"` before the language-specific updaters.

**`git-worktree-create.bats`**: Remove 3 symlink tests ("symlinks submodules from main worktree", "symlinked submodule content is accessible from worktree", "does not create symlinks when no submodules exist"). In the "calls git-dependencies-update" test, remove the `git-submodule-list-raw` mock since it's no longer needed.

**`git-dependencies-update.bats`**: Revert the "does not update submodules" test to assert that `git-submodule-update-all` IS called with the repo path.

## Behavioral Tests

**git-dependencies-update:**
- calls git-submodule-update-all with repo path

**git-worktree-create:**
- calls git-dependencies-update without origin commit (existing, just remove extra mock)

## Acceptance criteria

- [ ] `git-worktree-create` has no symlink logic
- [ ] `git-dependencies-update` calls `git-submodule-update-all`
- [ ] All tests pass
- [ ] Lint passes on all modified files
