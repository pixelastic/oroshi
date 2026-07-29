## Problem Statement

`deprecate-prepare` fails to detect npm packages in aberlaas monorepos. When the root `package.json` is `private: true`, the script stops looking and reports `npmPackage: null`, even though the real publishable package lives in `lib/package.json`. This causes `deprecate-end` to skip npm deprecation entirely.

## Solution

Create an `npm-name` helper that, given a project path, returns the npm package name — handling the monorepo fallback transparently. `deprecate-prepare` calls this helper instead of manually checking root `package.json`.

## User Stories

1. As a developer running `deprecate-prepare` on a monorepo like `gitinx`, I want the script to detect the publishable package in `lib/`, so that `deprecate-end` can deprecate it on npm.
2. As a developer running `deprecate-prepare` on a standard (non-monorepo) project, I want the existing behavior preserved — the root `package.json` name is returned when it's public.
3. As a developer running `deprecate-prepare` on a project with a private root and no workspaces, I want no npm package detected, so that the script doesn't attempt npm deprecation.
4. As a developer running `deprecate-prepare` on a monorepo whose `lib/package.json` is also private, I want no npm package detected.
5. As a developer running `deprecate-prepare` on a monorepo that has workspaces but no `lib` entry in the workspaces array, I want no npm package detected.
6. As a developer running `deprecate-prepare` on a project with no `package.json` at all, I want no npm package detected.

## Implementation Decisions

### Module: `npm-name` (new zsh autoload function)

- Lives in `tools/term/zsh/config/functions/autoload/npm/`
- Takes a single argument: a filepath to a project root
- Returns the npm package name on stdout, or nothing (empty output + non-zero exit) if no publishable package is found
- Early-return flow:
  1. No `package.json` at the given path -> return empty
  2. Root package is not private -> return its `name` field
  3. Root is private but not a monorepo (no `workspaces` key) -> return empty
  4. Root is private monorepo: check if `lib` is listed in the `workspaces` array. If not -> return empty
  5. Check `<root>/lib/package.json` exists and is not private -> return its `name` field
  6. Otherwise -> return empty
- Composes existing helpers: `yarn-package-is-private`, `yarn-package-name`, and direct `jq` reads for workspace detection
- Does NOT use `yarn-is-monorepo` (which relies on `git-directory-root` and grep) — instead reads `workspaces` directly with `jq` to avoid git dependency and get the array values in one shot

### Module: `deprecate-prepare` (caller update)

- Replace the 4-line package detection block (lines 54-58) with a single `npm-name "$clonedAt"` call
- The `|| true` pattern ensures empty output from `npm-name` doesn't trigger `set -e`

### Manual step: deprecate `gitinx`

- Run `npm deprecate gitinx "<message>"` manually after the fix lands

## Testing Decisions

### What makes a good test here

Tests should exercise the external behavior of `npm-name` by creating filesystem fixtures (package.json files in temp directories) and asserting on stdout output and exit code. Mock collaborators like `yarn-package-is-private` and `yarn-package-name` rather than reimplementing their internals.

### Modules tested

- `npm-name`: full test coverage via bats, covering all 6 early-return branches from the implementation decisions
- `deprecate-prepare`: no new tests — it's a one-line caller change, and the existing `deprecate-prepare.bats` covers integration

### Prior art

- `yarn-package-is-private.bats` — uses `bats_tmp_dir` + `bats_disable_worktree_aware` with inline package.json fixtures
- `yarn-is-monorepo.bats` — creates monorepo directory structures with `bats_mock` for `git-directory-root` and `yarn`
- `npm-is-deprecated.bats` — uses `bats_mock` for external command mocking

## Out of Scope

- **Sibling workspace deprecation**: aberlaas-style monorepos with multiple published workspaces (e.g. `aberlaas-lint`, `aberlaas-test`) are not handled. Only the `lib/` workspace is detected. This will be addressed when the need arises.
- **Nested or non-`lib` workspace conventions**: only `lib` as a workspace entry is supported.
- **npm registry lookups**: `npm-name` only reads local `package.json` files — it does not check if the package is actually published.
