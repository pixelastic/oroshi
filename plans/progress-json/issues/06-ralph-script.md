## TLDR

Update the `ralph` orchestrator script to use `plans-directory` instead of `ralph-directory`.

## What to build

Update the `ralph` main script (the loop/single-shot orchestrator) to use the renamed tools:

1. Replace `ralph-directory` calls with `plans-directory`
2. The script already uses `ralph-state` for runtime state — that now writes to `ralph.json` (handled by issue 03)
3. No other logic changes needed — the script's loop, sentinel watcher, and auto-commit flow stay the same

Update bats tests if they reference the old directory or file names.

## Acceptance criteria

- [ ] `ralph` script uses `plans-directory` to resolve the plan path
- [ ] Single-shot and loop mode work with the new paths
- [ ] Bats tests pass