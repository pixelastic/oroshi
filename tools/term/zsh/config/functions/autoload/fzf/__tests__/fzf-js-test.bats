bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock git-directory-root to return a known path
  git-directory-root() { echo "/project"; }
  fd() { printf '__tests__/my-test.js\n'; }
  bats_mock git-directory-root fd
}

# fzf-source

@test "--source: first field is the absolute filepath" {
  bats_run_zsh "fzf-js-test --source"
  [[ "$status" -eq 0 ]]
  local firstField="${output%%▮*}"
  [[ "$firstField" = "/project/__tests__/my-test.js" ]]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-js-test --source"
  [[ "$status" -eq 0 ]]
  local secondField="${output##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: outputs nothing when no test files exist" {
  fd() { echo ""; }
  bats_mock fd
  bats_run_zsh "fzf-js-test --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
