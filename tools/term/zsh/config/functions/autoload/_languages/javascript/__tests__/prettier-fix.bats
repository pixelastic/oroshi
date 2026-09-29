bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export PROJECT_DIR="$BATS_TMP_DIR/project"
  mkdir -p "$PROJECT_DIR/node_modules/.bin"

  # Global prettier records its arguments and prints a marker
  prettier() {
    printf '%s\n' "$*" > "$BATS_TMP_DIR/global_prettier_args"
    echo "formatted by global prettier"
  }
  # yarn-root resolves every file to $PROJECT_DIR
  yarn-root() { echo "$PROJECT_DIR"; }
  bats_mock prettier yarn-root
  bats_mock_env PROJECT_DIR "$PROJECT_DIR"
  bats_disable_worktree_aware

  # Local prettier leaves a marker file if it runs
  cat > "$PROJECT_DIR/node_modules/.bin/prettier" <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/local_prettier_args"
echo "formatted by local prettier"
SCRIPT
  chmod +x "$PROJECT_DIR/node_modules/.bin/prettier"
}

@test "runs the global prettier with the oroshi config when the project has a local binary but no config" {
  local file="$PROJECT_DIR/test.js"
  echo "const a=1" > "$file"

  bats_run_zsh "prettier-fix $file < /dev/null"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/local_prettier_args" ]]
  local args="$(< "$BATS_TMP_DIR/global_prettier_args")"
  [[ "$args" == *"--config $OROSHI_ROOT/prettier.config.js"* ]]
}

@test "runs the local prettier with the project config when the project has both" {
  local file="$PROJECT_DIR/test.js"
  echo "const a=1" > "$file"
  touch "$PROJECT_DIR/prettier.config.js"

  bats_run_zsh "prettier-fix $file < /dev/null"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/global_prettier_args" ]]
  local args="$(< "$BATS_TMP_DIR/local_prettier_args")"
  [[ "$args" == *"--config $PROJECT_DIR/prettier.config.js"* ]]
}

@test "prints the formatted file on stdout" {
  local file="$PROJECT_DIR/test.js"
  echo "const a=1" > "$file"

  bats_run_zsh "prettier-fix $file < /dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "formatted by global prettier" ]]
  local args="$(< "$BATS_TMP_DIR/global_prettier_args")"
  [[ "$args" == *"$file"* ]]
  [[ "$args" != *"--write"* ]]
}

@test "--in-place writes the file and prints nothing" {
  local file="$PROJECT_DIR/test.js"
  echo "const a=1" > "$file"

  bats_run_zsh "prettier-fix --in-place $file < /dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  local args="$(< "$BATS_TMP_DIR/global_prettier_args")"
  [[ "$args" == *"--write $file"* ]]
}

@test "formats piped content with --parser" {
  bats_run_zsh "echo 'const a=1' | prettier-fix --parser babel"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "formatted by global prettier" ]]
  local args="$(< "$BATS_TMP_DIR/global_prettier_args")"
  [[ "$args" == *"--parser babel"* ]]
}

@test "resolves the config from --filepath for piped content" {
  touch "$PROJECT_DIR/prettier.config.js"
  # The mock body runs in the zsh subprocess, so it spells the path out
  yarn-root() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/yarn_root_args"
    echo "$PROJECT_DIR"
  }
  bats_mock yarn-root

  bats_run_zsh "echo 'const a=1' | prettier-fix --filepath $PROJECT_DIR/src/real.js"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "formatted by local prettier" ]]
  [[ "$(< "$BATS_TMP_DIR/yarn_root_args")" == *"$PROJECT_DIR/src"* ]]
}

@test "fails when piped content has neither --parser nor --filepath" {
  bats_run_zsh "echo 'const a=1' | prettier-fix"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--filepath or --parser"* ]]
}
