## Guidance

**Single file changed:** `tools/keybindings/ymdk/config/keymap.c`

**Build validation:** run `ymdk-build/deploy` — successful compile = passing test. No unit test framework exists for QMK firmware.

**Layer structure:** 5 named layers (`_LAYER_NORMAL`, `_LAYER_UNUSED`, `_LAYER_CONFIG`, `_LAYER_SPOTIFY`, `_LAYER_RP`). All layer references use enum names, never raw indices.

**Color convention:** `get_color_for_key` maps keycode → color by keycode identity (not by layer). Entries are shared across layers — do not remove an entry unless the keycode is unreachable from *all* layers.

**Key `MODE_NORMAL`** appears in the color map and is still used by `_LAYER_CONFIG` bot-left — keep it.

**Key `MODE_CONFIG`** appears in the color map and is still used by `_LAYER_INSERT` (now `_LAYER_RP`) top-right — keep it.

## Discoveries
