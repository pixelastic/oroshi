## TLDR

Remove dead statusbar code from Kitty tab bar and delete associated scripts.

## What to build

The Kitty statusbar is dead code: `statusbar.init()` is never called, so `statusbarState["order"]` stays empty, `draw_statusbar()` renders nothing, and the statusbar scripts are never invoked.

Clean up:
1. Delete `tools/term/kitty/config/lib/statusbar.py`
2. Remove `draw_statusbar()` call from `tools/term/kitty/config/lib/tabs_second_pass.py`
3. Remove `get_statusbar_width()` call from `tools/term/kitty/config/lib/pick_tabs.py`
4. Remove any statusbar imports in the above files
5. Delete statusbar scripts: `scripts/bin/statusbar/statusbar-cpu`, `scripts/bin/statusbar/statusbar-ram`, `scripts/bin/statusbar/statusbar-ping`
6. Delete `tools/term/zsh/config/functions/autoload/kitty/statusbar-clock` (migrated in issue 13, but dead)
7. Delete associated tests for statusbar-clock
8. Remove statusbar icon definitions from `tools/term/zsh/config/theming/dist/icons.json` and `icons.zsh` (statusbar-clock, statusbar-cpu, statusbar-cpu-fire, statusbar-ram, statusbar-ram-fire, statusbar-ping, statusbar-ping-offline)
9. Revert the `bin-zsh` change in `statusbar.py` — moot since the file is deleted

## Acceptance criteria

- [ ] `statusbar.py` deleted
- [ ] No remaining imports or calls to statusbar functions in Kitty tab bar code
- [ ] All `statusbar-*` scripts deleted
- [ ] Statusbar icon definitions removed
- [ ] Kitty tab bar still renders correctly (no import errors)
