bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "makes POST request with JSON file body" {
  # Create a test JSON file
  echo '{"key": "value"}' > "$BATS_TMP_DIR/body.json"

  http() { echo "$@" > "$BATS_TMP_DIR/http-args.txt"; }
  bats_mock http

  bats_run_zsh "http-post https://api.example.com/endpoint $BATS_TMP_DIR/body.json"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/http-args.txt")"
  [[ "$args" == *"POST"* ]]
  [[ "$args" == *"https://api.example.com/endpoint"* ]]
}
