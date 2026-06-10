## Problem Statement

`OROSHI_ROOT` serves two purposes: locating binaries/functions (PATH, fpath, autoload) and locating config files (icons, colors, kitty, etc.). In tests, mocking `OROSHI_ROOT` to control config file paths breaks all autoloaded functions because PATH/fpath are also rebuilt from the mocked value. This forces either per-script env var escape hatches or limits testing to functions that call no other custom commands.

## Solution

Introduce `bats_mock_oroshi_root` — a bats helper that writes `export OROSHI_ROOT="<mock path>"` into `mock.zsh`. Since `mock.zsh` is sourced **after** `.zshenv` has already built PATH/fpath, the mock only affects where scripts read config files, not which functions are available.

Additionally, clean up the test infrastructure: remove deprecated helpers (`bats_run_function`, `bats_run_script`), remove the redundant `OROSHI_ROOT` pin from the bats helper, hardcode non-test-critical variables in zshenv, and rename the remaining escape hatch to `OROSHI_WORKTREES_DIR_MOCK` to make its test-only purpose explicit.

## User Stories

1. As a developer writing a test for a function that reads config from `$OROSHI_ROOT`, I want to redirect where config is read without breaking autoloaded functions, so that I can create minimal fixtures and test parsing logic in isolation.
2. As a developer writing a test for `colors-build`, I want to provide a small fake `colors.conf` and still call helper functions like `colorize`, so that I don't need to mock every downstream function.
3. As a developer reading a `.bats` file, I want `bats_mock_oroshi_root` to clearly signal "this test uses a fake config root", so that I understand the test setup at a glance.
4. As a developer reading `zshenv.zsh`, I want `OROSHI_WORKTREES_DIR_MOCK` to make it obvious this escape hatch exists for tests, so that I don't confuse it with a runtime feature.
5. As a developer writing tests for zshenv itself, I want to control `OROSHI_WORKTREES_DIR` via the mock variable, so that I can simulate worktree detection with fake directories.
6. As a developer writing tests for worktree-related functions (`git-worktree-create`, `git-directory-dirty-count`, etc.), I want the mock rename to be transparent, so that existing tests keep working after updating the variable name.
7. As a developer running `bats` from a worktree, I want PATH/fpath to automatically resolve to that worktree's scripts, so that I test the code I'm developing — not the main install.
8. As a developer reading the bats helper, I want a single way to run zsh scripts and functions (`bats_run_zsh`), so that I don't have to choose between three deprecated/overlapping helpers.
9. As a developer writing a new `.bats` file, I want `bats-lint` to flag `run zsh -c` and suggest only `bats_run_zsh`, so that I use the correct helper from the start.
10. As a developer combining function mocks and config mocks in the same test, I want `bats_mock_oroshi_root` to compose with `bats_mock` since both write to `mock.zsh`, so that I don't need separate injection mechanisms.

## Implementation Decisions

### Module 1 — `bats_mock_oroshi_root` helper

- Add `bats_mock_oroshi_root` function to the bats helper library. It writes `export OROSHI_ROOT="$1"` into `$BATS_TMP_DIR/mock.zsh` (same file `bats_mock` uses).
- It calls `bats_tmp_dir` if `$BATS_TMP_DIR` is empty (same guard as `bats_mock`).
- The mock persists for the entire `@test` block (cleaned up by `bats_cleanup` in teardown). No auto-reset after each `bats_run_zsh` call.
- Remove the `OROSHI_ROOT` pin (the `export OROSHI_ROOT="$(git rev-parse --show-toplevel)"` block and derived variables) from the helper. The worktree detection in zshenv handles this already: when bats runs from a worktree, `$PWD` is under `$OROSHI_WORKTREES_DIR`, so zshenv detects it and sets `OROSHI_ROOT` to the worktree root.
- Remove `bats_run_function` and `bats_run_script` (both deprecated). All callers migrated to `bats_run_zsh`.

### Module 2 — zshenv.zsh cleanup

- Hardcode `OROSHI_ROOT` — remove escape hatch: `export OROSHI_ROOT="$HOME/.oroshi"` (no `${:-}`).
- Rename escape hatch: `OROSHI_WORKTREES_DIR` reads from `${OROSHI_WORKTREES_DIR_MOCK:-$HOME/local/www/worktrees}` to make the test-only purpose explicit.
- Hardcode `OROSHI_TMP_FOLDER` — remove escape hatch: `export OROSHI_TMP_FOLDER="$HOME/local/tmp/oroshi"` (no test uses it).
- Remove the comment "The following paths are overridable by tests" — no longer accurate for all three.

### Module 3 — Test migrations (deprecated helper removal)

Three files currently using deprecated helpers:

- `icons-load-definitions.bats`: replace `bats_run_function` with `bats_run_zsh` + `bats_mock_oroshi_root`. Each test creates the fake config directory tree and calls `bats_mock_oroshi_root` instead of `export OROSHI_ROOT=`.
- `post-commit.bats`: replace `bats_run_script "$CURRENT"` with `bats_run_zsh "$CURRENT"`. No other changes needed — mocks use `bats_mock` already.
- `kitty-helper-claude-start.bats`: replace `bats_run_script "$SCRIPT"` with `bats_run_zsh "$SCRIPT"`. No other changes needed.

### Module 4 — `OROSHI_WORKTREES_DIR` → `OROSHI_WORKTREES_DIR_MOCK` in tests

Six test files that `export OROSHI_WORKTREES_DIR=...` need renaming to `OROSHI_WORKTREES_DIR_MOCK`:

- `zshenv.bats` — inline scripts use the variable; update all `printf` statements. Also rewrite the test "OROSHI_ROOT is unchanged when PWD is outside OROSHI_WORKTREES_DIR" since zshenv now hardcodes OROSHI_ROOT (the test should verify OROSHI_ROOT equals `$HOME/.oroshi` when outside worktrees, not that a pre-set value is preserved).
- `git-worktree-create.bats` — `export` in setup.
- `git-directory-dirty-count.bats` — `export` in individual tests.
- `git-file-list-dirty-raw.bats` — `export` in individual tests.
- `sidequest.bats` — `export` in setup.
- `git-worktree-list.bats` — only reads `$OROSHI_WORKTREES_DIR` in assertions (no mock), not impacted.

### Module 5 — Lint rule update

- `rule-no-run-zsh.zsh`: update the error message to mention only `bats_run_zsh` (already the case — message says "Use bats_run_zsh instead of run zsh"). No code change needed.
- `rule-no-run-zsh.bats`: replace `bats_run_function` references in test strings with `bats_run_zsh`, since `bats_run_function` no longer exists and the rule's "no violation" test should use the current recommended helper.

## Testing Decisions

No new test files are created. Existing tests are migrated and must continue to pass.

- **Module 1** (bats helper): no dedicated tests. The helper is validated indirectly — if the migrated tests pass, the helper works.
- **Module 2** (zshenv): existing `zshenv.bats` tests are updated for the rename and hardcoding. The test "OROSHI_ROOT is unchanged when PWD is outside OROSHI_WORKTREES_DIR" is rewritten to assert `OROSHI_ROOT` defaults to `$HOME/.oroshi`.
- **Module 3** (test migrations): the 3 migrated test files must pass with `bats_run_zsh`. `icons-load-definitions.bats` additionally validates `bats_mock_oroshi_root` end-to-end.
- **Module 4** (WORKTREES_DIR rename): the 5 updated test files must pass with the renamed variable.
- **Module 5** (lint rule): existing `rule-no-run-zsh.bats` tests updated and must pass.
- **Prior art**: `icons-load-definitions.bats` (config mock pattern), `post-commit.bats` (function mock pattern), `path.bats` (inline script pattern for infra tests).

## Out of Scope

- Migrating existing scripts to use idempotent loaders instead of direct `$OROSHI_ROOT` reads (e.g., `env-generate-colors` reading `colors.conf`).
- Adding new tests for scripts that don't have tests yet.
- Refactoring `oroshi-chpwd` or the prompt worktree badge.
- Creating a second global variable (`OROSHI_CONFIG`, `OROSHI_TOOLS`) to separate config from tools in production code.

## Further Notes

- The execution order in `bats_run_zsh` is: `.zshenv` (builds PATH/fpath) → `mock.zsh` (overrides OROSHI_ROOT) → function under test. This order is what makes the whole approach work.
- `bats_mock_oroshi_root` composes naturally with `bats_mock` because both write to the same `mock.zsh` file.
- Tests are responsible for creating the directory structure and fixture files inside the mock root — no convenience helper for that (mkdir + cp is sufficient).
