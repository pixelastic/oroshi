## PRD

[PRD.md](./PRD.md) — Bats Helper Redesign

## What to build

Rewrite `config/term/bats/helper` from scratch with a consistent `bats_` prefix on all
functions and a `BATS_` prefix on all test-only variables. This is a clean break — old names
(`run_zsh_fn`, `run_zsh_script`, `mock`, `bats_tmp`, `TMP_DIRECTORY`) are removed entirely.

The new helper exposes 8 functions:

- `bats_tmp_dir` — creates an isolated sandbox at a predictable path, sets `BATS_TMP_DIR`
- `bats_git_dir [name]` — creates a git repo inside the sandbox (auto-creates sandbox if
  needed), branch `main`, initial commit `"init"`, user config set; sets `BATS_GIT_DIR` and
  returns the path
- `bats_git_worktree <branch>` — creates a linked worktree in `$BATS_TMP_DIR/worktrees/`;
  sets `BATS_GIT_WORKTREES` and `OROSHI_WORKTREES_DIR`; returns the worktree path
- `bats_run_function <name> [args]` — runs a zsh autoloaded function via `zsh -c`, injecting
  mocks from `$BATS_TMP_DIR/mock.zsh` before the call
- `bats_run_script <path> [args]` — sources a zsh script via `zsh -c`, injecting mocks from
  `$BATS_TMP_DIR/mock.zsh` before sourcing
- `bats_mock <fn1> [fn2...]` — serializes function definitions into mock.zsh using
  `declare -f`, then unsets them from the current scope
- `bats_cleanup` — deletes `$BATS_TMP_DIR`; intended for use in `teardown()`
- `bats_strip_ansi <str>` — returns the string with all ANSI escape sequences removed

The header of the file unsets `GIT_DIR`, `GIT_INDEX_FILE`, `GIT_OBJECT_DIRECTORY`, and
`GIT_WORK_TREE`, with a comment explaining that these are injected by the pre-commit hook and
would otherwise leak into test git commands.

Each function has a short comment with signature and one usage example.

Validation: all Tier 0 test files (text-*.bats, slugify.bats, bats-test-path.bats) that do
not use the helper must continue to pass after the rewrite.

## Acceptance criteria

- [ ] `bats_tmp_dir` creates `/tmp/oroshi/bats/<file>/<slug>/`, sets `BATS_TMP_DIR`, does not
  return the path
- [ ] `bats_git_dir` creates a git repo inside `$BATS_TMP_DIR/<name>/` on branch `main` with
  an initial commit and user config; sets `BATS_GIT_DIR`; returns the path
- [ ] `bats_git_dir` auto-calls `bats_tmp_dir` if `BATS_TMP_DIR` is not set
- [ ] `bats_git_dir "custom"` creates `$BATS_TMP_DIR/custom/` instead of the default `git/`
- [ ] `bats_git_worktree <branch>` creates the worktree in `$BATS_TMP_DIR/worktrees/<branch>/`
- [ ] `bats_git_worktree` sets both `BATS_GIT_WORKTREES` and `OROSHI_WORKTREES_DIR`
- [ ] `bats_run_function` and `bats_run_script` both inject `mock.zsh` before executing
- [ ] `bats_mock fn1 fn2` writes the function definitions to `mock.zsh` and then unsets them
  from the current shell scope
- [ ] `bats_cleanup` removes `$BATS_TMP_DIR`
- [ ] `bats_strip_ansi` removes ANSI escape codes from its argument
- [ ] The header unsets the 4 git env vars with an explanatory comment
- [ ] Each function has a comment with signature and usage example
- [ ] None of the old names (`run_zsh_fn`, `run_zsh_script`, `mock`, `bats_tmp`) exist in
  the helper
- [ ] All Tier 0 test files pass: text-*.bats, slugify.bats, bats-test-path.bats

## Blocked by

None — can start immediately.
