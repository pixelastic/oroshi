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
