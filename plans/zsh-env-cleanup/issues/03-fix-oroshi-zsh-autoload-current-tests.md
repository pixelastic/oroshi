## TLDR

Replace `$OROSHI_ZSH_AUTOLOAD` in bats `CURRENT=` assignments with `$BATS_TEST_DIRNAME`-relative paths.

## What to build

Four bats test files assign a `CURRENT` variable in `setup()` to point at the function under test, using the removed `$OROSHI_ZSH_AUTOLOAD` variable:

- `tools/term/zsh/config/functions/autoload/colors/__tests__/colors-load-definitions.bats`
- `tools/term/zsh/config/functions/autoload/colors/__tests__/colors-template-render.bats`
- `tools/term/zsh/config/functions/autoload/term/js/__tests__/is-js.bats`
- `tools/term/zsh/config/functions/autoload/json/__tests__/jsonc2json.bats`

In each file, replace the `$OROSHI_ZSH_AUTOLOAD/<subpath>/<fn>` assignment with `$BATS_TEST_DIRNAME/../<fn>`. The function file lives one directory above the `__tests__/` directory in all four cases.

`$BATS_TEST_DIRNAME` is provided by the bats runtime and resolves to the directory of the currently executing `.bats` file. Using it makes each suite self-contained — no environment variable needs to be set before running the tests.

## Behavioral tests

Run all four bats suites after the edit — all tests must pass.

## Acceptance criteria

- [ ] None of the four files references `$OROSHI_ZSH_AUTOLOAD`
- [ ] `CURRENT` in each `setup()` resolves via `$BATS_TEST_DIRNAME`
- [ ] All four bats suites pass
- [ ] All four files pass `bats-lint`
