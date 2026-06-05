## TLDR

Extract loop logic from `ralph` into `__lib/ralph-loop.zsh`, migrate passing tests to `ralph-loop.bats`.

## What to build

Create `__lib/ralph-loop.zsh` exporting a `ralph-loop` function. Extract the loop block from `ralph` verbatim — sentinel watcher, iteration counter, `prd_done` early exit, git commit after each iteration, Ctrl+C handling. No logic changes during extraction.

Follow the same guard-clause pattern as `ralph-single.zsh`.

Run the existing `ralph.bats` tests before migration. Move only the passing tests into `ralph-loop.bats`. Drop any tests that were already failing — do not fix them.

## Behavioral Tests

Migrate from `ralph.bats` (passing tests only):
- runs exactly N iterations when `--max N` is given
- exits early when `prd_done` is set after an iteration
- stops cleanly on Ctrl+C with no commit
- ralph.json exists during each iteration and is cleared after all iterations complete

## Acceptance criteria

- [ ] `__lib/ralph-loop.zsh` exists and is not executable
- [ ] Guard clause present at top of file
- [ ] `ralph-loop.bats` exists with all migrated tests passing
- [ ] Only previously-passing tests were migrated (no new fixes to loop bugs)
- [ ] `ralph.bats` original loop tests removed (they move to `ralph-loop.bats`)
