## TLDR

Migrate all 11 yarn/node `compdef` completion functions to use `$COLORS[key]` and `$ICONS[key]`, and add the two load-definitions calls.

## What to build

Update these files under `tools/term/zsh/config/completion/compdef/`:
`_yarn-runnables`, `_yarn-link-universal-enabled`, `_yarn-link-local`, `_yarn-link-classic-disabled`, `_yarn-link-classic-enabled`, `_yarn-link-classic-all`, `_yarn-link-global`, `_yarn-dependencies`, `_yarn-dependencies-recursive`, `_node-modules`, `_node-versions-installed`

For each file:
1. Add `colors-load-definitions` and `icons-load-definitions` as the first two statements inside the function body.
2. Replace `$COLOR_ALIAS_*` with `$COLORS[key]` and `$COLOR_WHITE`/`$COLOR_BLACK` with `$COLORS[white]`/`$COLORS[black]`.
3. Add a `$ICONS[key]` reference to header labels that currently have none.

Color mappings for this group:
- `COLOR_ALIAS_LANGUAGE_JAVASCRIPT` → `$COLORS[language-javascript]`
- `COLOR_ALIAS_LANGUAGE_NODE` → `$COLORS[language-node]`
- `COLOR_ALIAS_YARN_LINK_EXTERNAL` → `$COLORS[yarn-link-external]`
- `COLOR_ALIAS_YARN_LINK_LOCAL` → `$COLORS[yarn-link-workspace]`
- `COLOR_ALIAS_YARN_LINK_CLASSIC` → `$COLORS[yarn-link-classic]`
- `COLOR_ALIAS_YARN_LINK_GLOBAL` → `$COLORS[yarn-package-global]`
- `COLOR_ALIAS_YARN_PACKAGE_GLOBAL` → `$COLORS[yarn-package-global]`

Icon mappings for this group:
- `_yarn-runnables` (scripts header) → `$ICONS[node-package]`
- `_yarn-runnables` (binaries header) → `$ICONS[node]`
- `_yarn-link-universal-enabled` → already uses `$ICONS[node-link]`
- `_yarn-link-local` / `_yarn-link-classic-*` / `_yarn-link-global` → `$ICONS[node-link]`
- `_yarn-dependencies` / `_yarn-dependencies-recursive` → `$ICONS[node-package]`
- `_node-modules` / `_node-versions-installed` → `$ICONS[node]`

## Acceptance criteria

- [ ] All 11 files have `colors-load-definitions` + `icons-load-definitions` as the first two function statements
- [ ] No `$COLOR_ALIAS_*`, `$COLOR_WHITE`, or `$COLOR_BLACK` references remain
- [ ] All header labels include a `$ICONS[key]` reference
- [ ] `zsh-lint` passes on all 11 files
