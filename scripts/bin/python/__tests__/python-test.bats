bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "passing test file: exits 0" {
  local file="$BATS_TMP_DIR/test_pass.py"
  printf 'def test_ok():\n    assert True\n' > "$file"

  bats_run_zsh "python-test $file"
  [[ "$status" -eq 0 ]]
}

@test "failing test file: exits non-zero, pytest output visible" {
  local file="$BATS_TMP_DIR/test_fail.py"
  printf 'def test_bad():\n    assert False\n' > "$file"

  bats_run_zsh "python-test $file"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"FAILED"* ]]
}

@test "missing file: skipped silently, exits 0" {
  local file="$BATS_TMP_DIR/test_pass.py"
  printf 'def test_ok():\n    assert True\n' > "$file"

  bats_run_zsh "python-test $file $BATS_TMP_DIR/missing.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"Error"* ]]
}

@test "non-.py file: skipped silently" {
  local pyfile="$BATS_TMP_DIR/test_pass.py"
  local txtfile="$BATS_TMP_DIR/notes.txt"
  printf 'def test_ok():\n    assert True\n' > "$pyfile"
  printf 'hello\n' > "$txtfile"

  bats_run_zsh "python-test $pyfile $txtfile"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"Error"* ]]
}

@test "multiple files: runs all of them" {
  local file1="$BATS_TMP_DIR/test_a.py"
  local file2="$BATS_TMP_DIR/test_b.py"
  printf 'def test_a():\n    assert True\n' > "$file1"
  printf 'def test_b():\n    assert True\n' > "$file2"

  bats_run_zsh "python-test $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"test_a"* ]]
  [[ "$output" == *"test_b"* ]]
}

@test "directory: runs all tests discovered" {
  local dir="$BATS_TMP_DIR/tests"
  mkdir -p "$dir"
  printf 'def test_a():\n    assert True\n' > "$dir/test_a.py"
  printf 'def test_b():\n    assert True\n' > "$dir/test_b.py"

  bats_run_zsh "python-test $dir"
  [[ "$status" -eq 0 ]]
}
