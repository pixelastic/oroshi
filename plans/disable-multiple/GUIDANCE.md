## Guidance

### What this PRD is about

Extend the `zshlint` and `batslint` disable-comment syntax from single-rule to comma-separated multi-rule:
`# zsh-lint disable=rule1,rule2`

### Key file

- **Engine (one change point):** `tools/term/zsh/config/functions/autoload/lint/lint-custom-run` — the disable-check logic is around line 60
- **zshlint tests:** `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint-custom.bats`
- **batslint tests:** `scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats`

### Testing commands

```zsh
bats scripts/bin/zsh/zsh-lint/__tests__/zsh-lint-custom.bats
bats scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats
```

### Conventions

- No spaces around commas in the disable list
- Unknown rule codes silently ignored
- Scope is always the single line immediately following the comment
- Tests go through the linter entry points — do NOT invoke `lint-custom-run` directly in tests
- zsh local variable pattern: `local var="$(cmd)"` + manual guard; never split `local`/assignment

## Discoveries
