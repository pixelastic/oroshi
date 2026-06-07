bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../kitty-helper-claude-start"
}

teardown() {
  bats_cleanup
}

@test "no argument: claude called without extra args" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  bats_mock git-directory-root claude

  bats_run_script "$SCRIPT"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/claude-args")" = "" ]
}

@test "with prompt argument: claude called with the prompt string" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  bats_mock git-directory-root claude

  bats_run_script "$SCRIPT" "@/path/to/file.md"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/claude-args")" = "@/path/to/file.md" ]
}
