bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  # git repo with tracked and untracked files
  git -C "$BATS_TMP_DIR" init --quiet
  mkdir -p "$BATS_TMP_DIR/src/deep"
  touch "$BATS_TMP_DIR/README.md"
  touch "$BATS_TMP_DIR/src/app.js"
  touch "$BATS_TMP_DIR/src/deep/nested.js"
  touch "$BATS_TMP_DIR/ignored.log"
  printf 'ignored.log\n' > "$BATS_TMP_DIR/.gitignore"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: outputs tracked and untracked files from git root" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"README.md"* ]]
  [[ "$output" == *"app.js"* ]]
  [[ "$output" == *"nested.js"* ]]
}

@test "fzf-source: respects .gitignore exclusions" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ignored.log"* ]]
}

@test "fzf-source: outputs two-column lines with ▮ separator" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"▮"* ]]
}

@test "fzf-source: first column is absolute path" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  local firstCol="${lines[0]%%▮*}"
  [[ "$firstCol" == "$BATS_TMP_DIR/"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from selection" {
  bats_run_zsh "printf '/tmp/project/src/app.js▮src/app.js\n' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/src/app.js" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles paths with spaces" {
  bats_run_zsh "printf '/tmp/my project/my file.js▮my file.js\n' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/my project/my file.js" ]
}
