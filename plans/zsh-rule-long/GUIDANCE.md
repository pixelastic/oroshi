## Guidance

**Goal:** Add a `commandTooLong` custom rule to `zsh-lint`.

**Testing:**
- Run rule tests: `bats scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-command-too-long.bats`
- Lint rule file: `zsh-lint scripts/bin/zsh/zsh-lint/__rules/rule-command-too-long.zsh`
- Lint test file: `bats-lint scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-command-too-long.bats`
- Smoke test: `zsh-lint tools/ai/claude/config/hooks/preToolUse-Bash-helper.zsh`

**File locations (relative to repo root):**
- New rule: `scripts/bin/zsh/zsh-lint/__rules/rule-command-too-long.zsh`
- New tests: `scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-command-too-long.bats`
- Registration: `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh`

**Prior art:**
- Simplest existing rule: `scripts/bin/zsh/zsh-lint/__rules/rule-single-equals-in-test.zsh`
- Its tests: `scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-single-equals-in-test.bats`
- Test helpers used: `bats_load_library 'helper'` + `bats_load_library 'rules-helper'`
- Test pattern: `run_rule <rule-file> <function-name> <test-filename> "${input[@]}"` + `expect_rule_violation <code> <lineno>` / `expect_clean`

**Rule conventions:**
- Function name: `zshLintRule_<camelCase>`
- Code identifier: camelCase string, used in disable comments (`# zsh-lint disable: commandTooLong`)
- Output separator: `$_SEP` (injected by the runner)
- Output format: `file▮code▮error▮lineno▮message`

## Discoveries
