## Problem Statement

Worktree creation replaces submodule directories with symlinks to the main worktree. Git tracks this as a `typechange` (160000 submodule -> 120000 symlink). If committed, the submodule references are destroyed and replaced with symlinks containing absolute local paths.

## Solution

Revert to proper git submodules in worktrees. Each worktree gets its own submodule checkout via `git submodule update`, the standard git workflow. The symlink approach is removed entirely.

## User Stories

1. As a developer, I want worktrees to have proper submodule checkouts, so that `git status` shows no unexpected typechange diffs
2. As a developer, I want `git-dependencies-update` to sync submodules on branch switch/pull, so that submodule refs stay correct when branches point to different submodule commits
3. As a developer, I want worktree creation to not create symlinks for submodules, so that I never accidentally commit a symlink replacing a submodule reference
4. As a developer, I want the `private` submodule content available in worktrees, so that environment variables and secrets are accessible

## Implementation Decisions

- Revert the symlink block in `git-worktree-create` — remove the loop that replaces submodule dirs with symlinks
- Restore the comment to "Sync all dependencies (node, ruby, submodules)"
- Restore `git-submodule-update-all` call in `git-dependencies-update` before language-specific updaters
- Remove 3 symlink-specific tests from `git-worktree-create` tests
- Remove the `git-submodule-list-raw` mock from the dependency-update test in `git-worktree-create` tests
- Revert the "does not update submodules" test to assert submodules ARE updated

## Testing Decisions

- Test that `git-dependencies-update` calls `git-submodule-update-all` with the repo path
- Test that `git-worktree-create` calls `git-dependencies-update` (existing test, just remove unneeded mock)
- No symlink tests needed since symlink logic is removed
- Prior art: existing bats tests in both test files

## Out of Scope

- Optimizing submodule update performance (if slow, address separately)
- Helper commands for syncing submodule changes between worktrees and main

## Further Notes

The original symlink approach was introduced in commit f822aac to avoid redundant submodule work. The performance concern was mostly perceived (two status lines during worktree creation), not measured. If submodule update proves slow, that should be addressed as a separate optimization.
