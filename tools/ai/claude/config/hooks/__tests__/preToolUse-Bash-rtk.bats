bats_load_library 'helper'

SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash-rtk.zsh"

setup() {
  bats_tmp_dir
  printf "source '%s'\n" "$SCRIPT" > "$BATS_TMP_DIR/mock.zsh"
}

teardown() { bats_cleanup; }

@test "prints original command when rtk rewrite has no equivalent" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_function preToolUse-Bash-rtk "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "echo hello" ]
}

@test "prints rewritten command from rtk rewrite stdout" {
  rtk() { print -- "rtk $2"; }
  bats_mock rtk

  bats_run_function preToolUse-Bash-rtk "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk echo hello" ]
}

@test "is idempotent when command already uses RTK" {
  bats_run_function preToolUse-Bash-rtk "rtk git status"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
}
