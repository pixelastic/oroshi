## Problem Statement

When committing changes to theming source files (colors.jsonc, filetypes.jsonc, icons.jsonc, projects.jsonc), lint-staged triggers `colors-reload` which rebuilds all dist files. But lint-staged v15+ no longer auto-stages modified files, so the regenerated dist files are left as dirty unstaged changes requiring a second manual commit.

## Solution

Create a yarn script `colors-build-and-stage` that calls `colors-reload` then `git add`s all generated dist directories. Update lint-staged config to call this new script instead of `colors-reload` directly.

## User Stories

1. As a developer editing colors.jsonc, I want the rebuilt dist files to be included in the same commit, so that I don't need a second commit for generated artifacts.
2. As a developer editing filetypes.jsonc, I want the same auto-staging behavior, so that all theming source files share one consistent commit workflow.
3. As a developer editing icons.jsonc or projects.jsonc, I want the same auto-staging behavior for consistency.
4. As a developer running `colors-reload` manually (outside a commit), I want no auto-staging side effects, so that my working tree stays under my control.

## Implementation Decisions

- The `git add` step lives in a new yarn wrapper script `scripts/yarn/colors-build-and-stage`, not inside the global `colors-reload` bin. This keeps manual reload free of git side effects.
- The wrapper calls the global `colors-reload` (not `yarn run colors-reload`) then `git add`s all four dist directories:
  - `tools/term/zsh/config/theming/dist/`
  - `tools/cli/bat/config/dist/`
  - `tools/cli/rg/config/dist/`
  - `tools/git/git/config/dist/`
- The `colors-reload` entry in `package.json` scripts is replaced by `colors-build-and-stage`.
- Both lint-staged glob patterns switch from `yarn run colors-reload` to `yarn run colors-build-and-stage`.
- The existing `scripts/yarn/filetypes-build` is dead code (nothing references `yarn run filetypes-build`) and is deleted.

## Testing Decisions

No tests needed — this is a config/plumbing change. The build scripts themselves are already tested. The fix can be verified manually by committing a colors.jsonc change and confirming dist files are staged.

## Out of Scope

- Changing the global `colors-reload` script behavior.
- Adding new generated output directories.
- Refactoring the build pipeline itself.

## Further Notes

`git add` on unchanged files is a no-op, so staging all four dist directories is safe even when only some files change.
