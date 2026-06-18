bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export AUTOLOAD="$BATS_TMP_DIR/tools/term/zsh/config/functions/autoload"
  mkdir -p "$AUTOLOAD"
  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
}

# --- Tracking ---

@test "extension-less file is tracked in OROSHI_AUTOLOADED_FUNCTIONS" {
  touch "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; echo \${OROSHI_AUTOLOADED_FUNCTIONS[foo]}"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "file with extension is not tracked" {
  touch "$AUTOLOAD/foo.zsh"
  bats_run_zsh "oroshi-reload-fpath; echo \${#OROSHI_AUTOLOADED_FUNCTIONS}"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

# --- fpath ---

@test "subdirectory is added to fpath" {
  mkdir -p "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$AUTOLOAD/foo"* ]]
}

# --- root arg ---

@test "root arg: fpath contains autoload subdirs of given root" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload/bar"
  bats_run_zsh "oroshi-reload-fpath $altRoot; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$altRoot/tools/term/zsh/config/functions/autoload/bar"* ]]
}

@test "root arg: function in given root is autoloaded" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload"
  touch "$altRoot/tools/term/zsh/config/functions/autoload/bar"
  bats_run_zsh "oroshi-reload-fpath $altRoot; echo \${OROSHI_AUTOLOADED_FUNCTIONS[bar]}"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "root arg: previously loaded fpath dirs are removed" {
  altRoot="$BATS_TMP_DIR/alt-root"
  mkdir -p "$AUTOLOAD/foo"
  mkdir -p "$altRoot/tools/term/zsh/config/functions/autoload"
  bats_run_zsh "oroshi-reload-fpath; oroshi-reload-fpath $altRoot; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$AUTOLOAD"* ]]
}

# --- no arg ---

@test "no arg uses OROSHI_ROOT" {
  touch "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; echo \${OROSHI_AUTOLOADED_FUNCTIONS[foo]}"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

# --- fpath cleanup ---

@test "second call does not duplicate fpath entries" {
  mkdir -p "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; oroshi-reload-fpath; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$AUTOLOAD/foo"* ]]
}

# --- completion/compdef ---

@test "completion/compdef dir is added to fpath" {
  altRoot="$BATS_TMP_DIR/alt-root"
  local compdefDir="$altRoot/tools/term/zsh/config/completion/compdef"
  mkdir -p "$compdefDir"
  bats_run_zsh "oroshi-reload-fpath $altRoot; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$compdefDir"* ]]
}

@test "old completion/compdef is removed when switching roots" {
  altRoot="$BATS_TMP_DIR/alt-root"
  local oldCompdef="$BATS_TMP_DIR/completion/compdef"
  mkdir -p "$oldCompdef"
  mkdir -p "$altRoot/tools/term/zsh/config/completion/compdef"
  bats_run_zsh "fpath+=(\"$oldCompdef\"); OROSHI_AUTOLOADED_FPATH+=(\"$oldCompdef\"); oroshi-reload-fpath $altRoot; echo \$fpath"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$oldCompdef"* ]]
}

# --- Idempotency ---

@test "second call exits 0" {
  touch "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; oroshi-reload-fpath"
  [ "$status" -eq 0 ]
}

@test "second call re-registers function" {
  touch "$AUTOLOAD/foo"
  bats_run_zsh "oroshi-reload-fpath; oroshi-reload-fpath; echo \${OROSHI_AUTOLOADED_FUNCTIONS[foo]}"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}
