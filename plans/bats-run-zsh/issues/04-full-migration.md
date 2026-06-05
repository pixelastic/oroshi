## TLDR

Migrate all remaining test files to `bats_run_zsh`.

## What to build

Migrate all remaining `bats_run_function`, `bats_run_script`, and `run zsh` calls in all `.bats` files to `bats_run_zsh`, passing full file paths.

For `bats_run_function "func-name"` calls, resolve the full path as `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/<subdir>/func-name`.
For `bats_run_script "/path/to/script"` calls, pass the same path directly.
For `run zsh` calls, convert to the appropriate `bats_run_zsh` form based on what is being invoked.

All tests must pass after migration. Run `bats-lint` on all migrated files to confirm no `noRunZsh` violations remain.

## Scaffolding Tests

- No `noRunZsh` violations across all `.bats` files
- No `bats_run_function` calls remain in any `.bats` file
- No `bats_run_script` calls remain in any `.bats` file

## Acceptance criteria

- [ ] All `.bats` files migrated — no `bats_run_function` or `bats_run_script` calls remain
- [ ] No `noRunZsh` violations reported by `bats-lint` across the full codebase
- [ ] Full test suite passes (`bats <all test files>`)
