bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs a JSON array with id, date, tags, and title per entry" {
  bats_mock_env "NOTION_PHONE_DB_ID" "test-db-id"
  notion() {
    echo '{"results":[{"id":"page-id-1","properties":{"Date":{"date":{"start":"2026-07-06"}},"Tags":{"multi_select":[{"name":"ai"},{"name":"work"}]},"Name":{"title":[{"plain_text":"My Note"}]}}}]}'
  }
  bats_mock notion

  bats_run_zsh "phone-pickup-list"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e 'type == "array"'
  echo "$output" | jq -e '.[0] | keys == ["date","id","tags","title"]'
  echo "$output" | jq -e '.[0].tags | type == "array"'
}

@test "exits non-zero when NOTION_PHONE_DB_ID is unset" {
  bats_run_zsh "unset NOTION_PHONE_DB_ID && phone-pickup-list"
  [[ "$status" -ne 0 ]]
}
