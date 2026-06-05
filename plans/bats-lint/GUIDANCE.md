## Guidance

### Goal

Bring all ~120 BATS test files to zero violations under `bats-lint` (shellcheck + custom rules). Each issue is one domain. Process domains sequentially — the ruleset evolves as you go, and issue 17 does the final global cleanup.

### Process per domain

1. Run `bats-lint <file>` on each file in the domain
2. For each violation, present it to the developer and decide: **fix** / **exception** / **new rule**
3. If a new rule is needed: implement it (rule file + test file + fixtures) in the same session
4. Confirm: `bats-lint` exits 0 on all domain files + `bats` passes on all domain files
5. Mark the issue done in `state.json` and add a Discoveries entry below

### Commands

```zsh
# Lint a file
bats-lint <filepath>

# Run tests
bats <filepath>

# Lint all files in a directory
bats-lint <dir>/**/*.bats(N)
```

### File locations

- bats-lint tool: `scripts/bin/term/bats/bats-lint/`
- bats-lint rules: `scripts/bin/term/bats/bats-lint/__rules/`
- bats-lint rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- BATS helper: `tools/term/bats/config/helper`
- BATS rules-helper: `tools/term/bats/config/rules-helper`

### bats-lint rule interface

Each rule outputs: `file▮code▮severity▮line▮message` (separator = U+25AE ▮)
Inline disable: `# bats-lint-disable <RuleCode>` on the offending line.
Prior art: `rule-no-run-zsh.zsh`, `rule-no-inline-function.zsh`

### Done criteria per issue

- `bats-lint` exits 0 on every file in the domain
- `bats` passes on every file in the domain
- Developer review sign-off

### Key conventions

- All test variables declared inside `setup()`, not at file top level
- Use `bats_run_zsh` (never `run zsh`)
- Use `bats_mock` for stubs (no env-var mocks in prod code)
- `bats-lint` must be run explicitly from the worktree (git-file-lint may miss untracked files)

### Prior art for rule tests

- `rule-no-run-zsh.bats` — minimal fixture, tests violation + clean case
- `rule-no-inline-function.bats` — tests length and multi-instruction variants

## Discoveries

<!-- Agents: append findings after each completed issue using the format below -->
<!-- ### Issue XX — short title -->
<!-- - Non-trivial finding -->
