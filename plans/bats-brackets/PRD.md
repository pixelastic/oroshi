## Problem Statement

`.bats` test files inconsistently use single bracket `[ ]` and double bracket `[[ ]]` for assertions. Single brackets are less safe (word splitting, globbing in Bash), and since Bats runs under Bash, `[[ ]]` is strictly better. There are 1,435 single-bracket assertions across 161 files, vs 799 double-bracket assertions across 116 files. No lint rule enforces `[[`, so agents keep writing `[`.

## Solution

Add a `bats-lint` custom rule that flags `[ ]` assertions as errors, requiring `[[ ]]` instead. Fix all existing violations across the repo.

## User Stories

1. As a developer running `bats-lint`, I want single-bracket assertions flagged as errors, so that unsafe `[ ]` usage is caught before merge
2. As an AI agent writing `.bats` tests, I want `bats-lint` to reject `[ ]`, so that I learn to always use `[[ ]]`
3. As a developer, I want all existing `.bats` files migrated to `[[ ]]`, so that the codebase is consistent from day one of the rule
4. As a developer, I want to suppress the rule on specific lines via `# bats-lint disable=noSingleBracket`, so that edge cases can be handled

## Implementation Decisions

- **Rule name and code:** `rule-no-single-bracket.zsh`, function `batsLintRule_noSingleBracket`, code `noSingleBracket`
- **Detection regex:** Match lines starting with optional whitespace then `[ ` not followed by `[` (i.e. `^\s*\[ [^\[]`). Skip comment lines (`^[[:space:]]*#`) and `@test` title lines
- **Scope: line-start only.** Other rules (`noAndBlock`, `noInlineFunction`) already enforce assertions on their own line, so checking after `&&`/`||`/`;` is redundant
- **Error message:** `"Use [[ ]] instead of [ ]"`
- **Wiring:** Source the rule in `bats-lint-custom.zsh` and add `batsLintRule_noSingleBracket` to the `lint-custom-run` call
- **Bulk fix:** `sed` replacement on all `.bats` files — `[ ` to `[[ ` at line start, ` ]` to ` ]]` at line end. Verified by running `bats-lint` after
- **No `testing.md` update:** The lint rule is deterministic — agents get feedback from `bats-lint`, no need to duplicate guidance in the zsh-writer skill

## Testing Decisions

- **Only the rule gets tests.** Wiring is config glue, bulk fix is a one-time operation verified by running `bats-lint`
- **Prior art:** `rule-no-run-zsh.bats` — same framework (`run_rule`, `expect_rule_violation`, `expect_clean`)
- **Test cases:**
  - Flag: `[ "$status" -eq 0 ]` (basic assertion)
  - Flag: `  [ -f "$file" ]` (indented)
  - Flag: multiple violations on correct line numbers
  - Clean: `[[ "$status" -eq 0 ]]` (double bracket)
  - Clean: `# [ "$x" -eq 0 ]` (comment)
  - Clean: `@test "checks [ bracket" {` (test title)

## Out of Scope

- Enforcing `[[` in ZSH source files (zsh-lint has no such rule today)
- Detecting `[ ]` after `&&`/`||`/`;` — other rules already prevent this pattern
- Updating `zsh-writer` skill references — the lint rule is sufficient
