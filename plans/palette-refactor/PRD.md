# Palette Refactor PRD

## Problem Statement

The terminal color palette was built incrementally and now has several structural inconsistencies:

- Slot layout is irregular (palette ranges start at 60, with a gap at 120-129, dark colors isolated at 210-226)
- The `dark-*` color family is a separate named concept when it is semantically just "shade 0" of each palette family
- Named color slots 16-31 duplicate values already present in the palette at specific shades, creating two sources of truth for the same color
- `colors.jsonc` mixes three concerns: named slot mappings, palette range assignments, and semantic aliases — the first two are derivable from `colors.conf` directly
- The alias file is flat with no grouping, making it hard to find related aliases
- The palette only covers 14 color families using outdated Tailwind v1/v2 values mixed with v3, with no consistent canonical shade across families
- New color families needed (lime, indigo, fuchsia, pink) to complete the chromatic spectrum and populate the standard terminal "bright" slots with semantically meaningful alt colors

## Solution

Redesign the palette as a clean, systematic structure:

- **21 color families** organized in 4 groups: 6 primary (standard terminal), 6 secondary (terminal alt/bright), 4 bonus (palette-only), 4 neutral
- **Consistent slot layout**: standard terminal 0-15, palette families at 20-239 in aligned decades, buffer at 180-199, neutrals at 200-239
- **Unified shade convention**: shade 0 = dark/bg (replaces all `dark-*` colors), shades 1-9 = Tailwind gradient light-to-dark, canonical = shade 5
- **Auto-generated canonical and dark aliases** in `colors-build`: every family gets `familyname` → `familyname-5` and `familyname-dark` → `familyname-0` without any configuration
- **`colors.jsonc` becomes aliases-only**: remove `namedColors` and `palettes` sections; slot→family mapping lives in `colors-build`; aliases use nested grouping for readability
- **Hex values**: Tailwind v1 for red/green/yellow/blue/purple (existing beloved values at shade 5), Tailwind v3 for all other families, shade 9 = TW950 (v3) or TW900 (v1)

## User Stories

1. As a developer, I want `$COLORS[orange]` to resolve to `orange-5` automatically, so that I can use color family names without thinking about which shade is canonical.
2. As a developer, I want `$COLORS[orange-dark]` to resolve to `orange-0` automatically, so that I can reference background-suitable colors without a separate `dark-*` namespace.
3. As a developer, I want every palette family to have exactly 10 shades (0-9), so that the scale is predictable and I know shade 0 is always the darkest background tint.
4. As a developer, I want the terminal base colors (slots 1-6) to match the canonical shade 5 of their respective palette families, so that tools using terminal colors and tools using `$COLORS[red]` see the same red.
5. As a developer, I want the terminal "bright" slots (8-15) to hold the canonical shade 5 of the secondary color families, so that bold text in terminals displays a semantically meaningful alt color.
6. As a developer, I want `colors.jsonc` to contain only semantic aliases with nested grouping, so that I can find all git-related aliases under a `git` key rather than scanning a flat list.
7. As a developer, I want `colors-build` to flatten nested alias groups with dashes, so that `git.branch` in the JSONC becomes `COLORS[git-branch]` without extra configuration.
8. As a developer editing `colors.jsonc`, I want to add a new alias by writing `"myalias": "orange"` at the root level (no wrapping key needed), so that the file is minimal and direct.
9. As a developer, I want the palette to include lime, indigo, fuchsia, and pink families, so that the full chromatic spectrum is covered.
10. As a developer, I want amber, emerald, sky, and violet available as bonus palette families, so that I can reference them from semantic aliases even though they have no dedicated terminal slot.
11. As a developer, I want 4 neutral palette families (gray, slate, neutral, stone), so that I have a range of gray-tone options for UI elements.
12. As a developer, I want slot 8 to hold gray-5 and slot 15 to hold stone-5, so that tools relying on the terminal "bright black" and "bright white" slots get semantically appropriate neutral colors.
13. As a project owner, I want `backgroundInactive` in project definitions to use `familyname-dark` instead of `dark-familyname`, so that the naming is consistent with the new shade convention.
14. As a developer, I want `colors.conf` to have clear comments labeling each family group, so that the slot layout is self-documenting without needing a separate reference.
15. As a developer, I want `color-documentation.html` to reflect the final slot layout and family groupings, so that the visual reference stays accurate after the migration.

## Implementation Decisions

### Slot layout

- Slots 0-7: standard terminal base (unchanged semantics, hex values updated where needed)
- Slots 8-15: canonical shade 5 of secondary families: gray(8), pink(9), lime(10), orange(11), indigo(12), fuchsia(13), teal(14), stone(15)
- Slots 16-31: freed (no longer used)
- Slots 20-79: primary palette families — red(20), green(30), yellow(40), blue(50), purple(60), cyan(70)
- Slots 80-139: secondary palette families — pink(80), lime(90), orange(100), indigo(110), fuchsia(120), teal(130)
- Slots 140-179: bonus palette families — amber(140), emerald(150), sky(160), violet(170)
- Slots 180-199: free buffer (2 future families)
- Slots 200-239: neutral palette families — gray(200), slate(210), neutral(220), stone(230)
- Slots 240-255: free

### Hex values

- red, green, yellow, blue, purple: Tailwind v1 scale (shades 1-8 = TW v1 200-900; shade 9 = TW v1 900 value; canonical shade 5 = TW v1 600)
- cyan and all other families: Tailwind v3 scale (shades 1-9 = TW v3 200-950)
- Shade 0 (dark/bg): existing near-black tinted values for current families, computed for new families (lime, indigo, fuchsia, pink)
- Slots 0-7 hex: keep existing values for slots 0-7 (current values are either exact Tailwind v1 600 or TW v3 500/600 exact matches); slot 1 updated from TW v3 red-500 to TW v1 red-600 (#E53E3E, Δ=13 — visually identical)

### `colors.conf` structure

- Each family group preceded by a comment naming the family
- Slot 0 = near-black background (`#0c0f15` — unchanged)
- Slot 7 = white foreground (`#ffffff` — unchanged)
- Shade 0 column documents the dark/bg color for each family

### `colors.jsonc` structure

- Sections `namedColors` and `palettes` removed entirely
- File root contains semantic aliases directly (no wrapping `aliases` key)
- Nested objects allowed for grouping; `colors-build` flattens with dash separator
- Example structure:
  ```jsonc
  {
    "comment":   "gray",
    "error":     "red",
    "git": {
      "branch":  "orange",
      "added":   "green"
    },
    "docker": {
      "container":         "yellow",
      "container-running": "green"
    }
  }
  ```

### `colors-build` algorithm

1. Load palette slot→family mapping (hardcoded, matching `colors.conf` structure)
2. Parse `colors.conf` to populate `colorsByName` (family-shade keys → ANSI/hex)
3. Auto-generate canonical aliases: for every family `F`, add `F` → `F-5`
4. Auto-generate dark aliases: for every family `F`, add `F-dark` → `F-0`
5. Load and flatten `colors.jsonc` recursively (nested keys joined with `-`)
6. Resolve aliases (two-pass if needed, since semantic aliases may reference canonical names)
7. Generate `dist/colors.json` and `dist/colors.zsh`

### `projects-build` migration

- `backgroundInactive` computation: strip trailing shade suffix, append `-dark` instead of prepending `dark-`
- Before: `gsub("-[0-9]+$"; "") | "dark-" + .` → `"dark-yellow"`
- After: `gsub("-[0-9]+$"; "") + "-dark"` → `"yellow-dark"`
- All generated `PROJECTS[...:backgroundInactive:name]` values change format accordingly

### Naming conventions

- Canonical alias: `familyname` (no suffix) → `familyname-5`
- Dark alias: `familyname-dark` → `familyname-0`
- Light alias: reserved for future use (`familyname-light`)
- Existing `dark-*` keys removed from all output

## Testing Decisions

Good tests verify external behavior (what `dist/colors.json` and `dist/colors.zsh` contain), not implementation details of the build script.

### Module 1 — `colors.conf`

Scaffolding tests verifying:
- Each expected family is present at its correct slot range (20-29 = red, etc.)
- Slot 8 hex matches gray-5 canonical value
- Slot 15 hex matches stone-5 canonical value
- Shade 0 slot for each family exists and is very dark (luminance below threshold)

Prior art: `plans/colors/scaffold/*.bats`

### Module 2 — `colors.jsonc`

Scaffolding tests verifying:
- No `namedColors` key at root
- No `palettes` key at root
- No top-level `aliases` wrapper key
- All values resolve to known family names or family-shade strings

Prior art: `plans/colors/scaffold/*.bats`

### Module 3 — `colors-build`

Behavioral tests verifying:
- `COLORS[orange]` resolves to same ANSI/hex as `COLORS[orange-5]`
- `COLORS[orange-dark]` resolves to same ANSI/hex as `COLORS[orange-0]`
- Nested alias `git.branch: orange` produces `COLORS[git-branch]` = orange canonical
- No `dark-*` keys exist in output
- `dist/colors.json` contains entries for all 21 families × 10 shades = 210 entries plus canonicals and darks

Prior art: `tools/term/zsh/config/theming/__tests__/colors-build.bats`

### Module 4 — `projects-build`

Behavioral tests verifying:
- Project with `background: "blue-7"` gets `backgroundInactive.name = "blue-dark"` (not `"dark-blue"`)
- `backgroundInactive` ANSI/hex matches `COLORS[blue-0]`

Prior art: `tools/term/zsh/config/theming/__tests__/projects-build.bats`

### Module 5 — `color-documentation.html`

No automated tests — visual verification only.

## Out of Scope

- Migration of `plans/colors` issues 11-15 (zshlint, NeoVim kebab keys, icons) — done after this refactor
- `familyname-light` canonical alias — structure reserved but not implemented
- Converting `env-generate-filetypes` from `$COLOR_*` env vars to `COLORS[]` array (separate concern)
- Restructuring `src/projects.json` or `projects-build` beyond the `backgroundInactive` naming fix
- Changes to `colors-template-render` or template source files

## Further Notes

Visual reference: `tools/term/zsh/config/theming/src/color-documentation.html` documents the intended final slot layout and can be used during implementation to verify hex values.

Beloved orange: the old canonical orange `#dd6b20` (Tailwind v1 orange-ish, not in any standard palette) is intentionally replaced by TW v3 orange-5 `#ea580c`. The old value is preserved in `plans/palette-refactor/` memory for historical reference.
