bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  export OROSHI_WORKTREE_ARCHIVES_DIR="$BATS_TMP_DIR/worktrees/_ARCHIVES"

  # The plan directory of the worktree
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  export PLAN_DIR="$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  mkdir -p "$PLAN_DIR"
  plan-directory() { echo "$PLAN_DIR"; }
  bats_mock plan-directory
  bats_disable_worktree_aware
}

# Commit in the worktree, and record the commit as pushed in commits.json
# Usage: commit_and_record "message"
commit_and_record() {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "$1"
  local hash="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD)"
  local recorded="[]"
  [[ -f "$PLAN_DIR/commits.json" ]] && recorded="$(cat "$PLAN_DIR/commits.json")"
  echo "$recorded" | jq --arg hash "$hash" '. + [$hash]' > "$PLAN_DIR/commits.json"
}

@test "moves plan dir to archive entry" {
  commit_and_record "work"
  echo "# PRD" > "$PLAN_DIR/PRD.md"
  echo '{}' > "$PLAN_DIR/state.json"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  # Plan files present in archive entry
  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ -f "$entry/PRD.md" ]]
  [[ -f "$entry/state.json" ]]
  [[ -f "$entry/commits.json" ]]

  # Original plan dir is gone
  [[ ! -d "$PLAN_DIR" ]]
}

@test "generates COMMITS.md with commit hash, date, subject, and separator" {
  commit_and_record "add feature"
  commit_and_record "fix typo"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  local commits="$(cat "$entry/COMMITS.md")"

  # Contains both commits (oldest first)
  [[ "$commits" == *"add feature"*"fix typo"* ]]

  # Contains hash + date format
  [[ "$commits" =~ [a-f0-9]{7,}\ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]

  # Contains separator
  [[ "$commits" == *"---"* ]]
}

@test "lists the pushed commits even after they are merged into main" {
  commit_and_record "add feature"
  git -C "$BATS_GIT_DIR" merge --ff-only --quiet feature

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ "$(cat "$entry/COMMITS.md")" == *"add feature"* ]]
}

@test "only lists the pushed commits, not the unpushed ones" {
  commit_and_record "pushed work"
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unpushed work"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ "$(cat "$entry/COMMITS.md")" == *"pushed work"* ]]
  [[ "$(cat "$entry/COMMITS.md")" != *"unpushed work"* ]]
}

@test "creates archive entry with COMMITS.md for a worktree with no plan" {
  # Only commits.json in the plan dir, no state.json
  commit_and_record "work"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  local entry
  entry="$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -name '*_my-repo--feature' -print -quit)"
  [[ -d "$entry" ]]
  [[ -f "$entry/COMMITS.md" ]]
}

@test "skips archive when no commit was pushed" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unpushed work"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]

  # No archive entry created
  [[ -z "$(find "$OROSHI_WORKTREE_ARCHIVES_DIR" -maxdepth 1 -mindepth 1 2>/dev/null)" ]]
}

@test "preserves plan dir when skipping archive" {
  echo "# PRD" > "$PLAN_DIR/PRD.md"

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-archive '${BATS_GIT_WORKTREES}my-repo--feature'"
  [[ "$status" -eq 0 ]]
  [[ -d "$PLAN_DIR" ]]
  [[ -f "$PLAN_DIR/PRD.md" ]]
}
