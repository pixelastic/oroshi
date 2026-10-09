bats_load_library 'helper'

setup() {
  # src/ holds foo.py and bar.py, each with a passing test in src/__tests__/
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  printf 'def test_foo():\n    assert True\n' > "$BATS_TMP_DIR/src/__tests__/test_foo.py"
  printf 'def test_bar():\n    assert True\n' > "$BATS_TMP_DIR/src/__tests__/test_bar.py"
  touch "$BATS_TMP_DIR/src/foo.py"
  touch "$BATS_TMP_DIR/src/bar.py"
}

@test "test file: runs it" {
  bats_run_zsh "python-test $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"test_foo"* ]]
  [[ "$output" != *"test_bar"* ]]
}

@test "source file: runs its test file" {
  bats_run_zsh "python-test $BATS_TMP_DIR/src/foo.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"test_foo"* ]]
  [[ "$output" != *"test_bar"* ]]
}

@test "directory: runs every test below it" {
  bats_run_zsh "python-test $BATS_TMP_DIR/src"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"test_foo"* ]]
  [[ "$output" == *"test_bar"* ]]
}

@test "source and test file together: runs the test once" {
  bats_run_zsh "python-test $BATS_TMP_DIR/src/foo.py $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
  local count="$(grep --only-matching 'test_foo' <<<"$output" | wc --lines)"
  [[ "$count" -eq 1 ]]
}

@test "failing test: exits non-zero, output on stdout" {
  printf 'def test_bad():\n    assert False\n' > "$BATS_TMP_DIR/src/__tests__/test_foo.py"

  bats_run_zsh "python-test $BATS_TMP_DIR/src/foo.py 2>/dev/null"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"test_bad"* ]]
}

@test "no argument: exits 0, no output, does not run pytest" {
  pytest() { echo "pytest $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock pytest

  bats_run_zsh "python-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "source file without test file: exits 0, no output, does not run pytest" {
  touch "$BATS_TMP_DIR/src/baz.py"
  pytest() { echo "pytest $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock pytest

  bats_run_zsh "python-test $BATS_TMP_DIR/src/baz.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "non-Python file: skipped" {
  printf 'hello\n' > "$BATS_TMP_DIR/notes.txt"
  pytest() { echo "pytest $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock pytest

  bats_run_zsh "python-test $BATS_TMP_DIR/notes.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

# ─── FAIL FAST ────────────────────────────────────────────────────────────────

# Write a test file holding two failing tests
write_failing_tests() {
  printf 'def test_first_failure():\n    assert False\n\ndef test_second_failure():\n    assert False\n' > "$BATS_TMP_DIR/src/__tests__/test_failing.py"
}

@test "reports every failure without --fail-fast" {
  write_failing_tests

  bats_run_zsh "python-test $BATS_TMP_DIR/src/__tests__/test_failing.py"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"test_first_failure"* ]]
  [[ "$output" == *"test_second_failure"* ]]
}

@test "reports only the first failure with --fail-fast" {
  write_failing_tests

  bats_run_zsh "python-test --fail-fast $BATS_TMP_DIR/src/__tests__/test_failing.py"
  [[ "$output" == *"test_first_failure"* ]]
  [[ "$output" != *"test_second_failure"* ]]
}

@test "exits non-zero with --fail-fast when a test fails" {
  write_failing_tests

  bats_run_zsh "python-test --fail-fast $BATS_TMP_DIR/src/__tests__/test_failing.py"
  [[ "$status" -ne 0 ]]
}

@test "exits zero with --fail-fast when all tests pass" {
  bats_run_zsh "python-test --fail-fast $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
}

# ─── TOKEN SAVING ─────────────────────────────────────────────────────────────

# Write a test file holding one passing and one failing test
write_mixed_tests() {
  printf 'def test_passing_one():\n    assert True\n\ndef test_broken_one():\n    assert 1 == 2\n' > "$BATS_TMP_DIR/src/__tests__/test_mixed.py"
}

@test "--token-saving hides passing tests" {
  write_mixed_tests

  bats_run_zsh "python-test --token-saving $BATS_TMP_DIR/src/__tests__/test_mixed.py"
  [[ "$output" != *"Passing one"* ]]
  [[ "$output" != *"PASSED"* ]]
  [[ "$output" != *"1 passed"* ]]
}

@test "--token-saving shows failing test names and their tracebacks" {
  write_mixed_tests

  bats_run_zsh "python-test --token-saving $BATS_TMP_DIR/src/__tests__/test_mixed.py"
  [[ "$output" == *"test_broken_one"* ]]
  [[ "$output" == *"assert 1 == 2"* ]]
}

@test "--token-saving drops the session header and progress lines" {
  write_mixed_tests

  bats_run_zsh "python-test --token-saving $BATS_TMP_DIR/src/__tests__/test_mixed.py"
  [[ "$output" != *"test session starts"* ]]
  [[ "$output" != *"rootdir"* ]]
  [[ "$output" != *"[100%]"* ]]
}

@test "--token-saving prints All tests passed. when every test passes" {
  bats_run_zsh "python-test --token-saving $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "All tests passed." ]]
}

@test "--token-saving exits non-zero when a test fails" {
  write_mixed_tests

  bats_run_zsh "python-test --token-saving $BATS_TMP_DIR/src/__tests__/test_mixed.py"
  [[ "$status" -ne 0 ]]
  [[ "$output" != *"All tests passed."* ]]
}

@test "--token-saving works with --fail-fast" {
  write_failing_tests

  bats_run_zsh "python-test --token-saving --fail-fast $BATS_TMP_DIR/src/__tests__/test_failing.py"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"test_first_failure"* ]]
  [[ "$output" != *"test_second_failure"* ]]
}

@test "without --token-saving prints passing tests" {
  write_mixed_tests

  bats_run_zsh "python-test $BATS_TMP_DIR/src/__tests__/test_mixed.py"
  [[ "$output" == *"Passing one"* ]]
  [[ "$output" == *"Broken one"* ]]
}
