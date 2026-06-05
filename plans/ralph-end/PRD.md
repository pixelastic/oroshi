## Problem Statement

The `ralph` script mixes single-shot and loop mode logic in a single file. When debugging or extending single-shot mode — the mode used daily — the developer must read through sentinel watcher code, iteration logic, and git commit handling that are irrelevant to their task. The risk of accidentally breaking single-shot mode while touching loop code is high.

Additionally, the semaphore guard (preventing two concurrent single-shot sessions in the same plan directory) currently lives in `ralph-start`, a script called by the Claude skill — not by the `ralph` script itself. This means the lock is only enforced after Claude has already launched.

## Solution

Split `ralph` into two focused modules — `ralph-single` and `ralph-loop` — extracted as sourced ZSH function files. The `ralph` script becomes a thin dispatcher. The semaphore check moves into `ralph-single`, making it the authoritative owner of the single-shot session lifecycle (create lock → launch Claude → clear lock). `ralph-start` becomes a pure issue-selection utility with no session state logic.

## User Stories

1. As a developer, I want single-shot mode code isolated from loop mode code, so that I can read and debug it without loop-related noise.
2. As a developer, I want the semaphore enforced in `ralph-single` before Claude launches, so that a concurrent session is rejected as early as possible.
3. As a developer, I want `ralph-start` to be a pure issue-selection utility, so that its responsibility is clear and its tests are focused.
4. As a developer, I want `ralph` to remain the single entry point, so that my muscle memory and aliases are unchanged.
5. As a developer, I want to call `ralph <dir>` and have it dispatch to single-shot mode by default, so that common usage stays simple.
6. As a developer, I want to call `ralph --max N <dir>` and have it dispatch to loop mode, so that the interface is unchanged.
7. As a developer, I want `ralph-single.zsh` and `ralph-loop.zsh` to follow the preToolUse guard-clause pattern, so that tests can mock their dependencies before sourcing.
8. As a developer, I want the `__lib` directory excluded from PATH automatically, so that internal function files are not exposed as user-callable commands.
9. As a developer, I want `ralph-end` behavior unchanged — no-op in single mode, sets `done=true` in loop mode — so that the Claude skill requires no modification.
10. As a developer, I want `ralph-state` unchanged, so that all ralph.json CRUD remains in one place.

## Implementation Decisions

- **Dispatcher**: `ralph` parses the `--max` flag. Without it, calls `ralph-single`. With it, calls `ralph-loop`. It sources both function files from a `__lib` subdirectory adjacent to itself.

- **`__lib` subdirectory**: The PATH loader already skips all directories prefixed with `__`, so placing internal `.zsh` files there prevents them from appearing in PATH.

- **`ralph-single` function**:
  1. Check for existing `ralph.json` with `mode=single` → refuse and exit if found (semaphore)
  2. Initialize lock via `ralph-state init single`
  3. Navigate to git root
  4. Launch Claude in foreground with `/ralph <dir>`
  5. Clear lock via `ralph-state clear`

- **`ralph-loop` function**: Extracted verbatim from the current `ralph` loop block. Contains `_sentinel_watcher` as a nested helper. No changes to logic during extraction.

- **`ralph-start` modification**: Remove the `ralph.json` existence check and `ralph-state init single` call entirely. The function becomes: resolve dir → check state.json exists → find next eligible issue → return JSON.

- **Guard clause pattern** (same as preToolUse hooks): Each `.zsh` file opens with `whence <function-name> >/dev/null && return 0` to allow tests to pre-define mocks before sourcing.

- **Skill unchanged**: The Claude skill (`SKILL.md`) calls `ralph-start` and `ralph-end` — both remain available with compatible interfaces.

## Testing Decisions

Good tests exercise only externally observable behavior: exit codes, file system state (ralph.json created/cleared), and which downstream functions are called. They do not assert on internal variable names or function call order.

**Modules tested:**

- **`ralph-single`** (new tests): semaphore rejects a second session when `ralph.json` with `mode=single` exists; lock is created before Claude runs; lock is cleared after Claude exits; Claude is called with the correct arguments. Prior art: `preToolUse-Bash-rtk.bats` — sources a `.zsh` file, uses `bats_run_function`, mocks dependencies with `bats_mock`.

- **`ralph-loop`** (migrated tests): run existing `ralph.bats` tests first; migrate only the passing ones. No new tests written for loop mode.

- **`ralph` dispatcher** (new tests, replacing current `ralph.bats`): without `--max`, calls `ralph-single`; with `--max N`, calls `ralph-loop` with correct arguments.

- **`ralph-start`** (updated tests): remove all tests that assert on `ralph.json` creation or session lock behavior.

## Out of Scope

- Fixing any existing bugs in loop mode. The extraction is a refactor — loop behavior is preserved as-is.
- Writing new loop mode tests beyond migrating passing ones.
- Changing the Claude skill (`SKILL.md`).
- Changing `ralph-end` or `ralph-state`.
- Any changes to aliases, keybindings, or completions referencing `ralph`.

## Further Notes

The `__lib` naming follows the existing convention in this repo (`__src`, `__rules`) where double-underscore prefixes mark directories that are not user-callable entry points.
