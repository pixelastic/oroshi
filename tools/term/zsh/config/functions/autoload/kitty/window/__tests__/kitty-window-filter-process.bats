bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock JSON: tab 1 has zsh (id:10) and claude (id:11), tab 2 has nvim (id:20)
  export MOCK_KITTY_JSON='[{"tabs":[{"id":1,"windows":[{"id":10,"foreground_processes":[{"cmdline":["zsh"]}]},{"id":11,"foreground_processes":[{"cmdline":["/usr/bin/claude"]}]}]},{"id":2,"windows":[{"id":20,"foreground_processes":[{"cmdline":["nvim"]}]}]}]}]'

  kitty-remote() { cat <<<"$MOCK_KITTY_JSON"; }
  kitty-tab-id() { echo "1"; }
  bats_mock kitty-remote kitty-tab-id
}

@test "finds window by process name in current tab" {
  bats_run_zsh "kitty-window-filter-process claude"
  [[ "$status" -eq 0 ]]
  [[ "$output" -eq 11 ]]
}

@test "matches process by basename when path is absolute" {
  bats_run_zsh "kitty-window-filter-process claude"
  [[ "$status" -eq 0 ]]
  [[ "$output" -eq 11 ]]
}

@test "finds window in explicit tab via --tab" {
  bats_run_zsh "kitty-window-filter-process nvim --tab 2"
  [[ "$status" -eq 0 ]]
  [[ "$output" -eq 20 ]]
}

@test "exits 1 when process not found in tab" {
  bats_run_zsh "kitty-window-filter-process nvim --tab 1"
  [[ "$status" -eq 1 ]]
}

@test "exits 2 with usage when no process name given" {
  bats_run_zsh "kitty-window-filter-process"
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"Usage"* ]]
}
