## TLDR

Update disk.lua to use the Neovim API for all FZF keybindings. (HITL — requires manual verification in Neovim)

## What to build

Update `disk.lua` so all FZF keybindings call the new FZF Scripts via the Neovim API
instead of Legacy FZF autoloads.

For each binding (Ctrl-P, Ctrl-Shift-P, Ctrl-G, Ctrl-Shift-G):
- `source` → `<script> --source`
- `options` → `<script> --options`
- `sinklist` callback calls `<script> --postprocess` then performs editor actions (tab drop / line jump)

Also remove the Ctrl-T binding from Neovim (duplicate of Ctrl-Shift-P, already removed from ZSH in issue 01).

This issue is HITL because Neovim Lua changes have no automated test coverage (see project memory:
no Lua test framework). Manual verification is required for each keybinding.

## Acceptance criteria

- [ ] Ctrl-P in Neovim opens the project file picker using `ctrl-p --source` and `ctrl-p --options`
- [ ] Ctrl-Shift-P in Neovim opens the subdir file picker using `ctrl-shift-p --source` and `ctrl-shift-p --options`
- [ ] Ctrl-G in Neovim opens the project regexp picker using `ctrl-g --source` and `ctrl-g --options`
- [ ] Ctrl-Shift-G in Neovim opens the subdir regexp picker using `ctrl-shift-g --source` and `ctrl-shift-g --options`
- [ ] All four pickers return correct results and open files/lines in new tabs
- [ ] Ctrl-T binding removed from Neovim
- [ ] No references to Legacy FZF autoload names remain in `disk.lua`
- [ ] Manual verification performed in a running Neovim instance
