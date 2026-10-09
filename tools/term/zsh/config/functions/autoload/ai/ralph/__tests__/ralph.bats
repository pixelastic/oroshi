bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  mkdir -p "$PRD_DIR"
}

@test "calls ralph-single with the directory" {
  ralph-single() { echo "SINGLE:$*"; }
  bats_mock ralph-single

  bats_run_zsh "ralph $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "SINGLE:${PRD_DIR}" ]]
}

@test "no arg + worktree has plan → auto-detects plans dir" {
  ralph-single() { echo "SINGLE:$*"; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-single plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}/plans/feat_my-feature" ]]
}

@test "no arg + cwd inside plan subdir → path not doubled" {
  local planDir="$BATS_TMP_DIR/plans/feat_my-feature"
  mkdir -p "$planDir"
  ralph-single() { echo "SINGLE:$*"; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-single plan-directory

  bats_run_zsh "cd $planDir && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}/plans/feat_my-feature" ]]
}

@test "no arg + no worktree plan → fallback to cwd" {
  ralph-single() { echo "SINGLE:$*"; }
  plan-directory() { return 1; }
  bats_mock ralph-single plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}" ]]
}
