## TLDR

Update `color-documentation.html` to reflect the new slot layout from issue 01.

## What to build

Update `tools/term/zsh/config/theming/src/color-documentation.html` so it accurately reflects the palette after issue 01:

- Slot numbers in the standard terminal section (0-15) updated to show the new alt canonical colors at slots 8-15
- Palette families shown at their new slot ranges (red=20, green=30, … stone=230)
- Family groupings match the 4 groups: primary, secondary, bonus, neutral
- Free buffer slots (180-199) and free tail (240-255) shown as unused placeholders
- Family order within each group matches the new layout
- All labels and section titles in English

The HTML file is the visual reference for the full refactor. It should be accurate enough that an implementer can read slot numbers directly from it.

## Acceptance criteria

- [ ] Standard terminal section shows slots 8-15 with new alt canonical labels (gray, pink, lime, orange, indigo, fuchsia, teal, stone)
- [ ] All 21 palette families displayed at correct slot ranges
- [ ] Free buffer 180-199 shown as unused rows
- [ ] Free tail 240-255 shown as unused rows
- [ ] No French text remaining
- [ ] Page renders without JavaScript errors
