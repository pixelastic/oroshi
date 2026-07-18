## TLDR

Add `--public` flag to `yarn-workspace-list-raw` to exclude private workspaces; use it in `yarn-link`.

## What to build

Add a `--public` flag to `yarn-workspace-list-raw` that skips workspaces where `package.json` has `"private": true`. Without the flag, behavior is unchanged (list all workspaces).

Then update `yarn-link` to call `yarn-workspace-list-raw --public $path` instead of `yarn-workspace-list-raw $path`, so monorepo linking skips private workspaces (e.g. documentation modules).

## Behavioral Tests

**yarn-workspace-list-raw:**
- without `--public`, lists all workspaces including private ones
- with `--public`, excludes workspaces that have `"private": true` in their `package.json`

**yarn-link:**
- linking a monorepo skips private workspaces

## Acceptance criteria

- [ ] `yarn-workspace-list-raw /path` still lists all workspaces (unchanged)
- [ ] `yarn-workspace-list-raw --public /path` excludes private workspaces
- [ ] `yarn-link /path/to/monorepo` only links public workspaces
- [ ] All bats tests pass
