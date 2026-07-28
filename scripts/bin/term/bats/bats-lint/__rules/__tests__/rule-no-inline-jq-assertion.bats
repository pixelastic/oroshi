bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-inline-jq-assertion.zsh" "batsLintRule_noInlineJqAssertion" "test.bats" "$@"
}

@test "flags exact match pattern and suggests expect_json" {
  # bats-lint disable=noInlineJqAssertion
  run_this_rule '[[ "$(echo "$output" | jq ".name")" == "tim" ]]'
  expect_rule_violation noInlineJqAssertion 1
  [[ "$output" == *"Use expect_json instead"* ]]
}

@test "flags null check pattern and suggests expect_json_null" {
  # bats-lint disable=noInlineJqAssertion
  run_this_rule '[[ "$(echo "$output" | jq ".missing")" == "null" ]]'
  expect_rule_violation noInlineJqAssertion 1
  [[ "$output" == *"expect_json_null"* ]]
}

@test "flags jq -r with null comparison and suggests expect_json not expect_json_null" {
  # bats-lint disable=noInlineJqAssertion
  run_this_rule '[[ "$(echo "$output" | jq -r ".missing")" == "null" ]]'
  expect_rule_violation noInlineJqAssertion 1
  [[ "$output" == *"Use expect_json instead"* ]]
}

@test "flags glob match pattern and suggests expect_json_glob" {
  # bats-lint disable=noInlineJqAssertion
  run_this_rule '[[ "$(echo "$output" | jq -r ".name")" == tim* ]]'
  expect_rule_violation noInlineJqAssertion 1
  [[ "$output" == *"expect_json_glob"* ]]
}

@test "ignores jq -e boolean expressions" {
  run_this_rule 'echo "$output" | jq -e ".active"'
  expect_clean
}

@test "ignores jq on files not piped from output" {
  run_this_rule '[[ "$(jq ".name" file.json)" == "tim" ]]'
  expect_clean
}

@test "ignores jq outside double brackets" {
  run_this_rule 'local val="$(echo "$output" | jq ".name")"'
  expect_clean
}
