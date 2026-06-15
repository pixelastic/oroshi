## TLDR

For ~15 test files where `CURRENT` holds a `.zsh` file that is sourced inside the command string, rename the variable to `sourcePrefix` and update all call sites.

## What to build

Migrate every `.bats` file where `CURRENT` holds the path to a `.zsh` autoload file and is used inside a `source $CURRENT` expression within a `bats_run_zsh` string. These files cannot use the direct-by-name pattern because `.zsh` autoload files are not on the PATH.

For each file:
1. Rename `CURRENT` to `sourcePrefix` in `setup()`.
2. Change the value from a bare path to a full source expression: `sourcePrefix="source '$BATS_TEST_DIRNAME/../file.zsh'"`.
3. Update every call site: `bats_run_zsh "$sourcePrefix && function-name arg"`.
4. If `setup()` contains only this one line and nothing else is needed, it stays (the variable is still useful).
5. Run `bats <filepath>` and confirm it passes before moving to the next file.

## Scaffolding Tests

- No `.bats` file in the migrated set contains `CURRENT=`.
- Every migrated file that previously sourced via `CURRENT` now has a `sourcePrefix=` assignment.
- `sourcePrefix` value begins with `source '`.

## Acceptance criteria

- [ ] All ~15 source-pattern files are migrated
- [ ] `bats <filepath>` passes for every migrated file
- [ ] `bats-lint <filepath>` passes for every migrated file
- [ ] No `CURRENT=` remains in any migrated file
- [ ] All `sourcePrefix` assignments follow the canonical form
