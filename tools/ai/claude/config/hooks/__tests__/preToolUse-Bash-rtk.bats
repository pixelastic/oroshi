bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../preToolUse-Bash-rtk.zsh'"
}

@test "prepends rtk when rtk-can-rewrite exits 0" {
  rtk-can-rewrite() { return 0; }
  bats_mock rtk-can-rewrite

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-rtk 'bats foo.bats'"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk bats foo.bats" ]
}

@test "ignores command when rtk-can-rewrite exits 1" {
  rtk-can-rewrite() { return 1; }
  bats_mock rtk-can-rewrite

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-rtk 'echo hello'"
  [ "$status" -eq 0 ]
  [ "$output" = "echo hello" ]
}

@test "preserves \xa0 as 4 literal characters through RTK ignore path" {
  rtk-can-rewrite() { return 1; }
  bats_mock rtk-can-rewrite

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-rtk 'echo \xa0'"
  [ "$status" -eq 0 ]
  [ "$output" = 'echo \xa0' ]
}

@test "is idempotent when command already uses RTK without calling rtk-can-rewrite" {
  rtk-can-rewrite() {
    touch "$BATS_TMP_DIR/unexpected-call"
    return 1
  }
  bats_mock rtk-can-rewrite

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-rtk 'rtk git status'"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
  [ ! -f "$BATS_TMP_DIR/unexpected-call" ]
}
