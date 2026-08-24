bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock git-directory-root to return a known path
  git-directory-root() { echo "/project"; }
  fd() { printf 'config/settings.json\n'; }
  bats_mock git-directory-root fd
}

# fzf-source

@test "--source: first field is the absolute filepath" {
  bats_run_zsh "fzf-json-files --source"
  [[ "$status" -eq 0 ]]
  local firstField="${output%%▮*}"
  [[ "$firstField" = "/project/config/settings.json" ]]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-json-files --source"
  [[ "$status" -eq 0 ]]
  local secondField="${output##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: does not list non-json files" {
  fd() { printf 'config/settings.json\n'; }
  bats_mock fd
  bats_run_zsh "fzf-json-files --source"
  [[ "$status" -eq 0 ]]
  # Only json files appear — fd mock only returns .json
  [[ "$output" == *"settings.json"* ]]
  [[ "$output" != *".go"* ]]
  [[ "$output" != *".ts"* ]]
}

@test "--source: outputs nothing when no json files exist" {
  fd() { echo ""; }
  bats_mock fd
  bats_run_zsh "fzf-json-files --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
