#!/usr/bin/env bats

bats_load_library 'helper'

SCRIPT="${BATS_TEST_DIRNAME}/../bats-lint-shellcheck.zsh"

setup() {
  bats_tmp_dir
  printf "source '%s'\n" "$SCRIPT" >"$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '# clean bats file\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "detects bash syntax error in bats file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $(\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  [[ "$status" -eq 1 ]]
  [[ "$output" != '[]' ]]
}

@test "violation has file field matching argument path" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  [[ "$output" == *"\"file\":\"$file\""* ]]
}

@test "violation has line and col fields as numbers" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  run bash -c "jq '.[0] | (.line | type) + \" \" + (.col | type)' <<< '$output'"
  [[ "$output" == '"number number"' ]]
}

@test "violation code uses SC prefix" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  run bash -c "jq -r '.[0].code' <<< '$output'"
  [[ "$output" == SC* ]]
}

@test "violation has message field as string" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  run bash -c "jq '.[0].message | type' <<< '$output'"
  [[ "$output" == '"string"' ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '# clean\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
