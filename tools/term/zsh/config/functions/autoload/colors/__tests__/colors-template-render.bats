bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/colors/colors-template-render"
  TEMPLATE="$BATS_TMP_DIR/template.txt"
  SCRIPT="$BATS_TMP_DIR/test.zsh"

  cat >"$SCRIPT" <<SCRIPT
typeset -gA COLORS
COLORS[yellow-7]=87
COLORS[yellow-7:hex]="#a16207"
COLORS[git-branch]=17
COLORS[git-branch:hex]="#d69e2e"
colors-load-definitions() { }
colors-template-render() { source "${CURRENT}" }
colors-template-render "${TEMPLATE}"
SCRIPT
}

teardown() {
  bats_cleanup
}

# --- Basic substitution ---

@test "{{name}} is replaced with ANSI integer" {
  printf '{{yellow-7}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "87" ]
}

@test "{{name:hex}} is replaced with hex string" {
  printf '{{yellow-7:hex}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#a16207" ]
}

# --- Alias substitution ---

@test "alias {{name:hex}} is resolved correctly" {
  printf '{{git-branch:hex}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#d69e2e" ]
}

# --- Unknown placeholders ---

@test "unknown placeholder is left unchanged" {
  printf '{{unknown-color}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "{{unknown-color}}" ]
}

# --- Output ---

@test "rendered output goes to stdout" {
  printf '{{yellow-7}}' >"$TEMPLATE"
  bats_run_zsh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${output}" = "87" ]
}
