bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns HTTP headers for a given URL" {
  curl() {
    echo "HTTP/2 200"
    echo "content-type: text/html"
  }
  bats_mock curl

  bats_run_zsh "http-header https://example.com"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"HTTP/2 200"* ]]
  [[ "$output" == *"content-type: text/html"* ]]
}
