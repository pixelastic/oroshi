bats_load_library 'helper'

setup() {
  bats_git_dir
  bats_disable_worktree_aware

  # git repo with a file containing known content
  printf 'hello world\nfoo bar\n' > "$BATS_GIT_DIR/sample.txt"
}

# fzf-source

@test "fzf-source: outputs nothing when called with no query" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "fzf-source: outputs matches when a query is passed" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello"* ]]
}

@test "fzf-source: output includes the filename" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sample.txt"* ]]
}

@test "fzf-source: emits a file header line as filepath▮1▮display" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  # Header: filepath▮1▮<colored relpath>
  [[ "${lines[0]}" == *"▮1▮"* ]]
  [[ "${lines[0]}" == *"sample.txt"* ]]
}

@test "fzf-source: match lines have filepath▮line▮content format" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  # Second line is the match — three ▮-separated fields
  [[ "${lines[1]}" == *"▮"*"▮"* ]]
  [[ "${lines[1]}" == *"hello"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: extracts file:line from match line" {
  bats_run_zsh "printf '/tmp/project/app.js▮42▮  content\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/app.js:42" ]
}

@test "fzf-postprocess: header line navigates to file:1" {
  bats_run_zsh "printf '/tmp/project/app.js▮1▮src/app.js\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/app.js:1" ]
}

@test "fzf-postprocess: handles multiple lines" {
  bats_run_zsh "printf '/tmp/a.js▮1▮  foo\n/tmp/b.js▮2▮  bar\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "/tmp/a.js:1" ]
  [ "${lines[1]}" = "/tmp/b.js:2" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# fzf-source (fold mode)

@test "fzf-source: fold-mode=on shows no context lines" {
  printf 'line1\nline2\nmatch\nline4\nline5\n' > "$BATS_GIT_DIR/ctx-sample.txt"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  bats_mock_env "KITTY_WINDOW_ID" "test-window"
  mkdir -p "$BATS_TMP_DIR/fzf/var/test-window"
  echo "on" > "$BATS_TMP_DIR/fzf/var/test-window/regexp-fold-mode"

  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source match"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "fzf-source: fold-mode=off shows 2 lines of context around matches" {
  printf 'line1\nline2\nmatch\nline4\nline5\n' > "$BATS_GIT_DIR/ctx-sample.txt"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  bats_mock_env "KITTY_WINDOW_ID" "test-window"
  mkdir -p "$BATS_TMP_DIR/fzf/var/test-window"
  echo "off" > "$BATS_TMP_DIR/fzf/var/test-window/regexp-fold-mode"

  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source match"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 6 ]
}

@test "fzf-source: fold-mode=on inserts blank line between different files" {
  printf 'match\n' > "$BATS_GIT_DIR/file-a.txt"
  printf 'match\n' > "$BATS_GIT_DIR/file-b.txt"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  bats_mock_env "KITTY_WINDOW_ID" "test-window"
  mkdir -p "$BATS_TMP_DIR/fzf/var/test-window"
  echo "on" > "$BATS_TMP_DIR/fzf/var/test-window/regexp-fold-mode"

  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source match"
  [ "$status" -eq 0 ]
  # header-A + match-A + blank + header-B + match-B = 5
  [ "${#lines[@]}" -eq 5 ]
}
