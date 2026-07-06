bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats-test-list-raw() { printf 'my-test▮/path/to/my-test.bats\n'; }
  bats_mock bats-test-list-raw
}

# fzf-source

@test "--source: first field is the plain filepath" {
  bats_run_zsh "fzf-bats-test --source"
  [ "$status" -eq 0 ]
  local firstField="${output%%▮*}"
  [ "$firstField" = "/path/to/my-test.bats" ]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-bats-test --source"
  [ "$status" -eq 0 ]
  local secondField="${output##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: outputs nothing when no test files" {
  bats-test-list-raw() { echo ""; }
  bats_mock bats-test-list-raw
  bats_run_zsh "fzf-bats-test --source"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
