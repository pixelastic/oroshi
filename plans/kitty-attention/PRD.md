## Problem Statement

The Attention Icon auto-clear mechanism is broken: when focusing a tab that has
Attention, the icon stays indefinitely instead of disappearing after 2 seconds.
Debugging this is blocked by two tooling gaps: (1) there is no way to
programmatically switch tabs, which makes automated testing impossible, and (2)
the Reload mechanism always loads Python modules from the main oroshi repo, not
from the active worktree, so code changes made during development are invisible
until merged.

## Solution

Build two utility scripts (`kitty-tab-switch`, `kitty-pwd`), make
`kitty-reload` worktree-aware so it loads modules from the active worktree when
applicable, then use the new tooling to diagnose and fix the auto-clear bug.

## User Stories

1. As a developer, I want to switch kitty tabs by Tab ID from a script, so that automated tests can simulate tab navigation without manual intervention.
2. As a developer, I want to get the cwd of the currently focused kitty window from a script, so that other tools can make context-aware decisions.
3. As a developer working in an oroshi worktree, I want Alt-R (Reload) to load Tab Bar Python modules from my worktree, so that I see my code changes immediately without merging to main.
4. As a developer working outside an oroshi worktree, I want Alt-R (Reload) to load Tab Bar Python modules from the main oroshi repo, so that the default behavior is unchanged.
5. As a user, I want the Attention Icon to disappear ~2 seconds after I focus a tab that has Attention, so that the icon reflects the current state.
6. As a developer, I want debug logging in the auto-clear callback, so that I can determine whether the timer fires, what Tab ID it sees, and whether the subprocess succeeds.

## Implementation Decisions

- **`kitty-tab-switch`**: minimal shell script calling `kitty @ focus-tab --match id:$1`. Propagates errors, no validation.
- **`kitty-pwd`**: shell script returning the cwd of the active window in the focused tab, using `kitty @ ls --match-tab state:focused` piped to `jq`.
- **`kitty-reload` worktree-aware**: calls `kitty-pwd` to get the focused window's cwd, then tests with `git-worktree-is-oroshi` whether it is inside an oroshi worktree. If yes, writes the worktree root path into the Reload Beacon. If no, writes `$OROSHI_ROOT`. The beacon content is always a path (never an empty file).
- **`reload.py` path-aware loading**: reads the Reload Beacon content (a path), constructs per-module file paths under `{path}/tools/term/kitty/config/lib/`, and uses `importlib.util.spec_from_file_location` to load each `lib.*` module from that path. No `sys.path` modification.
- **Debug logging**: temporary append-only logging in `_on_attention_clear()`, writing to `$OROSHI_TMP_FOLDER/kitty/attention-debug.log`. Logs timer fire, `activeTabId`, on-disk attention entries, and subprocess result. Removed after the bug is fixed.
- **Bug fix**: determined after diagnosis via the debug logging. Scope of fix unknown until then.

## Testing Decisions

Good tests mock external commands (kitty, git) and assert on observable output or
file side-effects, not implementation details.

- **`kitty-pwd`**: bats tests mocking `kitty @ ls` output (via `bats_mock`) and asserting the parsed cwd value from jq.
- **`kitty-reload`**: bats tests mocking `kitty-pwd`, `git-worktree-is-oroshi`, `kitty-redraw`, and the beacon path. Assert beacon file content is the worktree path when in a worktree, and `$OROSHI_ROOT` otherwise.
- **`kitty-tab-switch`**: no tests — trivial one-liner delegating to `kitty @`.
- **`reload.py`**: no tests — `spec_from_file_location` is hard to test in isolation.
- **Debug logging**: no tests — temporary code.

Prior art: existing bats tests in `scripts/bin/kitty/__tests__/` (e.g., `kitty-reload.bats`, `kitty-tab-attention-add.bats`) use `bats_mock`, `bats_mock_env`, and `bats_run_zsh`.

## Out of Scope

- Making `kitty-pwd` accept arguments (tab ID, window ID).
- Reloading `tab_bar.py` itself (entry point loaded by kitty, requires restart).
- Permanent logging or observability for the Tab Bar.
- Testing `reload.py` Python changes.

## Further Notes

The execution order matters: modules 1-3 (tooling) must be built before module 4
(worktree-aware reload), which must be deployed before module 5 (debug logging),
since the debug logging code lives in the worktree and needs the worktree-aware
reload to be testable. The bug fix (module 6) depends on what the debug logging
reveals.
