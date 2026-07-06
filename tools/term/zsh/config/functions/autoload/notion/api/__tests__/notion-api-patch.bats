bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits non-zero when NOTION_TOKEN is unset" {
  bats_run_zsh "unset NOTION_TOKEN && notion-api-patch pages/abc '{}'"
  [[ "$status" -ne 0 ]]
}

@test "passes NOTION_TOKEN in Authorization header" {
  bats_mock_env "NOTION_TOKEN" "secret-token"
  curl() { echo "$@" > "$BATS_TMP_DIR/curl.log"; }
  bats_mock curl

  bats_run_zsh "notion-api-patch pages/abc '{}'"
  [[ "$(cat "$BATS_TMP_DIR/curl.log")" == *"Bearer secret-token"* ]]
}
