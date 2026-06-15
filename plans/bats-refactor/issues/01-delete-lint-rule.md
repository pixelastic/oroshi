## TLDR

Delete the `rule-current-script-var` bats-lint rule, which enforces the now-retired `CURRENT` naming convention.

## What to build

Remove the `rule-current-script-var.zsh` file from the bats-lint rules directory. This rule currently errors when a `$BATS_TEST_DIRNAME/../basename` path assignment is not named `CURRENT`. Since the `CURRENT` convention is being retired, this rule must be deleted before any test files are migrated — otherwise it would misfire on intermediate states.

No replacement rule is introduced. The convention is simply removed.

## Scaffolding Tests

- The rule file no longer exists in the bats-lint rules directory
- Running `bats-lint` on a `.bats` file that previously triggered the rule produces no error

## Acceptance criteria

- [ ] `rule-current-script-var.zsh` is deleted from the bats-lint rules directory
- [ ] `bats-lint` runs without referencing this rule
