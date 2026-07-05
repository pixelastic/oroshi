## TLDR

Create `icons-build` to generate `dist/icons.zsh` + `dist/icons.json`, update `icons-load-definitions` to source the generated file, and write bats tests that verify icon keys are accessible via `icons-load-definitions`.

## What to build

Create `tools/term/zsh/config/functions/autoload/icons/icons-build`. It reads `src/icons.jsonc`, flattens nested keys using `-` as separator (same strategy as `colors-build`), and writes two outputs:

- `dist/icons.zsh` — starts with `# zsh-lint disable-file=commandTooLong`, then `typeset -gA ICONS`, then one `ICONS[key]="glyph"` line per entry, keys sorted.
- `dist/icons.json` — flat `{ "key": "glyph" }` object, keys sorted.

Update `tools/term/zsh/config/functions/autoload/icons/icons-load-definitions` to source `dist/icons.zsh` instead of the (now deleted) static `icons.zsh`.

Write bats tests in `tools/term/zsh/config/functions/autoload/icons/__tests__/icons-build.bats`. Tests should verify behavior end-to-end through `icons-load-definitions` where possible — i.e. run `icons-build` then `icons-load-definitions` and assert icon keys are readable.

Update the existing `icons-load-definitions.bats` to mock `dist/icons.zsh` under the tmp root instead of the old static path.

## Behavioral Tests

**`dist/icons.zsh` output:**
- produces `dist/icons.zsh` with `typeset -gA ICONS` declaration
- a flat key in the source appears as `ICONS[key]="glyph"` in `dist/icons.zsh`
- a nested key (e.g. `git.branch`) flattens to `ICONS[git-branch]` in `dist/icons.zsh`

**`dist/icons.json` output:**
- produces `dist/icons.json`
- a known key has the correct glyph value in `dist/icons.json`

**End-to-end through `icons-load-definitions`:**
- after running `icons-build` then `icons-load-definitions`, a known key is accessible in `ICONS`
- `icons-load-definitions` is a no-op when `ICONS` is already populated

**Both outputs:**
- `icons-build` generates both `dist/icons.zsh` and `dist/icons.json` in a single run

## Acceptance criteria

- [ ] `icons-build` exists and is runnable as an autoload function
- [ ] `dist/icons.zsh` is generated with correct format
- [ ] `dist/icons.json` is generated as a flat key→glyph object
- [ ] Nested keys in `src/icons.jsonc` are flattened with `-` in both outputs
- [ ] `icons-load-definitions` sources `dist/icons.zsh`
- [ ] `icons-build.bats` passes (new tests)
- [ ] `icons-load-definitions.bats` passes (updated tests)
