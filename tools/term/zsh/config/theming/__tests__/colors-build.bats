bats_load_library 'helper'

setup() {
  CURRENT="$(realpath "${BATS_TEST_DIRNAME}/../colors-build")"
  bats_tmp_dir

  export OROSHI_ROOT="$BATS_TMP_DIR"
  export THEMING_ROOT="$BATS_TMP_DIR/tools/term/zsh/config/theming"
  mkdir -p "$THEMING_ROOT/dist"
  mkdir -p "$BATS_TMP_DIR/tools/term/kitty/config"

  # Minimal colors.conf:
  # color17 → ORANGE (namedColors[17])   — aliased by GIT_BRANCH
  # color87 → YELLOW_7 (range 8=YELLOW, scale 7)
  cat >"$BATS_TMP_DIR/tools/term/kitty/config/colors.conf" <<'CONF'
color17  #dd6b20
color87  #a16207
CONF
}

teardown() {
  bats_cleanup
}

# --- ZSH output ---

@test "produces dist/colors.zsh" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.zsh" ]
}

@test "dist/colors.zsh declares typeset -gA COLORS" {
  bats_run_zsh "$CURRENT"
  run grep "typeset -gA COLORS" "$THEMING_ROOT/dist/colors.zsh"
  [ "$status" -eq 0 ]
}

@test "dist/colors.zsh sets yellow-7 ansi integer" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[yellow-7]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "87" ]
}

@test "dist/colors.zsh sets yellow-7 hex string" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[yellow-7:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#a16207" ]
}

# --- JSON output ---

@test "produces dist/colors.json" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.json" ]
}

@test "dist/colors.json has yellow-7 with correct ansi" {
  bats_run_zsh "$CURRENT"
  run jq -r '."yellow-7".ansi' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "87" ]
}

@test "dist/colors.json has yellow-7 with correct hex" {
  bats_run_zsh "$CURRENT"
  run jq -r '."yellow-7".hex' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "#a16207" ]
}

# --- Aliases ---

@test "aliases: COLORS[git-branch] resolves to ORANGE ansi" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-branch]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "17" ]
}

@test "aliases: COLORS[git-branch:hex] resolves to ORANGE hex" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-branch:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#dd6b20" ]
}

@test "aliases: no alias-git-branch key in dist/colors.zsh" {
  bats_run_zsh "$CURRENT"
  run grep "alias-git-branch" "$THEMING_ROOT/dist/colors.zsh"
  [ "$status" -ne 0 ]
}

@test "aliases: no alias-git-branch key in dist/colors.json" {
  bats_run_zsh "$CURRENT"
  run jq 'has("alias-git-branch")' "$THEMING_ROOT/dist/colors.json"
  [ "$output" = "false" ]
}

# --- Both outputs ---

@test "both dist/colors.zsh and dist/colors.json written in single run" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/colors.zsh" ]
  [ -f "$THEMING_ROOT/dist/colors.json" ]
}
