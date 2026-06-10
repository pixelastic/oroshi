## TLDR

Rewrite `colors-build` to derive palettes from `colors.conf` directly and auto-generate canonical + dark aliases; reduce `colors.jsonc` to semantic aliases only.

## What to build

### `src/colors.jsonc` — aliases only

Remove the `namedColors` and `palettes` sections entirely. The root object contains only semantic aliases (flat key→value pairs for now; nested grouping comes in issue 04). No wrapping `aliases` key.

### `colors-build` — new algorithm

Replace the palette loading logic with a hardcoded slot→family table that mirrors `colors.conf`:

```
20-29=red, 30-39=green, 40-49=yellow, 50-59=blue, 60-69=purple, 70-79=cyan,
80-89=pink, 90-99=lime, 100-109=orange, 110-119=indigo, 120-129=fuchsia, 130-139=teal,
140-149=amber, 150-159=emerald, 160-169=sky, 170-179=violet,
200-209=gray, 210-219=slate, 220-229=neutral, 230-239=stone
```

The shade number is derived from the last digit of the ANSI index (slot 25 in range 20-29 → shade 5).

**Auto-generated entries** — after loading the palette from `colors.conf`, for every family `F` add:
- `F` (canonical) → same ANSI/hex as `F-5`
- `F-dark` → same ANSI/hex as `F-0`

**Two-pass alias resolution** — load `colors.jsonc` semantic aliases, then resolve them against the already-populated map (which includes canonical and dark entries). A semantic alias like `"git-branch": "orange"` resolves because `orange` was auto-generated in the previous step.

Prior art for the build script structure: `tools/term/zsh/config/theming/colors-build`.
Prior art for tests: `tools/term/zsh/config/theming/__tests__/colors-build.bats`.

## Behavioral Tests

**Canonical alias auto-generation:**
- `COLORS[orange]` resolves to the same ANSI integer as `COLORS[orange-5]`
- `COLORS[orange:hex]` equals `COLORS[orange-5:hex]`
- `COLORS[gray]` resolves to the same ANSI integer as `COLORS[gray-5]`

**Dark alias auto-generation:**
- `COLORS[orange-dark]` resolves to the same ANSI integer as `COLORS[orange-0]`
- `COLORS[blue-dark]` resolves to the same ANSI integer as `COLORS[blue-0]`

**Semantic alias resolution through canonical:**
- `COLORS[git-branch]` resolves (alias `git-branch: orange` → canonical `orange` → `orange-5`)

**No legacy keys in output:**
- `dist/colors.json` contains no key starting with `dark-`
- `dist/colors.json` contains no key matching ANSI slots 16-31

**Coverage:**
- `dist/colors.json` contains entries for all 21 families × 10 shades = 210 palette entries

## Scaffolding Tests

Written in `plans/palette-refactor/scaffold/03-colors-build-new-algorithm.bats`.

- `src/colors.jsonc` has no `namedColors` key
- `src/colors.jsonc` has no `palettes` key
- `src/colors.jsonc` has no top-level `aliases` wrapper key

## Acceptance criteria

- [ ] `src/colors.jsonc` contains only semantic alias key-value pairs at root (no `namedColors`, no `palettes`, no `aliases` wrapper)
- [ ] `colors-build` no longer loads a `palettes` or `namedColors` section from `colors.jsonc`
- [ ] `colors-build` hardcodes the slot→family table matching `colors.conf`
- [ ] `COLORS[orange]` = `COLORS[orange-5]` in generated output
- [ ] `COLORS[orange-dark]` = `COLORS[orange-0]` in generated output
- [ ] No `dark-*` keys in `dist/colors.json`
- [ ] All existing `colors-build.bats` tests pass (or are updated to reflect the new fixture format)
- [ ] All 21 families × 10 shades present in `dist/colors.json`
