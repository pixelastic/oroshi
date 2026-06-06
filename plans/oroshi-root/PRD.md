## Problem Statement

When working in an oroshi git worktree (e.g. developing a new `bats-lint` rule), all shell tools (`bats-lint`, `zsh-lint`, autoloaded functions) resolve from `~/.oroshi` — the global install pointing at the `main` branch. New rules or functions being developed in the worktree are invisible to the running shell, `vfl`, NeoVim's lint integration, and pre-commit hooks. The developer cannot validate their in-progress work locally until it is merged to `main`.

## Solution

Make `OROSHI_ROOT` worktree-aware so that every zsh process — interactive shell, NeoVim subshell, pre-commit subprocess, `zsh -c` invocation — automatically resolves tools from the correct oroshi root without per-script instrumentation.

Three complementary layers:

1. **`zshenv` detection**: before `OROSHI_ROOT` is defaulted, a fast string check on `$PWD` detects whether the process was spawned inside an oroshi worktree and sets `OROSHI_ROOT` accordingly. Since `.zshenv` is sourced for every new zsh process, this covers NeoVim subshells, `bats_run_zsh` invocations, and pre-commit subprocess chains automatically.

2. **Reloadable path/fpath functions**: the existing inline PATH-building code and the existing `oroshi-reload-functions` logic are wrapped in named, persistently-available functions (`oroshi-reload-path`, `oroshi-reload-fpath`) that accept an optional root argument. This makes them callable by any code that needs to switch context at runtime.

3. **`chpwd` hook**: when the user `cd`s or jumps into/out of an oroshi worktree during an active session, a `chpwd` function detects the context change, updates `OROSHI_ROOT` and its derived variables, and calls the two reload functions.

## User Stories

1. As a developer, I want opening a terminal whose `$PWD` is inside an oroshi worktree to automatically load tools from that worktree, so that `bats-lint` and `zsh-lint` reflect my in-progress changes.
2. As a developer, I want NeoVim's lint integration to use worktree-local rules when NeoVim is opened from inside a worktree directory, so that lint violations appear in real time as I write code.
3. As a developer, I want `vfl` (git-file-lint) to use worktree-local rules when run from inside a worktree, so that I see accurate results before committing.
4. As a developer, I want pre-commit hooks to run against worktree-local rules, so that the commit gate reflects the rules I am developing, not the merged ones.
5. As a developer, I want `cd`-ing into an oroshi worktree mid-session to switch the active tooling to that worktree, so that I don't need to open a new terminal.
6. As a developer, I want `cd`-ing back out of a worktree to restore `~/.oroshi` as the active root, so that my shell returns to its normal state automatically.
7. As a developer, I want transitioning between two different oroshi worktrees to correctly switch tooling from one to the other, so that I never accidentally run rules from the wrong branch.
8. As a developer, I want `oroshi-reload-path [root]` to rebuild `$PATH` from a given oroshi root, so that I can call it explicitly when needed.
9. As a developer, I want `oroshi-reload-fpath [root]` to rebuild `fpath` and re-register all autoloaded functions from a given oroshi root, so that function resolution stays consistent with the active root.
10. As a developer, I want the worktree detection in `.zshenv` to be a fast string check (no subprocess), so that shell startup time is not degraded.

## Implementation Decisions

- **Worktree detection mechanism**: a string prefix check of `$PWD` against `$OROSHI_WORKTREES_DIR` in `.zshenv`. No `git` subprocess is spawned. A short comment acknowledges that the more accurate `git-directory-is-worktree` helper exists but is too costly to run on every shell. The worktree root is extracted by stripping the first path component after `$OROSHI_WORKTREES_DIR/`.

- **`OROSHI_ROOT` is set before its dependents**: derived variables (`ZSH_CONFIG_PATH`, `OROSHI_ZSH_AUTOLOAD`) are computed from `OROSHI_ROOT`, so detection must happen before the default assignment line.

- **`oroshi-reload-path [root]`**: the existing `oroshi_path()` function in `path.zsh` is renamed to `oroshi-reload-path`, kept persistent (no longer `unfunction`-ed after first call), and updated to accept an optional root argument that overrides `$OROSHI_ROOT` for the duration of the call.

- **`oroshi-reload-fpath [root]`**: `oroshi-reload-functions` is renamed to `oroshi-reload-fpath`. Its existing `"worktree"` string argument hack is replaced with an explicit optional root argument (same contract as `oroshi-reload-path`). All call sites that passed `"worktree"` are updated.

- **`chpwd` hook**: a new function registers itself via `chpwd_functions`. On each directory change it determines the new oroshi root (worktree root or `$HOME/.oroshi`) and compares it to `$OROSHI_ROOT`. If different: updates `OROSHI_ROOT`, `ZSH_CONFIG_PATH`, `OROSHI_ZSH_AUTOLOAD`, then calls `oroshi-reload-path` and `oroshi-reload-fpath` with the new root.

- **No per-script instrumentation**: `bats-lint`, `zsh-lint`, and all other tools continue to resolve their helpers via `OROSHI_ROOT` and `fpath` as they already do — no self-re-exec logic is added to individual scripts.

- **Scope is oroshi worktrees only**: the detection is keyed on `$OROSHI_WORKTREES_DIR`. Non-oroshi repos are unaffected.

## Testing Decisions

Good tests verify observable behavior (exported variable values, command resolution) from outside the implementation, not internal logic.

- **`oroshi-reload-path`** tests: invoke the function in a subshell with a given root argument; assert that `$PATH` contains the expected `scripts/bin/` subdirectories from that root and not from another.
- **`oroshi-reload-fpath`** tests: invoke the function in a subshell with a given root argument; assert that `fpath` contains the expected `functions/autoload/` subdirectories from that root, and that a function exclusive to that root is correctly autoloaded.
- **Module 1 (`zshenv` detection) and Module 4 (`chpwd`)**: verified manually by the developer after implementation.
- Prior art: tests for `bats_run_zsh` helpers in `tools/term/bats/config/` demonstrate the subshell-with-overridden-env pattern to follow.

## Out of Scope

- Prompt indicator for worktree-active state (the existing branch display is sufficient).
- Per-script self-re-exec logic in `bats-lint` / `zsh-lint`.
- Fixing existing `# bats-lint disable` comment syntax and placement issues in source files.
- Support for non-oroshi worktrees or other repos with a similar structure.
