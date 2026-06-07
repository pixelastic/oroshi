## TLDR

New `colors-template-render` autoload function replaces `envsubst` for bat/rg/git config generation, using `{{NAME}}` / `{{NAME:hex}}` placeholder syntax.

## What to build

Create `tools/term/zsh/config/functions/autoload/colors/colors-template-render`:
- Signature: `colors-template-render <filepath>` → stdout
- Calls `colors-load-definitions` internally
- Replaces `{{NAME}}` with `$colors[NAME]` and `{{NAME:hex}}` with `$colors[NAME:hex]` throughout the file
- Pure ZSH string substitution — no call to `envsubst`
- Unknown placeholders are left unchanged

Update the three config template source files to use `{{NAME}}` / `{{NAME:hex}}` syntax (replacing all `$COLOR_*`, `$COLOR_*_HEXA`, `$COLOR_ALIAS_*`, `$COLOR_ALIAS_*_HEXA` references):
- `tools/cli/bat/config/src/oroshi.xml`
- `tools/cli/rg/config/src/rgrc.conf`
- `tools/git/git/config/src/gitconfig`

Update the three generation scripts to call `colors-template-render` instead of `envsubst`:
- `tools/cli/bat/config/generate-theme`
- `tools/cli/rg/config/generate-config`
- `tools/git/git/config/generate-config`

These scripts no longer source `env/colors.zsh` — `colors-template-render` handles color loading internally.

## Behavioral Tests

**Basic substitution:**
- A template containing `{{YELLOW_7}}` is rendered with the correct ANSI integer
- A template containing `{{YELLOW_7:hex}}` is rendered with the correct hex string

**Alias substitution:**
- A template containing `{{GIT_BRANCH:hex}}` is resolved to the correct hex value

**Unknown placeholders:**
- A placeholder referencing a non-existent color name is left unchanged in the output

**Output:**
- Output is written to stdout, not to a file

## Acceptance criteria

- [ ] `colors-template-render` autoload function exists in `colors/` domain
- [ ] Accepts a filepath argument and writes rendered output to stdout
- [ ] `{{NAME}}` replaced with ANSI integer from `colors[NAME]`
- [ ] `{{NAME:hex}}` replaced with hex string from `colors[NAME:hex]`
- [ ] Calls `colors-load-definitions` internally (no need for callers to pre-load)
- [ ] `src/oroshi.xml` updated to `{{NAME:hex}}` syntax
- [ ] `src/rgrc.conf` updated to `{{NAME}}` / `{{NAME:hex}}` syntax
- [ ] `src/gitconfig` updated to `{{NAME}}` / `{{NAME:hex}}` syntax
- [ ] `generate-theme` uses `colors-template-render` instead of `envsubst`
- [ ] `generate-config` (rg) uses `colors-template-render` instead of `envsubst`
- [ ] `generate-config` (git) uses `colors-template-render` instead of `envsubst`
- [ ] Bats tests pass
