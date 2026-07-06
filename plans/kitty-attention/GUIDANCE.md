## Guidance

### Goal

Display an Attention Icon on background Kitty tabs when Claude finishes
responding, cleared when the user sends their next message to Claude in that tab.

### Glossary

Domain vocabulary is defined in `tools/term/kitty/config/GLOSSARY.md`.
Key terms: **Tab Bar**, **Redraw**, **Reload**, **Reload Beacon**, **Attention**,
**Attention Icon**, **Attention File**, **Tab ID**.

### Architecture

Three independent subsystems in the Tab Bar:
- **Statusbar** — auto-updates on its own timers (cpu:30, ram:30). Do not touch.
- **Redraw** — `kitty-redraw` forces immediate visual re-render via `kitty @ set-tab-color` hack.
- **Reload** — `kitty-reload` (renamed from `kitty-refresh`) writes Reload Beacon + calls `kitty-redraw`.

The Attention mechanism sits on top of Redraw:
- `kitty-tab-attention-add <tabId>` → writes to Attention File → calls `kitty-redraw`
- `kitty-tab-attention-remove <tabId>` → removes from Attention File → calls `kitty-redraw`
- Tab Bar Python reads Attention File on every Redraw

### Key paths

| Path | Role |
|---|---|
| `scripts/bin/kitty/kitty-redraw` | New — lightweight Redraw script |
| `scripts/bin/kitty/kitty-reload` | Renamed from `kitty-refresh` |
| `scripts/bin/kitty/kitty-tab-attention-add` | WIP — needs bug fix |
| `scripts/bin/kitty/kitty-tab-attention-remove` | WIP — needs kitty-redraw update |
| `tools/term/kitty/config/tab_bar_modules/parseRawTabData.py` | Tab bar rendering |
| `tools/term/kitty/config/tab_bar_modules/statusbar.py` | Statusbar + beacon polling |
| `tools/term/zsh/config/theming/src/icons.jsonc` | Icon source — add kitty-tab-attention, kitty-tab-fullscreen |
| `tools/term/zsh/config/theming/dist/icons.json` | Generated — read by Python tab bar |
| `tools/ai/claude/config/hooks/stop` | Add Attention on Claude finish |
| `tools/ai/claude/config/hooks/userPromptSubmit` | New — remove Attention on user reply |
| `tools/ai/claude/config/settings.json` | Register UserPromptSubmit hook here (not via symlink) |

### Testing commands

- Zsh: `bats <filepath>`
- Zsh lint: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`

### Critical assumption

Issue 01 must be done first. The entire architecture depends on `kitty @ set-tab-color`
triggering an immediate Tab Bar Redraw. If this assumption fails, revise the
Glossary and PRD before proceeding.

### settings.json

`~/.claude/settings.json` is a symlink. Always edit
`tools/ai/claude/config/settings.json` in the worktree directly.

## Discoveries

### Issue 00 — Tab bar hot-reload

- `if "_generation" not in globals()` is the correct Python idiom to persist a module-level variable across `importlib.reload()` calls — module code re-executes but the module's `__dict__` is mutated in-place, so the guard prevents resetting.
- `$OROSHI_TMP_FOLDER` is the correct env var for `/home/tim/local/tmp/oroshi/` in ZSH scripts (not hardcoded paths). Python files in the tab bar use hardcoded paths (pre-existing pattern; Python can't use env vars).
- `ctrl+shift+r` is fully occupied by the special-character keybinding system (`Ⓡ`); use `alt+shift+r` for tab bar reload instead.
- Pre-reload increment of `_generation` is a valid safety measure even though `initStatusbar()` also increments — it ensures stale callbacks can't fire in the brief window during the reload sequence.
