bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/ai/claude/claude-terminal-fix"
}

teardown() {
  bats_cleanup
}

@test "exits successfully" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "calls stty sane" {
  stty() { echo "$*" > "$BATS_TMP_DIR/stty.log"; }
  bats_mock stty

  bats_run_zsh "$CURRENT"
  [ "$(cat "$BATS_TMP_DIR/stty.log")" = "sane" ]
}
