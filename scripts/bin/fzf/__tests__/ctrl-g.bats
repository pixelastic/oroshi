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

@test "fzf-source: emits a file header line (empty first column) before matches" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  # Header line: ▮colored_filepath (column 1 is empty, column 2 is the filename)
  [[ "${lines[0]}" == "▮"* ]]
}

@test "fzf-source: match lines have file:line:col before ▮" {
  bats_run_zsh "cd $BATS_GIT_DIR && ctrl-g --source hello"
  [ "$status" -eq 0 ]
  # Second line is the match — column 1 must be non-empty and contain ':'
  [[ "${lines[1]}" == *":"*":"*"▮"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: extracts file:line:col from match line" {
  bats_run_zsh "printf '/tmp/project/app.js:42:1▮  content\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/app.js:42:1" ]
}

@test "fzf-postprocess: skips file header lines (empty first column)" {
  bats_run_zsh "printf '▮/tmp/project/app.js\n/tmp/project/app.js:42:1▮  match\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/app.js:42:1" ]
}

@test "fzf-postprocess: handles multiple match lines" {
  bats_run_zsh "printf '/tmp/a.js:1:1▮  foo\n/tmp/b.js:2:3▮  bar\n' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "/tmp/a.js:1:1" ]
  [ "${lines[1]}" = "/tmp/b.js:2:3" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
