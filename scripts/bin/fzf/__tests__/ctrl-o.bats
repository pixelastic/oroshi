bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git repo so fd respects .gitignore
  git -C "$BATS_TMP_DIR" init --quiet
  mkdir -p "$BATS_TMP_DIR/subdir"
  mkdir -p "$BATS_TMP_DIR/ignored-dir"
  touch "$BATS_TMP_DIR/file.txt"
  printf 'ignored-dir/\n' > "$BATS_TMP_DIR/.gitignore"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: lists directories under git root" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-o --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"subdir"* ]]
}

@test "fzf-source: does not include the .git directory" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-o --source"
  [ "$status" -eq 0 ]
  [[ "$output" != *"/.git"* ]]
}

@test "fzf-source: respects .gitignore exclusions" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-o --source"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ignored-dir"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from two-column selection" {
  bats_run_zsh "printf '/tmp/test/subdir▮subdir\n' | ctrl-o --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/test/subdir" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-o --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
