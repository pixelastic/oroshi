bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  export AUTOLOAD="$BATS_TMP_DIR/tools/term/zsh/config/functions/autoload"
  printf 'check "$@"\n' >"$CURRENT"
  mkdir -p "$AUTOLOAD"
  bats_mock_oroshi_root "$BATS_TMP_DIR"
}

teardown() {
  bats_cleanup
}

# --- Tracking ---

@test "extension-less file is tracked in OROSHI_AUTOLOADED_FUNCTIONS" {
  touch "$AUTOLOAD/my-func"
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
  touch "$AUTOLOAD/my-func.zsh"
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
  mkdir -p "$AUTOLOAD/mydir"
  # shellcheck disable=SC2154
  check() {
    oroshi-reload-fpath
    [[ "${fpath[(r)$AUTOLOAD/mydir]}" == "$AUTOLOAD/mydir" ]] && echo "yes"
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
  mkdir -p "$AUTOLOAD/main-dir"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath "$1"
    local found=0
    for dir in $fpath; do [[ "$dir" == "$AUTOLOAD"* ]] && found=1; done
    echo "$found"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

# --- no arg ---

@test "no arg uses OROSHI_ROOT" {
  touch "$AUTOLOAD/default-func"
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
  mkdir -p "$AUTOLOAD/mydir"
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

# --- completion/compdef ---

@test "completion/compdef dir is added to fpath" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$altRoot/tools/term/zsh/config/completion/compdef"
  check() {
    local compdefDir="$1/tools/term/zsh/config/completion/compdef"
    oroshi-reload-fpath "$1"
    [[ "${fpath[(r)$compdefDir]}" == "$compdefDir" ]] && echo "yes"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "yes" ]
}

@test "old completion/compdef is removed when switching roots" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$BATS_TMP_DIR/completion/compdef"
  mkdir -p "$altRoot/tools/term/zsh/config/completion/compdef"
  check() {
    fpath+=("$BATS_TMP_DIR/completion/compdef")
    OROSHI_AUTOLOADED_FPATH+=("$BATS_TMP_DIR/completion/compdef")
    oroshi-reload-fpath "$1"
    local found=0
    # shellcheck disable=SC2128
    for dir in $fpath; do [[ "$dir" == "$BATS_TMP_DIR/completion/compdef" ]] && found=1; done
    echo "$found"
  }
  bats_mock check
  bats_run_zsh "$CURRENT" "$altRoot"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

# --- Idempotency ---

@test "second call exits 0" {
  touch "$AUTOLOAD/my-func"
  check() {
    oroshi-reload-fpath
    oroshi-reload-fpath
  }
  bats_mock check
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "second call re-registers function" {
  touch "$AUTOLOAD/my-func"
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
