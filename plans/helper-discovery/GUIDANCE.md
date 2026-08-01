## Guidance

- Autoload functions: `tools/term/zsh/config/functions/autoload/misc/`
- Tests: `tools/term/zsh/config/functions/autoload/misc/__tests__/`
- Run tests: `bats <filepath>`
- Run lint: `zsh-lint <filepath>` for autoload, `bats-lint <filepath>` for tests
- Field separator: `▮` (U+2800)
- Color vars: `$COLORS[comment]` for descriptions, `colorize` function for applying colors
- Existing list/list-raw pairs to reference: `git-branch-list-raw`, `skills-list-raw`, `yarn-script-list-raw`
- Agent-facing docs: `tools/ai/claude/config/skills/zsh-writer/references/calling-commands.md`
- Use `$OROSHI_ROOT` for all oroshi paths, never hardcoded `~/.oroshi`

## Discoveries
