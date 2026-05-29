## Guidance

**Single file changed:** `tools/keybindings/ymdk/config/keymap.c`

**Build validation:** run `tools/keybindings/ymdk/deploy` from the worktree root — successful compile = passing test. No unit test framework exists for QMK firmware. Do not use `ymdk-build` (the zsh function) nor manually copy files.

**Layer structure:** 5 named layers (`_LAYER_NORMAL`, `_LAYER_UNUSED`, `_LAYER_CONFIG`, `_LAYER_SPOTIFY`, `_LAYER_RP`). All layer references use enum names, never raw indices.

**Color convention:** `get_color_for_key` maps keycode → color by keycode identity (not by layer). Entries are shared across layers — do not remove an entry unless the keycode is unreachable from *all* layers.

**Key `MODE_NORMAL`** appears in the color map and is still used by `_LAYER_CONFIG` bot-left — keep it.

**Key `MODE_CONFIG`** appears in the color map and is still used by `_LAYER_INSERT` (now `_LAYER_RP`) top-right — keep it.

## Discoveries

### Issue 01 — Remove INSERT layer
- Build: call `tools/keybindings/ymdk/deploy` directly — it copies config and compiles in one step. The `ymdk-build` zsh function points to a different deploy script with no config dir and should not be used.
- No bats tests for keymap.c: it's a hand-authored config, the build is the only test (memory rule: config changes are the artifact)
- `MODE_NORMAL` and `MODE_CONFIG` color entries are shared across layers — they lived in the `// Insert` block but belong to no single layer; after deleting Insert, `MODE_NORMAL` now sits orphaned between the Normal and Config blocks (fine functionally, but worth noting for future reorganisation)
