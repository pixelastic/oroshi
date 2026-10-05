bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_CONFLUENCE_EMAIL" "me@example.com"
  bats_mock_env "OROSHI_CONFLUENCE_API_TOKEN" "secret-token"
  bats_mock_env "OROSHI_CONFLUENCE_CLOUD_ID" "cloud-123"
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
  [[ "$output" == *"Usage: confluence-read <url|id>"* ]]
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

@test "resolves a long page URL to its page id" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read https://algolia.atlassian.net/wiki/spaces/PAP/pages/4826628097/Mobility+Pass+Program"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == */wiki/api/v2/pages/4826628097\?body-format=storage ]]
}

@test "resolves the Vanta guide URL to its page id" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read https://algolia.atlassian.net/wiki/spaces/IT/pages/6208291016/Algolia+Vanta+Agent+Linux+User+Guide"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == */wiki/api/v2/pages/6208291016\?body-format=storage ]]
}

@test "accepts a bare numeric id" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read 4826628097"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == */wiki/api/v2/pages/4826628097\?body-format=storage ]]
}

@test "accepts a URL with a trailing slash" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read https://algolia.atlassian.net/wiki/spaces/PAP/pages/4826628097/"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == */wiki/api/v2/pages/4826628097\?body-format=storage ]]
}

@test "accepts a URL with a query string" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read 'https://algolia.atlassian.net/wiki/spaces/PAP/pages/4826628097/Mobility+Pass+Program?focusedCommentId=1'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/curl-url.txt")" == */wiki/api/v2/pages/4826628097\?body-format=storage ]]
}

@test "rejects text that is neither a page URL nor an id" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read not-a-page"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: confluence-read <url|id>"* ]]
  [[ ! -e "$BATS_TMP_DIR/curl-url.txt" ]]
}

@test "rejects a Confluence URL that has no page id" {
  stub_curl "page-with-link.json"

  bats_run_zsh "confluence-read https://algolia.atlassian.net/wiki/spaces/PAP/overview"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: confluence-read <url|id>"* ]]
}

@test "removes the panel macro comment" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"Unsupported macro: panel"* ]]
}

@test "removes the table of contents comment" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"Table of Contents"* ]]
}

@test "keeps content that follows a removed comment on the same line" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$output" == *"> "*"**Info:** Info body"* ]]
}

@test "leaves other unsupported macro comments visible" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$output" == *"Unsupported macro: jira"* ]]
}

@test "leaves headings, text and lists unchanged" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$output" == *"## Intro"* ]]
  [[ "$output" == *"Before"* ]]
  [[ "$output" == *"- First item"* ]]
  [[ "$output" == *"After"* ]]
}

@test "collapses the blank lines left by a removed comment" {
  stub_curl "page-with-macros.json"

  bats_run_zsh "confluence-read 789012"
  [[ "$output" != *$'\n\n\n'* ]]
}

@test "removes inline comment reference markers" {
  stub_curl "page-with-inline-comment.json"

  bats_run_zsh "confluence-read 345678"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"comment-ref"* ]]
  [[ "$output" == *"Run the agent now"* ]]
}
