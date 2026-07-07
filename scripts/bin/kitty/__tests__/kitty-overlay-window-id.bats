bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env KITTY_WINDOW_ID "42"
}

@test "overlay: prints parent window ID when run inside an overlay" {
  kitty-remote() { echo '[{"tabs":[{"windows":[{"id":42,"overlay_for":10}]}]}]'; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-overlay-window-id"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "10" ]]
}

@test "not-overlay: exits non-zero when overlay_for is null" {
  kitty-remote() { echo '[{"tabs":[{"windows":[{"id":42,"overlay_for":null}]}]}]'; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-overlay-window-id"

  [[ "$status" -ne 0 ]]
}
