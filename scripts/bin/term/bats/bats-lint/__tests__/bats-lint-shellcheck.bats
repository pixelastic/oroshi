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

@test "violation has expected JSON shape" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_function bats-lint-shellcheck "$file"
  run jq '.' <<<"$output"
  [[ "$output" == '[
  {
    "file": "'"$file"'",
    "line": 1,
    "endLine": 1,
    "column": 6,
    "endColumn": 11,
    "level": "info",
    "code": "SC2086",
    "message": "Double quote to prevent globbing and word splitting."
  }
]' ]]
}
