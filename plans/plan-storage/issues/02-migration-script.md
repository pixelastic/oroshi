## TLDR

One-shot script that copies existing plans to `$OROSHI_PLANS_DIR` and symlinks this worktree's plan back.

## What to build

A throwaway ZSH script that:

1. Lists all worktrees registered in git (via `git worktree list`) across all projects that have worktrees in `$OROSHI_WORKTREES_DIR`. Detect projects by scanning directory names in `$OROSHI_WORKTREES_DIR` (each dir is `<project>--<branch>`), extract unique project names, find their Git Repo Main.
2. For each worktree, check if `<worktreePath>/plans/<branchSlug>/` exists.
3. For each found plan, copy to `$OROSHI_PLANS_DIR/<project>--<branchSlug>/` (same naming as worktree dirs). Skip if destination already exists (idempotent).
4. `git init` + `git add -A` + initial commit in each new plan dir.
5. Leave originals in place.
6. Specifically for this worktree (`oroshi--plan-storage`): remove the local `plans/plan-storage/` directory and replace it with a symlink to `$OROSHI_PLANS_DIR/oroshi--plan-storage/`.

## Behavioral Tests

**Skip** — throwaway script, verified by manual inspection.

## Acceptance criteria

- [ ] All existing plans from all worktrees are copied to `$OROSHI_PLANS_DIR/`
- [ ] Each copied plan dir has a git repo with an initial commit
- [ ] Original plans are untouched in their worktrees
- [ ] `plans/plan-storage` in this worktree is a symlink to `$OROSHI_PLANS_DIR/oroshi--plan-storage/`
- [ ] Script is idempotent (safe to run twice)
