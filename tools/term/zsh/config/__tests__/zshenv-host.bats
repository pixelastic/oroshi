bats_load_library 'helper'

setup() {
  bats_tmp_dir
  MOCK_FILE="$BATS_TMP_DIR/mock.zsh"
  sourcePrefix="source '$BATS_TEST_DIRNAME/../zshenv-host.zsh'"
}

teardown() {
  bats_cleanup
  git -C "$OROSHI_ROOT" worktree prune
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
  [[ "$output" = "$HOME/.oroshi" ]]
}

@test "OROSHI_ROOT is default in oroshi main" {
  run_bare_zsh "cd $HOME/.oroshi; $sourcePrefix && echo \$OROSHI_ROOT"
  [[ "$output" = "$HOME/.oroshi" ]]
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
  [[ "$status" -eq 0 ]]
  [[ "$output" = "guest" ]]
}

@test "OROSHI_ROOT is worktree root when inside a submodule of an oroshi worktree" {
  # Create a worktrees/ folder
  worktreeRoot="$BATS_TMP_DIR/worktrees"
  mkdir -p "$worktreeRoot"

  # Add a git repo inside of it (to act as a worktree)
  worktreeDirName="oroshi--with-submodule"
  bats_git_dir "worktrees/$worktreeDirName"

  # Create a separate repo to use as a submodule source
  submoduleOrigin="$BATS_TMP_DIR/sub-origin"
  git init "$submoduleOrigin"
  touch "$submoduleOrigin/README.md"
  git -C "$submoduleOrigin" add .
  git -C "$submoduleOrigin" commit -m "init"

  # Add the submodule inside the worktree repo
  git -C "$worktreeRoot/$worktreeDirName" -c protocol.file.allow=always submodule add "$submoduleOrigin" private
  git -C "$worktreeRoot/$worktreeDirName" commit -m "add submodule"

  # Add a fake zshenv-guest.zsh so sourcing succeeds
  zshenvConfigDir="$worktreeRoot/$worktreeDirName/tools/term/zsh/config/"
  mkdir -p "$zshenvConfigDir"
  echo "" > "$zshenvConfigDir/zshenv-guest.zsh"

  # OROSHI_ROOT should be the worktree root, not the submodule root
  mock_env "MOCK_OROSHI_WORKTREES_DIR" "$worktreeRoot"
  run_bare_zsh "cd '$worktreeRoot/$worktreeDirName/private'; $sourcePrefix && echo \$OROSHI_ROOT"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$worktreeRoot/$worktreeDirName" ]]
}

# --- Worktree-aware integration ---

@test "outside any worktree, chains resolve from ~/.oroshi" {
  cd "$BATS_TMP_DIR"

  bats_run_zsh "bats-fixture-script-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$HOME/.oroshi"* ]]

  bats_run_zsh "bats-fixture-function-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$HOME/.oroshi"* ]]
}

@test "inside a detected oroshi worktree, chains resolve from that worktree" {
  # Make a real worktree of oroshi
  worktreeDir="$BATS_TMP_DIR/worktrees/oroshi--bats-test"
  git -C "$OROSHI_ROOT" worktree add --detach "$worktreeDir"
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  cd "$worktreeDir"

  # Ensure fixtures dir exists and has the full chain
  mkdir -p "$worktreeDir/scripts/bin/fixtures"
  cp "$OROSHI_ROOT/scripts/bin/fixtures"/bats-fixture-script-* "$worktreeDir/scripts/bin/fixtures/"
  rm -rf "$worktreeDir/scripts/bin/term/bats"

  # Overwrite leaf fixture to echo a custom string
  echo '#!/usr/bin/env zsh' > "$worktreeDir/scripts/bin/fixtures/bats-fixture-script-baz"
  echo 'echo "from-test-worktree"' >> "$worktreeDir/scripts/bin/fixtures/bats-fixture-script-baz"
  echo 'echo "from-test-worktree"' > "$worktreeDir/tools/term/zsh/config/functions/autoload/_languages/bats/bats-fixture-function-baz"

  # It correctly uses the new fixtures
  bats_run_zsh "bats-fixture-script-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "from-test-worktree" ]]

  bats_run_zsh "bats-fixture-function-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "from-test-worktree" ]]
}

@test "with worktree-aware disabled, chains resolve from inherited OROSHI_ROOT" {
  # Make a real worktree of oroshi
  worktreeDir="$BATS_TMP_DIR/worktrees/oroshi--bats-test"
  git -C "$OROSHI_ROOT" worktree add --detach "$worktreeDir"
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  cd "$worktreeDir"

  # Ensure fixtures dir exists and has the full chain
  mkdir -p "$worktreeDir/scripts/bin/fixtures"
  cp "$OROSHI_ROOT/scripts/bin/fixtures"/bats-fixture-script-* "$worktreeDir/scripts/bin/fixtures/"
  rm -rf "$worktreeDir/scripts/bin/term/bats"

  # Overwrite leaf fixture to echo a custom string
  echo '#!/usr/bin/env zsh' > "$worktreeDir/scripts/bin/fixtures/bats-fixture-script-baz"
  echo 'echo "from-test-worktree"' >> "$worktreeDir/scripts/bin/fixtures/bats-fixture-script-baz"
  echo 'echo "from-test-worktree"' > "$worktreeDir/tools/term/zsh/config/functions/autoload/_languages/bats/bats-fixture-function-baz"

  # Disable worktree-aware behavior
  bats_disable_worktree_aware

  bats_run_zsh "bats-fixture-script-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" != "from-test-worktree" ]]
  [[ "$output" == *"$OROSHI_ROOT"* ]]

  bats_run_zsh "bats-fixture-function-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" != "from-test-worktree" ]]
  [[ "$output" == *"$OROSHI_ROOT"* ]]
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
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$HOME/.oroshi" ]]
}
