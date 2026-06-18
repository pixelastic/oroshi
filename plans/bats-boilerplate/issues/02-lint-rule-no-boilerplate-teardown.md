## TLDR

Add a `noBoilerplateTeardown` lint rule that flags `teardown()` blocks whose body is solely `bats_cleanup`.

## What to build

New rule in `scripts/bin/term/bats/bats-lint/__rules/rule-no-boilerplate-teardown.zsh`:

- Define `batsLintRule_noBoilerplateTeardown` following the existing rule API (receives file path, outputs violations as `file▮code▮level▮line▮message`).
- Detect `teardown()` whose body consists solely of a `bats_cleanup` call — both one-liner (`teardown() { bats_cleanup; }`) and multiline forms.
- Do NOT flag teardowns that call `bats_cleanup` alongside other statements.
- Register the rule in `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`.

Prior art: `rule-no-run-zsh.zsh`, `rule-no-top-level-var.zsh`.

## Behavioral Tests

New file `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-boilerplate-teardown.bats`, following the pattern in `rule-no-run-zsh.bats` (uses `rules-helper` and `run_rule`).

**violations:**
- detects one-liner teardown with bats_cleanup
- detects multiline teardown with bats_cleanup
- reports correct line number

**no violations:**
- teardown with bats_cleanup plus additional statements
- file with no teardown function
- file with empty teardown

**suppression:**
- bats-lint disable comment suppresses the violation

## Acceptance criteria

- [ ] Rule detects both one-liner and multiline boilerplate teardown forms
- [ ] Rule does not flag teardowns with extra statements beyond `bats_cleanup`
- [ ] Rule registered in `bats-lint-custom.zsh`
- [ ] `bats rule-no-boilerplate-teardown.bats` passes
- [ ] Running `bats-lint` on any file with boilerplate teardown reports `noBoilerplateTeardown` violation
