## TLDR

Create `npm-name` helper that returns the publishable npm package name from a project path, with monorepo `lib/` fallback.

## What to build

New zsh autoload function at `tools/term/zsh/config/functions/autoload/npm/npm-name`.

Takes a single filepath argument. Returns the npm package name on stdout. Returns nothing (non-zero exit) if no publishable package is found.

Early-return flow:
1. No `package.json` at the given path → return 1
2. Root not private → return its `name` via `yarn-package-name`
3. No `workspaces` array in root package.json → return 1
4. `lib` not listed in the `workspaces` array → return 1
5. `<root>/lib/package.json` exists and not private → return its `name` via `yarn-package-name`
6. Otherwise → return 1

Use `jq` to read the `workspaces` array directly (not `yarn-is-monorepo` which depends on git). Compose `yarn-package-is-private` and `yarn-package-name` for the checks.

## Behavioral Tests

**Standard project (public root)**
- returns the package name when root package.json is public

**No package.json**
- returns 1 when no package.json exists at the path

**Private root, no workspaces**
- returns 1 when root is private with no workspaces

**Private root, monorepo without lib**
- returns 1 when root is private monorepo but `lib` is not in workspaces array

**Private root, monorepo with lib (public)**
- returns the lib package name when root is private monorepo with `lib` workspace and lib/package.json is public

**Private root, monorepo with lib (private)**
- returns 1 when root is private monorepo with `lib` workspace but lib/package.json is also private

## Acceptance criteria

- [ ] `npm-name /path/to/standard-project` prints the package name
- [ ] `npm-name /path/to/monorepo` prints the lib package name
- [ ] `npm-name /path/to/private-no-workspaces` exits non-zero with no output
- [ ] `npm-name /path/to/monorepo-without-lib` exits non-zero with no output
- [ ] All 6 bats tests pass
- [ ] `zsh-lint` passes on the new function
- [ ] `bats-lint` passes on the test file
