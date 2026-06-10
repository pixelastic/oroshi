bats_load_library 'helper'

# Tests for colors-build alias migration (issue 08).
# Use the real colors.jsonc and real colors.conf to verify that each semantic
# alias resolves to its expected hex value after the palette renumbering.

setup() {
  CURRENT="$(realpath "${BATS_TEST_DIRNAME}/../colors-build")"
  bats_tmp_dir

  REAL_THEMING_ROOT="${CURRENT%/*}"
  REAL_OROSHI_ROOT="${REAL_THEMING_ROOT%/tools/term/zsh/config/theming}"

  bats_mock_oroshi_root "$REAL_OROSHI_ROOT"
  export THEMING_ROOT="$REAL_THEMING_ROOT"
}

teardown() {
  bats_cleanup
}

@test "alias migration: COLORS[error:hex] = #ef4444 (red-4)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[error:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#ef4444" ]
}

@test "alias migration: COLORS[variable-type:hex] = #f87171 (red-3)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[variable-type:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#f87171" ]
}

@test "alias migration: COLORS[git-behind:hex] = #991b1b (red-7)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-behind:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#991b1b" ]
}

@test "alias migration: COLORS[git-worktree:hex] = #c2410c (orange-6)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[git-worktree:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#c2410c" ]
}

@test "alias migration: COLORS[punctuation:hex] = #0f766e (teal-6)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[punctuation:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#0f766e" ]
}

@test "alias migration: COLORS[variable:hex] = #a78bfa (violet-3)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[variable:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#a78bfa" ]
}

@test "alias migration: COLORS[black:hex] = #0c0f15 (gray-0)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[black:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#0c0f15" ]
}

@test "alias migration: COLORS[white:hex] = #ffffff (gray-1)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[white:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#ffffff" ]
}

@test "alias migration: COLORS[link:hex] = #63b3ed (blue-3)" {
  bats_run_zsh "$CURRENT"
  local script="$BATS_TMP_DIR/verify.zsh"
  cat >"$script" <<SCRIPT
source '${REAL_THEMING_ROOT}/dist/colors.zsh'
echo \${COLORS[link:hex]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "#63b3ed" ]
}
