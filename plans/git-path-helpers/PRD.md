## Problem Statement

Git helpers in the repo don't accept a target directory argument. Scripts that need to operate on a repo at a different path (like `deprecate-end`) are forced to use raw `git -C` calls, bypassing the convention of using helpers over porcelain commands.

## Solution

Add optional path arguments to the 4 git helpers needed by `deprecate-end`, and migrate the 12 `scripts/bin/git/branch/` scripts to autoload functions to align with the rest of the git helper convention.

## User Stories

1. As a script author, I want to call `git-directory-is-dirty /path/to/repo` to check if a remote repo has uncommitted changes, so that I don't need raw `git -C` calls.
2. As a script author, I want to call `git-file-add --repo /path/to/repo` to stage all changes in a remote repo, so that the helper works from any working directory.
3. As a script author, I want to call `git-commit-create --repo /path/to/repo "message"` to commit in a remote repo, so that I use the same helper for local and remote repos.
4. As a script author, I want to call `git-commit-create-staged --repo /path/to/repo "message"` to commit staged changes in a remote repo, so that the helper is independently usable with a path.
5. As a script author, I want to call `git-branch-push --repo /path/to/repo` to push a remote repo's branch, so that push operations follow the helper convention.
6. As a script author, I want all `scripts/bin/git/branch/` commands available as autoload functions, so that they follow the same convention as every other git helper.
7. As a script author, I want `git-commit-create --repo` to thread the path to both `git-file-add` and `git-commit-create-staged`, so that the full add+commit flow works on a remote repo.

## Implementation Decisions

### Path argument convention

Two patterns exist in the codebase:
- **Positional `$1`** when no other argument exists (e.g., `git-branch-current`, `git-file-list-dirty-raw`)
- **`--repo` flag via zparseopts** when `$1` is already taken (e.g., `git-branch-remote`, `git-remote-url`)

Helpers follow whichever pattern fits their existing arg signature:

| Helper | `$1` used for | Pattern |
|---|---|---|
| `git-directory-is-dirty` | Nothing | Positional `$1` |
| `git-file-add` | Files to add (`$@`) | `--repo` flag |
| `git-commit-create` | Commit message | `--repo` flag |
| `git-commit-create-staged` | Commit message | `--repo` flag |
| `git-branch-push` | Branch name | `--repo` flag |

All default to current directory / `git-directory-root` when no path is provided (backward compatible).

### `git-commit-create` threading

`git-commit-create` parses `--repo` and forwards it to both `git-file-add --repo $path` and `git-commit-create-staged --repo $path`.

### Migration of 12 scripts to autoload

All 12 files in `scripts/bin/git/branch/` move to `tools/term/zsh/config/functions/autoload/git/branch/`:

- `git-branch-copy`
- `git-branch-create`
- `git-branch-merge`
- `git-branch-prune`
- `git-branch-pull`
- `git-branch-push`
- `git-branch-rebase`
- `git-branch-rebase-interactive`
- `git-branch-remove`
- `git-branch-remove-remote`
- `git-branch-squash`
- `git-branch-switch`

Migration is mechanical: remove shebang, swap `set -e` for `setopt local_options err_return`. `git-branch-push` additionally gets its custom arg parser replaced with zparseopts.

Old scripts are deleted after migration.

## Testing Decisions

Tests cover only the new `--repo`/`$1` path behavior, not full helper logic. Each test creates a temp git repo via `bats_git_dir` and calls the helper with a path pointing to it (without `cd`-ing into it first).

4 bats test files:
- `git-directory-is-dirty.bats` — test `$1` path arg
- `git-file-add.bats` — test `--repo` flag
- `git-commit-create-staged.bats` — test `--repo` flag
- `git-branch-push.bats` — test `--repo` flag

Prior art: `git-branch-remote.bats` demonstrates the `--repo` test pattern with `bats_git_dir` and `bats_run_zsh`.

No tests for the 12-script migration (mechanical change, no new logic).

## Out of Scope

- Full test coverage for the 4 modified helpers (only path arg is tested)
- Full test coverage for the 12 migrated scripts
- Updating `deprecate-end` to use the new helpers (separate task)
- Adding `--repo` to other git helpers beyond the 4 needed

## Further Notes

`deprecate-end` does not exist in the current worktree. It is either on another branch or planned. This PRD prepares the helpers it will consume.
