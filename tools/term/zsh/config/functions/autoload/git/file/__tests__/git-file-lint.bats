bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
}

teardown() {
  bats_cleanup
}

# ─── RETURN EARLY ─────────────────────────────────────────────────────────────

@test "exits 0 when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits 0 when all dirty files are deleted" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  rm "$BATS_GIT_DIR/script.zsh"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── BATS ─────────────────────────────────────────────────────────────────────

@test "exits 0 when is-bats true and bats-lint has no errors" {
  echo 'content' > "$BATS_GIT_DIR/test.bats"
  bats_git add test.bats
  bats_git commit --quiet -m "add test.bats"
  echo 'changed' >> "$BATS_GIT_DIR/test.bats"

  is-bats() { return 0; }
  bats-lint() { printf '[]'; }
  bats_mock is-bats bats-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "shows BATS header, errors and relative paths when is-bats true and bats-lint has errors" {
  echo 'content' > "$BATS_GIT_DIR/test.bats"
  bats_git add test.bats
  bats_git commit --quiet -m "add test.bats"
  echo 'changed' >> "$BATS_GIT_DIR/test.bats"

  is-bats() { return 0; }
  bats-lint() {
    printf '[{"file":"%s","line":1,"column":1,"code":"noRunZsh","message":"use bats_run_zsh"}]' \
      "$1"
  }
  bats_mock is-bats bats-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── BATS ──" ]]
  [[ "$output" =~ test.bats:1:1:\ noRunZsh: ]]
  [[ ! "$output" =~ $BATS_GIT_DIR ]]
}

@test "exits 0 when is-bats is false for all dirty files" {
  echo 'content' > "$BATS_GIT_DIR/test.bats"
  bats_git add test.bats
  bats_git commit --quiet -m "add test.bats"
  echo 'changed' >> "$BATS_GIT_DIR/test.bats"

  is-bats() { return 1; }
  bats_mock is-bats

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── ZSH ──────────────────────────────────────────────────────────────────────

@test "exits 0 when is-zsh true and zsh-lint has no errors" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  is-zsh() { return 0; }
  zsh-lint() { printf '[]'; }
  bats_mock is-zsh zsh-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "shows ZSH header, errors and relative paths when is-zsh true and zsh-lint has errors" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  is-zsh() { return 0; }
  zsh-lint() {
    printf '[{"file":"%s","line":2,"column":1,"code":"noGroupedLocals","message":"group locals"}]' \
      "$1"
  }
  bats_mock is-zsh zsh-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── ZSH ──" ]]
  [[ "$output" =~ script.zsh:2:1:\ noGroupedLocals: ]]
  [[ ! "$output" =~ $BATS_GIT_DIR ]]
}

@test "exits 0 when is-zsh is false for all dirty files" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  is-zsh() { return 1; }
  bats_mock is-zsh

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── JS ───────────────────────────────────────────────────────────────────────

@test "exits 0 when is-js true and lint:fix has no output" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  is-js() { return 0; }
  yarn() { printf ''; }
  bats_mock is-js yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "shows JS header and errors when is-js true and lint:fix has output" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  is-js() { return 0; }
  yarn() {
    printf 'script.js:1:1: no-unused-vars: x is defined but never used\n';
    return 1;
  }
  bats_mock is-js yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── JS ──" ]]
  [[ "$output" =~ script.js ]]
}

@test "exits 0 when is-js is false for all dirty files" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  is-js() { return 1; }
  bats_mock is-js

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── ALL ──────────────────────────────────────────────────────────────────────

@test "shows both headers when both zsh and bats have errors" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  echo 'content' > "$BATS_GIT_DIR/test.bats"
  bats_git add script.zsh test.bats
  bats_git commit --quiet -m "add files"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/test.bats"

  is-zsh() { [[ "$1" == *.zsh ]]; }
  is-bats() { [[ "$1" == *.bats ]]; }
  zsh-lint() {
    printf '[{"file":"%s","line":1,"column":1,"code":"noGroupedLocals","message":"group locals"}]' \
      "$1"
  }
  bats-lint() {
    printf '[{"file":"%s","line":1,"column":1,"code":"noRunZsh","message":"use bats_run_zsh"}]' \
      "$1"
  }
  bats_mock is-zsh is-bats zsh-lint bats-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── ZSH ──" ]]
  [[ "$output" =~ "── BATS ──" ]]
}

@test "exits 0 when both zsh and bats have no errors" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  echo 'content' > "$BATS_GIT_DIR/test.bats"
  bats_git add script.zsh test.bats
  bats_git commit --quiet -m "add files"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/test.bats"

  is-zsh() { [[ "$1" == *.zsh ]]; }
  is-bats() { [[ "$1" == *.bats ]]; }
  zsh-lint() { printf '[]'; }
  bats-lint() { printf '[]'; }
  bats_mock is-zsh is-bats zsh-lint bats-lint

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-lint"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
