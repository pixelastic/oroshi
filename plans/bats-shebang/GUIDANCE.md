## Guidance

### Commands

- **Run a bats test:** `bats <filepath>`
- **Lint a bats file:** `bats-lint <filepath>`
- **Lint a zsh file:** `zsh-lint <filepath>`

### File locations (relative to repo root)

- bats-lint orchestrator: `scripts/bin/term/bats/bats-lint/bats-lint`
- bats-lint-custom orchestrator: `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`
- bats-lint-shellcheck: `scripts/bin/term/bats/bats-lint/bats-lint-shellcheck.zsh`
- Custom rules: `scripts/bin/term/bats/bats-lint/__rules/`
- Custom rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- bats-lint integration tests: `scripts/bin/term/bats/bats-lint/__tests__/`

### Conventions

- Rule files: `rule-<name>.zsh`, function `batsLintRule_<camelName>`
- Rule test files: `rule-<name>.bats` — **no shebang**, no execute bit
- Rule tests use `run_rule` + `expect_rule_violation` / `expect_clean` from `rules-helper`
- All test variables go inside `setup()`, not at file top level
- Use `bats_run_zsh` for running zsh code; never `run` directly on zsh scripts
- Use `$OROSHI_ROOT` for repo paths, never `~/.oroshi` or hardcoded home

### Prior art

- `rule-no-top-level-var.zsh` + `rule-no-top-level-var.bats` — closest pattern to follow for the new rule

### Key findings from research

- `bats-lint-shellcheck` uses `--shell=bash` explicitly — does not rely on shebangs for shell detection
- 11 of 32 shebang-carrying files also have `+x` — both need cleanup
- `rule-no-top-level-var` regex `^[A-Z_][A-Z0-9_]*=` never matched shebangs; the "no violation for shebang" test was always testing an incidental non-match

## Discoveries
