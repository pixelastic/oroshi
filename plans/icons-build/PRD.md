## Problem Statement

Icons are hardcoded in a static zsh file with no build step and no JSON output. This makes them inaccessible to tools like NeoVim and Kitty that can read JSON but not zsh. The icons cannot be consumed outside the zsh environment.

## Solution

Introduce an `icons-build` script that mirrors the existing `colors-build`/`filetypes-build`/`projects-build` pipeline. It reads a JSONC source file and generates two dist outputs: a zsh file for runtime use in the shell, and a JSON file for consumption by any tool that can read JSON. The static hardcoded zsh file is replaced by the generated dist output.

## User Stories

1. As a developer, I want icons stored in a JSONC source file, so that I can edit them with comments and grouping by category.
2. As a developer, I want nested grouping in the JSONC source (e.g. all git icons under a `git` key), so that the source file is organized and readable.
3. As a developer, I want `icons-build` to flatten nested keys with a `-` separator, so that `git.branch` becomes `ICONS[git-branch]` in the output.
4. As a developer, I want `icons-build` to generate `dist/icons.zsh` with a `typeset -gA ICONS` declaration followed by one `ICONS[key]="glyph"` line per entry, so that the zsh runtime can load icons.
5. As a developer, I want `icons-build` to generate `dist/icons.json` as a flat key→glyph mapping, so that NeoVim, Kitty, or any other tool can read icons without a zsh runtime.
6. As a developer, I want `icons-load-definitions` to source `dist/icons.zsh` instead of the static file, so that it benefits from the build pipeline.
7. As a developer, I want `colors-refresh` to call `icons-build` before `filetypes-build`, so that the dist file is ready when filetypes-build resolves icon keys.
8. As a developer, I want committing `icons.jsonc` or `icons-build` to trigger `colors-refresh` via lint-staged, so that dist files are always in sync.
9. As a developer, I want bats tests for `icons-build` that verify the zsh and JSON outputs, so that regressions are caught automatically.
10. As a developer, I want the existing `icons-load-definitions` bats tests updated to reflect the new dist path, so that the test suite stays green after the migration.

## Implementation Decisions

### Source schema: nested JSONC with auto-flattening
The source file uses nested objects for grouping (e.g. all git icons under `"git": { ... }`). Keys within a group can themselves contain hyphens. The build script flattens all leaf paths using `-` as the separator — the same strategy used by `colors-build` via `jq paths(type == "string") | join("-")`. A key like `"git": { "branch-ahead": "…" }` produces `ICONS[git-branch-ahead]`.

### `dist/icons.zsh` format
The generated zsh file starts with `# zsh-lint disable-file=commandTooLong`, followed by `typeset -gA ICONS`, then one assignment line per icon: `ICONS[key]="glyph"`. Keys are sorted (via `jq --sort-keys`) for stable diffs.

### `dist/icons.json` format
A flat JSON object mapping each key to its glyph string: `{"git-branch": "…", …}`. Keys are sorted. Values are strings (the raw glyph character), not objects.

### Migration: two steps
Step 1 is data-only: convert the content of the static `icons.zsh` into `src/icons.jsonc` with nested grouping, then delete the static file. At this point `icons-load-definitions` still works because the dist file does not yet exist and the bats test will need updating.

Step 2 introduces `icons-build` itself. Once the build runs and `dist/icons.zsh` exists, update `icons-load-definitions` to source it.

### `icons-load-definitions` update
Change the single `source` call to point at `dist/icons.zsh`. The early-exit guard (`((${#ICONS} > 0)) && return`) is unchanged.

### `colors-refresh` ordering
`icons-build` is inserted between `colors-build` and `filetypes-build`. `filetypes-build` calls `icons-load-definitions` which sources `dist/icons.zsh`, so `icons-build` must run first.

### `lintstaged.config.js` glob extension
The existing glob that triggers `colors-refresh` is extended to include `icons.jsonc` and `icons-build`.

### No NeoVim loader
`dist/icons.json` is produced and available on disk. No Lua loader is added to NeoVim in this sidequest — the JSON file is sufficient to unblock future use.

## Testing Decisions

Good tests verify external behavior only: given a controlled input file, assert the shape and content of the outputs. Tests do not assert implementation details like intermediate variables or internal jq expressions.

**`icons-build` (new bats tests):**
- Use a tmp theming dir with `bats_mock_env OROSHI_ROOT` — same setup pattern as `colors-build.bats`.
- Verify `dist/icons.zsh` is created and contains `typeset -gA ICONS`.
- Verify a known flat key produces the correct `ICONS[key]="glyph"` line in `dist/icons.zsh`.
- Verify the same key is readable from the generated `dist/icons.zsh` when sourced in zsh.
- Verify `dist/icons.json` is created and the key has the correct glyph value.
- Verify nested input flattens correctly (e.g. `git.branch` → `git-branch`).
- Verify both output files are generated in a single run.
- Prior art: `colors-build.bats`.

**`icons-load-definitions` (update existing bats tests):**
- Update the test setup to create `dist/icons.zsh` under the tmp root instead of the static `icons.zsh` path.
- The two existing test cases (sources from mock root; no-op when already populated) remain valid, only the mocked file path changes.

**No tests for:** `colors-refresh`, `lintstaged.config.js`, `src/icons.jsonc` (config and data files).

## Out of Scope

- NeoVim icons loader — `dist/icons.json` exists; no Lua module is added until there is a concrete consumer.
- Kitty `icons.conf` — this file maps Unicode ranges to fonts and is unrelated to the named icon build pipeline.
- `dist/filetypes.json` — `filetypes-build` generates zsh only; adding JSON output is a separate sidequest.
- Nested depth beyond one level — grouping is one level deep (category → key); deeper nesting is not needed.
