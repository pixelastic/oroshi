## Problem Statement

When `yarn.lock` changes across worktree boundaries, `node_modules` gets out of sync silently. Pushing from a worktree to main leaves main's `node_modules` stale. Pulling main into a worktree leaves the worktree's `node_modules` stale. The user has to remember to run `yarn install` manually after every cross-worktree git operation.

## Solution

Automatically run `yarn install` (and other dependency updates) after `git-worktree-push` and `git-worktree-pull` by reusing the existing `git-dependencies-update` infrastructure. Also replace the inline `yarn install` in `git-worktree-create` with the same shared helper for consistency.

## User Stories

1. As a developer, I want `node_modules` to auto-sync after pushing from a worktree to main, so that main is always in a runnable state
2. As a developer, I want `node_modules` to auto-sync after pulling main into a worktree, so that I don't get stale dependency errors
3. As a developer, I want `git-worktree-create` to sync all dependencies (not just node), so that a fresh worktree is fully ready to use
4. As a developer, I want dependency updates to run in the background via `fork`, so that push/pull operations don't block my terminal
5. As a developer, I want a prompt indicator when yarn is installing in a worktree, so that I know when it's safe to run commands
6. As a developer, I want the dependency update to target a remote repo (via `--repo`), so that pushing from a worktree can trigger yarn install in main's directory without `cd`
7. As a developer, I want a single source of truth for the in-progress lockfile path, so that writers and readers can never drift out of sync
8. As a developer, I want the lockfile to live in `$OROSHI_TMP_FOLDER` instead of `.git/`, so that it works in linked worktrees where `.git` is a file
9. As a developer, I want a `context-slug` function that returns a filesystem-safe identifier for the current context (project + optional worktree), so that lockfiles are uniquely named per context
10. As a developer, I want the `context-*` functions to live in their own top-level `context/` domain with `project/` as a subdomain, so that the domain structure reflects the conceptual hierarchy

## Implementation Decisions

### Reorg `project/` → `context/`

The current `project/` autoload domain contains both `project-*` and `context-*` functions as siblings. Since a Context is a higher-level concept (Project + optional Worktree), `context/` becomes the top-level domain and `project/` becomes a subdomain. Tests are split accordingly: `context/__tests__/` for context tests, `context/project/__tests__/` for project tests. The `fpath` recurses via `**/*` glob so no loading changes are needed.

### `context-slug` — new function

Lives in `context/`. Accepts an optional path as first positional argument (defaults to `$PWD`). Returns the Repo Name when in main (`oroshi`), or `<repoName>--<branchSlug>` when in a worktree (`oroshi--yarn-sync`). Uses `project-name` and `git-directory-is-worktree` which both already accept a path argument. Existing contexts only — does not predict names for worktrees that don't exist yet.

### `git-dependencies-in-progress-lockfile` — new function

Lives in `git/dependencies/`. Required first argument is the language (`node`, `ruby`). Accepts `--repo` for targeting a different repository and `--reply` to write to `$REPLY` instead of echoing (avoids subshell in prompt-hot paths). Returns `$OROSHI_TMP_FOLDER/git-dependencies-update/<context-slug>--<language>.lock`. Both writers (`git-dependencies-update-node/ruby`) and readers (`yarn-install-in-progress`) use this single function.

### `git-submodule-update-all` — new function

Lives in `git/submodule/`. Accepts an optional path as first positional argument. Wraps `git -C "$path" submodule update`. Replaces the bare `git submodule update` call in `git-dependencies-update`.

### `--repo` propagation through the dependency update chain

`git-dependencies-update`, `git-dependencies-update-node`, `git-dependencies-update-ruby`, and `git-file-has-changed` all gain `--repo` support. Each parses the flag and passes it through to children. `git -C "$repoPath"` is used for git commands. When `--repo` is set, the `fork` command string is prefixed with `cd $gitRoot &&` so the background process runs in the correct directory.

### "No origin commit" means always run

When `git-dependencies-update-node` or `git-dependencies-update-ruby` receive no origin commit argument, they skip the `git-file-has-changed` check and run unconditionally (if the beacon file exists). This supports `git-worktree-create` where there is no previous commit to diff against.

### Callers

- `git-worktree-pull`: captures current commit before `git rebase main`, calls `git-dependencies-update` after
- `git-worktree-push`: captures main's HEAD before merge, calls `git-dependencies-update --repo $mainPath` after
- `git-worktree-create`: replaces inline `yarn install || true` with `git-dependencies-update` (no origin commit)
- `yarn-install-in-progress`: updated to use `git-dependencies-in-progress-lockfile node --reply`

### Edge cases accepted

- Rebase conflicts: if the rebase fails, `err_return` prevents `git-dependencies-update` from running. After manual conflict resolution, the user must run `yarn install` manually.
- The `TODO.md` entry about `git-worktree-delete` needing yarn is a misattribution — the real fix is in `git-worktree-push`. The entry will be removed.

## Testing Decisions

Good tests verify external behavior through the public interface, not implementation details.

- `context-slug` — testable with bats: given known project paths and worktree paths, assert the returned slug. Prior art: `context-root.bats`, `context-path.bats`
- `git-dependencies-in-progress-lockfile` — testable with bats: given a language and repo path, assert the returned path. Use `--reply` variant too
- `git-file-has-changed` — existing tests should be extended for `--repo`
- `git-submodule-update-all` — thin wrapper, no unit test needed (integration only)
- `git-dependencies-update-node/ruby` — test the "no origin commit = always run" path with bats
- Caller functions (`git-worktree-push/pull/create`) — integration-level; dependencies are collaborators mocked via `bats_mock`

## Out of Scope

- Handling `git-worktree-delete` dependency sync (misattributed problem — fixed by push)
- Post-rebase-continue auto-sync (would require git hooks, different scope)
- Predicting worktree names via `context-slug` (keep `git-worktree-create` inline logic)
- Extracting the repo-name computation shared between `context-slug` and `git-worktree-create`

## Further Notes

- The existing `fork` script handles background execution, lockfile management, and prompt redraw — no changes needed to `fork` itself
- `yarn install` on a synced lockfile is a no-op, so defensive runs are low-cost
- The `$OROSHI_TMP_FOLDER/git-dependencies-update/` directory must be created if it doesn't exist (by `git-dependencies-in-progress-lockfile` or `fork`)
