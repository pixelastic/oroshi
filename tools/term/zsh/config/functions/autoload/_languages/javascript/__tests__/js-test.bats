bats_load_library 'helper'

# Creates a fake vitest binary in <dir>/node_modules/.bin that logs its calls
make_vitest() {
  local binDir="$1/node_modules/.bin"
  mkdir -p "$binDir"
  printf '#!/usr/bin/env zsh\necho "$PWD $0 $*" >> "%s/calls.txt"\n' "$BATS_TMP_DIR" > "$binDir/vitest"
  chmod +x "$binDir/vitest"
}

setup() {
  # src/ holds foo.js and bar.js, each with a test in src/__tests__/
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  echo '{}' > "$BATS_TMP_DIR/package.json"
  touch "$BATS_TMP_DIR/vite.config.js"
  touch "$BATS_TMP_DIR/src/foo.js"
  touch "$BATS_TMP_DIR/src/bar.js"
  touch "$BATS_TMP_DIR/src/__tests__/foo.js"
  touch "$BATS_TMP_DIR/src/__tests__/bar.js"

  # Remember the real oroshi root, for the tests that run the real vitest
  REAL_OROSHI_ROOT="$OROSHI_ROOT"

  # Project vitest and oroshi vitest are both fakes, logging who was called
  make_vitest "$BATS_TMP_DIR"
  make_vitest "$BATS_TMP_DIR/oroshi"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
}

@test "test file: runs it" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/__tests__/foo.js"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == *"vitest run $BATS_TMP_DIR/src/__tests__/foo.js" ]]
}

@test "source file: runs its test file" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == *"vitest run $BATS_TMP_DIR/src/__tests__/foo.js" ]]
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
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR "* ]]
}

@test "project has a config and a vitest binary: uses the project one" {
  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR $BATS_TMP_DIR/node_modules/.bin/vitest run "* ]]
}

@test "project has only a vitest.config.js: uses the oroshi one, as aberlaas reads vite.config.js only" {
  rm "$BATS_TMP_DIR/vite.config.js"
  touch "$BATS_TMP_DIR/vitest.config.js"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR $BATS_TMP_DIR/oroshi/node_modules/.bin/vitest run "* ]]
}

@test "project has a vitest binary but no config: uses the oroshi one, from the project root" {
  rm "$BATS_TMP_DIR/vite.config.js"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/calls.txt")"
  [[ "$calls" == "$BATS_TMP_DIR $BATS_TMP_DIR/oroshi/node_modules/.bin/vitest run "* ]]
  [[ "$calls" == *"vitest run $BATS_TMP_DIR/src/__tests__/foo.js" ]]
  [[ "$(wc --lines < "$BATS_TMP_DIR/calls.txt")" -eq 1 ]]
}

@test "project has a config but no vitest binary: uses the oroshi one" {
  rm --recursive "$BATS_TMP_DIR/node_modules"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR $BATS_TMP_DIR/oroshi/node_modules/.bin/vitest run "* ]]
}

@test "project outside any package: uses the oroshi one" {
  rm "$BATS_TMP_DIR/package.json" "$BATS_TMP_DIR/vite.config.js"
  rm --recursive "$BATS_TMP_DIR/node_modules"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ "$(wc --lines < "$BATS_TMP_DIR/calls.txt")" -eq 1 ]]
}

@test "only a workspace has the vitest binary: uses it, from the project root" {
  # Workspace paths are relative to the git root
  git init --quiet "$BATS_TMP_DIR"
  rm --recursive "$BATS_TMP_DIR/node_modules"
  mkdir -p "$BATS_TMP_DIR/packages/app"
  make_vitest "$BATS_TMP_DIR/packages/app"
  yarn-workspace-list-raw() { echo "app▮packages/app"; }
  bats_mock yarn-workspace-list-raw

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "$BATS_TMP_DIR $BATS_TMP_DIR/packages/app/node_modules/.bin/vitest run "* ]]
}

@test "failing tests: exits 1" {
  printf '#!/usr/bin/env zsh\nexit 1\n' > "$BATS_TMP_DIR/node_modules/.bin/vitest"

  bats_run_zsh "js-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 1 ]]
}

@test "no argument: exits 0, does not run vitest" {
  bats_run_zsh "js-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "source file without test file: exits 0, does not run vitest" {
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

# ─── FAIL FAST ────────────────────────────────────────────────────────────────

# Replace the fake vitest with the real one, linking the real node_modules
use_real_vitest() {
  rm --recursive --force "$BATS_TMP_DIR/node_modules"
  ln --symbolic "$REAL_OROSHI_ROOT/node_modules" "$BATS_TMP_DIR/node_modules"
  echo "export default { test: { include: ['**/__tests__/*.js'] } }" > "$BATS_TMP_DIR/vite.config.js"
}

# Write a test file holding two failing tests
write_failing_tests() {
  cat > "$BATS_TMP_DIR/src/__tests__/failing.js" <<'JS'
import { test } from 'vitest';
test('first failure', () => { throw new Error('first'); });
test('second failure', () => { throw new Error('second'); });
JS
}

@test "reports every failure without --fail-fast" {
  use_real_vitest
  write_failing_tests

  bats_run_zsh "NO_COLOR=1 js-test $BATS_TMP_DIR/src/__tests__/failing.js"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"> first failure"* ]]
  [[ "$output" == *"> second failure"* ]]
}

@test "reports only the first failure with --fail-fast" {
  use_real_vitest
  write_failing_tests

  bats_run_zsh "NO_COLOR=1 js-test --fail-fast $BATS_TMP_DIR/src/__tests__/failing.js"
  [[ "$output" == *"> first failure"* ]]
  [[ "$output" != *"> second failure"* ]]
}

@test "exits non-zero with --fail-fast when a test fails" {
  use_real_vitest
  write_failing_tests

  bats_run_zsh "NO_COLOR=1 js-test --fail-fast $BATS_TMP_DIR/src/__tests__/failing.js"
  [[ "$status" -ne 0 ]]
}

@test "passes run --bail 1 to vitest with --fail-fast" {
  bats_run_zsh "js-test --fail-fast $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"vitest run --bail 1 $BATS_TMP_DIR/src/__tests__/foo.js" ]]
}
