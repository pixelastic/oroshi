## TLDR

Update the `noRunZsh` rule message to point to `bats_run_zsh` instead of `bats_run_function`.

## What to build

In the `noRunZsh` custom bats-lint rule, update the violation message from `"Use bats_run_function instead of run zsh"` to `"Use bats_run_zsh instead of run zsh"`.

Update the corresponding test in the rule's test file to assert the new message text.

## Behavioral Tests

**noRunZsh message**
- Violation message contains `bats_run_zsh`
- Violation message does not contain `bats_run_function`

## Acceptance criteria

- [ ] Rule violation message references `bats_run_zsh`
- [ ] Rule test file updated to match new message
- [ ] All rule tests pass
- [ ] `bats-lint` passes on the rule and test files
