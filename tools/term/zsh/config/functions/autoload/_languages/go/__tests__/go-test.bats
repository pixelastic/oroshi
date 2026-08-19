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
