bats_load_library 'helper'

setup() {
  bats_tmp_dir
  TEST_FILE="$BATS_TMP_DIR/test.zsh"
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../zsh-lint-custom.zsh'"
}

teardown() {
  bats_cleanup
}

@test "clean file" {
  printf '# clean\n' >"$TEST_FILE"

  bats_run_zsh "$sourcePrefix && zsh-lint-custom $TEST_FILE"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "file with errors file" {
  printf 'local a b c\nlocal d e f\n' >"$TEST_FILE"

  bats_run_zsh "$sourcePrefix && zsh-lint-custom $TEST_FILE"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"noGroupedLocals"'* ]]
  [[ "$output" == '['*']' ]]
}

@test "disable comment suppresses only the annotated line" {
  script='# zsh-lint disable=noGroupedLocals
local a b c
local d e f'
  printf '%s\n' "$script" >"$TEST_FILE"

  bats_run_zsh "$sourcePrefix && zsh-lint-custom $TEST_FILE | json-pretty"

  expected='[
  {
    "file": "'$TEST_FILE'",
    "code": "noGroupedLocals",
    "level": "error",
    "line": 3,
    "endLine": 3,
    "column": 1,
    "endColumn": 1,
    "message": "Declare each local variable on its own line"
  }
]'
  [[ "$output" == "$expected" ]]
}

@test "disable=X,Y suppresses two of three errors, keeps third" {
  script='# zsh-lint disable=noDashZ,noDashN
[[ -z "$a" && -n "$b" ]]
local y
y="value"'
  printf '%s\n' "$script" >"$TEST_FILE"

  bats_run_zsh "$sourcePrefix && zsh-lint-custom $TEST_FILE | json-pretty"

  expected='[
  {
    "file": "'$TEST_FILE'",
    "code": "noSplitLocal",
    "level": "error",
    "line": 3,
    "endLine": 3,
    "column": 1,
    "endColumn": 1,
    "message": "Combine local declaration and assignment on one line"
  }
]'
  [[ "$output" == "$expected" ]]
}
