bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "removes the queued command" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-write 'echo hello' && zsh-queue-delete && zsh-queue-read"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "succeeds when nothing is queued" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-delete"
  [[ "$status" -eq 0 ]]
}
