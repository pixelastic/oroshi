## TLDR

Replace all inline `echo "$output" | jq` assertions with `expect_json`, `expect_json_null`, or `expect_json_glob` across the codebase.

## What to build

Mechanical migration of all existing inline jq assertions in bats test files. Each line matching the pattern `[[ "$(echo "$output" | jq ...)" ... ]]` is replaced with the appropriate helper call.

Known files to migrate (from grep):
- `scripts/bin/ai/ralph/__tests__/ralph-start.bats`
- `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

Run `bats-lint` on every migrated file to confirm zero `noInlineJqAssertion` violations remain.

All changes go in a single commit.

## Scaffolding Tests

- `bats-lint` produces zero `noInlineJqAssertion` violations across all `.bats` files in the repo

## Acceptance criteria

- [ ] No `[[ "$(echo "$output" | jq ...)" ... ]]` patterns remain in bats files
- [ ] `bats-lint` reports zero `noInlineJqAssertion` violations
- [ ] All existing bats tests still pass after migration
