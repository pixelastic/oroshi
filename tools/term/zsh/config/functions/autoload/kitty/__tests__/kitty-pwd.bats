bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns cwd of the focused window when tab has one window" {
  kitty() {
    cat <<'JSON'
[{"tabs":[{"windows":[{"is_focused":true,"cwd":"/home/tim/projects"}]}]}]
JSON
  }
  bats_mock kitty

  bats_run_zsh "kitty-pwd"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "/home/tim/projects" ]]
}

@test "returns cwd of the focused window when tab has multiple windows" {
  kitty() {
    cat <<'JSON'
[{"tabs":[{"windows":[{"is_focused":false,"cwd":"/home/tim/other"},{"is_focused":true,"cwd":"/home/tim/active"},{"is_focused":false,"cwd":"/home/tim/another"}]}]}]
JSON
  }
  bats_mock kitty

  bats_run_zsh "kitty-pwd"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "/home/tim/active" ]]
}

@test "returns empty and fails when no focused window found" {
  kitty() {
    cat <<'JSON'
[{"tabs":[{"windows":[{"is_focused":false,"cwd":"/home/tim/other"}]}]}]
JSON
  }
  bats_mock kitty

  bats_run_zsh "kitty-pwd"

  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
