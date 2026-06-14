## Problem Statement

`ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` were removed from `zshenv` as part of a broader cleanup, but several production and test files still reference them. This causes runtime failures in the prod theming loader, the `colors-refresh` script, and broken test suites whenever those files are executed.

## Solution

Replace all remaining references to `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` with their equivalent `$OROSHI_ROOT`-based paths. In test files that use a `CURRENT=` assignment to point at the function under test, prefer a path relative to the test file's own location (`$BATS_TEST_DIRNAME`) to avoid environment coupling. Remove the now-satisfied TODO entries tracking this cleanup.

## User Stories

1. As a shell user, I want `theming/index.zsh` to load correctly at shell startup, so that colors and filetypes are available in every session.
2. As a developer, I want `colors-refresh` to run without errors, so that I can rebuild color dist files from any worktree.
3. As a developer running the git prompt test suite, I want all tests to pass, so that I can verify prompt behavior with confidence.
4. As a developer running the git-branch-color test suite, I want all tests to pass, so that branch color resolution is verified.
5. As a developer running the colors-load-definitions test suite, I want tests to resolve the function under test relative to the test file, so that the suite is self-contained and worktree-safe.
6. As a developer running the colors-template-render test suite, I want the same relative resolution, so that the test does not depend on any environment variable being set.
7. As a developer running the is-js test suite, I want the function path resolved relative to the test file, so that the test works in any clone or worktree.
8. As a developer running the jsonc2json test suite, I want the same relative resolution, so that the test is portable.
9. As a developer reading TODO.md, I want stale entries removed, so that the backlog reflects only outstanding work.

## Implementation Decisions

- **Prod replacement:** `$ZSH_CONFIG_PATH` in the theming index loader is replaced with the equivalent `$OROSHI_ROOT`-based path. `$OROSHI_ROOT` is already exported by `zshenv` before this file is sourced, so no load-order change is needed.
- **Script replacement:** `colors-refresh` has one remaining `$ZSH_CONFIG_PATH` call replaced identically.
- **Test `CURRENT=` pattern:** For the four bats files that assign a `CURRENT` variable in `setup()`, the path is resolved relative to the test file using `$BATS_TEST_DIRNAME`. This removes any dependency on `$OROSHI_ZSH_AUTOLOAD` being set in the environment and makes each suite self-contained.
- **Test heredoc pattern:** The two bats files that write inline zsh scripts via `<<'ZSCRIPT'` heredocs already source `zshenv.zsh` as their first line, making `$OROSHI_ROOT` available for subsequent sources. References to `$ZSH_CONFIG_PATH` and hardcoded `~/.oroshi` paths inside those heredocs are replaced with `$OROSHI_ROOT`-based paths. The heredoc delimiter remains single-quoted (`<<'ZSCRIPT'`) to avoid escaping runtime variables.
- **TODO cleanup:** Two entries in `TODO.md` that tracked this variable removal are deleted.

## Testing Decisions

A good test verifies external behavior: given inputs, does the function produce the correct output? It does not test which variable resolved a path.

All five affected bats test suites are run after the edits to confirm nothing regressed:
- `prompt/__tests__/git.bats`
- `functions/autoload/git/branch/__tests__/git-branch-color.bats`
- `functions/autoload/colors/__tests__/colors-load-definitions.bats`
- `functions/autoload/colors/__tests__/colors-template-render.bats`
- `functions/autoload/term/js/__tests__/is-js.bats`
- `functions/autoload/json/__tests__/jsonc2json.bats`

No new test files are written — the existing suites are the verification layer. Prior art: all suites use `bats_run_zsh` from the shared `helper` library.

## Out of Scope

- Replacing other hardcoded `~/.oroshi` paths in heredocs beyond the three identified in `git.bats` tests 4–5 (those do not use the deprecated variables).
- Removing or renaming the deprecated variables from any other config layer beyond `zshenv`.
- Adding new test coverage for `theming/index.zsh` or `colors-refresh`.

## Further Notes

The `$BATS_TEST_DIRNAME` variable is provided by the bats runtime and resolves to the directory containing the currently executing `.bats` file. It is available in `setup()`, `teardown()`, and test bodies, but not inside subprocess scripts written via heredoc — which is why the heredoc tests use `$OROSHI_ROOT` instead.
