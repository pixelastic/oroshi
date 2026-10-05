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
