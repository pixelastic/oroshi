## TLDR

Replace `ralph`'s body with a thin dispatcher that sources the two function files and calls the right one.

## What to build

Rewrite `ralph` to be a dispatcher only:
1. Source `__lib/ralph-single.zsh` and `__lib/ralph-loop.zsh` from the same directory as the script
2. Parse the `--max` flag
3. Without `--max`: call `ralph-single <dir>`
4. With `--max N`: call `ralph-loop <dir> <N>`

Replace the content of `ralph.bats` with dispatcher-focused tests only. The old loop tests are now in `ralph-loop.bats`.

## Behavioral Tests

**Dispatch without `--max`:**
- calls `ralph-single` with the resolved directory

**Dispatch with `--max`:**
- calls `ralph-loop` with the resolved directory and iteration count

## Acceptance criteria

- [ ] `ralph` sources both `.zsh` files from `__lib/`
- [ ] `ralph` body contains no loop logic and no semaphore logic
- [ ] `ralph.bats` tests only dispatch behavior (2 tests)
- [ ] All `ralph.bats` tests pass
- [ ] End-to-end: `ralph <dir>` runs a single issue; `ralph --max 1 <dir>` runs one loop iteration
