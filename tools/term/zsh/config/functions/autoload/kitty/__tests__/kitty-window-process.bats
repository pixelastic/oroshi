bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock JSON: tab 1 has zsh (id:10) and claude (id:11, absolute path), tab 2 has nvim (id:20)
  export MOCK_KITTY_JSON='[{"tabs":[{"id":1,"windows":[{"id":10,"foreground_processes":[{"cmdline":["zsh"]}]},{"id":11,"foreground_processes":[{"cmdline":["/usr/bin/claude"]}]}]},{"id":2,"windows":[{"id":20,"foreground_processes":[{"cmdline":["nvim"]}]}]}]}]'

  kitty-remote() { cat <<<"$MOCK_KITTY_JSON"; }
  bats_mock kitty-remote
}

@test "prints the process basename of a window" {
  bats_run_zsh "kitty-window-process 11"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "claude" ]]
}

@test "finds a window in any tab" {
  bats_run_zsh "kitty-window-process 20"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "nvim" ]]
}

@test "exits 1 for an unknown window id" {
  bats_run_zsh "kitty-window-process 99"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "exits 2 with usage when no id given" {
  bats_run_zsh "kitty-window-process"
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"Usage"* ]]
}
