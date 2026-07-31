## Guidance

- **Testing ZSH scripts**: `bats <filepath>`
- **Linting ZSH scripts**: `zsh-lint <filepath>`
- **Vale config location**: `tools/prose/vale/vale.ini`
- **Vale styles location**: `tools/prose/vale/styles/` (created by `vale sync`)
- **prose-lint script location**: `scripts/bin/prose/prose-lint`
- **slack-writer-end script location**: `scripts/bin/ai/slack-writer/slack-writer-end`
- **slack-writer skill location**: `tools/ai/claude/config/skills/slack-writer/SKILL.md`
- **clipboard-write location**: `scripts/bin/ubuntu/clipboard-write` — takes text as argument or stdin
- **Prior art for lint scripts**: `scripts/bin/zsh/zsh-lint/zsh-lint` — orchestrator pattern, JSON output
- **Prior art for bats tests on lint scripts**: `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`
- **Prior art for *-end scripts**: `scripts/bin/ai/ralph/ralph-end`
- **Prior art for bats tests on ai scripts**: `scripts/bin/ai/ralph/__tests__/`
- **Install script pattern**: `tools/_languages/lua/lua/selene` — downloads binary to `~/local/bin/`
- **$OROSHI_ROOT**: always use this env var for paths, never hardcode `~/.oroshi`
- **Selene config was migrated** from `config/_languages/lua/selene/` to `tools/_languages/lua/selene/` in this branch

## Discoveries
