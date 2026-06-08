bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/colors/colors-template-render"
  TEMPLATE="$BATS_TMP_DIR/template.txt"
  SCRIPT="$BATS_TMP_DIR/test.zsh"

  cat >"$SCRIPT" <<SCRIPT
typeset -gA colors
colors[YELLOW_7]=87
colors[YELLOW_7:hex]="#a16207"
colors[GIT_BRANCH]=17
colors[GIT_BRANCH:hex]="#d69e2e"
colors-load-definitions() { }
colors-template-render() { source "${CURRENT}" }
colors-template-render "${TEMPLATE}"
SCRIPT
}

teardown() {
  bats_cleanup
}

# --- Basic substitution ---

@test "{{NAME}} is replaced with ANSI integer" {
  printf '{{YELLOW_7}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "87" ]
}

@test "{{NAME:hex}} is replaced with hex string" {
  printf '{{YELLOW_7:hex}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#a16207" ]
}

# --- Alias substitution ---

@test "alias {{NAME:hex}} is resolved correctly" {
  printf '{{GIT_BRANCH:hex}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#d69e2e" ]
}

# --- Unknown placeholders ---

@test "unknown placeholder is left unchanged" {
  printf '{{UNKNOWN_COLOR}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "{{UNKNOWN_COLOR}}" ]
}

# --- Output ---

@test "rendered output goes to stdout" {
  printf '{{YELLOW_7}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${output}" = "87" ]
}
