# Decisions

## Global worktrees store shared across all repos

All worktrees, regardless of which repo they belong to, are created in a single directory (`$OROSHI_WORKTREES_DIR`). The alternative — a per-repo worktrees subfolder (siblings of the repo) — was rejected because it pollutes `~/local/www/projects/` and makes it impossible to get a global view of all work in progress. The global store keeps `projects/` clean.

## Deleting a worktree deletes its branch

`git-worktree-delete` removes both the worktree directory and its associated branch. A worktree is a working directory plus a branch — they form a single unit. Removing one without the other leaves a dangling branch that has no working context.

To guard against data loss, deletion is blocked if the branch has commits ahead of `main` (unmerged work). Pass `--force`/`-f` to bypass this check.

Previous decision (decoupled delete) was reversed after recognising that branches and worktrees are not parallel concepts: the worktree owns the branch.
