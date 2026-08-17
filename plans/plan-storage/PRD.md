## Problem Statement

Plan artifacts (PRDs, issues, state.json, GUIDANCE.md, review-log.md) are committed alongside code in worktree branches. When merged to main via `vwps`, these files pollute git history — they appear, then get deleted. The `lua` plan alone is duplicated across 13 worktrees because it was committed to main and inherited by every new branch.

Not committing plans is risky — the user already lost an entire plans directory once. Plans must be protected from accidental loss while staying out of feature repo history.

## Solution

Move plan storage to an external directory (`$OROSHI_PLANS_DIR`), following the same pattern as `$OROSHI_WORKTREES_DIR`. Each plan directory is its own git repository, giving diff tracking (nvim git gutter) without polluting the feature repo.

Plan files are committed to the plan repo atomically when the user commits code in the worktree, via the shared `git-commit-create` bottleneck.

## User Stories

1. As a developer, I want plans stored outside my feature repo, so that merging to main doesn't pollute git history with temporary planning artifacts.
2. As a developer, I want each plan directory to be its own git repo, so that I get nvim git gutter diffs when reviewing GUIDANCE.md and review-log.md changes.
3. As a developer, I want `vfe` to show dirty GUIDANCE.md and review-log.md from the external plan repo alongside my dirty code files, so that I review everything in one place.
4. As a developer, I want GUIDANCE.md and review-log.md to appear first in the vfe buffer list, so that I review learnings before diving into code.
5. As a developer, I want plan files to stay dirty until I commit code, so that I see what changed since my last review via git gutter.
6. As a developer, I want my worktree commit to automatically commit the associated plan repo, so that plan state stays in sync without extra manual steps.
7. As a developer, I want `plan-directory` to be the single source of truth for plan path resolution, so that all tools (prompt, statusbar, ralph, vfe) consistently find plan artifacts.
8. As a developer, I want `context-slug` to accept `--project` and `--branch` overrides, so that I can build plan paths before a worktree exists.
9. As a developer, I want existing plans migrated to the external directory, so that worktrees with in-progress work continue functioning.
10. As a developer, I want plans to survive worktree deletion, so that I don't lose planning work if a worktree is removed.
11. As a developer, I want `git-worktree-delete` to clean up the external plan dir, so that completed plans don't accumulate forever.
12. As a developer, I want `git-worktree-rename` to rename the external plan dir, so that plan association survives branch renames.
13. As a developer, I want plan progress (done/total) to keep working in my ZSH prompt and Claude statusbar, so that I always know implementation status at a glance.
14. As a developer, I want `plan-start` to create the plan dir in `$OROSHI_PLANS_DIR` with `git init`, so that plans are tracked from the start.
15. As a developer, I want `plan-end` to commit to the plan repo (not the feature repo), so that the planning session is cleanly finalized.

## Implementation Decisions

- **External storage**: plans live in `$OROSHI_PLANS_DIR/<context-slug>/` (e.g., `~/local/www/plans/oroshi--plan-storage/`). Follows the `$OROSHI_WORKTREES_DIR` pattern.
- **Env var**: `OROSHI_PLANS_DIR` defined in `zshenv-host.zsh` with `MOCK_OROSHI_PLANS_DIR` test override.
- **One git repo per plan**: each plan directory is `git init`'d independently. Deleted with `rm -rf` when done.
- **`context-slug` API extension**: accepts `--project` and `--branch` flags, each independent. Path arg is the fallback source for missing flags. Priority: explicit flag > derived from path > derived from cwd.
- **`plan-directory` as single source of truth**: returns `$OROSHI_PLANS_DIR/$(context-slug)`. Same interface as `context-slug` (path + optional flags). All callers (`git-worktree-has-plan`, `ralph-is-running`, `vfe`, prompt, statusbar) go through it.
- **Atomic plan commit via `git-commit-create`**: after a successful `git commit` in the target repo, `git-commit-create` checks if the target repo has a dirty associated plan repo. If so, stages all plan changes and commits with the same message. Works for both `--repo` targeting and cwd.
- **No fallback**: external-only resolution. Old worktrees run old code (reads local plans). New code reads external only.
- **Migration**: one-shot script copies existing plans to `$OROSHI_PLANS_DIR`. For this worktree specifically, a symlink replaces the local plans dir to keep both old and new code working during implementation.
- **Removals**: `plan-list-raw`, `fzf-plans`, `complete-plans`, and Ctrl-O ralph dispatch are deleted — a single worktree has at most one plan, resolved by `plan-directory`.

## Testing Decisions

- Test external behavior through the public interface of each function (return values, filesystem side effects).
- `context-slug` tests: cover all flag combinations (no flags, path only, `--project` only, `--branch` only, both flags, both flags + path where path is ignored).
- `plan-directory` tests: mock `$OROSHI_PLANS_DIR` via `MOCK_OROSHI_PLANS_DIR`, verify path construction.
- `git-commit-create` tests: verify plan auto-commit fires on success, does not fire on commit abort/failure, uses same commit message.
- `git-file-edit` tests: verify external plan artifacts appear when dirty, don't appear when clean.
- All existing bats tests touching `plans/` paths must be audited and updated to use `$MOCK_OROSHI_PLANS_DIR`.
- Prior art: existing `git-worktree-create.bats`, `git-worktree-delete.bats`, `context-slug.bats` for patterns.

## Out of Scope

- Per-plan backup strategy beyond git init (no remote push, no rsync).
- Changes to how Ralph implements issues (only plan storage changes, not ralph's workflow).
- Changes to `vwps` / `git-worktree-push` (plans are no longer in the feature repo, so no filtering needed).
- UI changes to plan progress display (prompt, statusbar) — they work automatically through `plan-directory`.

## Further Notes

- The bootstrap problem: this plan itself lives locally during implementation. Issue 1 migrates it externally and symlinks back, so both old and new code resolve to the same files.
- The `lua` plan duplication (13 worktrees) will naturally stop once plans are external — new worktrees won't inherit plans from main.
