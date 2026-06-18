bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# ── No session ───────────────────────────────────────────────────────────────

@test "exits 1 when plan directory does not exist" {
  run ralph-is-running "$BATS_TMP_DIR/nonexistent"
  [ "$status" -eq 1 ]
}

@test "exits 1 when plan directory exists but has no ralph.json" {
  mkdir -p "$BATS_TMP_DIR/myplan"
  run ralph-is-running "$BATS_TMP_DIR/myplan"
  [ "$status" -eq 1 ]
}

# ── Session active ────────────────────────────────────────────────────────────

@test "exits 0 when ralph.json exists" {
  mkdir -p "$BATS_TMP_DIR/myplan"
  touch "$BATS_TMP_DIR/myplan/ralph.json"
  run ralph-is-running "$BATS_TMP_DIR/myplan"
  [ "$status" -eq 0 ]
}

# ── Default inference ─────────────────────────────────────────────────────────

@test "exits 0 when called with no argument and session is active" {
  local planDir="$BATS_TMP_DIR/plans/my-branch"
  mkdir -p "$planDir"
  jo mode=single done=false prd_done=false >"$planDir/ralph.json"

  git-directory-root() { echo "$BATS_TMP_DIR"; }
  git-branch-current() { echo "my-branch"; }
  git-branch-slug() { echo "my-branch"; }
  bats_mock git-directory-root git-branch-current git-branch-slug

  bats_run_zsh "ralph-is-running"
  [ "$status" -eq 0 ]
}
