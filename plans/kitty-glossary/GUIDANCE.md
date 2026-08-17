## Guidance

### Testing commands

- Python: `python-test <filepath>`
- Python lint: `python-lint <filepath>`
- ZSH functions: `bats <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- BATS lint: `bats-lint <filepath>`
- Icons: `icons-build` (rebuilds dist from src)

### Key file locations (relative to repo root)

- Icons src: `tools/term/zsh/config/theming/src/icons.jsonc`
- Icons dist: `tools/term/zsh/config/theming/dist/icons.json`
- Python source: `tools/term/kitty/config/lib/{state,redraw,tab_data,tabs_second_pass}.py`
- Python tests: `tools/term/kitty/config/__tests__/test_{redraw,tab_data,tabs_second_pass,tabs_first_pass,pick_tabs}.py`
- ZSH functions: `tools/term/zsh/config/functions/autoload/kitty/kitty-tab-{attention-add,attention-remove}`
- ZSH tests: same dir under `__tests__/`
- Hooks: `tools/ai/claude/config/hooks/{stop,notification}`
- Hook tests: same dir under `__tests__/`
- Allow-list: `tools/ai/claude/config/hooks/allow-list.json`
- Glossary: `tools/term/kitty/config/GLOSSARY.md` (already updated)

### Conventions

- Icons src file contains nerd font glyphs (U+E000-U+F8FF). NEVER use Write tool on it — use Edit only, or `sed` via Bash. The Write tool silently strips these glyphs.
- The on-disk file path `$OROSHI_TMP_FOLDER/kitty/attention` is NOT renamed — only code references and variable names change.
- Pre-existing test failures in `test_tabs_second_pass.py` (draw_statusbar) and `test_pick_tabs.py` (get_statusbar_width) are unrelated — ignore them.
- Python dist files are loaded at runtime by the Kitty tab bar. After editing icons src, always run `icons-build` and then `kitty-reload` to pick up changes in the live tab bar.

### Vocabulary (from GLOSSARY.md)

- **Notify**: action of alerting the user (sound + marker)
- **Notification Marker**: UTF-8 symbol suffix on a tab title
- **Notification Tab List**: state file listing notified tab IDs
- **notificationIds**: in-memory set of tab ID strings

## Discoveries

(append-only — agents add findings here after each issue)
