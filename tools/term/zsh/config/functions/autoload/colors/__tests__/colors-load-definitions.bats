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

@test "COLORS[green] returns correct ANSI integer after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${COLORS[green]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "2" ]
}

@test "COLORS[green:hex] returns correct hex string after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${COLORS[green:hex]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#38a169" ]
}

@test "COLORS[git-branch] returns correct alias value after load" {
  cat >"$SCRIPT" <<SCRIPT
source "$CURRENT"
echo \${COLORS[git-branch]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "17" ]
}

# --- Idempotency ---

@test "second call does not re-source dist/colors.zsh" {
  cat >"$SCRIPT" <<SCRIPT
typeset -gA COLORS
COLORS[green]=999
source "$CURRENT"
echo \${COLORS[green]}
SCRIPT
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "999" ]
}
