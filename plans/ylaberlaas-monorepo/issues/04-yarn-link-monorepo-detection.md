## TLDR

Make `yarn-link` detect monorepos and link all workspaces; update `ylaberlaas` alias.

## What to build

Edit `yarn-link` so that after resolving the absolute path, it calls `yarn-is-monorepo $path`. If the path is a monorepo:

1. Call `yarn-workspace-list-raw $path` to get all workspace module paths
2. For each workspace, call `yarn-link-create` with the absolute path (same as the existing per-module flow)
3. Skip the normal single-module linking for that path

If the path is not a monorepo, behavior is unchanged (link the single module).

Also update the `ylaberlaas` alias in `tools/term/zsh/config/aliases/yarn.zsh` from `yarn-link /home/tim/local/www/projects/aberlaas/modules/lib` to `yarn-link /home/tim/local/www/projects/aberlaas`.

## Behavioral Tests

**Monorepo path:**
- passing a monorepo root creates symlinks in `node_modules/` for all workspace modules
- each symlink points to the correct workspace directory

**Non-monorepo path:**
- passing a regular module path creates a single symlink (unchanged behavior)

## Acceptance criteria

- [ ] `yarn-link /path/to/monorepo` links all workspace modules
- [ ] `yarn-link /path/to/single/module` still links only that module
- [ ] `ylaberlaas` alias points to aberlaas monorepo root
- [ ] All bats tests pass
