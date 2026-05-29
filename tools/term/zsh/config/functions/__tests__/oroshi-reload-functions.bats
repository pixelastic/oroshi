bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/functions/autoload"
  printf "source '%s/tools/term/zsh/config/functions/oroshi-reload-functions.zsh'\nZSH_CONFIG_PATH='%s'\n" "$OROSHI_ROOT" "$BATS_TMP_DIR" > "$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

# --- Tracking ---

@test "extension-less file is tracked in OROSHI_AUTOLOADED_FUNCTIONS" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() { oroshi-reload-functions; echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"; }
  bats_mock check
  bats_run_function check my-func
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "file with extension is not tracked" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func.zsh"
  check() { oroshi-reload-functions; echo "${#OROSHI_AUTOLOADED_FUNCTIONS}"; }
  bats_mock check
  bats_run_function check
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

# --- fpath ---

@test "subdirectory is added to fpath" {
  mkdir -p "$BATS_TMP_DIR/functions/autoload/mydir"
  check() { oroshi-reload-functions; [[ "${fpath[(r)$BATS_TMP_DIR/functions/autoload/mydir]}" == "$BATS_TMP_DIR/functions/autoload/mydir" ]] && echo "yes"; }
  bats_mock check
  bats_run_function check
  [ "$status" -eq 0 ]
  [ "$output" = "yes" ]
}

# --- worktree arg ---

@test "worktree arg loads functions from current git root" {
  bats_git_dir
  mkdir -p "$BATS_GIT_DIR/tools/term/zsh/config/functions/autoload"
  touch "$BATS_GIT_DIR/tools/term/zsh/config/functions/autoload/my-wt-func"
  check() { ZSH_CONFIG_PATH="/nonexistent"; cd "$BATS_GIT_DIR"; oroshi-reload-functions worktree; echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"; }
  bats_mock check
  bats_run_function check my-wt-func
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "worktree arg ignores ZSH_CONFIG_PATH" {
  bats_git_dir
  mkdir -p "$BATS_GIT_DIR/tools/term/zsh/config/functions/autoload"
  touch "$BATS_GIT_DIR/tools/term/zsh/config/functions/autoload/wt-only-func"
  touch "$BATS_TMP_DIR/functions/autoload/default-func"
  check() { cd "$BATS_GIT_DIR"; oroshi-reload-functions worktree; echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"; }
  bats_mock check
  bats_run_function check default-func
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# --- Idempotency ---

@test "second call exits 0" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() { oroshi-reload-functions; oroshi-reload-functions; }
  bats_mock check
  bats_run_function check
  [ "$status" -eq 0 ]
}

@test "second call re-registers function" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() { oroshi-reload-functions; oroshi-reload-functions; echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"; }
  bats_mock check
  bats_run_function check my-func
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
