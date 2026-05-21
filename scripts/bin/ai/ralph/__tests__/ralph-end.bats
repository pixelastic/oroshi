bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
}

teardown() {
  bats_cleanup
}

@test "does nothing in single-shot mode" {
  ralph-state "$PRD_DIR" init single
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$PRD_DIR/prd.json"
  run ralph-end "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$(ralph-state "$PRD_DIR" get done)" != "true" ]
  [ "$(ralph-state "$PRD_DIR" get prd_done)" != "true" ]
}

@test "sets done=true in loop mode with open issues" {
  ralph-state "$PRD_DIR" init loop
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$PRD_DIR/prd.json"
  run ralph-end "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$(ralph-state "$PRD_DIR" get done)" = "true" ]
  [ "$(ralph-state "$PRD_DIR" get prd_done)" != "true" ]
}

@test "sets done=true and prd_done=true in loop mode when all issues complete" {
  ralph-state "$PRD_DIR" init loop
  echo '[{"id":"1","description":"foo","passes":true}]' > "$PRD_DIR/prd.json"
  run ralph-end "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$(ralph-state "$PRD_DIR" get done)" = "true" ]
  [ "$(ralph-state "$PRD_DIR" get prd_done)" = "true" ]
}

@test "sets only done=true in loop mode when prd.json is absent" {
  ralph-state "$PRD_DIR" init loop
  run ralph-end "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$(ralph-state "$PRD_DIR" get done)" = "true" ]
  [ "$(ralph-state "$PRD_DIR" get prd_done)" != "true" ]
}

@test "sets only done=true in loop mode when prd.json is malformed" {
  ralph-state "$PRD_DIR" init loop
  echo 'not valid json' > "$PRD_DIR/prd.json"
  run ralph-end "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$(ralph-state "$PRD_DIR" get done)" = "true" ]
  [ "$(ralph-state "$PRD_DIR" get prd_done)" != "true" ]
}

