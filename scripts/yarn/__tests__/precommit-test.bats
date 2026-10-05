bats_load_library 'helper'

setup() {
  # test_failing.py holds two failing tests, test_foo.py holds one passing test
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  printf 'def test_first_failure():\n    assert False\n\ndef test_second_failure():\n    assert False\n' > "$BATS_TMP_DIR/src/__tests__/test_failing.py"
  printf 'def test_foo():\n    assert True\n' > "$BATS_TMP_DIR/src/__tests__/test_foo.py"
}

@test "reports only the first failure of two failing tests" {
  bats_run_zsh "$BATS_TEST_DIRNAME/../precommit-test python $BATS_TMP_DIR/src/__tests__/test_failing.py"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"test_first_failure"* ]]
  [[ "$output" != *"test_second_failure"* ]]
}

@test "exits zero when all tests pass" {
  bats_run_zsh "$BATS_TEST_DIRNAME/../precommit-test python $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
}

@test "exits zero without running tests when no file is staged" {
  bats_run_zsh "$BATS_TEST_DIRNAME/../precommit-test python"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
