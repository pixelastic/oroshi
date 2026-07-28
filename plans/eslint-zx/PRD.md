## Problem Statement

`yarn run lint` fails with `'module' is not defined (no-undef)` in `scripts/bin/js/eslintrc.zx.js`. This file is a legacy CommonJS ESLint config consumed by `eslint-zx`, a wrapper around `eslint_d` for linting zx scripts. Neither `eslint-zx` nor any of the zx scripts it was designed to lint are actively used. The repo also contains two other dead zx scripts (`json2json5.mjs`, `kitty-layout-load.mjs`) and their supporting files.

## Solution

Delete all dead zx-related scripts and their supporting files (configs, symlinks, installers). Clean up references in files that mention the deleted scripts (commented-out code in `kitty-restore`, keybinding in `keybindings.conf`). This fixes the lint error by removing the offending file entirely rather than ignoring it.

## User Stories

1. As a developer, I want `yarn run lint` to pass cleanly, so that CI and local checks don't report false errors
2. As a developer, I want dead scripts removed from the repo, so that I don't waste time investigating whether they're used
3. As a developer, I want commented-out references to deleted scripts removed, so that the codebase doesn't accumulate stale TODOs
4. As a developer, I want orphaned keybindings removed, so that terminal shortcuts don't silently fail
5. As a developer, I want orphaned install scripts removed, so that provisioning doesn't install unused packages

## Implementation Decisions

- **Delete, don't ignore:** The root cause is dead code, not a missing ESLint ignore rule. Deleting the files is the correct fix.
- **Three removal groups:**
  - **eslint-zx group:** `eslint-zx` wrapper + `eslintrc.zx.js` config. Neither is referenced anywhere in the codebase.
  - **json2json5 group:** `json2json5.mjs` + its symlink + `json5/install` provisioning script. The `json5` npm package is not used anywhere else.
  - **kitty-layout group:** `kitty-layout-load.mjs` + its symlink + `kitty-layout-save`. The load script is commented out in `kitty-restore` (with a known bug). The save script is bound to Alt+F5 in `keybindings.conf` but produces output nothing consumes.
- **Reference cleanup:** Remove the commented-out `kitty-layout-load` block in `kitty-restore`. Remove the Alt+F5 `kitty-layout-save` keybinding in `keybindings.conf`.
- **No changes to `eslint.config.js`:** The offending file is deleted, so no ignore rule is needed.

## Testing Decisions

No tests. This is a deletion-only change. The acceptance criterion is `yarn run lint` passing without errors.

## Out of Scope

- Rewriting kitty layout save/restore from scratch (can be revisited later, using git history for inspiration)
- Converting any remaining scripts to zx
- Changes to the main `eslint.config.js` flat config
- Removing the `json5` transitive dependency from `node_modules` (it's pulled in by other tools)
