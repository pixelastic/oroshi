## TLDR

Migrate one representative test file to `bats_run_zsh` as an end-to-end smoke test.

## What to build

Pick one test file that exercises the autoload function detection path (the file's path falls under the autoload functions directory). Migrate all calls in that file from `bats_run_function` / `bats_run_script` / `run zsh` to `bats_run_zsh`, passing full file paths.

The goal is to validate that `bats_run_zsh` works correctly end-to-end before migrating the entire codebase. Choose a file that is small, has a clear set of passing tests, and exercises the autoload function path.

## Scaffolding Tests

- The migrated file has no `noRunZsh` violations when linted with `bats-lint`
- The migrated file has no remaining `bats_run_function` or `bats_run_script` calls

## Acceptance criteria

- [ ] One test file fully migrated to `bats_run_zsh`
- [ ] All tests in that file still pass (`bats <file>`)
- [ ] `bats-lint` reports no `noRunZsh` violations on that file
- [ ] No `bats_run_function` or `bats_run_script` calls remain in that file
