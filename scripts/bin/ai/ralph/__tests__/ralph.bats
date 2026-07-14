bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  mkdir -p "$PRD_DIR"
}

@test "without --max, calls ralph-single with the directory" {
  ralph-single() { echo "SINGLE:$*"; }
  ralph-loop() { return 0; }
  bats_mock ralph-single ralph-loop

  bats_run_zsh "ralph $PRD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == "SINGLE:${PRD_DIR}" ]]
}

@test "with --max N, calls ralph-loop with the directory and count" {
  ralph-single() { return 0; }
  ralph-loop() { echo "LOOP:$*"; }
  bats_mock ralph-single ralph-loop

  bats_run_zsh "ralph --max 3 $PRD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == "LOOP:${PRD_DIR} 3" ]]
}

@test "no arg + worktree has plan → auto-detects plans dir" {
  ralph-single() { echo "SINGLE:$*"; }
  ralph-loop() { return 0; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-single ralph-loop plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [ "$status" -eq 0 ]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}/plans/feat_my-feature" ]]
}

@test "no arg + cwd inside plan subdir → path not doubled" {
  local planDir="$BATS_TMP_DIR/plans/feat_my-feature"
  mkdir -p "$planDir"
  ralph-single() { echo "SINGLE:$*"; }
  ralph-loop() { return 0; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-single ralph-loop plan-directory

  bats_run_zsh "cd $planDir && ralph"
  [ "$status" -eq 0 ]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}/plans/feat_my-feature" ]]
}

@test "no arg + no worktree plan → fallback to cwd" {
  ralph-single() { echo "SINGLE:$*"; }
  ralph-loop() { return 0; }
  plan-directory() { return 1; }
  bats_mock ralph-single ralph-loop plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [ "$status" -eq 0 ]
  [[ "$output" == "SINGLE:${BATS_TMP_DIR}" ]]
}
