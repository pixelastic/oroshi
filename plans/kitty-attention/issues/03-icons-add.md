## TLDR

Add `kitty-tab-attention` and `kitty-tab-fullscreen` icons to the icons source and rebuild.

## What to build

Add two new entries to `tools/term/zsh/config/theming/src/icons.jsonc`:

- `kitty-tab-attention` — the Attention Icon (`󱅫`) displayed on tabs in Attention state
- `kitty-tab-fullscreen` — the fullscreen icon (`󰈈`) currently hardcoded in
  `tab_bar_modules/parseRawTabData.py`

Run `icons-build` to regenerate `dist/icons.json` and `dist/icons.zsh`.

## Acceptance criteria

- [ ] `kitty-tab-attention` entry present in `src/icons.jsonc`
- [ ] `kitty-tab-fullscreen` entry present in `src/icons.jsonc`
- [ ] `dist/icons.json` contains both keys after rebuild
- [ ] `dist/icons.zsh` contains both keys after rebuild
