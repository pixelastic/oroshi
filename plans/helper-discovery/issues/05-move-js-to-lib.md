## TLDR

Move `.js` implementation files in `scripts/bin/` into `__lib/` subdirectories so `helper-list-raw` no longer surfaces them as standalone helpers.

## What to build

For each `scripts/bin/` directory containing `.js` files alongside a ZSH wrapper:

1. Create a `__lib/` subdirectory
2. Move all `.js` files into `__lib/`
3. Update the ZSH wrapper's `node` path (e.g. `${0:A:h}/foo.js` → `${0:A:h}/__lib/foo.js`)
4. Update all internal `import`/`require` paths between moved `.js` modules
5. Update any test files that reference moved paths

Affected directories:
- `scripts/bin/json/` — `jsonc-remove-key.js`
- `scripts/bin/git/commit/git-commit-message/` — `git-commit-message.js` + 8 helper modules
- `scripts/bin/google/google-login/` — `google-login.js`
- `scripts/bin/google/gdocs/gdocs-comments-json/` — `gdocs-comments-json.js`
- `scripts/bin/google/gdocs/gdocs2md/` — `gdocs2md.js`
- `scripts/bin/google/` — `googleAuth.js` (shared helper, no wrapper)
- `scripts/bin/markdown/md2gdocs/` — `md2gdocs.js`

Special case: `googleAuth.js` sits in `scripts/bin/google/` and is imported by multiple gdocs/markdown modules. Move it to `scripts/bin/google/__lib/` and update all consumers.

## Behavioral Tests

**helper-list-raw filtering:**
- "does not return .js files in results"

## Scaffolding Tests

- "jsonc-remove-key.js exists in __lib/"
- "git-commit-message.js and helpers exist in __lib/"
- "google-login.js exists in __lib/"
- "gdocs-comments-json.js exists in __lib/"
- "gdocs2md.js exists in __lib/"
- "googleAuth.js exists in google/__lib/"
- "md2gdocs.js exists in __lib/"

## Acceptance criteria

- [ ] All `.js` files moved from `scripts/bin/**/` to `scripts/bin/**/__lib/`
- [ ] ZSH wrappers updated to point to `__lib/` paths
- [ ] Internal JS imports between modules still resolve
- [ ] `helper-list-raw` no longer returns `.js` files (already excluded by `! -path '*__*'`)
- [ ] All existing tests pass
- [ ] No `.js` files remain directly in `scripts/bin/` dirs (outside `__lib/` or `__tests__/`)
