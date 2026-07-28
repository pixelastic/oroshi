## Issue 01 — expect_json helpers
### Missing setup() in test file
```bats
bats_load_library 'helper'

# --- expect_json ---

@test "expect_json passes when jq path value matches expected string" {
```
**Problem:** Test file has no `setup()` function, convention suggests always having one.
**Reason skipped:** No shared state or variables to initialize; each test sets `output` inline. `setup()` would be empty.

## Issue 02 — noInlineJqAssertion lint rule
### Missing setopt local_options err_return
```zsh
function batsLintRule_noInlineJqAssertion() {
```
**Problem:** Missing error protection header
**Reason skipped:** Sibling rule functions (rule-no-single-bracket.zsh etc.) all omit it — lint rules are sourced, not standalone

### No comments on if/elif branches
```zsh
    if [[ ! "$line" =~ 'jq[[:space:]]+-r' && "$line" =~ '==[[:space:]]*"?null"?' ]]; then
      msg='Use expect_json_null instead of inline jq assertion'
    elif [[ "$line" =~ '==[[:space:]]*[^"[:space:]]' ]]; then
      msg='Use expect_json_glob instead of inline jq assertion'
    fi
```
**Problem:** Guard clause comment rule extends to conditional branches
**Reason skipped:** Assignment branches, not guard clauses — message values are self-documenting

### run_this_rule at file top level
```bash
run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-inline-jq-assertion.zsh" "batsLintRule_noInlineJqAssertion" "test.bats" "$@"
}
```
**Problem:** Helper should be in setup() per memory note
**Reason skipped:** All sibling rule tests use the same top-level helper pattern — local convention takes precedence

### Missing disable comment test
**Problem:** Spec lists "ignores lines with bats-lint disable comment" as a behavioral test
**Reason skipped:** Disable comments handled by lint-custom-run framework, not individual rules — already tested in framework tests

### Glob detection for unquoted literals
```zsh
    elif [[ "$line" =~ '==[[:space:]]*[^"[:space:]]' ]]; then
```
**Problem:** `== true` (exact match) would get expect_json_glob suggested
**Reason skipped:** Spec says "unquoted RHS → suggest expect_json_glob" — behavior matches spec
