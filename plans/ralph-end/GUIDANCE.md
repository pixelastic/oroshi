## Guidance

### Context

Refactoring `ralph` to separate single-shot and loop mode into two focused ZSH function files. The `ralph` script becomes a thin dispatcher.

### Key scripts (relative to repo root)

- `scripts/bin/ai/ralph/ralph` — main entry point (dispatcher after this refactor)
- `scripts/bin/ai/ralph/ralph-start` — issue selection utility
- `scripts/bin/ai/ralph/ralph-end` — session signal (unchanged by this refactor)
- `scripts/bin/ai/ralph/ralph-state` — ralph.json CRUD (unchanged by this refactor)
- `scripts/bin/ai/ralph/__lib/ralph-single.zsh` — NEW: single-shot function
- `scripts/bin/ai/ralph/__lib/ralph-loop.zsh` — NEW: loop function

### Test commands

```zsh
bats scripts/bin/ai/ralph/__tests__/ralph-start.bats
bats scripts/bin/ai/ralph/__tests__/ralph-single.bats
bats scripts/bin/ai/ralph/__tests__/ralph-loop.bats
bats scripts/bin/ai/ralph/__tests__/ralph.bats
```

### Test prior art

`tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-rtk.bats` — canonical example of sourcing a `.zsh` function file and testing with `bats_run_function` + `bats_mock`.

### Guard clause pattern for `.zsh` function files

Each `.zsh` file must open with:
```zsh
whence <function-name> >/dev/null && return 0
```
This allows tests to pre-define mock functions before sourcing the file.

### `__lib` directory

`scripts/bin/ai/ralph/__lib/` is excluded from PATH by the loader in `tools/term/zsh/config/path.zsh` (skips all `__`-prefixed directories). Files here are sourced, not executed directly.

### Unchanged scripts

`ralph-end` and `ralph-state` are not modified by this refactor. `ralph-end` remains a no-op in single mode and sets `done=true` in loop mode.

### ralph.json lifecycle (single mode, post-refactor)

`ralph-single` owns the full lifecycle: creates the lock, launches Claude, clears the lock. `ralph-start` has no knowledge of ralph.json.

## Discoveries

### Issue 02 — ralph-single

- `jo` available here does not support `:=` for raw JSON — use plain `key=value`; it auto-detects `true`/`false` as booleans.
- `bats_run_function` is deprecated in this codebase; use `bats_run_zsh` with the caller.zsh + mock.zsh pattern from `preToolUse-Bash-rtk.bats`.
- When mocking `ralph-state` in a test that pre-creates a `ralph.json` file, use a conditional mock (`[[ "$2" == "get" ]] && echo "<mode>"`) so the semaphore check sees the correct mode while init/clear are no-ops.