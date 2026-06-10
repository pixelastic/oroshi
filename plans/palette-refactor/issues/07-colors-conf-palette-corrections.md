## TLDR

Update `colors.conf` to implement the palette decisions documented in issue 06: switch red family to TW v3 and redesign the gray family as a full achromatic scale.

## What to build

Two targeted changes to `tools/term/kitty/config/colors.conf`.

### 1. Red family (slots 21-29): TW v1 → TW v3

The red family switches from Tailwind v1 to Tailwind v3 values. Slot 20 (red-0, near-black bg) is unchanged.

| Slot | Old (TW v1) | New (TW v3) | Note |
|------|------------|-------------|------|
| 21 | #fed7d7 | #fecaca | TW v3 red-200 |
| 22 | #feb2b2 | #fca5a5 | TW v3 red-300 |
| 23 | #fc8181 | #f87171 | TW v3 red-400 — `variable-type` exact match |
| 24 | #f56565 | #ef4444 | TW v3 red-500 — old RED canonical preserved here |
| 25 | #e53e3e | #dc2626 | TW v3 red-600 — new canonical |
| 26 | #c53030 | #b91c1c | TW v3 red-700 |
| 27 | #9b2c2c | #991b1b | TW v3 red-800 — `git-behind` exact match |
| 28 | #742a2a | #7f1d1d | TW v3 red-900 |
| 29 | #742a2a | #450a0a | TW v3 red-950 |

After this change, the systematic shift rule for red aliases becomes N→N-1 (same as orange, cyan, and other TW v3 families). Issue 08 migrates the alias values accordingly.

### 2. Gray family (slots 200-209): special achromatic scale

Gray becomes the full achromatic axis spanning terminal black to terminal white. Shade-0 and shade-1 are terminal anchors; shades 2-9 are the TW gradient (one slot shifted vs current).

| Slot | Old | New | Note |
|------|-----|-----|------|
| 200 | #111318 | #0c0f15 | terminal black (matches color0) |
| 201 | #e5e7eb | #ffffff | terminal white (matches color7) |
| 202 | #d1d5db | #e5e7eb | TW gray-200 (was slot 201) |
| 203 | #9ca3af | #d1d5db | TW gray-300 |
| 204 | #6b7280 | #9ca3af | TW gray-400 |
| 205 | #4b5563 | #6b7280 | TW gray-500 — new canonical (= old GRAY) |
| 206 | #374151 | #4b5563 | TW gray-600 |
| 207 | #1f2937 | #374151 | TW gray-700 |
| 208 | #111827 | #1f2937 | TW gray-800 |
| 209 | #030712 | #111827 | TW gray-900 |

After this change, `gray` canonical = `#6b7280` = the old GRAY value. All gray alias shade numbers in `colors.jsonc` remain valid without change (the shift is absorbed by the new scale definition).

Prior art: `tools/term/kitty/config/colors.conf`, `plans/palette-refactor/scaffold/01-colors-conf-new-layout.bats`.

## Scaffolding Tests

Written in `plans/palette-refactor/scaffold/07-colors-conf-palette-corrections.bats`.

- `color23` = `#f87171`
- `color24` = `#ef4444`
- `color25` = `#dc2626`
- `color27` = `#991b1b`
- `color200` = `#0c0f15`
- `color201` = `#ffffff`
- `color205` = `#6b7280`
- Slot 20 (red-0 bg) is unchanged at `#250f0f`
- All existing scaffolding tests from issue 01 still pass

## Acceptance criteria

- [ ] `colors.conf` slots 21-29 contain TW v3 red values as specified
- [ ] Slot 25 = `#dc2626` (TW v3 red-600, new red canonical)
- [ ] Slot 23 = `#f87171` (TW v3 red-400)
- [ ] Slot 200 = `#0c0f15` (terminal black)
- [ ] Slot 201 = `#ffffff` (terminal white)
- [ ] Slot 205 = `#6b7280` (TW gray-500, new gray canonical)
- [ ] Slot 20 unchanged at `#250f0f`
- [ ] `colors-build` runs cleanly after the change
- [ ] `dist/colors.json` regenerated with updated hex values
