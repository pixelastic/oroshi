## Guidance

- Testing ZSH: `bats <filepath>`
- Linting ZSH: `zsh-lint <filepath>`
- Linting bats: `bats-lint <filepath>`
- Helper scripts live at `scripts/bin/ai/` (flat, with shebang, `set -e`)
- Helper tests live at `scripts/bin/ai/__tests__/`
- Hook code lives at `tools/ai/claude/config/hooks/`
- Hook tests live at `tools/ai/claude/config/hooks/__tests__/`
- Hook helper functions are in `preToolUse-Bash-helper.zsh` (output JSON helpers: `autoApprove`, `askWithReason`, `askWithAutoAccept`)
- The hook pipeline glossary is in `tools/ai/claude/config/hooks/GLOSSARY.md`
- `json-get` is used for JSON parsing in hooks (not `jq` directly)
- Existing test patterns: `stop.bats` for hook tests, `preToolUse-Bash.bats` for hook pipeline tests
- `bats_mock` for mocking commands, `bats_mock_env` for mocking env vars
- Use `bats_run_zsh` to run scripts under test

## Discoveries
