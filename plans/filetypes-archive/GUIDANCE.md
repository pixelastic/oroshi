## Guidance

### Context

This plan adds missing archive file extensions to the FILETYPES data and drives archive completions dynamically from that data instead of a hardcoded glob.

### File locations (relative to repo root)

- `tools/term/zsh/config/theming/src/filetypes.jsonc` — source data (edit this, not the dist)
- `tools/term/zsh/config/theming/dist/filetypes.zsh` — generated artifact; regenerate with `filetypes-build`
- `tools/term/zsh/config/theming/filetypes-build` — build script
- `tools/term/zsh/config/functions/autoload/filetypes/filetypes-load-definitions` — loads FILETYPES into memory (idempotent)
- `tools/term/zsh/config/completion/compdef.zsh` — completion wiring file
- `tools/term/zsh/config/completion/compdef-glob-from-group` — new helper (issue 02)
- `tools/term/zsh/config/completion/__tests__/compdef-glob-from-group.bats` — new tests (issue 02)

### Conventions

- `dist/filetypes.zsh` is generated — never edit directly; always run `filetypes-build` after changing `src/filetypes.jsonc`
- `compdef-glob-from-group` follows the `styling.zsh` pattern: defined, used, then `unfunction`'d
- `compdef-glob-from-group` always calls `filetypes-load-definitions` (it is idempotent)
- FILETYPES key format: `<name>:pattern`, `<name>:group`, `<name>:color`, `<name>:icon`, `<name>:bold`

### Testing commands

- `bats tools/term/zsh/config/theming/__tests__/filetypes-build.bats`
- `bats tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-load-definitions.bats`
- `bats tools/term/zsh/config/completion/__tests__/compdef-glob-from-group.bats`
- `zsh-lint tools/term/zsh/config/completion/compdef-glob-from-group`
- `zsh-lint tools/term/zsh/config/completion/compdef.zsh`

### Prior art

- `tools/term/zsh/config/completion/styling.zsh` — pattern for define/use/unfunction in sourced config files
- `tools/term/zsh/config/theming/__tests__/filetypes-build.bats` — fixture setup with OROSHI_ROOT mock
- `tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-load-definitions.bats` — FILETYPES mock pattern via `bats_mock_env`

## Discoveries

_Append findings here after each issue._

### Issue 02 — compdef-glob-from-group

- File lives in `completion/` (not autoload), so it needs a `.zsh` extension to pass `is-zsh` / `zsh-lint`; no shebang needed.
- To inject a ZSH associative array in tests, mock the loader function itself with `bats_mock`: define it in `setup()` with `typeset -gA` assignments, then `bats_mock filetypes-load-definitions`. `bats_mock_env` only writes scalar exports and can't inject arrays.
