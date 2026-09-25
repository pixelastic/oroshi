bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns __tests__ bats file for an autoload function" {
  mkdir -p "$BATS_TMP_DIR/autoload/__tests__"
  touch "$BATS_TMP_DIR/autoload/my-func"
  touch "$BATS_TMP_DIR/autoload/__tests__/my-func.bats"

  bats_run_zsh "zsh-test-path $BATS_TMP_DIR/autoload/my-func"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/autoload/__tests__/my-func.bats" ]]
}

@test "returns __tests__ bats file for a .zsh file" {
  mkdir -p "$BATS_TMP_DIR/rules/__tests__"
  touch "$BATS_TMP_DIR/rules/my-rule.zsh"
  touch "$BATS_TMP_DIR/rules/__tests__/my-rule.bats"

  bats_run_zsh "zsh-test-path $BATS_TMP_DIR/rules/my-rule.zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/rules/__tests__/my-rule.bats" ]]
}

@test "returns the bats file directly when given a .bats file" {
  mkdir -p "$BATS_TMP_DIR/autoload/__tests__"
  touch "$BATS_TMP_DIR/autoload/__tests__/my-func.bats"

  bats_run_zsh "zsh-test-path $BATS_TMP_DIR/autoload/__tests__/my-func.bats"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/autoload/__tests__/my-func.bats" ]]
}

@test "exits 1 when given a .bats file that does not exist" {
  bats_run_zsh "zsh-test-path $BATS_TMP_DIR/autoload/__tests__/missing.bats"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns an absolute path when given a relative path" {
  mkdir -p "$BATS_TMP_DIR/autoload/__tests__"
  touch "$BATS_TMP_DIR/autoload/my-func"
  touch "$BATS_TMP_DIR/autoload/__tests__/my-func.bats"

  bats_run_zsh "cd $BATS_TMP_DIR && zsh-test-path ./autoload/my-func"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/autoload/__tests__/my-func.bats" ]]
}

@test "exits 1 with empty output when no test file exists" {
  mkdir -p "$BATS_TMP_DIR/rules"
  touch "$BATS_TMP_DIR/rules/no-test-exists.zsh"

  bats_run_zsh "zsh-test-path $BATS_TMP_DIR/rules/no-test-exists.zsh"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "exits 1 with no arguments" {
  bats_run_zsh "zsh-test-path"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}
