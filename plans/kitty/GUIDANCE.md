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

### Issue 02 — attention in tabState

- GLOSSARY defined Attention File as "read on every Redraw" — the change to once-per-cycle required updating both the term definition and the Relationships section.
- The render-cycle start detection (`if not tabState["allTabIds"]`) works because `allTabIds` is reset at the end of each `second_pass`; this invariant is documented in GUIDANCE under Conventions.

### Issue 03 — pick_tabs rename + snake_case locals

- New Python files carry over all local variable names from the source — must snake_case them too (not just function names). `python-writer` style requires snake_case for all locals in new files.
- `statusbar.py` imports `reloadTabBar` via a lazy import inside a function — easy to miss when scanning for call sites. Always grep for function name in addition to the module string.
- `get_active_tab_index` has an implicit `None` return when no tab is active — pre-existing latent bug, noted but left for a dedicated fix.

### Issue 01 — snake_case leaf modules

- GLOSSARY bans "refresh" for both Redraw and Reload — `refreshStatusbar` renamed to `redraw_statusbar`, `checkForForcedRefresh` renamed to `check_for_statusbar_reload`.
- Two extra call-site files not listed in the issue spec needed updating: `pickTabsToDisplay.py` (imports `get_statusbar_width`) and `tabs_second_pass.py` (imports `draw_statusbar`) and `parseRawTabData.py` (imports `get_project_data`).
- The beacon path was renamed from `kitty-refresh` to `kitty-reload` across `statusbar.py`, `scripts/bin/kitty/kitty-reload`, and the bats test for `colors-refresh`.
