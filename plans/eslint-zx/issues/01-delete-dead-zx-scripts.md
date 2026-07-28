## TLDR

Delete all dead zx scripts, their supporting files, and clean up stale references.

## What to build

Delete 9 files across three groups:

**eslint-zx group:**
- `scripts/bin/js/eslint-zx`
- `scripts/bin/js/eslintrc.zx.js`

**json2json5 group:**
- `scripts/bin/json/json2json5.mjs`
- `scripts/bin/json/json2json5` (symlink)
- `tools/_languages/json/json5/install`

**kitty-layout group:**
- `scripts/bin/kitty/kitty-layout-load.mjs`
- `scripts/bin/kitty/kitty-layout-load` (symlink)
- `scripts/bin/kitty/kitty-layout-save`

Edit 2 files to remove stale references:
- `scripts/bin/kitty/kitty-restore` — remove the commented-out `kitty-layout-load` block
- `tools/term/kitty/config/keybindings.conf` — remove the Alt+F5 `kitty-layout-save` binding

## Acceptance criteria

- [ ] All 9 files deleted
- [ ] Commented-out `kitty-layout-load` block removed from `kitty-restore`
- [ ] Alt+F5 keybinding removed from `keybindings.conf`
- [ ] `yarn run lint` passes without errors
