bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export RALPH_STATE_FILE="$BATS_TMP_DIR/prd-dir/.ralph-state.json"
}

teardown() {
  bats_cleanup
}

@test "does nothing in single-shot mode" {
  ralph-state init single
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ "$(ralph-state get done)" != "true" ]
  [ "$(ralph-state get prd_done)" != "true" ]
}

@test "sets done=true in loop mode with open issues" {
  ralph-state init loop
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ "$(ralph-state get done)" = "true" ]
  [ "$(ralph-state get prd_done)" != "true" ]
}

@test "sets done=true and prd_done=true in loop mode when all issues complete" {
  ralph-state init loop
  echo '[{"id":"1","description":"foo","status":"complete"}]' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ "$(ralph-state get done)" = "true" ]
  [ "$(ralph-state get prd_done)" = "true" ]
}

@test "sets only done=true in loop mode when prd.json is absent" {
  ralph-state init loop
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ "$(ralph-state get done)" = "true" ]
  [ "$(ralph-state get prd_done)" != "true" ]
}

@test "sets only done=true in loop mode when prd.json is malformed" {
  ralph-state init loop
  echo 'not valid json' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ "$(ralph-state get done)" = "true" ]
  [ "$(ralph-state get prd_done)" != "true" ]
}
