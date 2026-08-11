bats_load_library 'helper'

@test "extracts hostname from http URL" {
  bats_run_zsh "url2host 'http://example.com/path/to/page'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "example.com" ]]
}

@test "extracts hostname from https URL" {
  bats_run_zsh "url2host 'https://docs.github.com/en/actions'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "docs.github.com" ]]
}

@test "extracts hostname from URL with port" {
  bats_run_zsh "url2host 'http://localhost:3000/api'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "localhost" ]]
}

@test "extracts hostname from URL with query string" {
  bats_run_zsh "url2host 'https://search.com/q?term=hello&lang=en'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "search.com" ]]
}
