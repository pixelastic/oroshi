# PRD — Bats Helper Redesign

## Problem Statement

The bats test helper (`config/term/bats/helper`) was written incrementally and has accumulated
several problems that make it hard to write new tests consistently:

- Functions have inconsistent naming (`run_zsh_fn`, `run_zsh_script`, `mock`, `bats_tmp`) with no
  unifying convention
- `run_zsh_fn` does not support mocks, unlike `run_zsh_script` — testing autoloaded functions with
  dependencies requires a complex ZDOTDIR workaround that is undocumented and not reusable
- Creating a git repo requires ~5 lines of boilerplate duplicated in ~20 test files
- Creating a git worktree requires even more boilerplate, also widely duplicated
- `mock()` serializes functions but leaves them defined in the test scope, risking shadowing
- There is no helper for stripping ANSI codes, so tests do it manually with inline `sed`
- There is no teardown helper, so tests write `rm -rf "$TMP_DIRECTORY"` manually
- The variable `TMP_DIRECTORY` has no namespace, making it easy to confuse with oroshi runtime
  variables

## Solution

Rewrite the bats helper with a consistent `bats_` prefix convention for all functions and a
`BATS_` prefix for all test-only variables. Add missing helpers for git repo setup, worktree setup,
ANSI stripping, and teardown. Unify mock support across both run helpers. Then progressively
migrate all existing test files from simplest to most complex to validate the new foundation.

## User Stories

1. As a test author, I want all helper functions to share a `bats_` prefix, so that I can
   discover the full API via tab-completion
2. As a test author, I want all test-only variables to use a `BATS_` prefix, so that I can
   immediately distinguish test infrastructure variables from real oroshi runtime variables
3. As a test author, I want to call `bats_tmp_dir` to create an isolated sandbox for my test,
   so that each test starts with a clean slate without writing boilerplate
4. As a test author, I want `bats_tmp_dir` to set `BATS_TMP_DIR` automatically, so that I have
   one canonical way to reference the test sandbox
5. As a test author, I want to call `bats_git_dir` to get a fully-initialized git repo, so that
   I don't have to repeat `git init` + user config + initial commit in every test
6. As a test author, I want `bats_git_dir` to accept an optional name argument, so that I can
   create multiple repos in the same test and keep them distinct
7. As a test author, I want `bats_git_dir` to set `BATS_GIT_DIR` and also return the path, so
   that the single-repo case is ergonomic and the multi-repo case is possible
8. As a test author, I want `bats_git_dir` to always initialize the repo on branch `main` with
   an initial commit, so that my tests are portable across machines with different git defaults
9. As a test author, I want `bats_git_dir` to set user.name and user.email in the repo, so that
   git commands that require an identity work without extra setup
10. As a test author, I want `bats_git_dir` to auto-create the sandbox if I haven't called
    `bats_tmp_dir` yet, so that I can set up a git repo in one line with no prerequisites
11. As a test author, I want to call `bats_git_worktree branch` to create a linked worktree, so
    that I don't have to repeat the worktree creation boilerplate
12. As a test author, I want `bats_git_worktree` to create the worktree inside
    `$BATS_TMP_DIR/worktrees/`, so that it is contained within the test sandbox and cleaned up
    with it
13. As a test author, I want `bats_git_worktree` to set `BATS_GIT_WORKTREES` and also
    `OROSHI_WORKTREES_DIR`, so that oroshi worktree functions work without additional env setup
14. As a test author, I want `bats_git_worktree` to return the path of the created worktree, so
    that I can reference it directly in my test
15. As a test author, I want `bats_run_function name [args]` to run a zsh autoloaded function, so
    that I can test it from within bats (which runs in bash)
16. As a test author, I want `bats_run_script path [args]` to run a zsh script via source, so
    that mocks are visible when the script executes
17. As a test author, I want both `bats_run_function` and `bats_run_script` to inject mocks from
    `mock.zsh` before executing, so that I can mock dependencies in both cases with the same API
18. As a test author, I want to define mock functions as real zsh code and then call
    `bats_mock fn1 fn2`, so that I get syntax highlighting and multi-line support
19. As a test author, I want `bats_mock` to unset the mocked functions from the test scope after
    serializing them, so that they don't accidentally shadow things in the test body itself
20. As a test author, I want to call `bats_cleanup` in my `teardown()`, so that the test sandbox
    is removed after each test without writing `rm -rf` manually
21. As a test author, I want to be able to comment out `bats_cleanup` when debugging, so that I
    can inspect the test sandbox after a failure
22. As a test author, I want to call `bats_strip_ansi "$output"` to strip color codes, so that
    I can assert on colored output without inline `sed` expressions
23. As a test author, I want the helper to unset `GIT_DIR`, `GIT_INDEX_FILE`,
    `GIT_OBJECT_DIRECTORY`, and `GIT_WORK_TREE` at load time, with a comment explaining why, so
    that git commands in tests always resolve against the test repo and not the host repo
24. As a test author, I want each helper function to have a short comment explaining what it does
    and showing a usage example, so that I can understand it without reading the implementation
25. As a developer, I want all Tier 0 tests (text-*.bats, slugify.bats, bats-test-path.bats)
    migrated to the new helper, so that tests requiring no setup work with the new convention
26. As a developer, I want all Tier 1 tests (better-rm.bats, ralph-end.bats) migrated to the
    new helper, so that tests requiring only a sandbox use `bats_tmp_dir` and `bats_cleanup`
27. As a developer, I want all Tier 2 tests (git-github-*.bats, git-file-list-dirty-raw.bats,
    review-diff.bats, git-worktree-*.bats, complete-git-worktrees*.bats, prompt/index.zsh.bats)
    migrated to the new helper, so that tests requiring a git repo use `bats_git_dir`
28. As a developer, I want all Tier 3 tests (ralph.bats, review.bats, git-worktree-create.bats)
    migrated to the new helper, so that tests requiring mocks use `bats_mock` with both
    `bats_run_function` and `bats_run_script`
29. As a developer, I want all Tier 4 tests (prompt/git.zsh.bats, prompt/path.zsh.bats)
    migrated to the new helper, so that tests sourcing oroshi config work with the new convention

## Implementation Decisions

### Naming convention

All helper functions use the `bats_` prefix. All variables created by the helper use the `BATS_`
prefix. Oroshi runtime variables (e.g. `OROSHI_WORKTREES_DIR`) are set by helpers where needed
but are clearly distinct from `BATS_` variables.

### `bats_tmp_dir`

- Creates `/tmp/oroshi/bats/<test-file>/<slugified-test-name>/` (same path scheme as current
  `bats_tmp`)
- Deletes and recreates the directory to ensure a clean state
- Sets and exports `BATS_TMP_DIR`
- Does NOT return the path — only one pattern: always use `$BATS_TMP_DIR`

### `bats_git_dir [name]`

- Default name: `git`
- Creates `$BATS_TMP_DIR/<name>/` — auto-calls `bats_tmp_dir` if `BATS_TMP_DIR` is unset
- Runs: `git init --initial-branch=main`, sets `user.email` and `user.name`, creates an empty
  commit with message `"init"`
- Sets `BATS_GIT_DIR` and returns the path (return needed for multi-repo scenarios)

### `bats_git_worktree branch [repo]`

- Default repo: `$BATS_GIT_DIR`
- Creates the worktree in `$BATS_TMP_DIR/worktrees/<branch>/`
- Sets `BATS_GIT_WORKTREES=$BATS_TMP_DIR/worktrees/`
- Also sets `OROSHI_WORKTREES_DIR=$BATS_GIT_WORKTREES` so oroshi functions work in tests
- Returns the path of the created worktree

### `bats_run_function name [args]`

- Wraps `run zsh -c "[[ -f mock.zsh ]] && source mock.zsh; name args"`
- `.zshenv` loads automatically when `zsh -c` starts, giving access to FPATH and all oroshi
  autoloaded functions
- Mock functions sourced after `.zshenv` shadow autoloaded functions with the same name

### `bats_run_script path [args]`

- Wraps `run zsh -c "[[ -f mock.zsh ]] && source mock.zsh; source path args"`
- Sources the script (not executes) to keep mock functions in scope — a subprocess would lose
  them since zsh cannot export shell functions across processes

### `bats_mock fn1 fn2...`

- Uses `declare -f` to serialize each function definition into `$BATS_TMP_DIR/mock.zsh`
- After serialization, calls `unset -f fn1 fn2...` to remove the functions from test scope

### `bats_cleanup`

- Deletes `$BATS_TMP_DIR` if set
- Intended to be called from `teardown()` — not called automatically

### `bats_strip_ansi str`

- Takes a string argument, returns it with all ANSI escape sequences removed

### Git env var unset

The header of the helper unsets `GIT_DIR`, `GIT_INDEX_FILE`, `GIT_OBJECT_DIRECTORY`, and
`GIT_WORK_TREE`. A comment explains that these are set by the pre-commit hook to relative paths,
and if tests run from the hook they would leak into test git commands, causing resolution against
the host repo instead of the test repo.

### Clean break — no backward compat aliases

Old names (`run_zsh_fn`, `run_zsh_script`, `mock`, `bats_tmp`, `TMP_DIRECTORY`) are removed
entirely. Tests are migrated progressively.

### Mock file path

The mock file is `$BATS_TMP_DIR/mock.zsh`. Both `bats_run_function` and `bats_run_script`
reference this path. If `BATS_TMP_DIR` is not set when `bats_mock` is called, it fails loudly.

## Testing Decisions

The bats helper is test infrastructure — it is not tested with bats tests. Validation is done
by migrating existing test files and verifying they continue to pass.

Migration order follows the complexity tiers:

- **Tier 0** — no setup needed (text-*.bats, slugify.bats, bats-test-path.bats): validates
  that the clean break does not affect tests that don't use the helper
- **Tier 1** — tmp dir only (better-rm.bats, ralph-end.bats): validates `bats_tmp_dir`,
  `bats_run_script`, `bats_cleanup`
- **Tier 2** — git repo (git-github-*.bats, git-file-list-dirty-raw.bats,
  review-diff.bats, git-worktree-*.bats): validates `bats_git_dir`, `bats_run_function`
- **Tier 3** — git repo + mocks (ralph.bats, review.bats, git-worktree-create.bats):
  validates `bats_mock` with `bats_run_function` and `bats_run_script`
- **Tier 4** — config sourcing (prompt/*.bats): validates complex env setup

Each tier must be fully passing before moving to the next.

## Out of Scope

- `zsh-writer/references/testing.md` — a guide for writing bats tests will be written as a
  separate issue once the helper has been battle-tested across all tiers
- Tests for the bats helper itself — the helper is validated through migration, not
  self-referential tests
- Migrating tests that are not in the codebase yet — only existing 35 test files are in scope

## Further Notes

The distinction between `bats_run_function` and `bats_run_script` maps directly to the existing
split in the codebase: autoloaded zsh functions live in
`config/term/zsh/functions/autoload/` and use `return`, while standalone scripts live in
`scripts/bin/` and use `exit`. They are tested differently.

The `bats_` prefix on helper functions is consistent with the bats core library convention
(`bats_load_library`, `bats_require_minimum_version`, etc.) while the specific names chosen
(e.g. `bats_git_dir`, `bats_run_function`) are oroshi-specific and unlikely to collide with
future bats core additions.
