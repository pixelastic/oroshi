## Guidance

### Goal
Add an `alt+p` Kitty keybinding that opens the `ctrl-p` file picker in an overlay and inserts the selected path(s) into the parent window.

### Testing
- Run bats tests: `bats scripts/bin/kitty/__tests__/<file>.bats`
- Lint zsh scripts: `zsh-lint scripts/bin/kitty/<file>`
- Lint bats files: `bats-lint scripts/bin/kitty/__tests__/<file>.bats`

### File locations (relative to repo root)
- New scripts: `scripts/bin/kitty/`
- New tests: `scripts/bin/kitty/__tests__/`
- Keybinding config: `tools/term/kitty/config/keybindings.conf`
- Plan directory: `plans/keybinding-fzf/`

### Conventions
- All kitty scripts: `#!/usr/bin/env zsh`, `set -e`, header comment block
- Remote control: always use `kitty-remote` wrapper, never `kitty @` directly
- Tests: `bats_mock` for collaborator commands, `bats_mock_env` for env vars, all test vars in `setup()`
- No env var overrides in production scripts for test isolation — use `bats_mock` instead
- The `overlay_for` field in `kitty-remote ls` JSON is `null` for non-overlay windows

### Prior art
- `scripts/bin/kitty/kitty-window-get-var` — pattern for `kitty-remote ls | jq` field extraction
- `scripts/bin/kitty/kitty-window-focus` — pattern for `kitty-remote` with `--match "id:$id"`
- `scripts/bin/kitty/__tests__/kitty-tab-attention-add.bats` — test pattern with `bats_mock`
- `tools/term/zsh/config/keybindings/ctrl-p.zsh` — the ZSH widget this feature mirrors
- `scripts/bin/fzf/ctrl-p` — the file picker binary being reused

### Key concepts
- `kitty-overlay-window-id`: resolves parent via `overlay_for` in `kitty-remote ls` output
- `ctrl-p` outputs one absolute path per line (postprocessed, `▮colored` segment already stripped)
- Multi-path quoting: split on `\n`, each element `${(q-)}`, joined with spaces — mirrors the ZSH ctrl-p widget exactly

## Discoveries

<!-- Agents append findings here after each issue -->
