## Problem Statement

`vwR` (`git-worktree-delete`) can delete a worktree that has an active ralph session running inside it. This can corrupt the ralph session state and leave Claude hanging mid-session.

## Solution

Introduce a `ralph-is-running` helper that checks whether a ralph session is active for a given plan directory. `git-worktree-delete` uses this helper to hard-block deletion when a session is in progress. `ralph-single` is refactored to use the same helper, centralising the lock file detection logic.

## User Stories

1. As a developer, I want `vwR` to refuse to delete a worktree that has an active ralph session, so that I don't accidentally corrupt a running session.
2. As a developer, I want the refusal to be a hard block (not bypassable with `--force`), so that I cannot accidentally destroy active work even in a hurry.
3. As a developer, I want a clear error message when deletion is blocked by ralph, so that I understand why it failed and what to do.
4. As a developer, I want `ralph-is-running` to default to the current worktree's plan when called with no arguments, so that I can quickly check whether a session is running without needing to know the exact plan path.
5. As a developer, I want `ralph-is-running` to accept an explicit plan directory argument, so that callers with a known path don't need to rely on inference.
6. As a developer, I want `ralph-single` to use `ralph-is-running` instead of duplicating the lock file check, so that the detection logic lives in one place.
7. As a developer, I want the plans directory cleanup in `git-worktree-delete` to reference the correct worktree path, so that the right plans folder is removed on deletion.

## Implementation Decisions

- **`ralph-is-running` is a new standalone bin script** in the ralph bin directory, alongside `ralph-state` and `ralph-end`. It is not a subcommand of `ralph-state`.
- **Interface:** `ralph-is-running [planDir]` — exits 0 if a ralph session is active, 1 if not. Silent (no output).
- **Default argument:** when no `planDir` is given, the script infers it as `<currentWorktreeRoot>/plans/<branchSlug>`, using `git-directory-root` and `git-branch-slug`/`git-branch-current`.
- **Implementation:** delegates entirely to `ralph-state <planDir> get mode` — if the result is non-empty, a session is active.
- **`ralph-single` guard refactor:** the inline `[[ -f "$dir/ralph.json" ]]` check is replaced by a call to `ralph-is-running "$dir"`. Behaviour is identical; logic is now centralised.
- **`git-worktree-delete` guard:** added early in the per-branch loop, before any destructive steps. Calls `ralph-is-running "$worktreePath/plans/$branchSlug"`. This requires `branchSlug` to be computed before the destructive steps (currently it is computed after).
- **`--force` does not bypass the ralph guard** — the guard is a hard block. The `--force` flag only bypasses the unmerged-commits check, as before.
- **Plans path bugfix:** the existing plans directory cleanup in `git-worktree-delete` incorrectly references the main worktree path instead of the branch worktree path. This is fixed as part of this task.

## Testing Decisions

Good tests cover external behaviour only — they do not assert on internal implementation details such as which sub-commands are called. Tests should set up realistic filesystem state and assert on exit codes, output, and side effects.

**Modules with tests:**

- `ralph-is-running` — new bats test file. Tests: exits 1 when no `ralph.json` exists; exits 0 when `ralph.json` exists; default inference works when called from inside a worktree. Prior art: `ralph-state.bats`, `ralph-single.bats`.
- `git-worktree-delete` — extend existing bats test file. New tests: blocks deletion when ralph session is active; `--force` does NOT bypass the ralph guard; plans directory is removed from the correct worktree path (not the main repo).

**Modules without dedicated new tests:**

- `ralph-single.zsh` — the refactor is a pure internal substitution with identical behaviour. Covered by existing `ralph-single.bats`.

## Out of Scope

- Adding a ralph session guard to `ralph-loop` — it has no existing guard and adding one is a separate concern.
- Any changes to `ralph-state` interface.
- Guarding other worktree operations (rename, move) against active ralph sessions.

## Further Notes

The plans directory lives inside the branch worktree (`<worktreePath>/plans/<branchSlug>`), not in the main repo. The existing bug in `git-worktree-delete` (using the main repo path for plans cleanup) is fixed as part of this task since the ralph guard exposed the correct path pattern.
