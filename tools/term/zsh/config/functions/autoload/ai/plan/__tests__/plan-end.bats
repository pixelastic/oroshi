bats_load_library 'helper'

# Setup: create a plan dir as a git repo with an initial commit and a dirty file
setup() {
  bats_tmp_dir
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR"
}

_mock_plan_repo() {
  local planDir="$MOCK_OROSHI_PLANS_DIR/repo--my-feature"
  git init --initial-branch=main --quiet "$planDir"
  git -C "$planDir" config user.email "bats@oroshi"
  git -C "$planDir" config user.name "Bats"
  git -C "$planDir" commit --allow-empty --quiet --message="init"

  # Add a dirty file so there's something to commit
  echo "state" > "$planDir/state.json"

  echo "$planDir"
}

@test "exits 1 when plan directory doesn't exist" {
  bats_run_zsh "plan-end /nonexistent/path"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"plan directory"* ]]
}

@test "commits all plan files to the plan's own git repo" {
  local planDir="$(_mock_plan_repo)"

  git-commit-message() { echo "plan: update"; }
  claude-stop() { :; }
  bats_mock git-commit-message claude-stop

  bats_run_zsh "plan-end $planDir"
  [[ "$status" -eq 0 ]]

  # Plan repo has a new commit (2 total: init + plan-end)
  [[ "$(git -C "$planDir" log --oneline | wc -l)" -eq 2 ]]
}

@test "plan repo working tree is clean after commit" {
  local planDir="$(_mock_plan_repo)"

  git-commit-message() { echo "plan: update"; }
  claude-stop() { :; }
  bats_mock git-commit-message claude-stop

  bats_run_zsh "plan-end $planDir"
  [[ "$status" -eq 0 ]]

  # No uncommitted changes
  [[ -z "$(git -C "$planDir" status --porcelain)" ]]
}

@test "calls claude-stop" {
  local planDir="$(_mock_plan_repo)"

  git-commit-message() { echo "plan: update"; }
  claude-stop() { echo "stopped" > "$BATS_TMP_DIR/claude-stopped.txt"; }
  bats_mock git-commit-message claude-stop

  bats_run_zsh "plan-end $planDir"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/claude-stopped.txt" ]]
}
