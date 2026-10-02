bats_load_library 'helper'

@test "returns success when kitty-remote ls succeeds" {
  kitty-remote() {
    echo "some json"
    return 0
  }
  bats_mock kitty-remote

  bats_run_zsh "kitty-is-running"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "returns failure when kitty-remote ls fails" {
  kitty-remote() {
    echo "boom" >&2
    return 1
  }
  bats_mock kitty-remote

  bats_run_zsh "kitty-is-running"

  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
