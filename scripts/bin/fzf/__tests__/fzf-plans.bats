bats_load_library 'helper'

setup() {
  bats_git_dir
  mkdir -p "$BATS_GIT_DIR/plans/my-plan"
  mkdir -p "$BATS_GIT_DIR/plans/other-plan"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: lists plan subdirectories in absolute_path▮name format" {
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-plans --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"▮"*"my-plan"* ]]
  [[ "$output" == *"▮"*"other-plan"* ]]
}

@test "fzf-source: second field is ANSI-colored and ends with /" {
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-plans --source"
  [ "$status" -eq 0 ]
  local line="${lines[0]}"
  local secondField="${line##*▮}"
  [[ "$secondField" == *$'\e['* ]]
  [[ "$secondField" == *"/"* ]]
}

@test "fzf-source: first field is a plain absolute path" {
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-plans --source"
  [ "$status" -eq 0 ]
  local line="${lines[0]}"
  local firstField="${line%%▮*}"
  [[ "$firstField" != *$'\e['* ]]
  [[ "$firstField" == "/"* ]]
}

@test "fzf-source: outputs nothing when no plans directory" {
  rm -rf "$BATS_GIT_DIR/plans"
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-plans --source"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from selection" {
  bats_run_zsh "printf '/abs/plans/my-plan▮my-plan\n' | fzf-plans --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/abs/plans/my-plan" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | fzf-plans --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
