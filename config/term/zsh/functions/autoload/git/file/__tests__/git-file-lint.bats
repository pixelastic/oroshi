bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  cd "$BATS_GIT_DIR"
}

teardown() {
  bats_cleanup
}

@test "shows formatted violations for a dirty ZSH file" {
  echo 'echo hello' > "$BATS_GIT_DIR/bad.zsh"
  bats_git add bad.zsh
  bats_git commit --quiet -m "add bad.zsh"
  echo 'local a b c' >> "$BATS_GIT_DIR/bad.zsh"

  bats_run_function git-file-lint
  [ "$status" -eq 1 ]
  [[ "$output" =~ "bad.zsh" ]]
  [[ "$output" =~ ": noGroupedLocals: " ]]
  [[ ! "$output" =~ "\"level\"" ]]
  [[ ! "$output" =~ ": warning" ]]
  [[ ! "$output" =~ ": error" ]]
}

@test "exits silently for a dirty ZSH file with no violations" {
  echo 'echo hello' > "$BATS_GIT_DIR/clean.zsh"
  bats_git add clean.zsh
  bats_git commit --quiet -m "add clean.zsh"
  echo 'echo world' >> "$BATS_GIT_DIR/clean.zsh"

  bats_run_function git-file-lint
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits silently when only non-ZSH files are dirty" {
  echo 'console.log("hello")' > "$BATS_GIT_DIR/app.js"
  bats_git add app.js
  bats_git commit --quiet -m "add app.js"
  echo 'console.log("world")' >> "$BATS_GIT_DIR/app.js"

  bats_run_function git-file-lint
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits 0 on a clean working tree" {
  bats_run_function git-file-lint
  [ "$status" -eq 0 ]
}

@test "shows relative path, not absolute path" {
  echo 'echo hello' > "$BATS_GIT_DIR/bad.zsh"
  bats_git add bad.zsh
  bats_git commit --quiet -m "add bad.zsh"
  echo 'local a b c' >> "$BATS_GIT_DIR/bad.zsh"

  bats_run_function git-file-lint
  [ "$status" -eq 1 ]
  [[ "$output" =~ "bad.zsh" ]]
  [[ ! "$output" =~ "$BATS_GIT_DIR" ]]
}

@test "skips deleted ZSH files without error" {
  echo 'echo hello' > "$BATS_GIT_DIR/todelete.zsh"
  bats_git add todelete.zsh
  bats_git commit --quiet -m "add todelete.zsh"
  rm "$BATS_GIT_DIR/todelete.zsh"

  bats_run_function git-file-lint
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
