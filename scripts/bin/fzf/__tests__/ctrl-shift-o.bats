bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git repo so fd respects .gitignore
  git -C "$BATS_TMP_DIR" init --quiet
  mkdir -p "$BATS_TMP_DIR/subdir"
  mkdir -p "$BATS_TMP_DIR/ignored-dir"
  touch "$BATS_TMP_DIR/file.txt"
  touch "$BATS_TMP_DIR/subdir/nested.txt"
  printf 'ignored-dir/\n' > "$BATS_TMP_DIR/.gitignore"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: lists subdirectories under current directory" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-o --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"subdir"* ]]
}

@test "fzf-source: respects .gitignore exclusions" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-o --source"
  [[ "$output" != *"ignored-dir"* ]]
}

@test "fzf-source: does not include files" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-shift-o --source"
  [ "$status" -eq 0 ]
  local line
  for line in "${lines[@]}"; do
    local abspath="${line%%▮*}"
    [ ! -f "$abspath" ]
  done
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from two-column selection" {
  bats_run_zsh "printf '/tmp/test/subdir▮subdir\n' | ctrl-shift-o --postprocess"
  [ "$output" = "/tmp/test/subdir" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-shift-o --postprocess"
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles paths with spaces" {
  bats_run_zsh "printf '/tmp/my dir▮my dir\n' | ctrl-shift-o --postprocess"
  [ "$output" = "/tmp/my dir" ]
}
