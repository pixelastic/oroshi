bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns path for a colocalized script" {
  mkdir -p "$BATS_TMP_DIR/scripts/bin/foo/__tests__"
  touch "$BATS_TMP_DIR/scripts/bin/foo/my-script"
  touch "$BATS_TMP_DIR/scripts/bin/foo/__tests__/my-script.bats"

  bats_run_zsh "bats-test-path $BATS_TMP_DIR/scripts/bin/foo/my-script"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/scripts/bin/foo/__tests__/my-script.bats" ]
}

@test "returns path for an autoloaded zsh function" {
  mkdir -p "$BATS_TMP_DIR/functions/autoload/__tests__"
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  touch "$BATS_TMP_DIR/functions/autoload/__tests__/my-func.bats"

  bats_run_zsh "bats-test-path $BATS_TMP_DIR/functions/autoload/my-func"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/functions/autoload/__tests__/my-func.bats" ]
}

@test "returns the bats file path when given a .bats file" {
  mkdir -p "$BATS_TMP_DIR/scripts/__tests__"
  touch "$BATS_TMP_DIR/scripts/__tests__/my-script.bats"

  bats_run_zsh "bats-test-path $BATS_TMP_DIR/scripts/__tests__/my-script.bats"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/scripts/__tests__/my-script.bats" ]
}

@test "returns 1 if no test file exists" {
  mkdir -p "$BATS_TMP_DIR/scripts/bin/bar"
  touch "$BATS_TMP_DIR/scripts/bin/bar/orphan"

  bats_run_zsh "bats-test-path $BATS_TMP_DIR/scripts/bin/bar/orphan"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "returns 1 with no arguments" {
  bats_run_zsh "bats-test-path"
  [ "$status" -eq 1 ]
}

@test "strips extension and adds .bats for a .zsh file" {
  mkdir -p "$BATS_TMP_DIR/rules/__tests__"
  touch "$BATS_TMP_DIR/rules/rule-example.zsh"
  touch "$BATS_TMP_DIR/rules/__tests__/rule-example.bats"

  bats_run_zsh "bats-test-path $BATS_TMP_DIR/rules/rule-example.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/rules/__tests__/rule-example.bats" ]
}
