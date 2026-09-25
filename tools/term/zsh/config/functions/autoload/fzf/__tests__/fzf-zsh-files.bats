bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock git-directory-root to return a known path
  git-directory-root() { echo "/project"; }
  # .zsh files when searching by extension, autoload functions otherwise
  fd() {
    if [[ "$*" == *"--extension zsh"* ]]; then
      printf 'config/theming/icons.zsh\n'
      return 0
    fi
    printf 'config/functions/autoload/git/git-branch-list\n'
  }
  bats_mock git-directory-root fd
}

# fzf-source

@test "--source: first field is the absolute filepath" {
  bats_run_zsh "fzf-zsh-files --source"
  [[ "$status" -eq 0 ]]
  local firstField="${lines[0]%%▮*}"
  [[ "$firstField" == /project/* ]]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-zsh-files --source"
  [[ "$status" -eq 0 ]]
  local secondField="${lines[0]##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: lists both .zsh files and autoload functions" {
  bats_run_zsh "fzf-zsh-files --source"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "$output" == *"/project/config/theming/icons.zsh▮"* ]]
  [[ "$output" == *"/project/config/functions/autoload/git/git-branch-list▮"* ]]
}

@test "--source: searches autoload functions by full path" {
  fd() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/fd_args"
  }
  bats_mock fd
  bats_run_zsh "fzf-zsh-files --source"
  [[ "$status" -eq 0 ]]
  local arguments="$(cat "$BATS_TMP_DIR/fd_args")"
  [[ "$arguments" == *"--extension zsh"* ]]
  [[ "$arguments" == *"--full-path"* ]]
  [[ "$arguments" == *"functions/autoload"* ]]
}

@test "--source: outputs nothing when no zsh files exist" {
  fd() { :; }
  bats_mock fd
  bats_run_zsh "fzf-zsh-files --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
