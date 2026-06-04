bats_load_library 'helper'

SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash-rtk.zsh"

setup() {
  bats_tmp_dir
  printf "source '%s'\n" "$SCRIPT" > "$BATS_TMP_DIR/mock.zsh"
}

teardown() { bats_cleanup; }

@test "prepends rtk when rtk-can-rewrite exits 0" {
  rtk-can-rewrite() { return 0; }
  bats_mock rtk-can-rewrite

  bats_run_function preToolUse-Bash-rtk "bats foo.bats"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk bats foo.bats" ]
}

@test "ignores command when rtk-can-rewrite exits 1" {
  rtk-can-rewrite() { return 1; }
  bats_mock rtk-can-rewrite

  bats_run_function preToolUse-Bash-rtk "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "echo hello" ]
}

@test "is idempotent when command already uses RTK without calling rtk-can-rewrite" {
  rtk-can-rewrite() { touch "$BATS_TMP_DIR/unexpected-call"; return 1; }
  bats_mock rtk-can-rewrite

  bats_run_function preToolUse-Bash-rtk "rtk git status"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
  [ ! -f "$BATS_TMP_DIR/unexpected-call" ]
}
