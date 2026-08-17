## Guidance

### Testing commands
- `bats tools/term/zsh/config/functions/autoload/ai/rtk/__tests__/rtk-command-rewrite.bats`
- `bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

### File locations (relative to repo root)
- RTK autoload functions: `tools/term/zsh/config/functions/autoload/ai/rtk/`
- Hook scripts: `tools/ai/claude/config/hooks/`
- Hook tests: `tools/ai/claude/config/hooks/__tests__/`
- Allow list: `tools/ai/claude/config/hooks/allow-list.json`
- Glossary: `tools/ai/claude/config/hooks/GLOSSARY.md`

### Conventions
- ZSH autoload functions have no file extension
- Tests use `bats_load_library 'helper'` and `bats_run_zsh` for ZSH function tests
- `setopt local_options err_return` is the ZSH equivalent of `set -e`
- Hook must always exit 0 — non-zero exits bypass permission logic

### Prior art
- `rtk-can-rewrite` + `__tests__/rtk-can-rewrite.bats` — being replaced, use as structural reference
- `preToolUse-Bash-rtk.bats` — mock pattern with `bats_mock` for ZSH functions

## Discoveries
