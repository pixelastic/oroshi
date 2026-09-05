bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock git-directory-root to return a known path
  git-directory-root() { echo "/project"; }
  fd() { printf 'assets/icon.svg\n'; }
  bats_mock git-directory-root fd
}

# fzf-source

@test "--source: first field is the absolute filepath" {
  bats_run_zsh "fzf-svg-files --source"
  [[ "$status" -eq 0 ]]
  local firstField="${output%%▮*}"
  [[ "$firstField" = "/project/assets/icon.svg" ]]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-svg-files --source"
  [[ "$status" -eq 0 ]]
  local secondField="${output##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: does not list non-svg files" {
  fd() { printf 'assets/icon.svg\n'; }
  bats_mock fd
  bats_run_zsh "fzf-svg-files --source"
  [[ "$status" -eq 0 ]]
  # Only svg files appear — fd mock only returns .svg
  [[ "$output" == *"icon.svg"* ]]
  [[ "$output" != *".json"* ]]
  [[ "$output" != *".go"* ]]
}

@test "--source: outputs nothing when no svg files exist" {
  fd() { echo ""; }
  bats_mock fd
  bats_run_zsh "fzf-svg-files --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
