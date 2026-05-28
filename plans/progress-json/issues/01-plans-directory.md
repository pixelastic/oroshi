## TLDR

Rename `ralph-directory` to `plans-directory` and update `git-worktree-is-ralph` to check the new path structure.

## What to build

Rename `ralph-directory` to `plans-directory`. The script resolves the absolute path to the plan workspace for the current worktree. Change the output path from `$wtRoot/ralph/$slug/` to `$wtRoot/plans/$slug/`.

Update `git-worktree-is-ralph` to check for `plans/<slug>/state.json` instead of `ralph/<slug>/issues.json`. The function name stays `git-worktree-is-ralph` for now (it's a boolean about whether a worktree has a plan, the name can be revisited later).

Update all bats tests for both scripts. The test for `git-worktree-is-ralph` currently creates `ralph/<slug>/issues.json` — it must create `plans/<slug>/state.json` instead.

## Acceptance criteria

- [ ] `plans-directory` exists and outputs `$wtRoot/plans/$slug/` for a given worktree path
- [ ] `ralph-directory` is removed
- [ ] `git-worktree-is-ralph` checks `plans/<slug>/state.json` instead of `ralph/<slug>/issues.json`
- [ ] Bats tests for `plans-directory` pass (renamed from ralph-directory tests)
- [ ] Bats tests for `git-worktree-is-ralph` pass with the new path