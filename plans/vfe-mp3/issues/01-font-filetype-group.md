## TLDR

Add a `font` filetype group to `filetypes.jsonc` and rebuild the dist.

## What to build

Add a new `font` group to `tools/term/zsh/config/theming/src/filetypes.jsonc` with:
- Color: `pink-6`
- Icon: `filetype-font` (placeholder — not yet in icon definitions)
- Bold: `false`
- Extensions: `eot`, `otf`, `ttf`, `woff`, `woff2`

Move `eot`, `ttf`, `woff` out of the `script` group. Place the `font` group between `config` and `image` in the file.

Run `filetypes-build` to regenerate `tools/term/zsh/config/theming/dist/filetypes.zsh`.

## Scaffolding Tests

- `filetypes.jsonc` contains a `font` group with exactly `eot`, `otf`, `ttf`, `woff`, `woff2`
- `eot`, `ttf`, `woff` are no longer in the `script` group

## Acceptance criteria

- [ ] `font` group exists in `filetypes.jsonc` with color `pink-6`, icon `filetype-font`, bold `false`
- [ ] Extensions `eot`, `otf`, `ttf`, `woff`, `woff2` belong to `font` group
- [ ] `eot`, `ttf`, `woff` removed from `script` group
- [ ] `dist/filetypes.zsh` regenerated and contains `font` group entries
