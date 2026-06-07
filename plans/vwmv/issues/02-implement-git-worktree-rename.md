## TLDR

New `git-worktree-rename` autoloaded function (aliased `vwmv`) that renames a worktree's branch, directory, and plans artifacts atomically.

## What to build

Create `git-worktree-rename` as an autoloaded function under `git/worktree/`
in the autoload tree.

**Arguments:**
- `git-worktree-rename <new>` — rename the current linked worktree
- `git-worktree-rename <old> <new>` — rename the named linked worktree

**Upfront checks (all must pass before any mutation):**
1. Old branch resolves to a valid linked worktree (via `git-worktree-path`).
2. New branch does not already exist (via `git-branch-exists`).
3. New worktree directory (`$OROSHI_WORKTREES_DIR/<repoName>--<newSlug>`) does not exist on disk.
4. If `plans/<oldSlug>/` exists in the repo main, then `plans/<newSlug>/` must not exist.

The repo name follows the same convention as `git-worktree-create`: prefer the
GitHub project name, fall back to the main directory basename.

**Execution sequence (only if all checks pass):**
1. Rename the branch via `git-branch-rename`.
2. Move the worktree directory on disk.
3. Re-register the worktree: `git worktree repair <newDir>` run from the repo main.
4. If `plans/<oldSlug>/` exists: rename it to `plans/<newSlug>/`.
5. If `$PWD` was inside the old worktree directory: `cd <newDir>`.

**Wiring:**
- Add `alias vwmv='git-worktree-rename'` to the worktree aliases file.
- Add `git-worktree-rename` to the `compdef _git-worktrees-linked` call in `compdef.zsh`.

The `OROSHI_ROOT`/PATH/FPATH reload is automatic: the existing `oroshi-chpwd`
hook fires on the `cd` in step 5 and re-derives everything from the new path.

**Output:** silent on success; errors to stderr only.

## Behavioral Tests

Prior art: `git-worktree-delete.bats` — same patterns for cd side-effects,
upfront blocking, and plans artifact management.

**1-argument form**
- Branch is renamed to the new name.
- Old worktree directory no longer exists; new one does.
- Worktree is registered under the new name in `git worktree list`.

**2-argument form**
- Same outcomes as 1-argument form, with the old branch resolved by name.

**Called from outside a linked worktree (1-arg)**
- Fails with a non-zero exit code.

**Destination branch already exists**
- Fails before any mutation; original branch and directory unchanged.

**Destination directory already exists on disk**
- Fails before any mutation; original branch and directory unchanged.

**Destination plans directory already exists**
- When `plans/<oldSlug>/` is present and `plans/<newSlug>/` also exists: fails
  before any mutation.

**Plans directory renamed**
- When `plans/<oldSlug>/` exists, it is renamed to `plans/<newSlug>/` after a
  successful rename.

**Plans directory absent**
- When no `plans/<oldSlug>/` directory exists, the rename succeeds without error.

**Navigates to new directory**
- When called from inside the renamed worktree, `$PWD` is the new directory
  after the call.

**Stays in place**
- When called from outside the renamed worktree (e.g. from repo main), `$PWD`
  is unchanged.

## Acceptance criteria

- [ ] Autoloaded function created at `git/worktree/git-worktree-rename`
- [ ] Function uses `setopt local_options err_return`
- [ ] 1-argument form defaults to current worktree branch
- [ ] 2-argument form accepts explicit old branch name
- [ ] All 4 upfront checks run before any mutation
- [ ] Execution sequence: branch rename → dir move → worktree repair → plans rename → cd
- [ ] Silent on success
- [ ] `alias vwmv='git-worktree-rename'` added to worktree aliases file
- [ ] `git-worktree-rename` added to `compdef _git-worktrees-linked` in `compdef.zsh`
- [ ] BATS test file created in the adjacent `__tests__/` directory
- [ ] All 10 behavioral test cases covered
- [ ] `zsh-lint` passes on the new function
- [ ] `bats-lint` passes on the test file
