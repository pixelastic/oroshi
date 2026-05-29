## TLDR

Remove the unused INSERT layer; remap NORMAL top-left directly to CONFIG.

## What to build

In `keymap.c`, make four coordinated changes:

1. **Enum** — rename `_LAYER_INSERT` to `_LAYER_UNUSED`.
2. **Key defines** — delete `MODE_INSERT` and all defines used exclusively by the INSERT layer (`FULLSCREEN`, `COPY_OUTPUT`, `COPY_PATH`, `WINDOW_NEXT`, `MODE_NEXT`, `PASTE`).
3. **Visual grid** — change `LAYER_NORMAL_KEYS` top-left from `MODE_INSERT` to `MODE_CONFIG`. Replace `LAYER_INSERT_KEYS` with `LAYER_UNUSED_KEYS` (9× `EMPTY_KEY`).
4. **Color mapping** — delete the entire `// Insert` comment block and its color entries from `get_color_for_key`. Keep shared entries (`MODE_NORMAL`, `MODE_CONFIG`) that are still referenced by other layers.

The placeholder layer `_LAYER_UNUSED` remains in the enum and in the `keymaps[]` array with all-empty keys, so the slot is visible to future developers.

CONFIG, SPOTIFY, and RP layers are untouched.

## Acceptance criteria

- [ ] Pressing top-left in NORMAL goes to CONFIG (not INSERT).
- [ ] `_LAYER_UNUSED` exists in the enum at position 1, all 9 keys are `EMPTY_KEY`.
- [ ] No defines remain for INSERT-only keys (`FULLSCREEN`, `COPY_OUTPUT`, etc.).
- [ ] `get_color_for_key` has no entries for removed keycodes.
- [ ] `ymdk-build/deploy` compiles without errors.
- [ ] CONFIG, SPOTIFY, and RP layer definitions are byte-for-byte identical to before.
