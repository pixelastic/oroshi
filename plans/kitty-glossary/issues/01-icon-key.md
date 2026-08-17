## TLDR

Add `tab-notification` icon key to icons.jsonc alongside the existing attention keys.

## What to build

Add a new `tab-notification` entry in `tools/term/zsh/config/theming/src/icons.jsonc` under the `kitty` section, using the bell glyph (same as the current `tab-attention-notification`). Keep the old `tab-attention-stop` and `tab-attention-notification` keys for now — they'll be removed in the cleanup issue.

Run `icons-build` to regenerate dist files.

## Scaffolding Tests

- `dist/icons.json` contains `kitty-tab-notification` key
- `dist/icons.json` still contains `kitty-tab-attention-stop` and `kitty-tab-attention-notification` (not yet removed)

## Acceptance criteria

- [ ] `tab-notification` key added to `src/icons.jsonc` with the bell glyph
- [ ] `icons-build` succeeds
- [ ] `dist/icons.json` contains all three keys (two old + one new)
