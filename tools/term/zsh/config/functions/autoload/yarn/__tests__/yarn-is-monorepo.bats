bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  # Monorepo: has workspaces in package.json
  export MONOREPO_DIR="$BATS_TMP_DIR/monorepo"
  mkdir -p "$MONOREPO_DIR/modules/lib"
  echo '{ "name": "my-monorepo", "workspaces": ["modules/*"] }' \
    > "$MONOREPO_DIR/package.json"

  # Non-monorepo: no workspaces
  export PLAIN_DIR="$BATS_TMP_DIR/plain"
  mkdir -p "$PLAIN_DIR"
  echo '{ "name": "my-project" }' \
    > "$PLAIN_DIR/package.json"

  # Mock yarn presence
  yarn() { :; }

  # Default mock: returns root only when called with a path argument
  git-directory-root() {
    [[ "$1" != "" ]] && echo "$MONOREPO_DIR" && return 0
    echo ""
  }
  bats_mock yarn git-directory-root
}

@test "returns 0 when given the root of a monorepo" {
  bats_run_zsh "yarn-is-monorepo $MONOREPO_DIR"
  [ "$status" -eq 0 ]
}

@test "returns 0 when given a sub-directory inside a monorepo" {
  bats_run_zsh "yarn-is-monorepo $MONOREPO_DIR/modules/lib"
  [ "$status" -eq 0 ]
}

@test "returns 1 when given a non-monorepo path" {
  git-directory-root() {
    [[ "$1" != "" ]] && echo "$PLAIN_DIR" && return 0
    echo ""
  }
  bats_mock git-directory-root

  bats_run_zsh "yarn-is-monorepo $PLAIN_DIR"
  [ "$status" -eq 1 ]
}

@test "returns 0 with no argument from inside a monorepo" {
  git-directory-root() { echo "$MONOREPO_DIR"; }
  bats_mock git-directory-root

  bats_run_zsh "cd $MONOREPO_DIR && yarn-is-monorepo"
  [ "$status" -eq 0 ]
}
