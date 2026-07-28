## Guidance

- Testing ZSH: `bats <filepath>`
- Linting ZSH: `zsh-lint --fix <filepath>`
- Linting bats: `bats-lint <filepath>`
- Autoloaded functions live in `tools/term/zsh/config/functions/autoload/`
- Lint rules live in `scripts/bin/zsh/zsh-lint/__rules/`
- Lint rule tests live in `scripts/bin/zsh/zsh-lint/__rules/__tests__/`
- Rule registration is in `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh` (source line + function name in `lint-custom-run` call)
- Prior art for simple pattern rules: `rule-no-or-guard.zsh`
- Prior art for rule tests: `rule-no-or-guard.bats`
- The `_SEP` variable (▮ separator) is available in rule functions for output formatting
- The `echoerr` function body needs `# zsh-lint disable=useEchoerr` above its `echo` line

## Discoveries
