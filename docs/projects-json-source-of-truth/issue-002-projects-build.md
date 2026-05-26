## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

The core build script (`src/projects-build`) and its BATS test suite.

The script takes `src/projects.json` as input, sources `env/colors.zsh` to resolve color names, and produces two distribution files:

- `dist/projects.json` — nested format with full color objects (`name`, `ansi`, `hex`) for background, backgroundInactive, and foreground; plus `icon`, `path` (with trailing slash), and `hideNameInPrompt` (always explicit boolean)
- `dist/projects.zsh` — `typeset -gA PROJECTS` declaration followed by dot-notation key assignments mirroring the JSON path exactly (e.g. `PROJECTS[aberlaas.background.ansi]=87`)

Before generating dist, the script re-sorts `src/projects.json` in-place using `jq --sort-keys`.

`backgroundInactive` derivation rule: take the background color name, strip everything from the first underscore onward (e.g. `GREEN_8` → `GREEN`, `YELLOW_7` → `YELLOW`, `GREEN` → `GREEN`), prepend `DARK_` (→ `DARK_GREEN`, `DARK_YELLOW`), then look up the resulting name in `env/colors.zsh`.

The script replaces `src/env-generate-projects` but does not delete it — the old pipeline continues running in parallel until the ZSH functions PRD removes it.

BATS tests are written in `src/__tests__/projects-build.bats`. They mock a minimal `src/projects.json` and a minimal color palette, run the build script, and assert on the output files.

## Acceptance criteria

- [ ] Running `src/projects-build` produces `dist/projects.json` and `dist/projects.zsh`
- [ ] `dist/projects.json` contains `background`, `backgroundInactive`, `foreground` as objects with `name`, `ansi`, `hex` keys
- [ ] `backgroundInactive` is correctly derived for a color with numeric suffix (e.g. `GREEN_8` → `DARK_GREEN`)
- [ ] `backgroundInactive` is correctly derived for a color without numeric suffix (e.g. `GREEN` → `DARK_GREEN`)
- [ ] `dist/projects.json` contains `hideNameInPrompt: true` when set; `false` when omitted in src
- [ ] `dist/projects.json` contains `path` with trailing slash normalised
- [ ] `dist/projects.zsh` contains `typeset -gA PROJECTS` and dot-notation keys
- [ ] `dist/projects.zsh` keys exactly mirror the JSON paths (e.g. `PROJECTS[aberlaas.background.ansi]`)
- [ ] Running the script re-sorts `src/projects.json` alphabetically in-place
- [ ] All BATS tests pass (`bats src/__tests__/projects-build.bats`)

## Blocked by

- [issue-001-migration-script.md](./issue-001-migration-script.md) — `src/projects.json` must exist to run and test the build script
