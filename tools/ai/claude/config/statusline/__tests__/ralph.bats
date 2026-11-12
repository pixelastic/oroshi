bats_load_library 'helper'

setup() {
  bats_tmp_dir

  SEGMENT="${OROSHI_ROOT}/tools/ai/claude/config/statusline/segments/ralph.zsh"
  NBSP=$'\u00a0'

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[text]=15
    COLORS[ralph-auto]=226
  }

  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[ralph-auto]="AUTO"
  }
  plan-directory() { echo ""; }
  plan-badge() { echo ""; }
  ralph-mode() { echo ""; }
  bats_mock colors-load-definitions icons-load-definitions plan-directory plan-badge ralph-mode
}

# Run the segment on the given directory and print REPLY
run_segment() {
  bats_run_zsh "colors-load-definitions; icons-load-definitions; source '$SEGMENT'; getRalphSegment $1; print -rn -- \$REPLY"
}

@test "renders nothing when there is no plan" {
  run_segment /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "renders nothing when the plan has no badge" {
  plan-directory() { echo "/some/plan/dir"; }
  ralph-mode() { echo "auto"; }
  bats_mock plan-directory ralph-mode

  run_segment /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "renders the plan badge alone when the mode is not auto" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  ralph-mode() { echo "single"; }
  bats_mock plan-directory plan-badge ralph-mode

  run_segment /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$output" == "PLAN_BADGE" ]]
}

@test "renders the badge, a no-break space and the yellow icon when the mode is auto" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  ralph-mode() { [[ "$1" == "/some/plan/dir" ]] && echo "auto"; }
  bats_mock plan-directory plan-badge ralph-mode

  run_segment /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$output" == "PLAN_BADGE${NBSP}"$'\e[38;5;226mAUTO\e[0m' ]]
}

@test "reads the plan of the given directory" {
  plan-directory() { echo "$1" >"$BATS_TMP_DIR/arg"; }
  bats_mock plan-directory

  run_segment /some/dir
  [[ "$(cat "$BATS_TMP_DIR/arg")" == "/some/dir" ]]
}

@test "calls plan-directory once" {
  plan-directory() {
    echo "call" >>"$BATS_TMP_DIR/calls"
    echo "/some/plan/dir"
  }
  plan-badge() { echo "PLAN_BADGE"; }
  ralph-mode() { echo "auto"; }
  bats_mock plan-directory plan-badge ralph-mode

  run_segment /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$(wc -l <"$BATS_TMP_DIR/calls")" -eq 1 ]]
}
