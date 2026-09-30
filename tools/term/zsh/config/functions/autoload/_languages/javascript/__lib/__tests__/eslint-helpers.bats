bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
  export PROJECT_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$PROJECT_DIR"
}

# Install the eslint package under the given directory
add_eslint_install() {
  mkdir -p "$1/node_modules/eslint"
}

# Create a workspace whose package.json declares eslint as a devDependency
add_eslint_workspace() {
  local workspaceDirectory="$PROJECT_DIR/$1"
  mkdir -p "$workspaceDirectory"
  jo devDependencies="$(jo eslint=9.39.2)" > "$workspaceDirectory/package.json"
}

# Create a workspace whose package.json declares no eslint
add_plain_workspace() {
  local workspaceDirectory="$PROJECT_DIR/$1"
  mkdir -p "$workspaceDirectory"
  jo name=plain > "$workspaceDirectory/package.json"
}

# Mock workspace enumeration to emit the given relative paths, rooted at PROJECT_DIR
mock_workspaces() {
  local lines=""
  local relativePath
  for relativePath in "$@"; do
    lines+="pkg▮${relativePath}▮\n"
  done

  git-directory-root() { echo "$PROJECT_DIR"; }
  yarn-workspace-list-raw() { printf '%b' "$WORKSPACE_LINES"; }
  bats_mock git-directory-root yarn-workspace-list-raw
  bats_mock_env WORKSPACE_LINES "$lines"
  bats_disable_worktree_aware
}

# __eslint-root

@test "__eslint-root returns the project root when eslint is installed at the project root" {
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR" ]]
}

@test "__eslint-root returns the sub-workspace when only that workspace declares eslint" {
  add_eslint_workspace "modules/lint"
  add_plain_workspace "modules/app"
  mock_workspaces "modules/app" "modules/lint"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/modules/lint" ]]
}

@test "__eslint-root returns the first workspace that declares eslint when several do" {
  add_eslint_workspace "packages/lint"
  add_eslint_workspace "tools/lint"
  mock_workspaces "packages/lint" "tools/lint"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/packages/lint" ]]
}

@test "__eslint-root falls back to the bundled root when no workspace declares eslint" {
  add_plain_workspace "modules/app"
  mock_workspaces "modules/app"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT" ]]
}

@test "__eslint-root falls back to the bundled root when there is no project" {
  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT" ]]
}
