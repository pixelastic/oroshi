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
