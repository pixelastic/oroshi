bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  printf 'check "$@"\n' >"$CURRENT"
  mkdir -p "$BATS_TMP_DIR/functions/autoload"
  printf "source '%s/tools/term/zsh/config/functions/oroshi-reload-fpath.zsh'\nZSH_CONFIG_PATH='%s'\n" "$OROSHI_ROOT" "$BATS_TMP_DIR" > "$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

# --- Tracking ---

@test "extension-less file is tracked in OROSHI_AUTOLOADED_FUNCTIONS" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() {
    oroshi-reload-fpath
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" my-func
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "file with extension is not tracked" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func.zsh"
  check() {
    oroshi-reload-fpath
    echo "${#OROSHI_AUTOLOADED_FUNCTIONS}"
  }
  bats_mock check
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

# --- fpath ---

@test "subdirectory is added to fpath" {
  mkdir -p "$BATS_TMP_DIR/functions/autoload/mydir"
  # shellcheck disable=SC2154
  check() {
    oroshi-reload-fpath
    [[ "${fpath[(r)$BATS_TMP_DIR/functions/autoload/mydir]}" == "$BATS_TMP_DIR/functions/autoload/mydir" ]] && echo "yes"
  }
  bats_mock check
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "yes" ]
}

# --- root arg ---

@test "root arg: fpath contains autoload subdirs of given root" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload/alt-dir"
  check() {
    oroshi-reload-fpath "$1"
    [[ "${fpath[(r)$1/tools/term/zsh/config/functions/autoload/alt-dir]}" == "$1/tools/term/zsh/config/functions/autoload/alt-dir" ]] && echo "yes"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "yes" ]
}

@test "root arg: function in given root is autoloaded" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload"
  touch "$altRoot/tools/term/zsh/config/functions/autoload/my-alt-func"
  check() {
    oroshi-reload-fpath "$1"
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[$2]}"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot" my-alt-func
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "root arg: previously loaded fpath dirs are removed" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$BATS_TMP_DIR/functions/autoload/main-dir"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath "$1"
    local found=0
    for dir in $fpath; do [[ "$dir" == "$BATS_TMP_DIR/functions/autoload"* ]] && found=1; done
    echo "$found"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

# --- no arg ---

@test "no arg uses ZSH_CONFIG_PATH" {
  touch "$BATS_TMP_DIR/functions/autoload/default-func"
  check() {
    oroshi-reload-fpath
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" default-func
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

# --- fpath cleanup ---

@test "second call does not duplicate fpath entries" {
  mkdir -p "$BATS_TMP_DIR/functions/autoload/mydir"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath
    local count=0
    for dir in $fpath; do [[ "$dir" == *mydir ]] && count=$((count + 1)); done
    echo "$count"
  }
  bats_mock check
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

# --- Idempotency ---

@test "second call exits 0" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath
  }
  bats_mock check
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "second call re-registers function" {
  touch "$BATS_TMP_DIR/functions/autoload/my-func"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath
    echo "${OROSHI_AUTOLOADED_FUNCTIONS[$1]}"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" my-func
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}
