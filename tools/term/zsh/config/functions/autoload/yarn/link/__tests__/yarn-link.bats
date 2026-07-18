bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Create a fake monorepo structure
  export MONOREPO_DIR="$BATS_TMP_DIR/monorepo"
  mkdir -p "$MONOREPO_DIR"
  echo '{"workspaces": ["modules/*"]}' > "$MONOREPO_DIR/package.json"

  mkdir -p "$MONOREPO_DIR/modules/alpha"
  echo '{"name": "alpha"}' > "$MONOREPO_DIR/modules/alpha/package.json"

  mkdir -p "$MONOREPO_DIR/modules/beta"
  echo '{"name": "beta"}' > "$MONOREPO_DIR/modules/beta/package.json"

  # Create a single-module structure
  SINGLE_DIR="$BATS_TMP_DIR/single"
  mkdir -p "$SINGLE_DIR"
  echo '{"name": "single-mod"}' > "$SINGLE_DIR/package.json"

  # Mock yarn-version-is-classic to always fail (= Berry mode)
  yarn-version-is-classic() { return 1; }

  # Track yarn-link-create calls
  yarn-link-create() { echo "$1" >> "$BATS_TMP_DIR/link-create-calls.txt"; }

  # Mock yarn-is-monorepo: succeeds only for the monorepo dir
  yarn-is-monorepo() {
    [[ "$1" == "$MONOREPO_DIR" ]]
  }

  # Mock yarn-workspace-list-raw to return workspace entries
  # Returns only public workspaces when --public is passed
  yarn-workspace-list-raw() {
    echo "$@" > "$BATS_TMP_DIR/workspace-list-raw-args.txt"
    echo "alpha▮modules/alpha▮Alpha module"
    echo "beta▮modules/beta▮Beta module"
    if [[ "$1" != "--public" ]]; then
      echo "docs▮modules/docs▮Documentation site"
    fi
  }

  bats_mock yarn-version-is-classic yarn-link-create yarn-is-monorepo yarn-workspace-list-raw
}

@test "monorepo path creates symlinks for all workspace modules" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $MONOREPO_DIR"
  [[ "$status" -eq 0 ]]

  # yarn-link-create called for each public workspace
  local expected="${MONOREPO_DIR}/modules/alpha
${MONOREPO_DIR}/modules/beta"
  [[ "$(cat "$BATS_TMP_DIR/link-create-calls.txt")" == "$expected" ]]
}

@test "monorepo path passes --public to yarn-workspace-list-raw" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $MONOREPO_DIR"
  [[ "$status" -eq 0 ]]

  # Verify --public flag was passed
  local args="$(cat "$BATS_TMP_DIR/workspace-list-raw-args.txt")"
  [[ "$args" == *"--public"* ]]
}

@test "monorepo linking skips private workspaces" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $MONOREPO_DIR"
  [[ "$status" -eq 0 ]]

  # Only public workspaces linked, not the private docs workspace
  local expected="${MONOREPO_DIR}/modules/alpha
${MONOREPO_DIR}/modules/beta"
  [[ "$(cat "$BATS_TMP_DIR/link-create-calls.txt")" == "$expected" ]]
}

@test "non-monorepo path creates a single symlink" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $SINGLE_DIR"
  [[ "$status" -eq 0 ]]

  # yarn-link-create called exactly once with the module path
  [[ "$(cat "$BATS_TMP_DIR/link-create-calls.txt")" == "$SINGLE_DIR" ]]
}
