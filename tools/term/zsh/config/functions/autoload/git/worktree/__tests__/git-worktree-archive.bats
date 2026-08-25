bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
  # Hard-coded as $OROSHI_WORKTREES_DIR/_ARCHIVES; direct export for before merge
  export OROSHI_WORKTREE_ARCHIVES_DIR="$BATS_TMP_DIR/worktrees/_ARCHIVES"
}

@test "moves plan dir to archive entry" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "work"

  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  echo "# PRD" > "$MOCK_OROSHI_PLANS_DIR/my-repo--feature/PRD.md"
  echo '{}' > "$MOCK_OROSHI_PLANS_DIR/my-repo--feature/state.json"

  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"; }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  # Plan files present in archive entry
  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ -f "$entry/PRD.md" ]]
  [[ -f "$entry/state.json" ]]

  # Original plan dir is gone
  [[ ! -d "$MOCK_OROSHI_PLANS_DIR/my-repo--feature" ]]
}

@test "generates COMMITS.md with commit hash, date, subject, and separator" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "add feature"
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "fix typo"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  local commits="$(cat "$entry/COMMITS.md")"

  # Contains both commits (--reverse: oldest first)
  [[ "$commits" == *"add feature"* ]]
  [[ "$commits" == *"fix typo"* ]]

  # Contains hash + date format
  [[ "$commits" =~ [a-f0-9]{7,}\ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]

  # Contains separator
  [[ "$commits" == *"---"* ]]
}

@test "creates archive entry with COMMITS.md for planless worktree" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "work"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ -d "$entry" ]]
  [[ -f "$entry/COMMITS.md" ]]
}

@test "skips archive when branch has no commits ahead of main" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  # No archive entry created
  [[ -z "$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -mindepth 1 2>/dev/null)" ]]
}

@test "preserves plan dir when skipping archive" {
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  echo "# PRD" > "$MOCK_OROSHI_PLANS_DIR/my-repo--feature/PRD.md"

  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"; }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]
  [[ -d "$MOCK_OROSHI_PLANS_DIR/my-repo--feature" ]]
  [[ -f "$MOCK_OROSHI_PLANS_DIR/my-repo--feature/PRD.md" ]]
}
