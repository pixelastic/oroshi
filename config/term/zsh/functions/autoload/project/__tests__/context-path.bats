bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  mkdir -p "${BATS_GIT_DIR}/src/foo"
}

teardown() {
  bats_cleanup
}

@test "returns sub-path relative to context root with no leading slash" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-path ${BATS_GIT_DIR}/src/foo"
  [ "$status" -eq 0 ]
  [ "$output" = "src/foo" ]
}

@test "returns empty string for path at context root" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-path ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "returns empty string for path outside all known projects" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=; context-path /tmp/unregistered-dir"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
