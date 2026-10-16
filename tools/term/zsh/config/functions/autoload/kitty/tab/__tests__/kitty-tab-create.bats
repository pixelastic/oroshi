bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "no --cmd: kitty-remote called with zsh" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-tab-create 'My Tab'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *" zsh" ]]
}

@test "--cmd: prefixes command with bin-zsh for autoload support" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-tab-create 'My Tab' --cmd 'kitty-helper-claude-start'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *"bin-zsh kitty-helper-claude-start" ]]
}

@test "--cmd with args: prefixes full command with bin-zsh" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-tab-create 'My Tab' --cmd 'kitty-helper-claude-start @/tmp/file.md'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *"bin-zsh kitty-helper-claude-start @/tmp/file.md" ]]
}

@test "--cmd with quoted args: keeps each quoted arg as a single word" {
  kitty-remote() { printf "%s\n" "$@" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-tab-create 'My Tab' --cmd \"kitty-helper-claude-start '/ralph /tmp/it'\\''s plan'\""

  [[ "$status" -eq 0 ]]
  [[ "$(tail -n 2 "$BATS_TMP_DIR/kitty-args")" == $'kitty-helper-claude-start\n/ralph /tmp/it\'s plan' ]]
}
