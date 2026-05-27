bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "exits successfully" {
  bats_run_function claude-terminal-fix
  [ "$status" -eq 0 ]
}

@test "calls stty sane" {
  stty() { echo "$*" > "$BATS_TMP_DIR/stty.log"; }
  bats_mock stty

  bats_run_function claude-terminal-fix
  [ "$(cat "$BATS_TMP_DIR/stty.log")" = "sane" ]
}
