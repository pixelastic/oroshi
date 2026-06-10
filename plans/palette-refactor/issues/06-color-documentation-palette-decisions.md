## TLDR

Encode all palette design decisions from the grill-me session into `color-documentation.html` so it becomes the source of truth before implementation begins.

## What to build

Update `tools/term/zsh/config/theming/src/color-documentation.html` to reflect three design decisions:

### 1. Red family — TW v3 scale

Red (slots 20-29) now uses Tailwind v3 values instead of v1. Update the red family entries:

| Shade | Slot | Hex |
|-------|------|-----|
| 0 | 20 | #250f0f |
| 1 | 21 | #fecaca |
| 2 | 22 | #fca5a5 |
| 3 | 23 | #f87171 |
| 4 | 24 | #ef4444 |
| 5 | 25 | #dc2626 ← canonical |
| 6 | 26 | #b91c1c |
| 7 | 27 | #991b1b |
| 8 | 28 | #7f1d1d |
| 9 | 29 | #450a0a |

### 2. Gray family — special achromatic scale

Gray is the full achromatic axis. Its shade convention differs from all other families:

- **Shade 0** = terminal black = `#0c0f15` (same as `color0`, used as background)
- **Shade 1** = terminal white = `#ffffff` (same as `color7`, used as foreground)
- **Shades 2-9** = TW gray-200 → TW gray-900 (light to dark gradient)
- **Canonical** (shade 5) = `#6b7280` (TW gray-500)

The HTML must show a visual indicator on shade-0 and shade-1 marking them as terminal anchors, distinct from the TW gradient shades 2-9.

| Shade | Slot | Hex |
|-------|------|-----|
| 0 | 200 | #0c0f15 ← terminal black |
| 1 | 201 | #ffffff ← terminal white |
| 2 | 202 | #e5e7eb |
| 3 | 203 | #d1d5db |
| 4 | 204 | #9ca3af |
| 5 | 205 | #6b7280 ← canonical |
| 6 | 206 | #4b5563 |
| 7 | 207 | #374151 |
| 8 | 208 | #1f2937 |
| 9 | 209 | #111827 |

### 3. Neutral families (slate, neutral, stone) — standard convention

These three families follow the standard convention (same as colored families):

- **Shade 0** = near-black bg (tinted, for backgrounds only)
- **Shades 1-9** = TW-200 → TW-950 (light to dark)
- No white anchor at shade 1

Add a comment or legend to the HTML clarifying that gray is the exception to this rule.

Prior art: `tools/term/zsh/config/theming/src/color-documentation.html`.

## Scaffolding Tests

Written in `plans/palette-refactor/scaffold/06-color-documentation-palette-decisions.bats`.

- Red family: slot 23 shows hex `#f87171`
- Red family: slot 25 shows hex `#dc2626`
- Gray family: slot 200 shows hex `#0c0f15`
- Gray family: slot 201 shows hex `#ffffff`
- Gray family: slot 205 shows hex `#6b7280`
- Gray family has a distinct visual marker for shade-0 (black) and shade-1 (white)

## Acceptance criteria

- [ ] Red family slots 21-29 show TW v3 hex values in the HTML
- [ ] Slot 25 (red canonical) shows `#dc2626`
- [ ] Slot 23 shows `#f87171`
- [ ] Gray shade-0 shows `#0c0f15` with a label identifying it as terminal black
- [ ] Gray shade-1 shows `#ffffff` with a label identifying it as terminal white
- [ ] Gray shades 2-9 show TW-200 through TW-900
- [ ] Gray canonical (shade 5) shows `#6b7280`
- [ ] Neutral families (slate, neutral, stone) shade-0 is visually consistent with all other non-gray families
- [ ] A legend or note explains the gray exception
- [ ] All existing scaffolding tests from issues 01 and 02 still pass
