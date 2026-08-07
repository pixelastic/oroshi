bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# The script uses `exec zsh -ic "cd ... && { claude ... || true; }; exec zsh"`
# We mock zsh to capture the -ic command string instead of actually exec'ing.
# We also mock git-directory-root to control the cd target.

@test "no argument: claude called without extra args" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  zsh() { echo "$*" >"$BATS_TMP_DIR/zsh-cmd"; }
  bats_mock git-directory-root zsh

  bats_run_zsh "kitty-helper-claude-start"

  [[ "$status" -eq 0 ]]
  local cmd="$(cat "$BATS_TMP_DIR/zsh-cmd")"
  [[ "$cmd" == *"{ claude || true; }"* ]]
}

@test "with prompt argument: claude called with the prompt string" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  zsh() { echo "$*" >"$BATS_TMP_DIR/zsh-cmd"; }
  bats_mock git-directory-root zsh

  bats_run_zsh "kitty-helper-claude-start @/path/to/file.md"

  [[ "$status" -eq 0 ]]
  local cmd="$(cat "$BATS_TMP_DIR/zsh-cmd")"
  [[ "$cmd" == *"claude @/path/to/file.md"* ]]
}

@test "multiple arguments: claude called with all arguments forwarded in order" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  zsh() { echo "$*" >"$BATS_TMP_DIR/zsh-cmd"; }
  bats_mock git-directory-root zsh

  bats_run_zsh "kitty-helper-claude-start --permission-mode acceptEdits @/path/to/file.md"

  [[ "$status" -eq 0 ]]
  local cmd="$(cat "$BATS_TMP_DIR/zsh-cmd")"
  [[ "$cmd" == *"claude --permission-mode acceptEdits @/path/to/file.md"* ]]
}

@test "non-zero claude exit: zsh still called after" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  zsh() { echo "$*" >"$BATS_TMP_DIR/zsh-cmd"; }
  bats_mock git-directory-root zsh

  bats_run_zsh "kitty-helper-claude-start @/path/to/file.md"

  [[ "$status" -eq 0 ]]
  local cmd="$(cat "$BATS_TMP_DIR/zsh-cmd")"
  # The || true ensures zsh continues even if claude fails
  [[ "$cmd" == *"|| true"* ]]
  # exec zsh at the end keeps the tab alive
  [[ "$cmd" == *"exec zsh"* ]]
}
