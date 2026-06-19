## TLDR

Move `colors-build`, `filetypes-build`, `projects-build` from `tools/term/zsh/config/theming/` to autoloaded functions in their respective domain folders so they're callable by name.

## What to build

For each of the three build scripts (`colors-build`, `filetypes-build`, `projects-build`):

1. **Convert from script to autoloaded function.** Remove shebang (`#!/usr/bin/env zsh`), replace `set -e` with `setopt local_options err_return`.

2. **Replace `THEMING_ROOT` with `$OROSHI_ROOT`.** Change `local themingRoot="${THEMING_ROOT:-${0:A:h}}"` to `local themingRoot="$OROSHI_ROOT/tools/term/zsh/config/theming"`. Remove any `THEMING_ROOT` override support — it's no longer needed.

3. **Move to the autoload domain folder:**
   - `colors-build` → `tools/term/zsh/config/functions/autoload/colors/`
   - `projects-build` → `tools/term/zsh/config/functions/autoload/project/`
   - `filetypes-build` → `tools/term/zsh/config/functions/autoload/filetypes/`

4. **Adapt tests.** Replace `THEMING_ROOT="$BATS_TMP_DIR/theming"` with `bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"` and recreate the directory structure under `$BATS_TMP_DIR/tools/term/zsh/config/theming/{src,dist}`. Move test files to the `__tests__/` folder of their new domain.

5. **Call by name.** Tests should use `bats_run_zsh "colors-build"` (not `./colors-build` or `realpath`).

## Behavioral Tests

- All existing tests in `colors-build.bats`, `filetypes-build.bats`, `projects-build.bats` should pass after migration

## Acceptance criteria

- [ ] No build scripts left in `tools/term/zsh/config/theming/`
- [ ] `colors-build`, `filetypes-build`, `projects-build` callable by name (in PATH via autoload)
- [ ] No reference to `THEMING_ROOT` in any build script
- [ ] All build test suites pass with 0 failures
- [ ] Linter clean on all moved files
