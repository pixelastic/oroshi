## Problem Statement

The BATS helper (`tools/term/bats/config/helper`) does not reliably enforce three critical guarantees when running tests inside oroshi worktrees:

1. Binaries (PATH scripts and autoloaded functions) resolved during a test may silently come from `~/.oroshi` instead of the worktree under test — making it possible for tests to pass against the wrong version of a function.
2. Functions mocked via `bats_mock` are only visible in the immediate subprocess launched by `bats_run_zsh`. Any new zsh process spawned *within* the script under test bypasses the mock entirely, making deep call chains untestable in isolation.
3. `OROSHI_ROOT` cannot be reliably overridden for config/data testing without also breaking binary resolution, because there is no clean separation between "where binaries come from" and "what `OROSHI_ROOT` the script under test reads".

Additionally, two derived env vars (`ZSH_CONFIG_PATH`, `OROSHI_ZSH_AUTOLOAD`) add indirection on top of `OROSHI_ROOT` without providing value — they make Root Override harder to reason about and are candidates for elimination.

## Solution

Refactor the BATS helper to formally enforce three principles defined in `tools/term/bats/GLOSSARY.md`:

- **Worktree-aware**: all binaries resolved during a test run come from the oroshi root from which `bats` was launched, at any call depth.
- **Deep Mocking**: a function mocked via `bats_mock` overrides the real implementation at any call depth — including direct calls, subshells, and new zsh processes spawned via PATH.
- **Root Override**: `OROSHI_ROOT` can be overridden inside the zsh subprocess for config/data testing, without affecting binary resolution.

The public API (`bats_mock`, `bats_mock_oroshi_root`, `bats_run_zsh`) remains stable.

Eliminate `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` from the codebase, replacing all usages with explicit `$OROSHI_ROOT/...` paths. Remove the bats-lint rules that enforced the old variables.

## User Stories

1. As a test author, I want binaries resolved during my test to always come from the worktree I launched `bats` from, so that I am testing the code in my worktree and not a stale version from `~/.oroshi`.
2. As a test author, I want this worktree binding to apply at any call depth (foo → bar → baz), so that I do not need to mock every intermediate function just to ensure the right binary is used.
3. As a test author, I want the worktree binding to work equally when `bats` is run from the main oroshi root (`~/.oroshi`), so that the principle applies regardless of context.
4. As a test author, I want a function I mock to remain mocked when the script under test calls it via a subshell (`$()`), so that I can isolate side effects in nested expressions.
5. As a test author, I want a function I mock to remain mocked when the script under test calls it as an external command via PATH (spawning a new zsh process), so that deep call chains are fully testable in isolation.
6. As a test author, I want to override `OROSHI_ROOT` for a test so that the script under test reads config files from a controlled temp directory.
7. As a test author, I want a Root Override to not change which binaries are loaded, so that I can test config-reading behavior without breaking the rest of the script's dependencies.
8. As a test author, I want the default behavior (no Root Override) to have `OROSHI_ROOT` point to the current worktree root, so that I don't need to set anything up for the common case.
9. As a test author, I want Worktree-aware and Root Override to be composable in the same test, so that I can test config-reading code while still using real worktree binaries.
10. As a test author, I want Deep Mocking and Worktree-aware to be composable, so that I can mock specific functions while the rest of the call chain uses worktree binaries.
11. As a test author, I want mocks to take priority over worktree binaries, so that an explicit mock always wins regardless of what the worktree provides.
12. As a test author, I want the existing `bats_mock`, `bats_mock_oroshi_root`, and `bats_run_zsh` API to remain unchanged, so that I do not need to update existing tests.
13. As a developer reading a script, I want `$OROSHI_ROOT/tools/term/zsh/config/...` instead of `$ZSH_CONFIG_PATH/...`, so that the relationship to `OROSHI_ROOT` is explicit and there is one fewer indirection to track.
14. As a developer reading a script, I want `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/...` instead of `$OROSHI_ZSH_AUTOLOAD/...`, so that autoload paths are derivable from `OROSHI_ROOT` alone.
15. As a test author running tests for a function that rebuilds PATH, I want to be able to break binary resolution intentionally via Root Override, so that I can test the rebuild logic itself — accepting that this is my responsibility.

## Implementation Decisions

### Module 1 — BATS helper core

- The helper must inject the launcher's oroshi root into every subprocess as the default `OROSHI_ROOT`, bypassing `.zshenv`'s PWD-based detection which fails in test context (CWD is `/tmp/oroshi/bats/...`).
- Deep Mocking requires that `mock.zsh` is sourced not only in the top-level subprocess launched by `bats_run_zsh`, but also in any new zsh process spawned within the script under test. The mechanism is an implementation detail; the behavior is guaranteed.
- Binary resolution (Worktree-aware) and data/config path resolution (Root Override) must be handled by independent mechanisms so that overriding one does not affect the other.
- Mock wins over worktree binary — resolution priority: mock > worktree binary.
- `bats_mock_oroshi_root` continues to be the public entry point for Root Override; its internals may change.
- Tests for the helper are written as a `.bats` file alongside the helper, using the helper itself as the test subject. Each principle (Worktree-aware, Deep Mocking, Root Override) and their interactions are tested as behaviors, not implementation details.

### Module 2 — Variable elimination

- `ZSH_CONFIG_PATH` is removed from the codebase. All usages are replaced with `$OROSHI_ROOT/tools/term/zsh/config/...`.
- `OROSHI_ZSH_AUTOLOAD` is removed from the codebase. All usages in production scripts are replaced with `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/...`. Usages in `.bats` test files (the `CURRENT=` pattern) are updated accordingly.
- The `oroshi-export-zsh-paths` function in `zshenv.zsh` is removed or replaced once its only job (deriving the two variables) no longer exists.
- The bats-lint rules enforcing `$OROSHI_ZSH_AUTOLOAD` and `$ZSH_CONFIG_PATH` usage are deleted.
- No new tests are required for this module — existing test coverage for the affected functions is sufficient.

## Testing Decisions

- Tests verify external behavior only — what a test script observes as output, exit code, or file state — never internal implementation details of the helper.
- The BATS helper core (Module 1) is tested. Variable elimination (Module 2) is not separately tested.
- A good test for Worktree-aware: a script that prints the path of a binary it calls; the test asserts that path is inside the current worktree, not `~/.oroshi`.
- A good test for Deep Mocking: a script that calls a function via `$()` (subshell) and via an external PATH script; the mock is asserted to have been used in both cases.
- A good test for Root Override: a script that reads a file at `$OROSHI_ROOT/some/path`; the test overrides `OROSHI_ROOT` to a temp dir containing a controlled file, and asserts the controlled content is read.
- A good test for the interaction between Worktree-aware and Root Override: assert that overriding `OROSHI_ROOT` does not change which binary is resolved for a given command.
- Prior art: `tools/term/zsh/config/__tests__/zshenv.bats` for testing env var propagation into subprocesses; `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/` for worktree-specific test patterns.

## Out of Scope

- Tests that exercise functions which rebuild PATH or fpath (e.g. `oroshi-reload-path`, `oroshi-reload-fpath`) — these require full control over binary resolution and are advanced cases handled outside this PRD.
- Changes to the `bats_git_dir` / `bats_git_worktree` helpers — git isolation is a separate concern.
- Performance optimization of the helper (e.g. mock.zsh sourcing overhead).
- Support for non-zsh scripts (bash, node) — the helper is zsh-only.

## Further Notes

- The glossary is at `tools/term/bats/GLOSSARY.md` — use its terminology throughout implementation and test descriptions.
- The three principles are designed to be orthogonal: Worktree-aware governs binaries, Root Override governs data/config, Deep Mocking governs mock propagation. Each can be used independently or in combination.
