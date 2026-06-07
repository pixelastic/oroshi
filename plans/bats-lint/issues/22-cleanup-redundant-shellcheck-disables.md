## TLDR

Audit all .bats files for `# shellcheck disable=SCxxxx` comments that are now redundant because the rule is already globally excluded in `bats-lint-shellcheck.zsh`.

## Context

Throughout the domain lint passes (issues 01–17), some violations were silenced with inline `# shellcheck disable=SCxxxx` comments directly on the offending line. Since then, several of those rules were added to the global `excludedRules` list in `bats-lint-shellcheck.zsh` as confirmed false positives. Any inline disable for a globally-excluded rule is now dead code.

### Currently globally excluded rules

In `scripts/bin/term/bats/bats-lint/bats-lint-shellcheck.zsh`:

- `SC2016` — `$var` in single-quoted printf is intentional in bats fixtures
- `SC2155` — `local var="$(cmd)"` is the project convention
- `SC2317` — declaring unused functions for mocks is ok
- `SC2030` — modification of var is local to subshell caused by `@test`
- `SC2031` — var modified in subshell; change might be lost in `@test`

## What to do

1. Find all `# shellcheck disable=SCxxxx` (and `# shellcheck disable=SC2088` etc.) in `.bats` files
2. For each one, check if the rule is in `excludedRules`
3. If yes → remove the inline disable comment
4. Re-run `bats-lint` and `bats` to confirm nothing regressed

## Behavioral Tests

**No redundant disables remain:**
- No `.bats` file contains `# shellcheck disable=` for a rule in `excludedRules`

**No regressions:**
- `bats-lint` exits 0 on all `.bats` files after cleanup
- `bats` passes on all modified files

## Acceptance criteria

- [ ] All inline `# shellcheck disable=` for globally-excluded rules removed
- [ ] `bats-lint` exits 0 on all `.bats` files
- [ ] `bats` passes on all modified files
- [ ] No new rules introduced or modified
