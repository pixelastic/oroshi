## TLDR

Add `expect_json`, `expect_json_null`, and `expect_json_glob` helper functions for asserting JSON values from `$output` in bats tests.

## What to build

Create a new `helper-json` file in the bats helper directory with three functions:

- `expect_json <jq_path> <expected>` — extracts value with `jq -r`, compares with `[[ "$actual" = "$2" ]]` (quoted RHS, exact match)
- `expect_json_null <jq_path>` — extracts value with `jq` (no `-r`), compares to the string `"null"`
- `expect_json_glob <jq_path> <pattern>` — extracts value with `jq -r`, compares with `[[ "$actual" == $2 ]]` (unquoted RHS, glob match)

All three read from the bats `$output` variable. No caching.

On failure, each function prints: `<function_name> <jq_path>: expected '<expected>', got '<actual>'` and returns 1.

The existing `helper` file must source `helper-json` so that all tests get the functions via `bats_load_library 'helper'` without any extra import.

## Behavioral Tests

Test file: `tools/term/bats/config/__tests__/helper-json.bats`

**expect_json**
- passes when jq path value matches expected string
- fails when jq path value differs from expected string
- failure message contains function name, jq path, expected value, and actual value

**expect_json_null**
- passes when jq path value is null
- fails when jq path value is not null

**expect_json_glob**
- passes when jq path value matches glob pattern
- fails when jq path value does not match glob pattern

**integration**
- helpers are available after `bats_load_library 'helper'` without extra import

## Acceptance criteria

- [ ] `helper-json` file created with three functions
- [ ] `helper` sources `helper-json`
- [ ] `helper-json.bats` tests pass
- [ ] All pre-existing bats tests still pass
