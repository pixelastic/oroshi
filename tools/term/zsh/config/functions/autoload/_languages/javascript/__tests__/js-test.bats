bats_load_library 'helper'

setup() {
  # src/ holds foo.js and bar.js, each with a test in src/__tests__/
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  echo '{}' > "$BATS_TMP_DIR/package.json"
  touch "$BATS_TMP_DIR/src/foo.js"
  touch "$BATS_TMP_DIR/src/bar.js"
  touch "$BATS_TMP_DIR/src/__tests__/foo.js"
  touch "$BATS_TMP_DIR/src/__tests__/bar.js"
  yarn() { echo "$PWD yarn $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock yarn
}

@test "test file: runs it" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/__tests__/foo.js"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == *"yarn run test $BATS_TMP_DIR/src/__tests__/foo.js" ]]
}

@test "source file: runs its test file" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == *"yarn run test $BATS_TMP_DIR/src/__tests__/foo.js" ]]
  [[ "$calls" != *"bar.js"* ]]
}

@test "directory: runs every test below it" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == *"$BATS_TMP_DIR/src/__tests__/foo.js"* ]]
  [[ "$calls" == *"$BATS_TMP_DIR/src/__tests__/bar.js"* ]]
}

@test "source and test file together: runs the test once" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js $BATS_TMP_DIR/src/__tests__/foo.js"
  [[ "$status" -eq 0 ]]
  [[ "$(wc --lines < "$BATS_TMP_DIR/calls.txt")" -eq 1 ]]
  local count="$(grep --only-matching 'foo.js' "$BATS_TMP_DIR/calls.txt" | wc --lines)"
  [[ "$count" -eq 1 ]]
}

@test "does not use --related" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" != *"--related"* ]]
}

@test "runs from the top-level yarn root of the first file" {
  mkdir -p "$BATS_TMP_DIR/packages/app/__tests__"
  echo '{}' > "$BATS_TMP_DIR/packages/app/package.json"
  touch "$BATS_TMP_DIR/packages/app/__tests__/baz.js"

  bats_run_zsh "js-test $BATS_TMP_DIR/packages/app/__tests__/baz.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR yarn run test "* ]]
}

@test "failing tests: exits 1" {
  yarn() { return 1; }
  bats_mock yarn

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 1 ]]
}

@test "no argument: exits 0, does not run yarn" {
  bats_run_zsh "js-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "source file without test file: exits 0, does not run yarn" {
  touch "$BATS_TMP_DIR/src/baz.js"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/baz.js"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "non-JS file: skipped" {
  printf 'hello\n' > "$BATS_TMP_DIR/notes.txt"

  bats_run_zsh "js-test $BATS_TMP_DIR/notes.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}
