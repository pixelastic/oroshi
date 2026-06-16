bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git repo so fd respects .gitignore
  git -C "$BATS_TMP_DIR" init --quiet
  mkdir -p "$BATS_TMP_DIR/subdir"
  touch "$BATS_TMP_DIR/file.txt"
  touch "$BATS_TMP_DIR/subdir/nested.txt"
  touch "$BATS_TMP_DIR/ignored.txt"
  printf 'ignored.txt\n' > "$BATS_TMP_DIR/.gitignore"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: lists files under current directory" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-p --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"file.txt"* ]]
  [[ "$output" == *"nested.txt"* ]]
}

@test "fzf-source: respects .gitignore exclusions" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-p --source"
  [[ "$output" != *"ignored.txt"* ]]
}

@test "fzf-source: does not include directories" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-p --source"
  [ "$status" -eq 0 ]
  local line
  for line in "${lines[@]}"; do
    local abspath="${line%%▮*}"
    [ ! -d "$abspath" ]
  done
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from two-column selection" {
  bats_run_zsh "printf '/tmp/test/file.txt▮file.txt\n' | ctrl-shift-p --postprocess"
  [ "$output" = "/tmp/test/file.txt" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-shift-p --postprocess"
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles paths with spaces" {
  bats_run_zsh "printf '/tmp/dir/my file.txt▮my file.txt\n' | ctrl-shift-p --postprocess"
  [ "$output" = "/tmp/dir/my file.txt" ]
}
