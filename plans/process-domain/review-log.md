## Issue 02 — process-name
### Guard duplicates process-exists logic
```zsh
[[ "$pid" == "" ]] && return 1
[[ ! -f "/proc/$pid/comm" ]] && return 1
```
**Problem:** Guards duplicate logic from `process-exists`
**Reason skipped:** Different semantics — `process-exists` checks `-d /proc/$pid`, we need `-f /proc/$pid/comm`. Calling `process-exists` then reading comm would be two filesystem checks instead of one.

### $$ couples test to bats runner
```bash
bats_run_zsh "process-name $$"
[[ "$output" = "bash" ]]
```
**Problem:** Test assumes `$$` resolves to a process named "bash"
**Reason skipped:** Same pattern used in sibling `process-exists.bats`; `$$` in bats is always the bash runner PID. Stable and consistent with existing tests.

### No-op setup()
```bash
setup() {
  :
}
```
**Problem:** `setup()` body is a no-op
**Reason skipped:** Identical pattern in `process-exists.bats` — established convention in this test directory when no setup is needed.
