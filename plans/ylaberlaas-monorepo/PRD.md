## Problem Statement

The `ylaberlaas` shell alias links only the main `aberlaas` package (`modules/lib`) into a consumer project. But aberlaas is a monorepo with 13 workspace sub-packages (`aberlaas-lint`, `aberlaas-ci`, `aberlaas-test`, etc.), each published separately and depended on by the main `aberlaas` package via `workspace:*`. Because only the main package gets linked, the consumer keeps using published npm copies of all sub-packages — so local edits to any sub-package (e.g. fixing an ESLint rule in `aberlaas-lint`) are invisible in the consumer.

## Solution

Change `ylaberlaas` to point to the aberlaas monorepo root instead of `modules/lib`. Make `yarn-link` detect that a given path is a monorepo (has `workspaces` in its `package.json`) and automatically link every workspace module, so all local changes propagate to the consumer.

## User Stories

1. As a developer, I want `ylaberlaas` to link all aberlaas sub-packages at once, so that local changes to any sub-package are picked up by the consumer project.
2. As a developer, I want `yarn-link /path/to/monorepo` to detect the monorepo and link all its workspaces automatically, so I don't need to know or list every sub-package manually.
3. As a developer, I want `yarn-is-monorepo /some/path` to check whether an arbitrary path is inside a monorepo, so the detection works on external projects, not just the current directory.
4. As a developer, I want `yarn-workspace-list-raw /path/to/monorepo` to output all workspace names and paths, so I can script against workspace metadata.
5. As a developer, I want `yarn-workspace-list` to show a human-readable formatted table of workspaces, so I can quickly see what a monorepo contains.
6. As a developer, I want workspace discovery to be dynamic (parsed from `package.json` `workspaces` globs), so new sub-packages are linked automatically without alias changes.
7. As a developer, I want `yarn-link` to still work unchanged for non-monorepo paths, so existing single-module linking is unaffected.
8. As a developer, I want each workspace link to produce the same symlink + binary linking behavior as a regular `yarn-link-create`, so linked workspaces behave identically to individually-linked modules.

## Implementation Decisions

- **`yarn-is-monorepo` accepts an optional path argument.** When a path is given, it uses `git-directory-root $path` to resolve up to the git root, then checks that root's `package.json` for a `workspaces` field. When no argument is given, current behavior is preserved (uses the current directory's git root).
- **New `yarn-workspace-list-raw` function** in a new `yarn/workspace/` autoload directory. Accepts an optional path (defaults to `yarn-root`). Resolves to git root, parses the `workspaces` globs from `package.json` via `jq`, glob-expands each pattern, and outputs one `name▮path` line per workspace. Follows the existing `*-list-raw` convention (machine-parseable, `▮`-separated).
- **New `yarn-workspace-list` function** in the same directory. Calls `yarn-workspace-list-raw` and formats output as a human-readable table with colorized names and icons. Follows the existing `*-list` / `*-list-raw` pattern (e.g. `yarn-dependency-list` / `yarn-dependency-list-raw`).
- **`yarn-link` gains monorepo detection.** After resolving the absolute path, it calls `yarn-is-monorepo $path`. If true, it calls `yarn-workspace-list-raw $path` to get all workspace module paths, then iterates and calls `yarn-link-create` on each (same as the existing per-module flow). If false, current single-module behavior is unchanged.
- **`ylaberlaas` alias changes** from `yarn-link /home/tim/local/www/projects/aberlaas/modules/lib` to `yarn-link /home/tim/local/www/projects/aberlaas` (the monorepo root).

## Testing Decisions

Tests should verify external behavior (outputs, exit codes, symlink creation) not implementation details.

Modules to test:
- **`yarn-is-monorepo`** — test with path argument pointing to a monorepo root, a sub-directory inside a monorepo, and a non-monorepo path. Prior art: existing bats tests in `tools/term/zsh/config/functions/autoload/` using `bats_run_zsh`.
- **`yarn-workspace-list-raw`** — test output format (`name▮path` lines), test against the real aberlaas monorepo to verify all workspaces are discovered. Test with a non-monorepo path (should return empty/error).
- **`yarn-link`** — test that passing a monorepo root results in symlinks for all workspace modules in `node_modules/`, not just the root package. Test that passing a regular module path still links only that module.

No tests for: `yarn-workspace-list` (presentation layer), alias change (config artifact).

## Out of Scope

- **`yarn-link-remove` monorepo awareness** — removing all workspace links when unlinking a monorepo package. Will be addressed separately.
- **`ylnorska` alias update** — same class of problem, same fix pattern, but separate change.
- **`yarn-workspace-list` tests** — thin presentation layer over `yarn-workspace-list-raw`.

## Further Notes

- The `workspaces` field in aberlaas root `package.json` is `["modules/*"]`. The `jq` + glob approach handles any glob pattern, so this works for monorepos with different layouts (e.g. `packages/*`).
- `yarn-link-create` already handles symlink creation and binary linking per module. No changes needed there.
- The existing `yarn-link-list-raw` and `yarn-link-colorize` already support a `workspace` link type with its own icon (`ICONS[node-monorepo]`) and color. Linked workspaces will show up correctly in `yarn-link-list`.
