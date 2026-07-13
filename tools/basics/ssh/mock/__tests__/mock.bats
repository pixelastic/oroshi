bats_load_library 'helper'

# Start the Docker SSH container once for all tests (idempotent)
setup_file() {
  bats_ssh_mock_start
}

setup() {
  bats_tmp_dir
}

@test "scp transfers a file from local to the expected path on the mock host" {
  echo "hello from local" > "$BATS_TMP_DIR/input.txt"
  run scp "$BATS_TMP_DIR/input.txt" "mock:$BATS_TMP_DIR/output.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/output.txt" ]]
  [[ "$(cat "$BATS_TMP_DIR/output.txt")" = "hello from local" ]]
}

@test "ssh executes a command on the mock host and returns its output" {
  run ssh mock "echo hello"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}
