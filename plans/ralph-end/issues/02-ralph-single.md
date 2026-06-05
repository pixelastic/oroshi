## TLDR

Create `ralph-single.zsh` in `__lib/` — owns the full single-shot session lifecycle including the semaphore.

## What to build

Create a `__lib` subdirectory inside the ralph scripts folder (excluded from PATH by the loader's `__`-prefix rule). Inside it, create `ralph-single.zsh` exporting a `ralph-single` function.

The function owns the complete single-shot lifecycle:
1. Check for an existing ralph.json with `mode=single` → print error and refuse if found
2. Initialize the lock via `ralph-state init single`
3. Navigate to git root
4. Launch Claude in foreground with the ralph skill
5. Clear the lock via `ralph-state clear`

Follow the guard-clause pattern from `preToolUse-Bash-*.zsh`: open with `whence ralph-single >/dev/null && return 0` so tests can pre-define mocks before sourcing.

Write `ralph-single.bats` using `bats_run_function` (not `bats_run_script`), following the prior art in `preToolUse-Bash-rtk.bats`.

## Behavioral Tests

**Semaphore:**
- refuses to run when ralph.json with mode=single already exists
- proceeds normally when no ralph.json exists
- proceeds normally when ralph.json exists with mode=loop

**Session lifecycle:**
- creates ralph.json before launching Claude
- clears ralph.json after Claude exits (happy path)
- clears ralph.json after Claude exits with non-zero status

**Claude invocation:**
- calls Claude with the correct plan directory argument

## Acceptance criteria

- [ ] `__lib/ralph-single.zsh` exists and is not executable (sourced only)
- [ ] Guard clause present at top of file
- [ ] `ralph-single.bats` exists and all tests pass
- [ ] Semaphore rejects concurrent single sessions
- [ ] Lock is always cleared after Claude exits
