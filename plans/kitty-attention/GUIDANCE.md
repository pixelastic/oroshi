## Guidance

### What this plan does
Fixes 5 gaps in the kitty tab bar attention icon system: icon ordering, clear on Claude exit, clear on tab close, clear on focus (3s timer), and differentiated icons for `stop` vs `notification` attention types.

### Testing commands
- **Python tests:** `python-test <filepath>`
- **Bats tests (ZSH scripts):** `bats scripts/bin/kitty/__tests__/<file>.bats`
- **Linting ZSH:** `zsh-lint <filepath>`
- **Linting bats:** `bats-lint <filepath>`

### Key file locations (relative to repo root)
- Attention file format: `scripts/bin/kitty/kitty-tab-attention-add`, `scripts/bin/kitty/kitty-tab-attention-remove`
- Attention file I/O (Python): `tools/term/kitty/config/lib/redraw.py`
- Tab state: `tools/term/kitty/config/lib/state.py`
- Tab title builder: `tools/term/kitty/config/lib/tab_data.py`
- Render orchestration: `tools/term/kitty/config/lib/tabs_second_pass.py`
- Claude wrapper: `scripts/bin/ai/claude`
- Notification hook: `tools/ai/claude/config/hooks/notification`
- Icons source: `tools/term/zsh/config/theming/src/icons.jsonc`

### Attention file format (after issue 01)
Each line: `tabId:type` (e.g. `42:stop`, `7:notification`).
`tabState["attentionIds"]` is a `dict` mapping tab ID string → type string.

### Conventions
- ZSH scripts use `set -e` and `zparseopts` for flags
- Tab IDs are integers in Python (kitty), strings in ZSH/file
- `kitty-window-tab-id "$KITTY_WINDOW_ID"` resolves tab ID from window ID
- `kitty-tab-focused "$tabId"` returns 0 if focused, non-zero if not
- The stop hook (`tools/ai/claude/config/hooks/stop`) is prior art for the focus-check pattern used in issue 06

### Prior art for tests
- Bats: `scripts/bin/kitty/__tests__/kitty-tab-attention-add.bats`
- Python: `tools/term/kitty/config/__tests__/test_redraw.py`, `test_tabs_second_pass.py`, `test_tab_data.py`

### Notes
- `icons.jsonc` is a source file; the dist `icons.json` must be regenerated after edits (check how other icons are built — look for a build script in `tools/term/zsh/config/theming/`)
- The `tab-attention-notification` icon is a placeholder (`?`) — do not replace it; the user will set the final glyph manually
- The threading.Timer in issue 05 must only do file I/O in its callback — no kitty Python API calls

## Discoveries

### Issue 01 — Typed attention format
- `type` is a ZSH builtin — renamed to `attentionType` to avoid shadowing
- `str(id) in tabState["attentionIds"]` works unchanged with dict (checks keys), so `tab_data.py` needed no code changes
- Four other test files (`test_tab_data`, `test_pick_tabs`, `test_tabs_second_pass`, `test_tabs_first_pass`) reset `attentionIds` — all needed `set()` → `{}` update
- GLOSSARY.md Attention File definition needed updating to reflect `tabId:type` format
- Future cleanup: manifest entries for closed tabs are never pruned — should sync manifest with allTabIds after display pass

### Issue 03 — Clear on close
- `claude` wrapper has no `set -e` by design — must continue after binary exits non-zero
- Testing required fake HOME to redirect `~/.oroshi/node_modules/.bin/claude` to a mock binary; symlink `.zshenv` from real HOME + `bats_disable_worktree_aware` keeps zsh startup chain working
- `if/then/fi` is correct here (not guard+exit) because there are 2 instructions and code follows below
