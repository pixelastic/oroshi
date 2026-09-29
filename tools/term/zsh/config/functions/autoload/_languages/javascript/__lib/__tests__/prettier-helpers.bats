bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
  export PROJECT_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$PROJECT_DIR"
}

add_local_binary() {
  mkdir -p "$PROJECT_DIR/node_modules/.bin"
  touch "$PROJECT_DIR/node_modules/.bin/prettier"
}

# __prettier-config

@test "__prettier-config returns the oroshi config when there is no project" {
  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-config ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/prettier.config.js" ]]
}

@test "__prettier-config returns the oroshi config when the project has no prettier config" {
  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-config $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/prettier.config.js" ]]
}

@test "__prettier-config returns the project prettier.config.js when present" {
  touch "$PROJECT_DIR/prettier.config.js"

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-config $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/prettier.config.js" ]]
}

@test "__prettier-config returns the project .prettierrc.js when present" {
  touch "$PROJECT_DIR/.prettierrc.js"

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-config $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/.prettierrc.js" ]]
}

@test "__prettier-config prefers prettier.config.js over .prettierrc.js" {
  touch "$PROJECT_DIR/prettier.config.js"
  touch "$PROJECT_DIR/.prettierrc.js"

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-config $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/prettier.config.js" ]]
}

# __prettier-binary

@test "__prettier-binary returns the global prettier when there is no project" {
  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-binary ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "prettier" ]]
}

@test "__prettier-binary returns the global prettier when the project has a local binary but no config" {
  add_local_binary

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-binary $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "prettier" ]]
}

@test "__prettier-binary returns the local binary when the project has a local binary and a config" {
  add_local_binary
  touch "$PROJECT_DIR/prettier.config.js"

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-binary $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$PROJECT_DIR/node_modules/.bin/prettier" ]]
}

@test "__prettier-binary returns the global prettier when the project has a config but no local binary" {
  touch "$PROJECT_DIR/prettier.config.js"

  bats_run_zsh "source $LIB_DIR/prettier-helpers.zsh && __prettier-binary $PROJECT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "prettier" ]]
}
