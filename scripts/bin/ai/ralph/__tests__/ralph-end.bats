bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
}

teardown() {
  bats_cleanup
}

@test "writes .ralph-done when prd.json has open issues" {
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/prd-dir/.ralph-done" ]
  [ ! -f "$BATS_TMP_DIR/prd-dir/.ralph-prd-done" ]
}

@test "writes both sentinels when all issues are complete" {
  echo '[{"id":"1","description":"foo","status":"complete"}]' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/prd-dir/.ralph-done" ]
  [ -f "$BATS_TMP_DIR/prd-dir/.ralph-prd-done" ]
}

@test "writes only .ralph-done when prd.json is absent" {
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/prd-dir/.ralph-done" ]
  [ ! -f "$BATS_TMP_DIR/prd-dir/.ralph-prd-done" ]
}

@test "writes only .ralph-done when prd.json is malformed" {
  echo 'not valid json' > "$BATS_TMP_DIR/prd-dir/prd.json"
  run ralph-end "$BATS_TMP_DIR/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/prd-dir/.ralph-done" ]
  [ ! -f "$BATS_TMP_DIR/prd-dir/.ralph-prd-done" ]
}
