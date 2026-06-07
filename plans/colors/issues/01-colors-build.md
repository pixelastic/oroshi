## TLDR

New `colors-build` script that generates `dist/colors.zsh` (associative array) and `dist/colors.json` from `kitty/config/colors.conf`, replacing `env-generate-colors`.

## What to build

Create `tools/term/zsh/config/theming/colors-build` — a script (shebang + `set -e`) that:

1. Parses `kitty/config/colors.conf` to extract color number → hex mappings
2. Applies the named-color and palette-range mappings (same logic as `env-generate-colors`)
3. Applies alias definitions (same alias table as `env-generate-colors`, kept in the script)
4. Writes `dist/colors.zsh` declaring `typeset -gA colors` with entries:
   - `colors[NAME]=<ansi-int>` for each raw color and alias
   - `colors[NAME:hex]="<#hex>"` for each raw color and alias
   - Aliases use the alias name directly (no `ALIAS_` prefix)
5. Writes `dist/colors.json` as a flat map: `{ "NAME": { "ansi": <int>, "hex": "<#hex>" }, ... }` for every color and alias

Add a NeoVim trigger in `tools/vim/nvim/config/config/filetypes/colors.lua`: saving `colors-build` re-runs it (same pattern as the existing `projects-build` trigger).

The script accepts `THEMING_ROOT` env var override (same pattern as `projects-build`) so tests can control output paths.

## Behavioral Tests

**Given a minimal colors.conf with one named color and one palette color:**
- `dist/colors.zsh` contains `typeset -gA colors`
- `colors[YELLOW_7]` equals the correct ANSI integer
- `colors[YELLOW_7:hex]` equals the correct hex string
- `dist/colors.json` has a top-level key `"YELLOW_7"` with `"ansi"` and `"hex"` fields

**Given aliases defined in the build script:**
- `colors[GIT_BRANCH]` resolves to the ANSI value of the aliased raw color
- `colors[GIT_BRANCH:hex]` resolves to the hex value of the aliased raw color
- No key named `ALIAS_GIT_BRANCH` exists in either output

**Both outputs:**
- Both `dist/colors.zsh` and `dist/colors.json` are written in a single run

## Acceptance criteria

- [ ] `colors-build` script exists and is executable
- [ ] Running `colors-build` generates `dist/colors.zsh` with `typeset -gA colors`
- [ ] `dist/colors.zsh` entries use `colors[NAME]=<int>` and `colors[NAME:hex]="<hex>"` format
- [ ] Running `colors-build` generates `dist/colors.json` with the flat `{ "NAME": { "ansi", "hex" } }` structure
- [ ] Aliases appear without `ALIAS_` prefix in both output files
- [ ] `THEMING_ROOT` env var overrides the output directory
- [ ] NeoVim trigger added: saving `colors-build` re-runs it
- [ ] Bats tests pass
