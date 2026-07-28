bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
}

@test "returns 0 when package is private" {
  echo '{"name": "my-pkg", "private": true}' > "$BATS_TMP_DIR/package.json"

  bats_run_zsh "yarn-package-is-private $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when package is not private" {
  echo '{"name": "my-pkg"}' > "$BATS_TMP_DIR/package.json"

  bats_run_zsh "yarn-package-is-private $BATS_TMP_DIR"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when private is false" {
  echo '{"name": "my-pkg", "private": false}' > "$BATS_TMP_DIR/package.json"

  bats_run_zsh "yarn-package-is-private $BATS_TMP_DIR"
  [[ "$status" -eq 1 ]]
}
