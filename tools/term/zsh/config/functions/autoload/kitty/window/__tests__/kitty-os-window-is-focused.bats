bats_load_library 'helper'

# kitty is focused

@test "returns exit code 0 when kitty-remote ls reports is_focused true" {
  kitty-remote() { echo '[{"is_focused": true}]'; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-os-window-is-focused"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# kitty is not focused

@test "returns exit code 1 when kitty-remote ls reports is_focused false" {
  kitty-remote() { echo '[{"is_focused": false}]'; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-os-window-is-focused"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

# kitty-remote output contains control characters

@test "returns exit code 0 when kitty-remote ls output contains JSON escape sequences" {
  # kitty JSON-escapes terminal content (\n, \t), echo would interpret them
  kitty-remote() { printf '[{"is_focused": true, "text": "line1\\nline2"}]'; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-os-window-is-focused"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# kitty-remote fails

@test "returns exit code 1 when kitty-remote ls exits non-zero" {
  kitty-remote() { return 1; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-os-window-is-focused"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}
