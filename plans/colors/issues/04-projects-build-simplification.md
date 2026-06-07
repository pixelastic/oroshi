## TLDR

Simplify `projects-build` by removing its dependency on `COLOR_*` env vars — read `dist/colors.json` directly instead.

## What to build

Update `tools/term/zsh/config/theming/projects-build`:
- Remove the `colors-load-definitions` call at the top
- Remove the `buildColorMap()` function entirely
- Pass `dist/colors.json` as `--argjson colors` to the `jq` call that builds `dist/projects.json`

The color map contract is now: `{ "NAME": { "ansi": <int>, "hex": "<#hex>" } }` — identical to what `dist/colors.json` produces, so no jq query changes are needed beyond the input source.

Update `tools/term/zsh/config/theming/__tests__/projects-build.bats`:
- Replace the `colors-load-definitions` mock (which set `COLOR_*` env vars) with a `dist/colors.json` fixture file created in `THEMING_ROOT/dist/` during `setup()`
- All existing test assertions remain unchanged

## Scaffolding Tests

The existing bats tests for `projects-build` must continue to pass after removing `buildColorMap()` and the `colors-load-definitions` call. The fixture replaces the mock — same data, different delivery mechanism.

## Acceptance criteria

- [ ] `projects-build` no longer calls `colors-load-definitions`
- [ ] `buildColorMap()` function removed from `projects-build`
- [ ] `projects-build` reads `dist/colors.json` via `--argjson colors` in jq
- [ ] Existing bats tests updated to use a `dist/colors.json` fixture instead of the `colors-load-definitions` mock
- [ ] All existing bats tests pass without modification to their assertions
