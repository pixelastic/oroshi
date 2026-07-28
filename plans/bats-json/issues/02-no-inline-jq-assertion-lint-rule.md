## TLDR

Add a `noInlineJqAssertion` bats-lint rule that flags inline `echo "$output" | jq` inside `[[ ]]` and suggests the correct helper.

## What to build

Create a new rule file following the existing rule pattern (e.g. `rule-no-single-bracket.zsh`).

The rule scans each line for `[[ ... $(echo "$output" | jq ...) ... ]]` and reports a violation with a message pointing to the correct helper:

- If the line uses `jq` (no `-r`) and compares to `"null"` → suggest `expect_json_null`
- If the line uses `==` with an unquoted RHS → suggest `expect_json_glob`
- Otherwise → suggest `expect_json`

The rule must NOT flag:
- `jq -e` expressions (boolean exit code assertions)
- `jq` on files (not piped from `$output`)
- `jq` usage outside `[[ ]]`

Wire the rule into `bats-lint-custom.zsh`: source the file and register `batsLintRule_noInlineJqAssertion` in the `lint-custom-run` call.

Disable comment `# bats-lint disable=noInlineJqAssertion` is handled by the framework automatically.

## Behavioral Tests

Test file: `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-inline-jq-assertion.bats`

**detection**
- flags exact match pattern and suggests expect_json
- flags null check pattern and suggests expect_json_null
- flags glob match pattern and suggests expect_json_glob

**non-detection**
- ignores jq -e boolean expressions
- ignores jq on files (not $output)
- ignores jq outside double brackets
- ignores lines with bats-lint disable comment

## Acceptance criteria

- [ ] Rule file created following existing rule pattern
- [ ] Rule wired into `bats-lint-custom.zsh`
- [ ] Rule test file passes
- [ ] Running `bats-lint` on a clean file produces no violations
