bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "no argument: claude called without extra args and zsh called after" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  zsh() { touch "$BATS_TMP_DIR/zsh-called"; }
  bats_mock git-directory-root claude zsh

  bats_run_zsh "kitty-helper-claude-start"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/claude-args")" = "" ]]
  [[ -f "$BATS_TMP_DIR/zsh-called" ]]
}

@test "with prompt argument: claude called with the prompt string and zsh called after" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "$*" >"$BATS_TMP_DIR/claude-args"; }
  zsh() { touch "$BATS_TMP_DIR/zsh-called"; }
  bats_mock git-directory-root claude zsh

  bats_run_zsh "kitty-helper-claude-start @/path/to/file.md"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/claude-args")" = "@/path/to/file.md" ]]
  [[ -f "$BATS_TMP_DIR/zsh-called" ]]
}

@test "with prompt argument: zsh still called when claude exits non-zero" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() {
    echo "$*" >"$BATS_TMP_DIR/claude-args"
    return 1
  }
  zsh() { touch "$BATS_TMP_DIR/zsh-called"; }
  bats_mock git-directory-root claude zsh

  bats_run_zsh "kitty-helper-claude-start @/path/to/file.md"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/zsh-called" ]]
}
