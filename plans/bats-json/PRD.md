## Problem Statement

Bats tests that assert JSON output repeat `echo "$output" | jq -r '.key'` inside `[[ ]]` for every single key. This is verbose (~100 occurrences across ~10 files), obscures test intent behind plumbing, and parses the same JSON redundantly. There is no helper or lint rule to guide authors toward a better pattern.

## Solution

Introduce three bats helper functions for JSON assertions (`expect_json`, `expect_json_null`, `expect_json_glob`), a bats-lint rule that flags the old inline pattern and points to the correct helper, and a one-shot migration of all existing inline jq assertions.

## User Stories

1. As a test author, I want to write `expect_json '.status' 'ok'` instead of `[[ "$(echo "$output" | jq -r '.status')" = "ok" ]]`, so that my test intent is immediately clear
2. As a test author, I want to check null values with `expect_json_null '.key'`, so that I don't have to remember the `-r` flag subtlety for null detection
3. As a test author, I want to glob-match JSON values with `expect_json_glob '.path' '/*'`, so that I can assert patterns without raw `[[ ]]` plumbing
4. As a test author, I want clear failure messages showing the jq path, expected value, and actual value, so that I can diagnose failures without re-running with debug output
5. As a test author, I want `bats_load_library 'helper'` to automatically provide JSON helpers, so that I don't need an extra import line
6. As a contributor running bats-lint, I want inline jq assertions flagged with a specific suggestion (use `expect_json`, `expect_json_null`, or `expect_json_glob`), so that I know exactly which helper to use
7. As a reviewer, I want the codebase to consistently use helpers instead of inline jq, so that tests are scannable and the pattern doesn't regress

## Implementation Decisions

- **Three functions, no more**: `expect_json` (exact match), `expect_json_null` (null check), `expect_json_glob` (glob match). No cache, no operator overloading, no `expect_json_length`.
- **`expect_json`** uses `jq -r` and `[[ "$actual" = "$2" ]]` (quoted RHS, exact)
- **`expect_json_glob`** uses `jq -r` and `[[ "$actual" == $2 ]]` (unquoted RHS, glob)
- **`expect_json_null`** uses `jq` (no `-r`) and compares to the string `"null"`
- **Failure message format**: `<function_name> <jq_path>: expected '<expected>', got '<actual>'`
- **File split**: helpers live in a new `helper-json` file, sourced by the existing `helper` file. Callers don't change their import.
- **Lint rule `noInlineJqAssertion`**: detects `[[ ... $(echo "$output" | jq ...) ... ]]`. Suggests the correct helper based on the match (null check vs glob vs exact). Does NOT flag `jq -e` expressions or `jq` usage outside `[[ ]]`.
- **Lint wiring**: rule sourced and registered in `bats-lint-custom.zsh` alongside existing rules. Disable comment `# bats-lint disable=noInlineJqAssertion` supported automatically by the framework.
- **Migration**: single commit replacing all ~100 inline jq assertions across ~10 files. Mechanical, validated by existing tests passing.

## Testing Decisions

A good test for these helpers verifies external behavior: given a known `$output` JSON string, does the assertion pass or fail as expected, and does the failure message contain the right information?

**Tested modules:**

- **helper-json** (`helper-json.bats`): test each of the 3 functions for pass, fail, and failure message content. Prior art: `helper.bats` which tests `bats_cleanup` and mocking helpers.
- **rule-no-inline-jq-assertion** (`rule-no-inline-jq-assertion.bats`): test detection of each variant (exact, null, glob) and non-detection of legitimate jq usage (files, `jq -e`, outside `[[ ]]`). Prior art: `rule-no-single-bracket.bats`.

## Out of Scope

- `jq -e` boolean expressions (e.g. `jq -e 'length > 0'`) — no helper, not flagged by lint
- `jq` on files (`run jq -r '.key' "$file"`) — different pattern, not related to `$output` assertions
- Full JSON structure comparison (heredoc pattern) — already works fine in `projects-build.bats`
- `expect_json_length` or `expect_json_type` — YAGNI, revisit if `jq -e` length checks proliferate
- Autofix in the lint rule — report only, consistent with all existing bats-lint rules
