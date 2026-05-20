load '../../../__tests__/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  mkdir -p "$TMP_DIRECTORY/prd-dir"
  # Prepend worktree bin so local ralph-end is found before any installed version
  export PATH="$BATS_TEST_DIRNAME/../claude/ralph:$PATH"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "writes .ralph-done when prd.json has open issues" {
  echo '[{"id":"1","description":"foo","status":"open"}]' > "$TMP_DIRECTORY/prd-dir/prd.json"
  run ralph-end "$TMP_DIRECTORY/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/prd-dir/.ralph-done" ]
  [ ! -f "$TMP_DIRECTORY/prd-dir/.ralph-prd-done" ]
}

@test "writes both sentinels when all issues are complete" {
  echo '[{"id":"1","description":"foo","status":"complete"}]' > "$TMP_DIRECTORY/prd-dir/prd.json"
  run ralph-end "$TMP_DIRECTORY/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/prd-dir/.ralph-done" ]
  [ -f "$TMP_DIRECTORY/prd-dir/.ralph-prd-done" ]
}

@test "writes only .ralph-done when prd.json is absent" {
  run ralph-end "$TMP_DIRECTORY/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/prd-dir/.ralph-done" ]
  [ ! -f "$TMP_DIRECTORY/prd-dir/.ralph-prd-done" ]
}

@test "writes only .ralph-done when prd.json is malformed" {
  echo 'not valid json' > "$TMP_DIRECTORY/prd-dir/prd.json"
  run ralph-end "$TMP_DIRECTORY/prd-dir"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/prd-dir/.ralph-done" ]
  [ ! -f "$TMP_DIRECTORY/prd-dir/.ralph-prd-done" ]
}
