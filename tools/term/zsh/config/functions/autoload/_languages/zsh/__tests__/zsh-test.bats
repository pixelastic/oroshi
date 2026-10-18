bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  echo 'echo foo' > "$BATS_TMP_DIR/src/foo.zsh"
  echo '@test "foo" { true; }' > "$BATS_TMP_DIR/src/__tests__/foo.bats"
  echo 'echo bar' > "$BATS_TMP_DIR/src/bar.zsh"
  echo '@test "bar" { true; }' > "$BATS_TMP_DIR/src/__tests__/bar.bats"

  # Record each bats call, one argument per line, without the --jobs pair (its value is the CPU count)
  bats() {
    [[ "$1" == "--jobs" ]] && { print -r -- "$1" > "$BATS_TMP_DIR/jobs-flag.txt"; shift 2; }
    printf '%s\n' "$@" >> "$BATS_TMP_DIR/calls.txt"
  }
  bats_mock bats
}

# ─── RETURN EARLY ─────────────────────────────────────────────────────────────

@test "exits 0 with no arguments, without calling bats" {
  bats_run_zsh "zsh-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "exits 0 without calling bats when source has no test" {
  echo 'echo baz' > "$BATS_TMP_DIR/src/baz.zsh"

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/baz.zsh"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "exits 0 without calling bats when file is not ZSH" {
  echo 'console.log(1)' > "$BATS_TMP_DIR/src/foo.js"

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

# ─── RESOLUTION ───────────────────────────────────────────────────────────────

@test "runs the bats test of a ZSH source file" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs a bats file directly" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs a test once when both source and test file are given" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs all tests in a single bats call" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh $BATS_TMP_DIR/src/bar.zsh"
  [[ "$status" -eq 0 ]]
  local expected="$BATS_TMP_DIR/src/__tests__/foo.bats"$'\n'"$BATS_TMP_DIR/src/__tests__/bar.bats"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$expected" ]]
}

@test "runs bats with --jobs to parallelize the test files" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/jobs-flag.txt")" = "--jobs" ]]
}

# ─── DIRECTORY ────────────────────────────────────────────────────────────────

@test "expands a directory and runs every resolved test once" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/"
  [[ "$status" -eq 0 ]]
  local calls="$(sort "$BATS_TMP_DIR/calls.txt")"
  local expected="$BATS_TMP_DIR/src/__tests__/bar.bats"$'\n'"$BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$calls" = "$expected" ]]
}

# ─── EXIT CODE ────────────────────────────────────────────────────────────────

@test "exits non-zero when bats fails" {
  bats() { return 1; }
  bats_mock bats

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -ne 0 ]]
}

# ─── FAIL FAST ────────────────────────────────────────────────────────────────

# Drop the bats mock from setup, so the real bats runs
use_real_bats() {
  rm -f "$MOCK_OVERRIDE"
}

# Write a bats file holding two failing tests
write_failing_tests() {
  cat > "$BATS_TMP_DIR/src/__tests__/failing.bats" <<'BATS'
@test "first failure" { false; }
@test "second failure" { false; }
BATS
}

@test "reports every failure without --fail-fast" {
  use_real_bats
  write_failing_tests

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/failing.bats"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"first failure"* ]]
  [[ "$output" == *"second failure"* ]]
}

@test "reports only the first failure with --fail-fast" {
  use_real_bats
  write_failing_tests

  bats_run_zsh "zsh-test --fail-fast $BATS_TMP_DIR/src/__tests__/failing.bats"
  [[ "$output" == *"first failure"* ]]
  [[ "$output" != *"second failure"* ]]
}

@test "exits non-zero with --fail-fast when a test fails" {
  use_real_bats
  write_failing_tests

  bats_run_zsh "zsh-test --fail-fast $BATS_TMP_DIR/src/__tests__/failing.bats"
  [[ "$status" -ne 0 ]]
}

@test "exits zero with --fail-fast when all tests pass" {
  use_real_bats

  bats_run_zsh "zsh-test --fail-fast $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
}

# ─── TOKEN SAVING ─────────────────────────────────────────────────────────────

@test "--token-saving hides passing tests" {
  bats() {
    printf '%s\n' '1..2' 'ok 1 foo' 'not ok 2 bar' '# (in test file bar.bats, line 3)'
    return 1
  }
  bats_mock bats

  bats_run_zsh "zsh-test --token-saving $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$output" != *"ok 1 foo"* ]]
  [[ "$output" != *"1..2"* ]]
}

@test "--token-saving shows failing test names and their error output" {
  bats() {
    printf '%s\n' '1..2' 'ok 1 foo' 'not ok 2 bar'
    printf '%s\n' '# (in test file bar.bats, line 3)' "#   \`false' failed"
    return 1
  }
  bats_mock bats

  bats_run_zsh "zsh-test --token-saving $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$output" == *"not ok 2 bar"* ]]
  [[ "$output" == *"# (in test file bar.bats, line 3)"* ]]
  [[ "$output" == *"failed"* ]]
}

@test "--token-saving prints All tests passed. when every test passes" {
  bats() { printf '%s\n' '1..2' 'ok 1 foo' 'ok 2 bar'; }
  bats_mock bats

  bats_run_zsh "zsh-test --token-saving $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "All tests passed." ]]
}

@test "--token-saving exits non-zero when a test fails" {
  bats() {
    printf '%s\n' '1..1' 'not ok 1 foo'
    return 1
  }
  bats_mock bats

  bats_run_zsh "zsh-test --token-saving $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -ne 0 ]]
}

@test "--token-saving still resolves source files to their tests" {
  bats() {
    printf '%s\n' "$@" >> "$BATS_TMP_DIR/calls.txt"
    printf '%s\n' '1..1' 'ok 1 foo'
  }
  bats_mock bats

  bats_run_zsh "zsh-test --token-saving $BATS_TMP_DIR/src/foo.zsh"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = *"$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "prints the full bats output without --token-saving" {
  bats() { printf '%s\n' '1..2' 'ok 1 foo' 'ok 2 bar'; }
  bats_mock bats

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$output" == *"ok 1 foo"* ]]
  [[ "$output" == *"1..2"* ]]
}
