## TLDR

Fix 12 failing tests in `colors-jsonc-aliases.bats` — tests pass a file path to `bats_run_zsh` which expects a command string.

## What to build

1. **Evaluate if this test file is still needed.** The file tests `colors-build` alias migration (labeled "issue 08" in comments). Check whether this was a one-time migration scaffolding test that should have been removed, or ongoing behavioral tests that protect `colors-build` output. If scaffolding → delete the file. If behavioral → fix.

2. **If keeping: fix `bats_run_zsh` usage.** Every test does `bats_run_zsh "$script"` where `$script` is a file path. `bats_run_zsh` wraps `zsh -c "$1"`, so this interprets the path as code → permission denied. Fix: use `bats_run_zsh ". '$script'"` or `run zsh "$script"`.

3. **If keeping: update stale expected values.** The `git-behind` test expects `#991b1b` (red-7) but that color token was changed to red-6 (`#b91c1c`). Verify all expected hex values against current `colors.jsonc`.

## Behavioral Tests

- If file is kept: all 12 tests should pass
- If file is deleted: no tests needed

## Acceptance criteria

- [ ] Decision made: keep or delete `colors-jsonc-aliases.bats`
- [ ] If kept: `bats colors-jsonc-aliases.bats` reports 0 failures
- [ ] If deleted: file removed, no dangling references
