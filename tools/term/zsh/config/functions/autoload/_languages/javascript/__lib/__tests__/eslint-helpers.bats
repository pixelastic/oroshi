bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
  export PROJECT_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$PROJECT_DIR"
}

# Install a fake eslint binary under the given directory
add_eslint_install() {
  mkdir -p "$1/node_modules/.bin"
  touch "$1/node_modules/.bin/eslint"
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

# __eslint-root

@test "__eslint-root returns the project root when it has a config and eslint installed" {
  touch "$PROJECT_DIR/eslint.config.js"
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR" ]]
}

@test "__eslint-root accepts a legacy .eslintrc.js config" {
  touch "$PROJECT_DIR/.eslintrc.js"
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR" ]]
}

@test "__eslint-root returns the workspace when only that workspace has eslint installed" {
  touch "$PROJECT_DIR/eslint.config.js"
  add_eslint_install "$PROJECT_DIR/modules/lint"
  mock_workspaces "modules/app" "modules/lint"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/modules/lint" ]]
}

@test "__eslint-root falls back to the bundled root when the project has eslint but no config" {
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-root $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT" ]]
}

@test "__eslint-root falls back to the bundled root when the project has a config but no eslint" {
  touch "$PROJECT_DIR/eslint.config.js"
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

# __eslint-config

@test "__eslint-config returns the project config when it also has eslint installed" {
  touch "$PROJECT_DIR/eslint.config.js"
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR/eslint.config.js" ]]
}

@test "__eslint-config returns the project .eslintrc.js when it also has eslint installed" {
  touch "$PROJECT_DIR/.eslintrc.js"
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR/.eslintrc.js" ]]
}

@test "__eslint-config prefers eslint.config.js over .eslintrc.js" {
  touch "$PROJECT_DIR/eslint.config.js" "$PROJECT_DIR/.eslintrc.js"
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config $PROJECT_DIR"
  [[ "$output" == "$PROJECT_DIR/eslint.config.js" ]]
}

@test "__eslint-config returns the oroshi config when the project has a config but no eslint" {
  touch "$PROJECT_DIR/eslint.config.js"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config $PROJECT_DIR"
  [[ "$output" == "$OROSHI_ROOT/eslint.config.js" ]]
}

@test "__eslint-config returns the oroshi config when the project has eslint but no config" {
  add_eslint_install "$PROJECT_DIR"

  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config $PROJECT_DIR"
  [[ "$output" == "$OROSHI_ROOT/eslint.config.js" ]]
}

@test "__eslint-config returns the oroshi config when there is no project" {
  bats_run_zsh "source $LIB_DIR/eslint-helpers.zsh && __eslint-config ''"
  [[ "$output" == "$OROSHI_ROOT/eslint.config.js" ]]
}
