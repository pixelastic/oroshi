bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls notion-api with the correct blocks endpoint for the given page ID" {
  notion-api() {
    echo "$*" > "$BATS_TMP_DIR/api.log"
    echo '{"object":"list","results":[]}'
  }
  bats_mock notion-api

  bats_run_zsh "phone-pickup-read abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/api.log")" == *"blocks/abc-123/children"* ]]
}

@test "forwards raw JSON from notion-api to stdout unchanged" {
  notion-api() { echo '{"object":"list","results":[{"id":"block-1"}]}'; }
  bats_mock notion-api

  bats_run_zsh "phone-pickup-read abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '{"object":"list","results":[{"id":"block-1"}]}' ]]
}

@test "exits non-zero when called without arguments" {
  bats_run_zsh "phone-pickup-read"
  [[ "$status" -ne 0 ]]
}
