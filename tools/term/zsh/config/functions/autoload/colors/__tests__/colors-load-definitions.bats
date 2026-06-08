bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/colors/colors-load-definitions"
  SCRIPT="$BATS_TMP_DIR/test.zsh"
}

teardown() {
  bats_cleanup
}

# --- Loading ---

@test "colors[GREEN] returns correct ANSI integer after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${colors[GREEN]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "2" ]
}

@test "colors[GREEN:hex] returns correct hex string after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${colors[GREEN:hex]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#38a169" ]
}

@test "colors[GIT_BRANCH] returns correct alias value after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${colors[GIT_BRANCH]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "17" ]
}

# --- Idempotency ---

@test "second call does not re-source dist/colors.zsh" {
  cat >"$SCRIPT" <<SCRIPT
typeset -gA colors
colors[GREEN]=999
source "$CURRENT"
echo \${colors[GREEN]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "999" ]
}
