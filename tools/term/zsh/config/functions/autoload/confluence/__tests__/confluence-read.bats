bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_CONFLUENCE_EMAIL" "me@example.com"
  bats_mock_env "OROSHI_CONFLUENCE_API_TOKEN" "secret-token"
  bats_mock_env "OROSHI_CONFLUENCE_CLOUD_ID" "cloud-123"
  bats_mock_env "STUB_HTTP_STATUS" "200"
}

# Stub curl to return a fixture body followed by the HTTP status on its own line
stub_curl() {
  bats_mock_env "STUB_HTTP_BODY" "$BATS_TEST_DIRNAME/fixtures/$1"
  curl() {
    cat "$STUB_HTTP_BODY"
    printf '\n%s' "$STUB_HTTP_STATUS"
  }
  bats_mock curl
}

@test "prints a page with a link and a heading as Markdown" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read 123456"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"## Getting started"* ]]
  [[ "$output" == *"[documentation](https://example.com/docs)"* ]]
}

@test "prints a usage error when no id is given" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: confluence-read <id>"* ]]
}

@test "fails with the API error and prints no Markdown on 404" {
  stub_curl "page-with-link.json"
  bats_mock_env "STUB_HTTP_STATUS" "404"

  bats_run_zsh "confluence-read 123456"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"404"* ]]
  [[ "$output" != *"Getting started"* ]]
}

@test "prints a page with a list as Markdown" {
  stub_curl "page-with-list.json"

  bats_run_zsh "confluence-read 654321"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"## Checklist"* ]]
  [[ "$output" == *"- First item"* ]]
}
