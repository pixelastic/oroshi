## Guidance

### Goal

Replace the current 14-family irregular palette with a clean 21-family system using aligned decade slots, Tailwind v1/v3 hex values, and auto-generated canonical/dark aliases.

### Key file locations

- **Kitty color config (source of truth for hex values):** `tools/term/kitty/config/colors.conf`
- **Semantic aliases (JSONC source):** `tools/term/zsh/config/theming/src/colors.jsonc`
- **Build script:** `tools/term/zsh/config/theming/colors-build`
- **Generated ZSH array:** `tools/term/zsh/config/theming/dist/colors.zsh`
- **Generated JSON:** `tools/term/zsh/config/theming/dist/colors.json`
- **Projects build:** `tools/term/zsh/config/theming/projects-build`
- **Visual reference:** `tools/term/zsh/config/theming/src/color-documentation.html`
- **Prior art — colors build:** `plans/colors/` (issues 01-10, all done)

### Slot layout

```
0-15    standard terminal (0-7 base, 8-15 alt canonicals)
16-19   gap (unused)
20-79   primary families:   red(20), green(30), yellow(40), blue(50), purple(60), cyan(70)
80-139  secondary families: pink(80), lime(90), orange(100), indigo(110), fuchsia(120), teal(130)
140-179 bonus families:     amber(140), emerald(150), sky(160), violet(170)
180-199 free buffer
200-239 neutral families:   gray(200), slate(210), neutral(220), stone(230)
240-255 free
```

### Shade convention

- Shade 0 = dark/bg (near-black tinted, replaces old `dark-*` colors)
- Shades 1-9 = Tailwind gradient (TW200 → TW950 for v3; TW200 → TW900 for v1 families)
- Canonical = shade 5 (TW600)
- Shade number = last digit of ANSI slot index (slot 25 in range 20-29 → shade 5)

### Hex value sources

- red, green, yellow, blue, purple: **Tailwind v1** scale. Canonical (shade 5) = TW v1 600. These are the user's existing beloved values.
- All other families: **Tailwind v3** scale.
- Slot 1 (red terminal base) updated to TW v1 red-600 `#E53E3E` (Δ=13 from old `#ef4444`).

### Terminal alt canonical slots (8-15)

| Slot | Family | Canonical hex |
|------|--------|--------------|
| 8    | gray   | gray-5 = `#4b5563` |
| 9    | pink   | pink-5 = `#db2777` |
| 10   | lime   | lime-5 = `#65a30d` |
| 11   | orange | orange-5 = `#ea580c` |
| 12   | indigo | indigo-5 = `#4f46e5` |
| 13   | fuchsia| fuchsia-5 = `#c026d3` |
| 14   | teal   | teal-5 = `#0d9488` |
| 15   | stone  | stone-5 = `#57534e` |

### `colors.jsonc` structure after refactor

- No `namedColors` key
- No `palettes` key
- No `aliases` wrapper key
- Root object = flat + nested semantic aliases
- Nested keys flattened with `-` by `colors-build` (e.g. `git.branch` → `git-branch`)

### `colors-build` algorithm after refactor

1. Hardcoded slot→family table (matches `colors.conf`)
2. Parse `colors.conf` → populate `colorsByName` (family-shade keys)
3. Auto-generate `F` → `F-5` (canonical) for every family F
4. Auto-generate `F-dark` → `F-0` for every family F
5. Load + flatten `colors.jsonc` recursively
6. Two-pass alias resolution

### `projects-build` backgroundInactive

- Old: `"dark-" + family` → `"dark-blue"`
- New: `family + "-dark"` → `"blue-dark"`

### Testing commands

- **Run bats tests:** `bats <filepath>`
- **Lint zsh:** `zsh-lint <filepath>`
- **Lint bats:** `bats-lint <filepath>`
- Tests live in `__tests__/` adjacent to the file under test
- Scaffolding tests live in `plans/palette-refactor/scaffold/`

### Prior art

- Colors build tests: `tools/term/zsh/config/theming/__tests__/colors-build.bats`
- Projects build tests: `tools/term/zsh/config/theming/__tests__/projects-build.bats`
- Scaffolding test examples: `plans/colors/scaffold/*.bats`

## Discoveries

### Issue 01 — colors-conf-new-layout

- `colors-build.bats` reads the REAL `colors.conf`, not its fixture: `.zshenv` overrides `OROSHI_ROOT` via `git rev-parse --show-toplevel` when `$PWD` is inside a worktree — fixture `OROSHI_ROOT` override in `setup()` has no effect on ZSH subprocesses. Keep test fixture values in sync with actual slot values in `colors.conf`.
- All TW v3 families (including stone) use the standard 200-950 mapping; shade 5 = TW v3 600. Stone canonical = `#57534e` (stone-600).
- Spec wording "Slots 16-31 have no color definitions" is a typo; correct intent (per scaffolding test) is slots 16-19 only — new red family starts at slot 20.
