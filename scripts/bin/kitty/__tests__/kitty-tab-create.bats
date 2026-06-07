bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../kitty-tab-create"
}

teardown() {
  bats_cleanup
}

@test "no --cmd: kitty-remote called with zsh" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "$CURRENT" "My Tab"

  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *" zsh" ]]
}

@test "--cmd: kitty-remote called with the given command" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "$CURRENT" "My Tab" --cmd "kitty-helper-claude-start"

  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *" kitty-helper-claude-start" ]]
}

@test "--cmd with args: kitty-remote called with command and its arguments" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "$CURRENT" "My Tab" --cmd "kitty-helper-claude-start @/tmp/file.md"

  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *" kitty-helper-claude-start @/tmp/file.md" ]]
}
