bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls notion-api-post with databases query endpoint and correct DB ID" {
  bats_mock_env "NOTION_PHONE_DB_ID" "test-db-id"
  notion-api-post() {
    echo "$*" > "$BATS_TMP_DIR/api.log"
    echo '{"object":"list"}'
  }
  bats_mock notion-api-post

  bats_run_zsh "phone-pickup-list"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/api.log")" == *"databases/test-db-id/query"* ]]
}

@test "forwards raw JSON from notion-api-post to stdout unchanged" {
  bats_mock_env "NOTION_PHONE_DB_ID" "test-db-id"
  notion-api-post() { echo '{"object":"list","results":[]}'; }
  bats_mock notion-api-post

  bats_run_zsh "phone-pickup-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '{"object":"list","results":[]}' ]]
}

@test "exits non-zero when NOTION_PHONE_DB_ID is unset" {
  bats_run_zsh "unset NOTION_PHONE_DB_ID && phone-pickup-list"
  [[ "$status" -ne 0 ]]
}
