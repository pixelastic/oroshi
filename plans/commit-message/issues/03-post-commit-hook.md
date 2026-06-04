## TLDR

Delete `COMMIT_HINT` after a successful commit so it is never reused.

## What to build

A new zsh `post-commit` hook. On every successful commit it:
1. Calls `plan-directory` (no arguments).
2. If the call fails (not in a worktree with a plan), exits 0 silently.
3. If it succeeds, checks whether `COMMIT_HINT` exists in the returned directory.
4. If the file exists, deletes it. Otherwise exits 0 silently.

The hook must never fail loudly — any error exits 0 so it never blocks the user.

## Behavioral Tests

- when `plan-directory` exits non-zero, the hook exits 0 and deletes nothing
- when `plan-directory` succeeds but `COMMIT_HINT` is absent, the hook exits 0 and deletes nothing
- when `plan-directory` succeeds and `COMMIT_HINT` exists, the hook deletes the file and exits 0

Stub `plan-directory` via `bats_mock`. Prior art: other bats tests in the repo use `bats_mock` to stub zsh commands.

## Acceptance criteria

- [ ] Post-commit hook exists and is executable
- [ ] Hook is wired into the repo (correct location so git invokes it)
- [ ] Hook exits 0 in all cases
- [ ] `COMMIT_HINT` is deleted after a successful commit when it exists
- [ ] All bats tests pass
