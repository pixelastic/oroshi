bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "converts JSONL to JSON array file, exit 0" {
  printf '{"a":1}\n{"b":2}\n' > "$BATS_TMP_DIR/test.jsonl"
  bats_run_zsh "jsonl2json $BATS_TMP_DIR/test.jsonl"
  [[ "$status" -eq 0 ]]
  local result="$(jq 'length' "$BATS_TMP_DIR/test.json")"
  [[ "$result" = "2" ]]
}

@test "output file has .json extension, exit 0" {
  printf '{"x":1}\n' > "$BATS_TMP_DIR/data.jsonl"
  bats_run_zsh "jsonl2json $BATS_TMP_DIR/data.jsonl"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/data.json" ]]
}
