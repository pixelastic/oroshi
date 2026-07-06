bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits successfully" {
  bats_run_zsh "statusbar-clock"
  [[ "$status" -eq 0 ]]
}

@test "outputs a non-empty JSON array" {
  bats_run_zsh "statusbar-clock"
  echo "$output" | jq -e 'length > 0'
}

@test "output text contains time in HH:MM:SS format" {
  bats_run_zsh "statusbar-clock"
  local text
  text="$(echo "$output" | jq -r '.[0].text')"
  [[ "$text" =~ [0-9]{2}:[0-9]{2}:[0-9]{2} ]]
}
