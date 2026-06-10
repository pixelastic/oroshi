bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../kitty-helper-claude-start"
}

teardown() {
  bats_cleanup
}

@test "no argument: claude called without extra args" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  bats_mock git-directory-root claude

  # exec zsh is a binary call — mock it via PATH so it exits cleanly
  mkdir -p "$BATS_TMP_DIR/bin"
  printf '#!/bin/sh\nexit 0\n' > "$BATS_TMP_DIR/bin/zsh"
  chmod +x "$BATS_TMP_DIR/bin/zsh"
  echo "export PATH=\"$BATS_TMP_DIR/bin:\$PATH\"" >> "$BATS_TMP_DIR/mock.zsh"

  bats_run_zsh "$CURRENT"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/claude-args")" = "" ]
}

@test "with prompt argument: claude called with the prompt string" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  bats_mock git-directory-root claude

  bats_run_zsh "$CURRENT" "@/path/to/file.md"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/claude-args")" = "@/path/to/file.md" ]
}
