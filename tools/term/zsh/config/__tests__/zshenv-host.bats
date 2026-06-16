bats_load_library 'helper'

setup() {
  bats_tmp_dir
  MOCK_FILE="$BATS_TMP_DIR/mock.zsh"
  sourcePrefix="source '$BATS_TEST_DIRNAME/../zshenv-host.zsh'"
}

teardown() {
  bats_cleanup
}

# Run zsh without any config nor ENV variable (except mocked), so we can safely
# source zshenv-host.zsh and test its behavior in isolation.
run_bare_zsh() {
  zshCommand="$1"

  # Prepend mock file if present
  zshCommandPrefix="";
  [[ -f "$MOCK_FILE" ]] && zshCommandPrefix="source $MOCK_FILE;"

  # -f ignores all config files
  # -i ignore all existing ENV variables
  # bats-lint disable=noRunZsh
  run zsh -f -i -c "$zshCommandPrefix $zshCommand"
}

# Mock an ENV variable for run_bare_zsh
mock_env() {
  echo "export $1='$2'" >> "$MOCK_FILE"
}

@test "OROSHI_ROOT defaults to ~/.oroshi" {
  run_bare_zsh "cd /tmp; $sourcePrefix && echo \$OROSHI_ROOT"
  [ "$output" = "$HOME/.oroshi" ]
}

@test "OROSHI_ROOT is default in oroshi main" {
  run_bare_zsh "cd $HOME/.oroshi; $sourcePrefix && echo \$OROSHI_ROOT"
  [ "$output" = "$HOME/.oroshi" ]
}

@test "OROSHI_ROOT is worktree in oroshi worktree" {
  # Create a worktrees/ folder
  worktreeRoot="$BATS_TMP_DIR/worktrees"
  mkdir -p "$worktreeRoot"

  # Add a git repo inside of it (to act as a worktree)
  worktreeDirName="oroshi--something"
  bats_git_dir "worktrees/$worktreeDirName"

  # Add a fake zshenv-guest.zsh
  zshenvConfigDir="$worktreeRoot/$worktreeDirName/tools/term/zsh/config/"
  mkdir -p "$zshenvConfigDir"
  echo "echo guest" > "$zshenvConfigDir/zshenv-guest.zsh"

  mock_env "MOCK_OROSHI_WORKTREES_DIR" "$worktreeRoot"
  run_bare_zsh "cd '$worktreeRoot/$worktreeDirName'; $sourcePrefix"
  [ "$status" -eq 0 ]
  [ "$output" = "guest" ]
}

@test "OROSHI_ROOT is worktree in any other worktree" {
  # Create a worktrees/ folder
  worktreeRoot="$BATS_TMP_DIR/worktrees"
  mkdir -p "$worktreeRoot"

  # Add a git repo inside of it (to act as a worktree)
  worktreeDirName="aberlaas--something"
  bats_git_dir "worktrees/$worktreeDirName"

  mock_env "MOCK_OROSHI_WORKTREES_DIR" "$worktreeRoot"
  run_bare_zsh "cd '$worktreeRoot/$worktreeDirName'; $sourcePrefix && echo \$OROSHI_ROOT"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.oroshi" ]
}
