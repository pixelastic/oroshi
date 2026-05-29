## Problem Statement

The YMDK YMD09 keyboard has a `_LAYER_INSERT` layer (layer 1) that is never used in practice. To reach `_LAYER_CONFIG`, the user must first pass through `_LAYER_INSERT` via the top-left key in `_LAYER_NORMAL`, then press top-right in `_LAYER_INSERT`. This two-step navigation is unnecessary friction.

## Solution

Remove `_LAYER_INSERT` as an active layer. The top-left key in `_LAYER_NORMAL` goes directly to `_LAYER_CONFIG`. The former INSERT layer is kept as a named placeholder (`_LAYER_UNUSED`) with no active keys, so the slot is visible to future developers.

## User Stories

1. As a keyboard user, I want pressing top-left in NORMAL to go directly to CONFIG, so that I don't have to make an extra keypress.
2. As a keyboard user, I want all other layer navigation to remain unchanged, so that Spotify and RP layers are unaffected.
3. As a developer reading the config in 6 months, I want to see a `_LAYER_UNUSED` placeholder in the enum and keymap, so that I know a free layer slot exists and can assign keys to it.
4. As a developer, I want dead key definitions removed from the source, so that the config only documents keys that are actually reachable.
5. As a developer, I want the firmware to compile cleanly after the change, so that I can flash it immediately.

## Implementation Decisions

- **Single file change** — only `keymap.c` is modified; build scripts, deploy scripts, and rules.mk are untouched.
- **Layer enum** — `_LAYER_INSERT` is renamed to `_LAYER_UNUSED`. No explicit index is assigned; the compiler assigns it position 1, which is fine since all layer references use the enum name.
- **LAYER_NORMAL top-left** — changed from `MODE_INSERT` to `MODE_CONFIG`. Color stays WHITE (both map to WHITE in `get_color_for_key`).
- **Placeholder layer** — `LAYER_UNUSED_KEYS` is defined with 9× `EMPTY_KEY`. `_LAYER_UNUSED` remains in the `keymaps[]` array.
- **Dead code removal** — the following are deleted entirely: `MODE_INSERT`, `LAYER_INSERT_KEYS`, and the defines only used in LAYER_INSERT (`FULLSCREEN`, `COPY_OUTPUT`, `COPY_PATH`, `WINDOW_NEXT`, `MODE_NEXT`, `PASTE`). The `// Insert` block in `get_color_for_key` and all its color entries are removed.
- **Shared color entries preserved** — `MODE_NORMAL` and `MODE_CONFIG` color entries remain; they are used by CONFIG and other layers.
- **CONFIG, SPOTIFY, RP layers** — untouched, including their internal navigation.

## Testing Decisions

No automated tests. Acceptance criterion: `ymdk-build/deploy` compiles the firmware without errors.

## Out of Scope

- Reassigning any keys in `_LAYER_UNUSED` (deferred to a future change).
- Changing navigation within `_LAYER_CONFIG` (e.g. top-right currently goes to Spotify — left as-is).
- Any changes to other config files, build scripts, or deploy scripts.
