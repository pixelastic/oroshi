bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"
}

@test "returns 1 when nothing is queued" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-read"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}
