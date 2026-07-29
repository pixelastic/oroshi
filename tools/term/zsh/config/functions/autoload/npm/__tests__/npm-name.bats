bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
}

@test "returns the package name when root package.json is public" {
  mkdir -p "$BATS_TMP_DIR/project"
  echo '{"name": "my-pkg"}' > "$BATS_TMP_DIR/project/package.json"

  yarn-package-is-private() { return 1; }
  yarn-package-name() { echo "my-pkg"; }
  bats_mock yarn-package-is-private yarn-package-name

  bats_run_zsh "npm-name $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-pkg" ]]
}

@test "returns 1 when no package.json exists at the path" {
  mkdir -p "$BATS_TMP_DIR/empty"

  bats_run_zsh "npm-name $BATS_TMP_DIR/empty"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns 1 when root is private with no workspaces" {
  mkdir -p "$BATS_TMP_DIR/private"
  echo '{"name": "my-pkg", "private": true}' > "$BATS_TMP_DIR/private/package.json"

  yarn-package-is-private() { return 0; }
  bats_mock yarn-package-is-private

  bats_run_zsh "npm-name $BATS_TMP_DIR/private"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns 1 when root is private monorepo but lib is not in workspaces" {
  mkdir -p "$BATS_TMP_DIR/monorepo"
  echo '{"name": "my-mono", "private": true, "workspaces": ["packages/*"]}' \
    > "$BATS_TMP_DIR/monorepo/package.json"

  yarn-package-is-private() { return 0; }
  bats_mock yarn-package-is-private

  bats_run_zsh "npm-name $BATS_TMP_DIR/monorepo"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns the lib package name when root is private monorepo with lib workspace and lib is public" {
  mkdir -p "$BATS_TMP_DIR/monorepo/lib"
  echo '{"name": "my-mono", "private": true, "workspaces": ["lib"]}' \
    > "$BATS_TMP_DIR/monorepo/package.json"
  echo '{"name": "@scope/lib"}' > "$BATS_TMP_DIR/monorepo/lib/package.json"

  # Private root, public lib
  yarn-package-is-private() {
    [[ "$1" == *"/lib" ]] && return 1
    return 0
  }
  yarn-package-name() { echo "@scope/lib"; }
  bats_mock yarn-package-is-private yarn-package-name

  bats_run_zsh "npm-name $BATS_TMP_DIR/monorepo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "@scope/lib" ]]
}

@test "returns 1 when root is private monorepo with lib workspace but lib is also private" {
  mkdir -p "$BATS_TMP_DIR/monorepo/lib"
  echo '{"name": "my-mono", "private": true, "workspaces": ["lib"]}' \
    > "$BATS_TMP_DIR/monorepo/package.json"
  echo '{"name": "@scope/lib", "private": true}' \
    > "$BATS_TMP_DIR/monorepo/lib/package.json"

  yarn-package-is-private() { return 0; }
  bats_mock yarn-package-is-private

  bats_run_zsh "npm-name $BATS_TMP_DIR/monorepo"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}
