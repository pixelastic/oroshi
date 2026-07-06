## TLDR

Update the Tab Bar Python to load icons from `dist/icons.json` and render the Attention Icon.

## What to build

Update `tab_bar_modules/parseRawTabData.py`:

1. Load `dist/icons.json` once at module level (cached). Replace all inlined
   glyphs in the file with lookups from this loaded dict. This includes the
   fullscreen icon (`kitty-tab-fullscreen`) and any others.

2. Read the Attention File on every Redraw to get the current set of Tab IDs
   in Attention state.

3. If the tab's Tab ID is in the Attention set, append the Attention Icon
   (`kitty-tab-attention`) as a suffix on the tab title, placed before the
   fullscreen icon when both are active.

Title format examples:
- Normal:              ` {projectIcon}{name} `
- Attention:           ` {projectIcon}{name} 󱅫`
- Fullscreen:          ` {projectIcon}{name} 󰈈 `
- Attention+Fullscreen:` {projectIcon}{name} 󱅫󰈈 `

Also update `tab_bar_modules/statusbar.py` to reference `kitty-reload` beacon
path if hardcoded path has changed.

## Acceptance criteria

- [ ] `dist/icons.json` is loaded once at module level; no glyphs are inlined in the Python file
- [ ] Tabs in Attention state display the Attention Icon as a suffix
- [ ] Attention Icon appears before the fullscreen icon when both are active
- [ ] Tabs not in Attention state display no Attention Icon
- [ ] Attention File read on each Redraw (not cached)
