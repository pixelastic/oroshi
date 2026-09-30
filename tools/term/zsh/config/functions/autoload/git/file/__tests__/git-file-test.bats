bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  # Keep mocks active when cd-ing into the temp repo
  bats_disable_worktree_aware
}

# ─── RETURN EARLY ─────────────────────────────────────────────────────────────

@test "exits 0 when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "exits 0 when all dirty files are deleted" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  rm "$BATS_GIT_DIR/script.zsh"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# ─── ZSH ──────────────────────────────────────────────────────────────────────

@test "exits 0 when dirty ZSH file has a test and zsh-test passes" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { echo "$BATS_GIT_DIR/__tests__/script.bats"; }
  zsh-test() { return 0; }
  bats_mock zsh-test-path zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

@test "exits non-zero when zsh-test fails" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { echo "$BATS_GIT_DIR/__tests__/script.bats"; }
  zsh-test() { return 1; }
  bats_mock zsh-test-path zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 1 ]]
}

@test "passes dirty ZSH source files to zsh-test" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { echo "$BATS_GIT_DIR/__tests__/script.bats"; }
  zsh-test() { echo "$@" > "$BATS_TMP_DIR/zsh-test-calls.txt"; }
  bats_mock zsh-test-path zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/zsh-test-calls.txt")" = "$BATS_GIT_DIR/script.zsh" ]]
}

@test "passes dirty bats files to zsh-test" {
  mkdir -p "$BATS_GIT_DIR/__tests__"
  echo '@test "ok" { true; }' > "$BATS_GIT_DIR/__tests__/script.bats"
  bats_git add __tests__/script.bats
  bats_git commit --quiet -m "add script.bats"
  echo '# changed' >> "$BATS_GIT_DIR/__tests__/script.bats"

  zsh-test() { echo "$@" > "$BATS_TMP_DIR/zsh-test-calls.txt"; }
  bats_mock zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/zsh-test-calls.txt")" = "$BATS_GIT_DIR/__tests__/script.bats" ]]
}

@test "does not call zsh-test for non-ZSH files" {
  echo 'content' > "$BATS_GIT_DIR/README.md"
  bats_git add README.md
  bats_git commit --quiet -m "add README.md"
  echo 'changed' >> "$BATS_GIT_DIR/README.md"

  zsh-test-path() { echo "$BATS_GIT_DIR/__tests__/README.bats"; }
  zsh-test() { return 1; }
  bats_mock zsh-test-path zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 when no dirty ZSH file has an associated test" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { printf ''; }
  zsh-test() { return 1; }
  bats_mock zsh-test-path zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# ─── JS ───────────────────────────────────────────────────────────────────────

@test "exits 0 when is-js true and yarn test passes" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  zsh-test-path() { printf ''; }
  yarn() { return 0; }
  bats_mock zsh-test-path yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

@test "exits non-zero when is-js true and yarn test fails" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  zsh-test-path() { printf ''; }
  yarn() { return 1; }
  bats_mock zsh-test-path yarn

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when is-js false for all dirty files" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  bats_git add script.js
  bats_git commit --quiet -m "add script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"

  is-js() { return 1; }
  zsh-test-path() { printf ''; }
  bats_mock is-js zsh-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# ─── PYTHON ───────────────────────────────────────────────────────────────────

@test "exits 0 when python source has a matching test and python-test passes" {
  echo 'x = 1' > "$BATS_GIT_DIR/module.py"
  bats_git add module.py
  bats_git commit --quiet -m "add module.py"
  echo 'changed' >> "$BATS_GIT_DIR/module.py"

  zsh-test-path() { printf ''; }
  python-test-path() { echo "$BATS_GIT_DIR/__tests__/test_module.py"; }
  python-test() { return 0; }
  bats_mock zsh-test-path python-test-path python-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 when python source has no matching test" {
  echo 'x = 1' > "$BATS_GIT_DIR/module.py"
  bats_git add module.py
  bats_git commit --quiet -m "add module.py"
  echo 'changed' >> "$BATS_GIT_DIR/module.py"

  zsh-test-path() { printf ''; }
  python-test-path() { printf ''; }
  bats_mock zsh-test-path python-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "exits non-zero when python-test fails" {
  echo 'x = 1' > "$BATS_GIT_DIR/module.py"
  bats_git add module.py
  bats_git commit --quiet -m "add module.py"
  echo 'changed' >> "$BATS_GIT_DIR/module.py"

  zsh-test-path() { printf ''; }
  python-test-path() { echo "$BATS_GIT_DIR/__tests__/test_module.py"; }
  python-test() { return 1; }
  bats_mock zsh-test-path python-test-path python-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 and python-test is not called when only non-Python files are dirty" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { printf ''; }
  python-test() { return 1; }
  bats_mock zsh-test-path python-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

# ─── COMBINED ─────────────────────────────────────────────────────────────────

@test "runs both yarn and zsh-test when both types are dirty" {
  echo 'const x = 1' > "$BATS_GIT_DIR/script.js"
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.js script.zsh
  bats_git commit --quiet -m "add files"
  echo 'changed' >> "$BATS_GIT_DIR/script.js"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { echo "path"; }
  yarn() { echo "yarn" >> "$BATS_TMP_DIR/calls.txt"; }
  zsh-test() { echo "zsh-test" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock zsh-test-path yarn zsh-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'yarn\nzsh-test' ]]
}

# ─── CLAUDE CONTEXT ──────────────────────────────────────────────────────────

@test "calls zsh-test directly with no rtk prefix even when CLAUDECODE is set" {
  echo 'content' > "$BATS_GIT_DIR/script.zsh"
  bats_git add script.zsh
  bats_git commit --quiet -m "add script.zsh"
  echo 'changed' >> "$BATS_GIT_DIR/script.zsh"

  zsh-test-path() { echo "path"; }
  zsh-test() { echo "$@" > "$BATS_TMP_DIR/zsh-test-calls.txt"; }
  rtk() { touch "$BATS_TMP_DIR/rtk-called"; }
  bats_mock zsh-test-path zsh-test rtk

  bats_run_zsh "cd $BATS_GIT_DIR && CLAUDECODE=1 git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/zsh-test-calls.txt")" = "$BATS_GIT_DIR/script.zsh" ]]
  [[ ! -e "$BATS_TMP_DIR/rtk-called" ]]
}

# ─── GO ──────────────────────────────────────────────────────────────────────

@test "exits 0 when dirty .go file has tests and go-test passes" {
  echo 'package main' > "$BATS_GIT_DIR/main.go"
  bats_git add main.go
  bats_git commit --quiet -m "add main.go"
  echo 'changed' >> "$BATS_GIT_DIR/main.go"

  zsh-test-path() { printf ''; }
  go-test-path() { echo "$BATS_GIT_DIR/main_test.go"; }
  go-test() { return 0; }
  bats_mock zsh-test-path go-test-path go-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 when dirty .go file has no matching test" {
  echo 'package main' > "$BATS_GIT_DIR/main.go"
  bats_git add main.go
  bats_git commit --quiet -m "add main.go"
  echo 'changed' >> "$BATS_GIT_DIR/main.go"

  zsh-test-path() { printf ''; }
  go-test-path() { return 1; }
  bats_mock zsh-test-path go-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "exits non-zero when go-test fails" {
  echo 'package main' > "$BATS_GIT_DIR/main.go"
  bats_git add main.go
  bats_git commit --quiet -m "add main.go"
  echo 'changed' >> "$BATS_GIT_DIR/main.go"

  zsh-test-path() { printf ''; }
  go-test-path() { echo "$BATS_GIT_DIR/main_test.go"; }
  go-test() { return 1; }
  bats_mock zsh-test-path go-test-path go-test

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when is-go false for all dirty files" {
  echo 'package main' > "$BATS_GIT_DIR/main.go"
  bats_git add main.go
  bats_git commit --quiet -m "add main.go"
  echo 'changed' >> "$BATS_GIT_DIR/main.go"

  is-go() { return 1; }
  zsh-test-path() { printf ''; }
  bats_mock is-go zsh-test-path

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

