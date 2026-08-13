bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  PROJECT_DIR="$BATS_TMP_DIR/project"
  CLONE_BASE="$BATS_TMP_DIR/tmp/deprecate"
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR/tmp"

  # Default mocks: project in projects.jsonc, on disk, pixelastic owner, no npm
  project-exists() { return 0; }
  project-path() { echo "$BATS_TMP_DIR/project"; }
  git-github-project-owner() { echo "pixelastic"; }
  git-github-project-name() { echo "testproject"; }
  git-github-repo-exists() { return 0; }
  git-github-repo-description() { echo "A test project"; }
  git-github-repo-is-archived() { return 1; }
  npm-is-published() { return 1; }
  npm-is-deprecated() { return 1; }
  npm-is-logged-in() { return 1; }
  git-directory-sync() {
    echo "sync" >> "$BATS_TMP_DIR/sync-calls.log"
    mkdir -p "$2"
  }
  bats_mock project-exists project-path git-github-project-owner \
    git-github-project-name git-github-repo-exists git-github-repo-description \
    git-github-repo-is-archived npm-is-published npm-is-deprecated \
    npm-is-logged-in git-directory-sync
}

# --- Lookup paths ---

@test "project in projects.jsonc with path on disk" {
  mkdir -p "$PROJECT_DIR"

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'
  expect_json '.inProjectsJsonc' 'true'
  expect_json '.github.owner' 'pixelastic'
  expect_json '.github.repo' 'testproject'
  expect_json '.github.description' 'A test project'
  expect_json '.github.isArchived' 'false'
  expect_json '.clonedAt' "$PROJECT_DIR"
  # No clone needed
  [[ ! -f "$BATS_TMP_DIR/sync-calls.log" ]]
}

@test "project in projects.jsonc but path not on disk clones to temp" {
  # PROJECT_DIR not created — path doesn't exist
  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'
  expect_json '.inProjectsJsonc' 'true'
  expect_json '.github.owner' 'pixelastic'
  expect_json '.clonedAt' "$CLONE_BASE/testproject"
  [[ -f "$BATS_TMP_DIR/sync-calls.log" ]]
}

@test "project not in projects.jsonc but on GitHub" {
  project-exists() { return 1; }
  bats_mock project-exists

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'
  expect_json '.inProjectsJsonc' 'false'
  expect_json '.github.owner' 'pixelastic'
  expect_json '.github.repo' 'testproject'
  expect_json '.clonedAt' "$CLONE_BASE/testproject"
}

@test "not in projects.jsonc and not on GitHub returns not-found" {
  project-exists() { return 1; }
  git-github-repo-exists() { return 1; }
  bats_mock project-exists git-github-repo-exists

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'not-found'
}

@test "non-pixelastic owner on disk does not clone" {
  mkdir -p "$PROJECT_DIR"
  git-github-project-owner() { echo "someoneelse"; }
  bats_mock git-github-project-owner

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.github.owner' 'someoneelse'
  expect_json '.clonedAt' "$PROJECT_DIR"
  [[ ! -f "$BATS_TMP_DIR/sync-calls.log" ]]
}

# --- Temp clone idempotency ---

@test "git-directory-sync handles idempotent clone to temp" {
  project-exists() { return 1; }
  bats_mock project-exists

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.clonedAt' "$CLONE_BASE/testproject"
  # git-directory-sync was called
  [[ -f "$BATS_TMP_DIR/sync-calls.log" ]]
}

# --- npm detection ---

@test "npm fields set when published and not private" {
  mkdir -p "$PROJECT_DIR"
  echo '{"name": "testproject"}' > "$PROJECT_DIR/package.json"

  npm-is-published() { return 0; }
  npm-is-deprecated() { return 1; }
  npm-is-logged-in() { return 0; }
  bats_mock npm-is-published npm-is-deprecated npm-is-logged-in

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.npmPackage' 'testproject'
  expect_json '.npmIsDeprecated' 'false'
  expect_json '.npmIsLoggedIn' 'true'
}

@test "npm null when package is private" {
  mkdir -p "$PROJECT_DIR"
  echo '{"name": "testproject", "private": true}' > "$PROJECT_DIR/package.json"

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json_null '.npmPackage'
}

@test "npm null when no package.json" {
  mkdir -p "$PROJECT_DIR"

  bats_run_zsh "deprecate-prepare testproject"
  [[ "$status" -eq 0 ]]
  expect_json_null '.npmPackage'
  expect_json_null '.npmIsDeprecated'
  expect_json_null '.npmIsLoggedIn'
}
