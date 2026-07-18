## TLDR

Add optional path argument to `yarn-is-monorepo` so it can check external paths.

## What to build

Edit `yarn-is-monorepo` to accept an optional positional argument. When a path is given, use `git-directory-root $path` instead of `git-directory-root` to resolve the git root, then check that root's `package.json` for a `workspaces` field. When no argument is given, preserve the current behavior (resolves from current directory).

`git-directory-root` already accepts an optional path argument — no changes needed there.

## Behavioral Tests

**Monorepo root path:**
- returns 0 when given the root of a monorepo that has `workspaces` in its `package.json`

**Sub-directory inside monorepo:**
- returns 0 when given a deep sub-directory inside a monorepo (e.g. `modules/lib`)

**Non-monorepo path:**
- returns 1 when given a path to a project without `workspaces`

**Backward compatibility:**
- returns 0 when called with no argument from inside a monorepo (existing behavior)

## Acceptance criteria

- [ ] `yarn-is-monorepo /path/to/monorepo/root` returns 0
- [ ] `yarn-is-monorepo /path/to/monorepo/modules/lib` returns 0
- [ ] `yarn-is-monorepo /path/to/non-monorepo` returns 1
- [ ] `yarn-is-monorepo` with no argument still works as before
- [ ] All bats tests pass
