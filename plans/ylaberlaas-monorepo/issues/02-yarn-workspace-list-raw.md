## TLDR

New function to list all workspaces of a monorepo as machine-parseable `name▮relativePath▮description` lines.

## What to build

Create `yarn-workspace-list-raw` in a new `yarn/workspace/` autoload directory. It accepts an optional path argument (defaults to `yarn-root`). It:

1. Resolves to the git root via `git-directory-root $path`
2. Reads the `workspaces` globs from the root `package.json` via `jq` (e.g. `["modules/*"]`)
3. Glob-expands each pattern relative to the root
4. For each matched directory with a `package.json`, extracts the `name` and `description` fields
5. Outputs one line per workspace: `name▮relativePath▮description` where `relativePath` is relative to the monorepo root

Follows the existing `*-list-raw` convention (machine-parseable, `▮`-separated). See `yarn-dependency-list-raw` and `yarn-script-list-raw` for prior art.

## Behavioral Tests

**Output format:**
- each line contains exactly 3 `▮`-separated fields: name, relative path, description

**Workspace discovery:**
- discovers all workspace modules declared in `workspaces` globs
- relative paths are relative to the monorepo root (e.g. `modules/lib`, not absolute)
- each output path exists on disk and contains a `package.json`

**Path argument:**
- works when given a monorepo root path
- works when given a sub-directory inside a monorepo

**Non-monorepo:**
- returns empty output or non-zero exit for a non-monorepo path

## Acceptance criteria

- [ ] Function exists at `tools/term/zsh/config/functions/autoload/yarn/workspace/yarn-workspace-list-raw`
- [ ] Output format is `name▮relativePath▮description` per line
- [ ] Paths are relative to the monorepo root
- [ ] Discovers all workspaces from `workspaces` globs in root `package.json`
- [ ] Accepts optional path argument
- [ ] All bats tests pass
