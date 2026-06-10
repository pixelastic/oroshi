## TLDR

Rewrite `colors.conf` with the new 21-family slot layout and Tailwind v1/v3 hex values.

## What to build

Replace the current `tools/term/kitty/config/colors.conf` palette section with the new layout:

**Slots 0-7** — standard terminal base colors, unchanged semantically. Update slot 1 (red) from TW v3 red-500 to TW v1 red-600 (`#E53E3E`, Δ=13 — visually identical) so it matches the canonical shade.

**Slots 8-15** — canonical shade 5 of secondary families:
- 8 = gray-5, 9 = pink-5, 10 = lime-5, 11 = orange-5
- 12 = indigo-5, 13 = fuchsia-5, 14 = teal-5, 15 = stone-5

**Slots 16-31** — freed (removed).

**Palette families** at aligned decade slots, each with 10 shades (shade 0 = dark/bg near-black, shades 1-9 = Tailwind gradient):
- 20-29: red, 30-39: green, 40-49: yellow, 50-59: blue, 60-69: purple, 70-79: cyan (primary)
- 80-89: pink, 90-99: lime, 100-109: orange, 110-119: indigo, 120-129: fuchsia, 130-139: teal (secondary)
- 140-149: amber, 150-159: emerald, 160-169: sky, 170-179: violet (bonus)
- 180-199: free buffer (two empty ranges, no color entries)
- 200-209: gray, 210-219: slate, 220-229: neutral, 230-239: stone (neutral)

**Hex value sources:**
- red, green, yellow, blue, purple: Tailwind v1 scale. Shades 1-8 = TW v1 200-900, shade 9 = TW v1 900 (no v1 950 exists). Canonical shade 5 = TW v1 600.
- cyan and all other families: Tailwind v3 scale. Shades 1-9 = TW v3 200-950.
- Shade 0 (dark/bg): keep existing near-black tinted values for families that already exist; compute analogous near-black tinted values for new families (lime, indigo, fuchsia, pink, slate, neutral, stone).

Each family group must be preceded by a comment in `colors.conf` naming the family and its slot range.

Prior art for the current layout: `tools/term/kitty/config/colors.conf`.

## Scaffolding Tests

Written in `plans/palette-refactor/scaffold/01-colors-conf-new-layout.bats`.

- `colors.conf` defines a color entry at slot 20 (red shade 0)
- `colors.conf` defines a color entry at slot 29 (red shade 9)
- `colors.conf` defines a color entry at slot 200 (gray shade 0)
- `colors.conf` defines a color entry at slot 239 (stone shade 9)
- Slot 8 hex value matches gray-5 (the canonical gray)
- Slot 15 hex value matches stone-5 (the canonical stone)
- Slots 16-19 and 180-199 have no `colorN` entries
- Shade 0 of each family has luminance below 0.03 (near-black)

## Acceptance criteria

- [ ] `colors.conf` defines exactly 10 shades for each of the 21 palette families
- [ ] Slots 20-239 follow the decade alignment (red=20, green=30, … stone=230)
- [ ] Slots 8-15 hold canonical shade 5 values of the 8 secondary/neutral families
- [ ] Slots 16-31 and 180-199 have no color definitions
- [ ] Shade 0 of every family is a near-black tinted value
- [ ] Red, green, yellow, blue, purple use Tailwind v1 hex values
- [ ] All other families use Tailwind v3 hex values
- [ ] Each family block is preceded by a comment naming the family
- [ ] Running `colors-build` against the new file still produces valid `dist/colors.zsh` and `dist/colors.json` (existing tests pass)
