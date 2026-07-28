## TLDR

New bats-lint rule `noSingleBracket` that flags `[ ]` assertions, wired into the linter.

## What to build

Add `rule-no-single-bracket.zsh` to `scripts/bin/term/bats/bats-lint/__rules/`. The rule scans each line of a `.bats` file:

1. Skip comment lines (`^[[:space:]]*#`)
2. Skip `@test` title lines (`^@test `)
3. Flag lines matching `^[[:space:]]*\[ [^\[]` — a single bracket assertion not followed by `[`
4. Emit violations with code `noSingleBracket` and message `"Use [[ ]] instead of [ ]"`

Follow the exact pattern of `rule-no-run-zsh.zsh` (line-by-line scan, printf with `$_SEP`).

Wire the rule into `bats-lint-custom.zsh`: source the file and add `batsLintRule_noSingleBracket` to the `lint-custom-run` call.

## Behavioral Tests

Test file: `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-single-bracket.bats`

**Violation scenarios:**
- flags `[ "$status" -eq 0 ]` (basic assertion)
- flags indented `  [ -f "$file" ]`
- reports correct line numbers for multiple violations

**Clean scenarios:**
- `[[ "$status" -eq 0 ]]` (double bracket)
- `# [ "$x" -eq 0 ]` (comment)
- `@test "checks [ bracket" {` (test title)

## Acceptance criteria

- [ ] `rule-no-single-bracket.zsh` exists and follows existing rule pattern
- [ ] Rule is sourced and registered in `bats-lint-custom.zsh`
- [ ] All behavioral tests pass
- [ ] `bats-lint` on a file with `[ ]` reports `noSingleBracket` violations
- [ ] `bats-lint` on a file with only `[[ ]]` reports no `noSingleBracket` violations
