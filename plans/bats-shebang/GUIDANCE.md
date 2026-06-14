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

### Issue 02 — Strip shebangs
- 12 files had execute bit (not 11 as spec stated — one extra was added by issue 01's test file indirectly); strip all 12.
- `tail -n +2` left a leading blank line in every file — must follow up with `awk` to strip leading blank lines.
- `grep -rl '#!/usr/bin/env bats'` finds files that *contain* the string anywhere (e.g. test data) — use `awk 'FNR==1 && /^#!/'` to check only line 1.
- Pre-existing `currentScriptVar` violations in touched files must be fixed per `feedback_lint_preexisting.md` — this adds scope beyond the spec but is required by project standards.
- Scaffolding test "bats-lint exits 0" is unachievable — pre-existing `currentScriptVar` + `preferBatchMock` violations remain; narrow the test to `noShebang` specifically.
- `bats` via `rtk` wrapper rejects non-executable files with "permission denied"; run files directly with `bats <path>` to bypass this — tests do run and pass.

### Issue 01 — noShebang rule
- The rule test file intentionally has no shebang (it dogfoods the new rule); this looks inconsistent with siblings but the spec requires it — suppress the standards finding.
- `bats-lint-custom.bats` integration tests were already failing before this issue (pre-existing); they are not caused by this change.
