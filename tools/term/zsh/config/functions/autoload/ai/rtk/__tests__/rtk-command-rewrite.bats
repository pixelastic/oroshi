bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Native rewrite (RTK built-in) ---

@test "returns rtk git status for git status" {
  rtk() {
    [[ "$1" == "rewrite" ]] && echo "rtk git status" && return 0
  }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'git status'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk git status" ]]
}

@test "returns rtk git diff --stat for git diff --stat" {
  rtk() {
    [[ "$1" == "rewrite" ]] && echo "rtk git diff --stat" && return 0
  }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'git diff --stat'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk git diff --stat" ]]
}

# --- Filter-backed rewrite (bin-zsh) ---

@test "returns rtk bin-zsh bats foo.bats for bats foo.bats" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'bats foo.bats'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk bin-zsh bats foo.bats" ]]
}

@test "returns rtk bin-zsh yarn run test foo.js for yarn run test foo.js" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'yarn run test foo.js'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk bin-zsh yarn run test foo.js" ]]
}

@test "returns rtk bin-zsh python-test foo.py for python-test foo.py" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'python-test foo.py'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk bin-zsh python-test foo.py" ]]
}

@test "returns rtk bin-zsh go-test foo_test.go for go-test foo_test.go" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'go-test foo_test.go'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk bin-zsh go-test foo_test.go" ]]
}

# --- Pass-through ---

@test "returns echo hello unchanged for echo hello" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'echo hello'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "echo hello" ]]
}

@test "returns yarn install unchanged for yarn install" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'yarn install'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "yarn install" ]]
}

# --- Idempotency ---

@test "returns rtk git status unchanged for rtk git status" {
  rtk() {
    echo "should not be called" >&2
    return 1
  }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'rtk git status'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rtk git status" ]]
}

# --- No false positives ---

@test "returns bats-lint foo.bats unchanged for bats-lint foo.bats" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'bats-lint foo.bats'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "bats-lint foo.bats" ]]
}

@test "returns python-test-something unchanged for python-test-something" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'python-test-something'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "python-test-something" ]]
}

@test "returns go-test-something unchanged for go-test-something" {
  rtk() { return 1; }
  bats_mock rtk

  bats_run_zsh "rtk-command-rewrite 'go-test-something'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "go-test-something" ]]
}
