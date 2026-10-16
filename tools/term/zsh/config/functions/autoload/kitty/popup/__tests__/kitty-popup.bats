bats_load_library 'helper'

setup() {
  bats_tmp_dir
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote
}

@test "launches the command in a centered os-panel" {
  bats_run_zsh "kitty-popup kitty-popup-skala"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "launch --type=os-panel --os-panel edge=center-sized --os-panel columns=60 --os-panel lines=5 --os-panel focus-policy=exclusive bin-zsh kitty-popup-skala" ]]
}

@test "passes extra arguments to the command" {
  bats_run_zsh "kitty-popup kitty-popup-autocorrect one two"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == *"bin-zsh kitty-popup-autocorrect one two" ]]
}

@test "fails without a command" {
  bats_run_zsh "kitty-popup"

  [[ "$status" -eq 1 ]]
  [[ ! -f "$BATS_TMP_DIR/kitty-args" ]]
}
