bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/functions/autoload"
}

teardown() {
  bats_cleanup
}

# --- Tracking ---

@test "extension-less file is tracked in OROSHI_AUTOLOADED_FUNCTIONS" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    oroshi-reload-functions
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[my-func]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "file with extension is not tracked" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func.zsh"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    oroshi-reload-functions
    echo "${#OROSHI_AUTOLOADED_FUNCTIONS}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

# --- fpath ---

@test "subdirectory is added to fpath" {
  mkdir -p "$BATS_TMP_DIR/functions/autoload/mydir"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    oroshi-reload-functions
    [[ "${fpath[(r)$BATS_TMP_DIR/functions/autoload/mydir]}" == "$BATS_TMP_DIR/functions/autoload/mydir" ]] && echo "yes"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "yes" ]
}

# --- worktree arg ---

@test "worktree arg loads functions from current git root" {
  bats_git_dir
  mkdir -p "$BATS_GIT_DIR/config/term/zsh/functions/autoload"
  touch "$BATS_GIT_DIR/config/term/zsh/functions/autoload/my-wt-func"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="/nonexistent"
    cd "$BATS_GIT_DIR"
    oroshi-reload-functions worktree
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[my-wt-func]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "worktree arg ignores ZSH_CONFIG_PATH" {
  bats_git_dir
  mkdir -p "$BATS_GIT_DIR/config/term/zsh/functions/autoload"
  touch "$BATS_GIT_DIR/config/term/zsh/functions/autoload/wt-only-func"
  touch "$BATS_TMP_DIR/functions/autoload/default-func"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    cd "$BATS_GIT_DIR"
    oroshi-reload-functions worktree
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[default-func]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# --- Idempotency ---

@test "second call exits 0" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    oroshi-reload-functions
    oroshi-reload-functions
  '
  [ "$status" -eq 0 ]
}

@test "second call re-registers function" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  run zsh -c '
    source "$OROSHI_ROOT/config/term/zsh/functions/oroshi-reload-functions.zsh"
    ZSH_CONFIG_PATH="$BATS_TMP_DIR"
    oroshi-reload-functions
    oroshi-reload-functions
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[my-func]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
