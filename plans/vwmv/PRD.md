## Problem Statement

When working with git worktrees, there is no way to rename a worktree in one
command. Renaming a worktree involves multiple coordinated steps: renaming the
local branch, moving the directory on disk, repairing git's internal worktree
registration, and renaming any associated plans artifacts. Doing this manually
is error-prone and tedious. Additionally, the existing `git-branch-rename`
helper lives in `scripts/bin/` as a standalone script rather than as an
autoloaded function, making it inconsistent with the rest of the git helper
ecosystem.

## Solution

Add a `git-worktree-rename` autoloaded function (aliased as `vwmv`) that
orchestrates all steps needed to rename a worktree atomically: upfront
conflict checks, branch rename, directory move, worktree repair, plans
artifact rename, and automatic navigation to the new location if the user was
inside the renamed worktree.

As a prerequisite, migrate `git-branch-rename` from `scripts/bin/` to the
autoloaded functions directory and add BATS tests for it.

## User Stories

1. As a developer, I want to rename my current worktree with `vwmv <new-name>`, so that I don't have to manually run multiple git and filesystem commands.
2. As a developer, I want to rename any worktree by name with `vwmv <old-name> <new-name>`, so that I can rename worktrees I'm not currently inside.
3. As a developer, I want all conflict checks to run before any changes are made, so that the rename either fully succeeds or does nothing.
4. As a developer, I want an error if the destination branch already exists, so that I don't accidentally stomp on an existing branch.
5. As a developer, I want an error if the destination worktree directory already exists on disk, so that I don't accidentally overwrite files.
6. As a developer, I want an error if the destination plans directory already exists, so that plans artifacts are never silently overwritten.
7. As a developer, I want the plans directory to be renamed alongside the worktree, so that plans artifacts stay associated with the renamed branch.
8. As a developer, I want to be automatically navigated into the new worktree directory after a rename, so that my shell session remains valid.
9. As a developer, I want an error if I try to rename using the 1-argument form from outside a linked worktree, so that I get a clear failure instead of undefined behavior.
10. As a developer, I want the command to be completely silent on success, so that it fits the convention of the other worktree commands.
11. As a developer, I want tab-completion on the first argument of `vwmv` to suggest existing linked worktrees, so that I can quickly find the worktree I want to rename.
12. As a developer, I want `git-branch-rename` to be available as an autoloaded function (not just a bin script), so that it is consistent with all other git helpers.
13. As a developer, I want `git-branch-rename` to have BATS tests, so that regressions are caught automatically.
14. As a developer, I want `git-worktree-rename` to have BATS tests, so that each edge case is verified and protected against regressions.

## Implementation Decisions

### `git-branch-rename` migration

- Move from `scripts/bin/git/branch/` to the autoloaded functions directory under `git/branch/`.
- Keep the same interface: `git-branch-rename <new>` (rename current branch) or `git-branch-rename <old> <new>`.
- The implementation delegates directly to `git branch --move`.
- The bin script is removed; the autoloaded function takes over.

### `git-worktree-rename` function

- Autoloaded function, aliased as `vwmv` in the worktree aliases file.
- Follows `setopt local_options err_return` convention used by all other worktree functions.
- Argument parsing:
  - 1 argument: old branch = current worktree branch (error if not in a linked worktree).
  - 2 arguments: old branch = `$1`, new branch = `$2`.

### Upfront conflict checks (all run before any mutation)

1. Old branch resolves to a valid linked worktree (via `git-worktree-path`).
2. New branch does not already exist (via `git-branch-exists`).
3. New worktree directory (`$OROSHI_WORKTREES_DIR/<repoName>--<newSlug>`) does not already exist on disk.
4. If `plans/<oldSlug>/` exists in the repo main, then `plans/<newSlug>/` must not exist.

### Execution sequence (only runs if all checks pass)

1. Rename the branch: `git-branch-rename <old> <new>`.
2. Move the directory: `mv <oldDir> <newDir>`.
3. Re-register the worktree: `git worktree repair <newDir>` (run from the repo main context).
4. If `plans/<oldSlug>/` exists: `mv plans/<oldSlug>/ plans/<newSlug>/`.
5. If `$PWD` was inside the old worktree directory: `cd <newDir>`.

### OROSHI_ROOT handling

No explicit handling required. The existing `oroshi-chpwd` hook (a `chpwd`
hook in the prompt) automatically detects when the shell enters an oroshi
worktree directory and re-exports `OROSHI_ROOT`, `ZSH_CONFIG_PATH`, and
reloads PATH and FPATH. The `cd` in step 5 triggers this hook.

### Completion

`git-worktree-rename` is added to the existing `compdef _git-worktrees-linked`
call in `compdef.zsh`. No new compdef file is needed.

### Remote branches

Remote tracking branches are not affected. Worktrees are local-only branches
by convention.

### Output

Silent on success. Errors written to stderr, consistent with all other
worktree functions.

## Testing Decisions

Good tests verify external behavior only — what the function does to the git
repo, the filesystem, and the shell's working directory — not which internal
helpers were called or in what order.

### `git-branch-rename` tests

Prior art: existing BATS tests in `__tests__/` under the worktree autoload
directory, using `bats_mock` to stub git commands and `bats_run_script` to
invoke the function in isolation.

Cases to cover:
- Renames current branch when given 1 argument.
- Renames a named branch when given 2 arguments.
- Fails when given no arguments.

### `git-worktree-rename` tests

Prior art: `git-worktree-delete.bats` — it tests the auto-cd behavior,
argument resolution, and blocking conditions using `bats_mock`.

Cases to cover:
- Renames worktree by current branch (1-arg form): branch renamed, dir moved, worktree repaired.
- Renames worktree by explicit name (2-arg form).
- Errors if called with 1 arg from outside a linked worktree.
- Errors if destination branch already exists.
- Errors if destination directory already exists on disk.
- Errors if destination plans directory already exists (when source plans dir exists).
- Plans directory is renamed when it exists.
- Plans directory is left alone when it does not exist.
- Shell navigates to new directory when called from inside the renamed worktree.
- Shell stays at current directory when called from outside the renamed worktree.

## Out of Scope

- Renaming remote tracking branches.
- Handling detached HEAD worktrees.
- Undo / rollback on partial failure (all-or-nothing is enforced by upfront checks).
- Renaming the worktree on GitHub (PRs, etc.).
- Updating any CI/CD references to the branch name.

## Further Notes

`git worktree repair` was introduced in Git 2.30 (released January 2021). This
is a safe assumption for this codebase.

The `oroshi-chpwd` hook's early-return guard checks `$PWD == $OROSHI_ROOT` or
`$PWD == $OROSHI_ROOT/*`. After a rename, the new path no longer matches the
stale `$OROSHI_ROOT`, so the hook will correctly re-derive and export the
updated root on the `cd` call.
