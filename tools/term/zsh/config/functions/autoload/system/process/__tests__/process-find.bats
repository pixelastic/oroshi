bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns PIDs for a running process name" {
  pgrep() {
    echo "100"
    echo "200"
  }
  bats_mock pgrep

  bats_run_zsh "process-find myapp"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "100" ]]
  [[ "${lines[1]}" == "200" ]]
}

@test "returns 0 with no output when no processes match" {
  pgrep() { return 1; }
  bats_mock pgrep

  bats_run_zsh "process-find nonexistent"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when no name given" {
  bats_run_zsh "process-find"
  [[ "$status" -eq 1 ]]
}
