## Problem Statement

BATS tests currently have two separate helpers for running code in a ZSH context: `bats_run_function` (takes a function name) and `bats_run_script` (takes a file path). This forces test authors to know in advance whether what they're testing is an autoloaded ZSH function or a standalone script, and to pick the right helper accordingly. In practice this leads to inconsistent usage, legacy `run zsh` calls that bypass mock injection entirely, and tests that are harder to write and review.

Additionally, `bats_run_function` accepts a bare function name rather than a file path, which makes it less explicit about what is being tested and decouples the test from the actual file on disk.

## Solution

Introduce a single unified helper `bats_run_zsh` that accepts a file path in all cases. The helper auto-detects whether the file is a ZSH autoload function or a standalone script based on its location, and behaves appropriately for each case. Mock injection and worktree scoping work identically in both cases. The existing `bats_run_function` and `bats_run_script` helpers are deprecated but not removed.

## User Stories

1. As a test author, I want a single helper that works for both autoload functions and scripts, so that I don't need to know or remember which helper to use.
2. As a test author, I want to pass a file path to identify what I'm testing, so that it is explicit and unambiguous which file is under test.
3. As a test author, I want relative file paths to be automatically resolved to absolute paths, so that I don't need to call `realpath` myself before passing the path.
4. As a test author, I want mocks defined via `bats_mock` to be injected automatically, so that child commands can be replaced without modifying production code.
5. As a test author, I want all dependencies of the code under test to resolve from the current worktree, so that I am testing the worktree version rather than the global install.
6. As a test author, I want to pass arguments to the code under test, so that I can exercise different code paths.
7. As a test author, I want to pipe stdin to the code under test using `<<<`, so that I can test scripts that read from stdin.
8. As a test author testing an autoload function, I want to pass the file path of the function file and have it called via the ZSH autoload mechanism, so that the full dependency chain resolves from the worktree fpath.
9. As a test author testing a script, I want to pass the file path of the script and have it sourced in a ZSH context, so that mocked dependencies are visible to the script.
10. As a test author, I want `bats_run_function` and `bats_run_script` to still work unchanged, so that existing tests are not broken during the migration period.
11. As a test author reading a lint violation from `noRunZsh`, I want the message to point me to `bats_run_zsh`, so that I know exactly which helper to use instead of `run zsh`.

## Implementation Decisions

### Path normalization

The helper normalizes the input path to absolute using `realpath` before any other logic. If `realpath` fails (file does not exist), the helper fails immediately — no special handling.

### Detection: autoload function vs script

Detection is path-based: if the resolved absolute path falls under `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/`, it is treated as an autoload function file. Otherwise it is treated as a script. This is the only autoload directory in the codebase.

### Behavior for autoload function files

The helper calls the function by its basename (the filename without directory) inside a ZSH subprocess. ZSH resolves the function via `fpath`, which is set up by `.zshenv` using `OROSHI_ROOT` pinned to the current worktree.

The function is **not** sourced explicitly — the ZSH autoload mechanism is relied upon entirely. This forces the test to exercise the full `OROSHI_ROOT` wiring. If `OROSHI_ROOT` is not correctly pinned to the worktree, the test fails, which is the desired behavior.

### Behavior for scripts

The helper sources the script file (`source <file>`) inside a ZSH subprocess. This runs the script's top-level code in the same process where mocks have already been injected, making mocked dependencies visible to the script.

### Mock injection

In both cases, `$BATS_TMP_DIR/mock.zsh` is sourced before calling the function or sourcing the script. This is identical to the existing behavior in `bats_run_function` and `bats_run_script`.

### Worktree scoping

`OROSHI_ROOT` is exported by the bats helper to `git rev-parse --show-toplevel` (the current worktree root). `.zshenv` uses this to set `fpath` and `PATH`, so both autoloaded functions and binaries called from scripts resolve from the worktree.

### Deprecation of `bats_run_function` and `bats_run_script`

Both helpers receive a deprecation comment in the helper file. Their behavior is unchanged. Migration to `bats_run_zsh` happens progressively in separate commits.

### `noRunZsh` rule update

The violation message is updated from `"Use bats_run_function instead of run zsh"` to `"Use bats_run_zsh instead of run zsh"`. The rule's test file is updated to match.

## Testing Decisions

No direct tests are written for `bats_run_zsh`. The helper is validated implicitly as existing tests migrate to use it. This is consistent with the project's existing approach — the bats helper has no dedicated test file.

The `noRunZsh` rule has a dedicated test file (`rule-no-run-zsh.bats`). The test asserting the violation message text is updated to match the new message.

## Out of Scope

- Migration of existing `bats_run_function` and `bats_run_script` calls to `bats_run_zsh`.
- Migration of raw `run zsh` calls to `bats_run_zsh`.
- Support for autoload function directories outside of `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/`.
- Changes to how `OROSHI_ROOT` is pinned or how `.zshenv` sets up `fpath` and `PATH`.
