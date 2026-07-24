bats_load_library 'helper'

setup() {
  # Mock all collaborators — isolate dispatcher branching logic
  is-js() { return 1; }
  is-python() { return 1; }
  js-test-path() { return 1; }
  python-test-path() { return 1; }
  bats-test-path() { return 1; }
  bats_mock is-js is-python js-test-path python-test-path bats-test-path
}

@test "JS file: dispatches to js-test-path" {
  is-js() { return 0; }
  js-test-path() { echo "/some/__tests__/module.js"; }
  bats_mock is-js js-test-path

  bats_run_zsh "test-path /some/module.js"
  [ "$status" -eq 0 ]
  [ "$output" = "/some/__tests__/module.js" ]
}

@test "Python file: dispatches to python-test-path" {
  is-python() { return 0; }
  python-test-path() { echo "/some/__tests__/test_module.py"; }
  bats_mock is-python python-test-path

  bats_run_zsh "test-path /some/module.py"
  [ "$status" -eq 0 ]
  [ "$output" = "/some/__tests__/test_module.py" ]
}

@test "ZSH file: falls back to bats-test-path" {
  bats-test-path() { echo "/some/__tests__/my-func.bats"; }
  bats_mock bats-test-path

  bats_run_zsh "test-path /some/my-func"
  [ "$status" -eq 0 ]
  [ "$output" = "/some/__tests__/my-func.bats" ]
}

@test ".bats file: early return 1, no output" {
  bats_run_zsh "test-path /some/__tests__/my-func.bats"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "unrecognized file type: falls to bats-test-path, returns 1 if no test" {
  bats_run_zsh "test-path /some/readme.md"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "no argument: returns 1, no output" {
  bats_run_zsh "test-path"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}
