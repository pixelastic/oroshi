bats_load_library 'helper'

REVIEW_SCRIPT="$BATS_TEST_DIRNAME/../review"

setup() {
  bats_tmp_dir
  export CLAUDE_PRINT_CAPTURE="$BATS_TMP_DIR/claude-print-args"

  claude-print() { echo "$1" > "$CLAUDE_PRINT_CAPTURE"; }
  bats_mock claude-print
}

teardown() {
  bats_cleanup
}

@test "0-arg: invokes claude-print with '/review'" {
  bats_run_zsh "$REVIEW_SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$CLAUDE_PRINT_CAPTURE" ]
  local captured="$(cat "$CLAUDE_PRINT_CAPTURE")"
  [ "${captured% }" = "/review" ]
}

@test "1-arg: invokes claude-print with '/review <arg>'" {
  bats_run_zsh "$REVIEW_SCRIPT" main
  [ "$status" -eq 0 ]
  [ "$(cat "$CLAUDE_PRINT_CAPTURE")" = "/review main" ]
}

@test "2-arg: invokes claude-print with '/review <arg1> <arg2>'" {
  bats_run_zsh "$REVIEW_SCRIPT" abc123 feature-branch
  [ "$status" -eq 0 ]
  [ "$(cat "$CLAUDE_PRINT_CAPTURE")" = "/review abc123 feature-branch" ]
}
