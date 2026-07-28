## Guidance

- Lint rules live in `scripts/bin/term/bats/bats-lint/__rules/`
- Rule tests live in `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- Rule wiring is in `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`
- Prior art for rule: `rule-no-run-zsh.zsh` (same line-by-line scan pattern)
- Prior art for tests: `rule-no-run-zsh.bats` (same `run_rule`/`expect_rule_violation`/`expect_clean` framework)
- Test command: `bats <filepath>`
- Lint command: `bats-lint <filepath>`
- Rule function naming: `batsLintRule_<camelCaseName>`
- Violation output format: `file▮code▮error▮line▮message` (▮ = `$_SEP`)

## Discoveries
