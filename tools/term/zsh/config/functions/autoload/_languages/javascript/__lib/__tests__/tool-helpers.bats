bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
  export PROJECT_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$PROJECT_DIR"
}

# Install a fake binary of the tool under the given directory
add_binary() {
  mkdir -p "$1/node_modules/.bin"
  touch "$1/node_modules/.bin/$2"
}

# Mock workspace enumeration to emit the given relative paths, rooted at PROJECT_DIR
mock_workspaces() {
  local lines=""
  local relativePath
  for relativePath in "$@"; do
    mkdir -p "$PROJECT_DIR/$relativePath"
    lines+="pkg▮${relativePath}▮\n"
  done

  git-directory-root() { echo "$PROJECT_DIR"; }
  yarn-workspace-list-raw() { printf '%b' "$WORKSPACE_LINES"; }
  bats_mock git-directory-root yarn-workspace-list-raw
  bats_mock_env WORKSPACE_LINES "$lines"
  bats_disable_worktree_aware
}

# __tool-root

@test "__tool-root returns the project root when the binary is at the project root" {
  add_binary "$PROJECT_DIR" mytool

  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR" ]]
}

@test "__tool-root prefers the project root over a workspace" {
  add_binary "$PROJECT_DIR" mytool
  add_binary "$PROJECT_DIR/modules/lint" mytool
  mock_workspaces "modules/lint"

  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR" ]]
}

@test "__tool-root returns the workspace when only that workspace has the binary" {
  add_binary "$PROJECT_DIR/modules/lint" mytool
  mock_workspaces "modules/app" "modules/lint"

  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/modules/lint" ]]
}

@test "__tool-root returns the first workspace that has the binary when several do" {
  add_binary "$PROJECT_DIR/packages/lint" mytool
  add_binary "$PROJECT_DIR/tools/lint" mytool
  mock_workspaces "packages/lint" "tools/lint"

  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR/packages/lint" ]]
}

@test "__tool-root ignores a binary of another tool" {
  add_binary "$PROJECT_DIR" othertool
  add_binary "$PROJECT_DIR/modules/lint" othertool
  mock_workspaces "modules/lint"

  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "__tool-root returns nothing when there is no project" {
  bats_run_zsh "source $LIB_DIR/tool-helpers.zsh && __tool-root mytool ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
