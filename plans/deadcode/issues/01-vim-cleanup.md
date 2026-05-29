## TLDR

Delete the obsolete VimScript colorscheme file, fully superseded by Lua.

## What to build

Delete `oroshi-old.vim` from the colorscheme folder. The file is a legacy VimScript implementation of the oroshi colorscheme (~529 lines). A complete Lua equivalent exists in the same folder (`syntax.lua`, `ui.lua`, `unused.lua`, `init.lua`). No other file in the repo references `oroshi-old.vim`.

`vimium-mappings.vim` is intentionally kept.

## Acceptance criteria

- [ ] `oroshi-old.vim` is deleted
- [ ] The colorscheme folder still contains the 4 Lua files untouched
- [ ] No remaining references to `oroshi-old.vim` in the repo
