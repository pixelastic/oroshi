## Guidance

This plan refactors the Kitty tab bar Python modules. No behavior changes — pure renaming and structural consolidation.

### Key locations

- Python modules: `tools/term/kitty/config/tab_bar_modules/`
- Entry point: `tools/term/kitty/config/tab_bar.py`
- Zsh scripts: `scripts/bin/kitty/`
- Claude hooks: `tools/ai/claude/config/hooks/`

### Testing

No Python test runner exists. Verify by reloading Kitty's tab bar:
```
kitty-tab-bar-reload
```
Then visually confirm: tabs render, project colors apply, attention icon appears/clears, statusbar items show.

### Conventions

- All Python functions: snake_case
- `tabState` is the single source of truth for all tab-related runtime data
- The attention file path: `$OROSHI_TMP_FOLDER/kitty/attention` (one tab ID per line)
- A render cycle starts when `tabState["allTabIds"]` is empty (reset at end of `second_pass`)
- `draw_tab` in `tab_bar.py` is Kitty's required callback name — never rename it

### No tests

This is a pure Python refactor. BATS tests exist for the Zsh attention scripts and Claude hooks, but those are not modified in this plan.

## Discoveries
