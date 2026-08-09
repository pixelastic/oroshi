## Guidance

- Test command: `bats scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-no-local-subshell-guard.bats`
- Lint rule file: `zsh-lint scripts/bin/zsh/zsh-lint/__rules/rule-no-local-subshell-guard.zsh`
- Lint test file: `bats-lint scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-no-local-subshell-guard.bats`
- Prior art for rule: `scripts/bin/zsh/zsh-lint/__rules/rule-local-or-return.zsh`
- Prior art for test: `scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-local-or-return.bats`
- Rule output format: `file▮code▮level▮lineNumber▮message`
- Test helper: `bats_load_library 'rules-helper'` provides `run_rule` and `expect_rule_violation`
- Registration: source in `zsh-lint-custom.zsh`, add function name to `lint-custom-run` call
- Skill doc: `tools/ai/claude/config/skills/zsh-writer/references/calling-commands.md`

## Discoveries

_(append-only, updated after each issue)_
