bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Marks present
@test "outputs colored content when marks exist" {
  # Mock mark-list-raw to return two entries
  mark-list-raw() {
    echo "alpha▮/tmp/targets/projectA"
    echo "beta▮/tmp/targets/projectB"
  }
  bats_mock mark-list-raw

  bats_run_zsh "mark-list"
  [[ "$status" -eq 0 ]]
  # Output should contain ANSI escape codes (colorized)
  [[ "$output" == *$'\e['* ]]
}

# No marks
@test "outputs nothing and exits 0 when no marks exist" {
  # Mock mark-list-raw to return empty
  mark-list-raw() { :; }
  bats_mock mark-list-raw

  bats_run_zsh "mark-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
