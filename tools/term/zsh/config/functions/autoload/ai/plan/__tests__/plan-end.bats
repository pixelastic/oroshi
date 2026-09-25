bats_load_library 'helper'

# Setup: isolated plans + worktrees stores
setup() {
	bats_tmp_dir
	# Mocking OROSHI_WORKTREES_DIR defeats worktree detection, so lock the root
	bats_disable_worktree_aware
	export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
	export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
	mkdir -p "$MOCK_OROSHI_PLANS_DIR" "$MOCK_OROSHI_WORKTREES_DIR"
}

# Plan dir (optional name) as a git repo with an initial commit and a dirty file
_mock_plan_repo() {
	local planDirectory="$MOCK_OROSHI_PLANS_DIR/${1:-repo--my-feature}"
	git init --initial-branch=main --quiet "$planDirectory"
	git -C "$planDirectory" config user.email "bats@oroshi"
	git -C "$planDirectory" config user.name "Bats"
	git -C "$planDirectory" commit --allow-empty --quiet --message="init"

	# Add a dirty file so there's something to commit
	echo "state" > "$planDirectory/state.json"

	echo "$planDirectory"
}

# Worktree (optional name) matching the plan dir, set as the current Context Root
_mock_in_worktree() {
	local worktreeDirectory="$MOCK_OROSHI_WORKTREES_DIR/${1:-repo--my-feature}"
	mkdir -p "$worktreeDirectory"
	echo "$worktreeDirectory" > "$BATS_TMP_DIR/context-root.txt"
}

# Side-effect mocks shared by all tests; calls recorded in calls.txt
_mock_side_effects() {
	claude-api() { echo "plan(my-feature): update plan artifacts"; }
	context-root() { cat "$BATS_TMP_DIR/context-root.txt" 2>/dev/null; }
	claude-stop() { echo "claude-stop $*" >> "$BATS_TMP_DIR/calls.txt"; }
	kitty-notify() { echo "kitty-notify $*" >> "$BATS_TMP_DIR/calls.txt"; }
	kitty-tab-create() { echo "kitty-tab-create $*" >> "$BATS_TMP_DIR/calls.txt"; }
	bats_mock claude-api context-root claude-stop kitty-notify kitty-tab-create
}

# Guards

@test "exits 1 when plan directory doesn't exist" {
	bats_run_zsh "plan-end /nonexistent/path"
	[[ "$status" -eq 1 ]]
	[[ "$output" == *"plan directory"* ]]
}

# Commit

@test "commits all plan files to the plan's own git repo" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	# Plan repo has a new commit (2 total: init + plan-end)
	[[ "$(git -C "$planDirectory" log --oneline | wc -l)" -eq 2 ]]
}

@test "plan repo working tree is clean after commit" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	# No uncommitted changes
	[[ -z "$(git -C "$planDirectory" status --porcelain)" ]]
}

@test "commit message comes from git-commit-message, not hardcoded" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_side_effects
	claude-api() { echo "plan(my-feature): add PRD and issues"; }
	bats_mock claude-api

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	# Commit message matches what claude-api returned
	local lastMessage="$(git -C "$planDirectory" log -1 --format=%s)"
	[[ "$lastMessage" == "plan(my-feature): add PRD and issues" ]]
}

# In-worktree case

@test "in worktree: calls claude-stop with --next and the ralph command for the plan directory" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_worktree
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "claude-stop --next claude '/ralph $planDirectory'" ]]
}

@test "in worktree: queued ralph command survives quotes and spaces in the plan directory" {
	local planName="repo--it's my-feat"
	local planDirectory="$(_mock_plan_repo "$planName")"
	_mock_in_worktree "$planName"
	_mock_side_effects
	claude-stop() { printf "%s\n" "$2" > "$BATS_TMP_DIR/next.txt"; }
	bats_mock claude-stop

	bats_run_zsh "plan-end ${planDirectory@Q}"
	[[ "$status" -eq 0 ]]

	# Re-parse the queued command: argument must round-trip untouched
	bats_run_zsh "local -a words=(\${(z)\"\$(<$BATS_TMP_DIR/next.txt)\"}); print -r -- \${(Q)words[2]}"
	[[ "$output" == "/ralph $planDirectory" ]]
}

@test "in worktree: does not create a Kitty tab" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_worktree
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	run grep --count "^kitty-tab-create" "$BATS_TMP_DIR/calls.txt"
	[[ "$output" == "0" ]]
}

# Outside worktree case

@test "outside worktree: calls plain claude-stop" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "claude-stop " ]]
}

@test "outside worktree: calls plain claude-stop when Worktree exists elsewhere" {
	local planDirectory="$(_mock_plan_repo)"
	mkdir -p "$MOCK_OROSHI_WORKTREES_DIR/repo--my-feature"
	echo "$BATS_TMP_DIR/elsewhere" > "$BATS_TMP_DIR/context-root.txt"
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "claude-stop " ]]
}

# Notification

@test "does not call kitty-notify" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_worktree
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	run grep --count "^kitty-notify" "$BATS_TMP_DIR/calls.txt"
	[[ "$output" == "0" ]]
}
