bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_CONFLUENCE_EMAIL" "me@example.com"
  bats_mock_env "OROSHI_CONFLUENCE_API_TOKEN" "secret-token"
  bats_mock_env "OROSHI_CONFLUENCE_CLOUD_ID" "cloud-123"
  bats_mock_env "OROSHI_CONFLUENCE_DOMAIN" "example.atlassian.net"
  bats_mock_env "STUB_HTTP_STATUS" "200"
}

# Stub curl to log the requested URL, then return a fixture body followed by the HTTP status on its own line
stub_curl() {
  bats_mock_env "STUB_HTTP_BODY" "$BATS_TEST_DIRNAME/fixtures/$1"
  bats_mock_env "STUB_CURL_LOG" "$BATS_TMP_DIR/curl-url.txt"
  curl() {
    print -r -- "${@[-1]}" > "$STUB_CURL_LOG"
    cat "$STUB_HTTP_BODY"
    printf '\n%s' "$STUB_HTTP_STATUS"
  }
  bats_mock curl
}

@test "prints a JSON array with id, title, space, url and excerpt" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search 'mobility pass'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output 'length' <<< "$output")" == "2" ]]
  [[ "$(jq --raw-output '.[0].id' <<< "$output")" == "111" ]]
  [[ "$(jq --raw-output '.[0].title' <<< "$output")" == "Mobility Pass Program" ]]
  [[ "$(jq --raw-output '.[0].space' <<< "$output")" == "People and Places" ]]
  [[ "$(jq --raw-output '.[0].url' <<< "$output")" == "https://example.atlassian.net/wiki/spaces/PAP/pages/111/Mobility+Pass+Program" ]]
}

@test "removes highlight markers from excerpts" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search 'mobility pass'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.[0].excerpt' <<< "$output")" == "Apply for the mobility pass today" ]]
  [[ "$output" != *"@@@"* ]]
}

@test "prints an empty array when nothing matches" {
  stub_curl "search-empty.json"

  bats_run_zsh "confluence-search nothing"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' <<< "$output")" == "[]" ]]
}

@test "uses a limit of 25 by default" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search pass"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == *"limit=25"* ]]
}

@test "passes --limit 5 to the request" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search --limit 5 pass"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == *"limit=5"* ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" != *"limit=25"* ]]
}

@test "restricts the search to pages so attachments are not listed" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search pass"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == *"type%20%3D%20page"* ]]
}

@test "prints a usage error when no query is given" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: confluence-search [--limit N] <query>"* ]]
}

@test "escapes double quotes and backslashes in the query" {
  stub_curl "search-results.json"

  bats_run_zsh "confluence-search 'say \"hi\" a\\b'"
  [[ "$status" -eq 0 ]]
  # Encoded form of: text ~ "say \"hi\" a\\b"
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == *"%22say%20%5C%22hi%5C%22%20a%5C%5Cb%22"* ]]
}
