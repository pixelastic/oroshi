bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
}

teardown() {
  bats_cleanup
}

# ─── RETURN EARLY ─────────────────────────────────────────────────────────────

@test "exits 0 when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits 0 when all dirty files are deleted" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  rm "$BATS_GIT_DIR/script.zsh"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── BATS ─────────────────────────────────────────────────────────────────────

@test "exits 0 when dirty file has a test and bats passes" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  bats-test-path() { return 0; }
  bats() { return 0; }
  bats_mock bats-test-path bats

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
}

@test "exits non-zero when bats tests fail" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  bats-test-path() { echo "path"; }
  bats() { return 1; }
  bats_mock bats-test-path bats

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 1 ]
}

@test "exits 0 when no dirty file has an associated test" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  bats-test-path() { printf ''; }
  bats_mock bats-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── JS ───────────────────────────────────────────────────────────────────────

@test "exits 0 when is-js true and yarn test passes" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  bats-test-path() { printf ''; }
  yarn() { return 0; }
  bats_mock bats-test-path yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
}

@test "exits non-zero when is-js true and yarn test fails" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  bats-test-path() { printf ''; }
  yarn() { return 1; }
  bats_mock bats-test-path yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 1 ]
}

@test "exits 0 when is-js false for all dirty files" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  is-js() { return 1; }
  bats-test-path() { printf ''; }
  bats_mock is-js bats-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# ─── COMBINED ─────────────────────────────────────────────────────────────────

@test "runs both yarn and bats when both types are dirty" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.js script.zsh
  bats_git commit --quiet -m "add files"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  bats-test-path() { echo "path"; }
  yarn() { return 0; }
  bats() { return 0; }
  bats_mock bats-test-path yarn bats

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [ "$status" -eq 0 ]
}
