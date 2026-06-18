## TLDR

Fix 1 failing test in `projects-build.bats` — the generated `.zsh` file doesn't quote the `path` value, so tilde paths aren't expanded correctly.

## What to build

In `tools/term/zsh/config/theming/projects-build`:

1. **Quote the path value in the jq template.** The line generating `PROJECTS[name:path]=~/projects/full` needs quotes around the value so zsh properly stores/expands the path. Expected output: `PROJECTS[name:path]="~/projects/full"`.

2. **Verify the test expectation.** The test at line 196 expects `$HOME/projects/full` (expanded). Check whether the script should store the expanded path or the literal `~/projects/full`. Align the fix and the test.

3. **Also check `bats_run_zsh "$script"` usage.** The test on line 185 does `bats_run_zsh "$script"` where `$script` is a file path — same pattern as issue 06. Fix if needed.

## Behavioral Tests

- The "dist/projects.zsh sets all values for a full project" test should pass

## Acceptance criteria

- [ ] `bats projects-build.bats` reports 0 failures
- [ ] Path values in generated `.zsh` are properly quoted
