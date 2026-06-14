## TLDR

New `ralph-is-running` bin script that exits 0 when a ralph session is active for a given plan directory.

## What to build

Create a new standalone script `ralph-is-running` in the ralph bin directory (alongside `ralph-state`, `ralph-end`, etc.).

**Interface:** `ralph-is-running [planDir]`
- With argument: checks whether a ralph session is active in `<planDir>` by calling `ralph-state <planDir> get mode`. Exits 0 if a session is active (mode is non-empty), exits 1 if not.
- Without argument: infers the plan directory as `<currentWorktreeRoot>/plans/<branchSlug>`, using `git-directory-root` and `git-branch-current`/`git-branch-slug`, then behaves as above.
- Silent — no output, exit code only.

Create a `__tests__/ralph-is-running.bats` test file in the ralph tests directory.

## Behavioral Tests

**No session active:**
- exits 1 when plan directory does not exist
- exits 1 when plan directory exists but has no `ralph.json`

**Session active:**
- exits 0 when `ralph.json` exists with mode=single
- exits 0 when `ralph.json` exists with mode=loop

**Default inference:**
- exits 0 when called with no argument from inside a worktree that has an active session in its inferred plan dir

## Acceptance criteria

- [ ] `ralph-is-running <planDir>` exits 0 when session active, 1 when not
- [ ] `ralph-is-running` with no arg infers plan dir from current worktree + branch slug
- [ ] Silent — no stdout/stderr output
- [ ] Script lives in the ralph bin directory
- [ ] `ralph-is-running.bats` test file created with passing tests
- [ ] Linting passes
