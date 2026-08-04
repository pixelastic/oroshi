## TLDR

Wire `git-dependencies-update` into `git-worktree-push`, `git-worktree-pull`, and `git-worktree-create`.

## What to build

**`git-worktree-pull`:**
- Capture current commit before `git rebase main`
- Call `git-dependencies-update $previousCommit` after rebase
- `err_return` ensures dependencies don't update if rebase fails

**`git-worktree-push`:**
- Capture main's HEAD before merge: `git -C "$mainPath" rev-parse HEAD`
- After the `git -C "$mainPath" merge --ff-only`, call `git-dependencies-update --repo "$mainPath" "$previousCommit"`

**`git-worktree-create`:**
- Replace the inline `yarn install || true` block with `git-dependencies-update` (no origin commit argument)
- This triggers unconditional dependency sync for all languages (node, ruby, submodules)

## Behavioral Tests

**`git-worktree-pull`:**
- calls `git-dependencies-update` with the pre-rebase commit after successful rebase
- does not call `git-dependencies-update` when rebase fails

**`git-worktree-push`:**
- calls `git-dependencies-update --repo <mainPath>` with main's pre-merge HEAD

**`git-worktree-create`:**
- calls `git-dependencies-update` without origin commit (replaces inline yarn install)

## Acceptance criteria

- [ ] `git-worktree-pull` syncs dependencies after rebase
- [ ] `git-worktree-push` syncs dependencies in main after merge
- [ ] `git-worktree-create` uses `git-dependencies-update` instead of inline `yarn install`
- [ ] No dependency update on rebase failure
- [ ] Tests pass
