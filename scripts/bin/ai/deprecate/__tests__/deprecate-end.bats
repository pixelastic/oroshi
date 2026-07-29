bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  CLONE_DIRECTORY="$BATS_TMP_DIR/clone"
  mkdir -p "$CLONE_DIRECTORY/.github"
  echo '{"extends": ["config:base"]}' > "$CLONE_DIRECTORY/.github/renovate.json"

  # Default state: everything needs to be done
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=true \
    github="$(jo owner=pixelastic repo=testproject description="A test project" isArchived=false)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=testproject \
    npmIsDeprecated=false \
    npmIsLoggedIn=true \
  )"

  # Mock deprecate-prepare to return controlled JSON
  deprecate-prepare() { echo "$PREPARE_JSON"; }

  # Mock all action helpers — log calls to a file
  git-github-repo-description-set() {
    echo "description-set $*" >> "$BATS_TMP_DIR/calls.log"
  }
  git-github-repo-archive() { echo "archive $*" >> "$BATS_TMP_DIR/calls.log"; }
  npm-is-logged-in() { return 0; }
  npm-deprecate() { echo "npm-deprecate $*" >> "$BATS_TMP_DIR/calls.log"; }
  project-remove() { echo "project-remove $*" >> "$BATS_TMP_DIR/calls.log"; }
  projects-build() { echo "projects-build" >> "$BATS_TMP_DIR/calls.log"; }

  # Mock git helpers for commit+push inside cloned repo
  git-directory-is-dirty() { return 0; }
  git-commit-create-all() { echo "commit-create-all $*" >> "$BATS_TMP_DIR/calls.log"; }
  git-branch-push() { echo "branch-push $*" >> "$BATS_TMP_DIR/calls.log"; }

  bats_mock deprecate-prepare git-github-repo-description-set \
    git-github-repo-archive npm-is-logged-in npm-deprecate \
    project-remove projects-build git-directory-is-dirty \
    git-commit-create-all git-branch-push
}

# --- Happy path ---

@test "calls all steps in order and returns ok" {
  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'

  # Renovate disabled
  [[ "$(cat "$CLONE_DIRECTORY/.github/renovate.json")" == '{"enabled":false}' ]]

  # All steps called in order
  local calls="$(cat "$BATS_TMP_DIR/calls.log")"
  [[ "$calls" == *"commit-create-all"* ]]
  [[ "$calls" == *"branch-push"* ]]
  [[ "$calls" == *"description-set pixelastic/testproject"* ]]
  [[ "$calls" == *"archive pixelastic/testproject"* ]]
  [[ "$calls" == *"npm-deprecate testproject"* ]]
  [[ "$calls" == *"project-remove testproject"* ]]
  [[ "$calls" == *"projects-build"* ]]
}

# --- Idempotency ---

@test "skips GitHub block when isArchived is true" {
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=false \
    github="$(jo owner=pixelastic repo=testproject description="A test project" isArchived=true)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=null \
    npmIsDeprecated=false \
    npmIsLoggedIn=true \
  )"
  deprecate-prepare() { echo "$PREPARE_JSON"; }
  bats_mock deprecate-prepare

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'

  # No GitHub calls
  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"commit-create-all"* ]]
    [[ "$calls" != *"branch-push"* ]]
    [[ "$calls" != *"description-set"* ]]
    [[ "$calls" != *"archive"* ]]
  }
}

@test "skips npm block when npmIsDeprecated is true" {
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=false \
    github="$(jo owner=pixelastic repo=testproject description="A test project" isArchived=true)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=testproject \
    npmIsDeprecated=true \
    npmIsLoggedIn=true \
  )"
  deprecate-prepare() { echo "$PREPARE_JSON"; }
  bats_mock deprecate-prepare

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ok'

  # No npm calls
  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"npm-deprecate"* ]]
  }
}

@test "skips npm block when npmPackage is null" {
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=false \
    github="$(jo owner=pixelastic repo=testproject description="A test project" isArchived=true)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=null \
  )"
  deprecate-prepare() { echo "$PREPARE_JSON"; }
  bats_mock deprecate-prepare

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]

  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"npm-deprecate"* ]]
  }
}

@test "skips projects.jsonc block when inProjectsJsonc is false" {
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=false \
    github="$(jo owner=pixelastic repo=testproject description="A test project" isArchived=true)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=null \
  )"
  deprecate-prepare() { echo "$PREPARE_JSON"; }
  bats_mock deprecate-prepare

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]

  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"project-remove"* ]]
    [[ "$calls" != *"projects-build"* ]]
  }
}

@test "skips commit+push when no uncommitted changes" {
  git-directory-is-dirty() { return 1; }
  bats_mock git-directory-is-dirty

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/calls.log")"
  [[ "$calls" != *"commit-create-all"* ]]
  [[ "$calls" != *"branch-push"* ]]
  # But description-set and archive still called
  [[ "$calls" == *"description-set"* ]]
  [[ "$calls" == *"archive"* ]]
}

@test "skips description update when already prefixed with [DEPRECATED]" {
  export PREPARE_JSON="$(jo \
    status=ok \
    projectName=testproject \
    inProjectsJsonc=false \
    github="$(jo owner=pixelastic repo=testproject description="[DEPRECATED] A test project" isArchived=false)" \
    clonedAt="$CLONE_DIRECTORY" \
    npmPackage=null \
  )"
  deprecate-prepare() { echo "$PREPARE_JSON"; }
  bats_mock deprecate-prepare

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/calls.log")"
  [[ "$calls" != *"description-set"* ]]
  # But archive still called
  [[ "$calls" == *"archive"* ]]
}

# --- Fail-fast ---

@test "stops and returns error JSON when a step fails" {
  git-github-repo-archive() { return 1; }
  bats_mock git-github-repo-archive

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -ne 0 ]]
  expect_json '.status' 'error'
  expect_json '.step' 'archive'

  # npm and projects steps not reached
  local calls="$(cat "$BATS_TMP_DIR/calls.log")"
  [[ "$calls" != *"npm-deprecate"* ]]
  [[ "$calls" != *"project-remove"* ]]
}

@test "does not execute subsequent steps after failure" {
  npm-deprecate() { return 1; }
  bats_mock npm-deprecate

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -ne 0 ]]
  expect_json '.status' 'error'
  expect_json '.step' 'npm-deprecate'

  # projects steps not reached
  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"project-remove"* ]]
  }
}

# --- npm auth guard ---

@test "fails with error when npm-is-logged-in returns false" {
  npm-is-logged-in() { return 1; }
  bats_mock npm-is-logged-in

  bats_run_zsh "deprecate-end testproject"
  [[ "$status" -ne 0 ]]
  expect_json '.status' 'error'
  expect_json '.step' 'npm-auth'

  # npm-deprecate not called
  [[ ! -f "$BATS_TMP_DIR/calls.log" ]] || {
    local calls="$(cat "$BATS_TMP_DIR/calls.log")"
    [[ "$calls" != *"npm-deprecate"* ]]
  }
}
