bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Create a fake module structure
  mkdir -p "$BATS_TMP_DIR/mymod/pkg/parser"
  mkdir -p "$BATS_TMP_DIR/mymod/pkg/lexer"
  echo "module example.com/mymod" > "$BATS_TMP_DIR/mymod/go.mod"
  echo "package parser" > "$BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  echo "package parser" > "$BATS_TMP_DIR/mymod/pkg/parser/parser_test.go"
  echo "package lexer" > "$BATS_TMP_DIR/mymod/pkg/lexer/lexer.go"
  echo "package lexer" > "$BATS_TMP_DIR/mymod/pkg/lexer/lexer_test.go"
}

@test "runs go test on the package of a single file" {
  # Mock go to capture the test command
  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = *"test ./pkg/parser/..."* ]]
}

@test "deduplicates packages when multiple files are in the same directory" {
  echo "package parser" > "$BATS_TMP_DIR/mymod/pkg/parser/helpers.go"

  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go $BATS_TMP_DIR/mymod/pkg/parser/helpers.go"
  [[ "$status" -eq 0 ]]
  # Should only call go test once for the parser package
  local callCount="$(grep -c 'test' "$BATS_TMP_DIR/calls.txt")"
  [[ "$callCount" -eq 1 ]]
}

@test "runs go test on multiple distinct packages" {
  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go $BATS_TMP_DIR/mymod/pkg/lexer/lexer.go"
  [[ "$status" -eq 0 ]]
  local callCount="$(grep -c 'test' "$BATS_TMP_DIR/calls.txt")"
  [[ "$callCount" -eq 2 ]]
}

# --- Directory support ---

@test "expands a directory and runs go test on packages with test files" {
  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"test ./pkg/parser/..."* ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"test ./pkg/lexer/..."* ]]
}

@test "directory expansion skips non-Go files" {
  # Add a non-Go file in the parser package
  echo "not go" > "$BATS_TMP_DIR/mymod/pkg/parser/README.md"

  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/parser/"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"test ./pkg/parser/..."* ]]
  # Only one go test call — README.md was not processed
  local callCount="$(grep -c 'test' "$BATS_TMP_DIR/calls.txt")"
  [[ "$callCount" -eq 1 ]]
}

@test "handles mixed file and directory arguments" {
  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR/mymod && go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go $BATS_TMP_DIR/mymod/pkg/lexer/"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"test ./pkg/parser/..."* ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == *"test ./pkg/lexer/..."* ]]
}

@test "exits 0 with no arguments, without calling go" {
  go() { echo "go $*" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go

  bats_run_zsh "go-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

# --- Fail fast (real go toolchain) ---

# Write a package whose test file holds the given failing tests
write_failing_package() {
  local pkg="$1"
  shift
  local pkgDir="$BATS_TMP_DIR/mymod/pkg/$pkg"
  mkdir -p "$pkgDir"
  echo "package $pkg" > "$pkgDir/$pkg.go"
  {
    echo "package $pkg"
    echo 'import "testing"'
    for name in "$@"; do
      echo "func $name(t *testing.T) { t.Fail() }"
    done
  } > "$pkgDir/${pkg}_test.go"
}

@test "reports every failure without --fail-fast" {
  write_failing_package parser TestFirstFailure TestSecondFailure

  bats_run_zsh "go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--- FAIL: TestFirstFailure"* ]]
  [[ "$output" == *"--- FAIL: TestSecondFailure"* ]]
}

@test "reports only the first failure with --fail-fast" {
  write_failing_package parser TestFirstFailure TestSecondFailure

  bats_run_zsh "go-test --fail-fast $BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  [[ "$output" == *"--- FAIL: TestFirstFailure"* ]]
  [[ "$output" != *"--- FAIL: TestSecondFailure"* ]]
}

@test "runs every failing package without --fail-fast" {
  write_failing_package parser TestParserFailure
  write_failing_package lexer TestLexerFailure

  bats_run_zsh "go-test $BATS_TMP_DIR/mymod/pkg/parser/parser.go $BATS_TMP_DIR/mymod/pkg/lexer/lexer.go"
  [[ "$output" == *"--- FAIL: TestParserFailure"* ]]
  [[ "$output" == *"--- FAIL: TestLexerFailure"* ]]
}

@test "skips the packages after the first failing one with --fail-fast" {
  write_failing_package parser TestParserFailure
  write_failing_package lexer TestLexerFailure

  bats_run_zsh "go-test --fail-fast $BATS_TMP_DIR/mymod/pkg/parser/parser.go $BATS_TMP_DIR/mymod/pkg/lexer/lexer.go"
  [[ "$output" == *"--- FAIL: TestParserFailure"* ]]
  [[ "$output" != *"TestLexerFailure"* ]]
}

@test "exits non-zero with --fail-fast when a test fails" {
  write_failing_package parser TestFirstFailure TestSecondFailure

  bats_run_zsh "go-test --fail-fast $BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  [[ "$status" -ne 0 ]]
}

@test "exits zero with --fail-fast when all tests pass" {
  printf 'package parser\nimport "testing"\nfunc TestOk(t *testing.T) {}\n' > "$BATS_TMP_DIR/mymod/pkg/parser/parser_test.go"

  bats_run_zsh "go-test --fail-fast $BATS_TMP_DIR/mymod/pkg/parser/parser.go"
  [[ "$status" -eq 0 ]]
}
