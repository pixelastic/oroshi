bats_load_library 'helper'

setup() {
  :
}

@test "writes message to stderr" {
  bats_run_zsh "echoerr 'hello' 2>&1 1>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "writes nothing to stdout" {
  bats_run_zsh "echoerr 'hello' 2>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "passes -n flag to suppress newline" {
  bats_run_zsh "echoerr -n 'hello' 2>&1 1>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "handles multiple arguments" {
  bats_run_zsh "echoerr 'hello' 'world' 2>&1 1>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello world" ]]
}
