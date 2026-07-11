## TLDR

Decouple the statusbar from `tab_bar.py`, update keybindings, and update the Glossary to reflect the new beacon layout.

## What to build

**`tab_bar.py`**: remove the `import lib.statusbar as statusbar` import and the `statusbar.init()` call in the startup block. The `statusbar.py` file itself is not touched.

**`keybindings.conf`**: change `Alt-R` from `load_config_file` alone to a `combine` action that runs `load_config_file` then launches `kitty-reload` in the background. Change `Alt-Shift-R` from `kitty-tab-bar-reload` to a `# TODO` comment.

**`__tests__/test_tab_bar.py`**: remove `test_init_statusbar_called_on_first_draw` (statusbar is no longer initialized at startup). Add `test_init_tab_data_called_on_first_draw` if not already present from issue 01.

**`GLOSSARY.md`** (`tools/term/kitty/config/GLOSSARY.md`): update beacon file paths to reflect the `kitty/beacons/` directory layout; add **Redraw Beacon** as a term; remove **Hard Reload Beacon** (merged into Reload Beacon); confirm **State File** and **Definition File** terms are accurate.

## Scaffolding Tests

`tab_bar.py` does not reference `statusbar` (import or init call).

## Acceptance criteria

- [ ] `tab_bar.py` has no `statusbar` import and no `statusbar.init()` call
- [ ] `statusbar.py` is unchanged
- [ ] `keybindings.conf`: `Alt-R` uses `combine : load_config_file : launch --type=background kitty-reload`
- [ ] `keybindings.conf`: `Alt-Shift-R` is marked `# TODO`
- [ ] `test_tab_bar.py`: `test_init_statusbar_called_on_first_draw` removed
- [ ] `GLOSSARY.md`: beacon paths updated, Redraw Beacon term added, Hard Reload Beacon removed
- [ ] All existing tests still pass
