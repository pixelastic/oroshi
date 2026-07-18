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
  yarn-workspace-list-raw() {
    echo "alpha▮modules/alpha▮Alpha module"
    echo "beta▮modules/beta▮Beta module"
  }

  bats_mock yarn-version-is-classic yarn-link-create yarn-is-monorepo yarn-workspace-list-raw
}

@test "monorepo path creates symlinks for all workspace modules" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $MONOREPO_DIR"
  [[ "$status" -eq 0 ]]

  # yarn-link-create called for each workspace
  [[ -f "$BATS_TMP_DIR/link-create-calls.txt" ]]
  local callCount="$(wc -l < "$BATS_TMP_DIR/link-create-calls.txt")"
  [[ "$callCount" -eq 2 ]]
}

@test "monorepo path passes absolute workspace paths to yarn-link-create" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $MONOREPO_DIR"
  [[ "$status" -eq 0 ]]

  # Each call should use the absolute workspace path
  grep -q "${MONOREPO_DIR}/modules/alpha" "$BATS_TMP_DIR/link-create-calls.txt"
  grep -q "${MONOREPO_DIR}/modules/beta" "$BATS_TMP_DIR/link-create-calls.txt"
}

@test "non-monorepo path creates a single symlink" {
  bats_run_zsh "cd $BATS_TMP_DIR && yarn-link $SINGLE_DIR"
  [[ "$status" -eq 0 ]]

  # yarn-link-create called exactly once
  [[ -f "$BATS_TMP_DIR/link-create-calls.txt" ]]
  local callCount="$(wc -l < "$BATS_TMP_DIR/link-create-calls.txt")"
  [[ "$callCount" -eq 1 ]]
  grep -q "$SINGLE_DIR" "$BATS_TMP_DIR/link-create-calls.txt"
}
