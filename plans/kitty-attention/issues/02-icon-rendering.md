## TLDR

Fix icon order in the tab title and render different icons for `stop` vs `notification` attention types.

## What to build

Two changes to the tab title builder in `tab_data.py`:

1. **Order fix** — the fullscreen icon must appear before the attention icon. Previously reversed.

2. **Type-based icon selection** — when a tab has attention, look up its type from `attentionIds[str(id)]` and select the corresponding icon key:
   - type `stop` → `kitty-tab-attention` (existing bell-ring icon)
   - type `notification` → `kitty-tab-attention-notification` (new icon)

Add `"tab-attention-notification": "?"` as a placeholder entry to the `kitty` block in `icons.jsonc` (source file). The user will replace `?` with the final glyph. The dist file (`icons.json`) must be regenerated after editing the source.

## Behavioral Tests

**Icon order**
- When both fullscreen and attention are active, the fullscreen icon appears before the attention icon in the title string

**Icon type selection**
- A tab with attention type `stop` renders the `kitty-tab-attention` glyph
- A tab with attention type `notification` renders the `kitty-tab-attention-notification` glyph
- A tab with no attention renders neither attention icon

## Acceptance criteria

- [ ] Fullscreen icon precedes attention icon in the rendered title
- [ ] `stop` attention type uses `kitty-tab-attention` icon
- [ ] `notification` attention type uses `kitty-tab-attention-notification` icon
- [ ] `icons.jsonc` contains `"tab-attention-notification"` placeholder entry
- [ ] `test_tab_data.py` updated and passing
