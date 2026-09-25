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

# Plan dir as a git repo with an initial commit and a dirty file
_mock_plan_repo() {
	local planDirectory="$MOCK_OROSHI_PLANS_DIR/repo--my-feature"
	git init --initial-branch=main --quiet "$planDirectory"
	git -C "$planDirectory" config user.email "bats@oroshi"
	git -C "$planDirectory" config user.name "Bats"
	git -C "$planDirectory" commit --allow-empty --quiet --message="init"

	# Add a dirty file so there's something to commit
	echo "state" > "$planDirectory/state.json"

	echo "$planDirectory"
}

# Worktree matching the plan dir, set as the current Context Root
_mock_in_worktree() {
	local worktreeDirectory="$MOCK_OROSHI_WORKTREES_DIR/repo--my-feature"
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

@test "in worktree: calls claude-stop with --next ralph" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_worktree
	_mock_side_effects

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "claude-stop --next ralph" ]]
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

# Git Repo Main case

# Worktree on branch feat/my-feature, while the Context Root is the Git Repo Main
_mock_in_main() {
	local worktreeDirectory="$MOCK_OROSHI_WORKTREES_DIR/repo--my-feature"
	git init --initial-branch=feat/my-feature --quiet "$worktreeDirectory"
	git -C "$worktreeDirectory" -c user.email="bats@oroshi" -c user.name="Bats" \
		commit --allow-empty --quiet --message="init"
	echo "$BATS_TMP_DIR/main" > "$BATS_TMP_DIR/context-root.txt"
	echo "$worktreeDirectory"
}

# Record each kitty-tab-create / claude-stop argument on its own line
_mock_record_args() {
	kitty-tab-create() {
		echo "kitty-tab-create" >> "$BATS_TMP_DIR/calls.txt"
		printf "%s\n" "$@" > "$BATS_TMP_DIR/tab-args.txt"
	}
	claude-stop() {
		echo "claude-stop" >> "$BATS_TMP_DIR/calls.txt"
		printf "%s\n" "$@" > "$BATS_TMP_DIR/stop-args.txt"
	}
	bats_mock kitty-tab-create claude-stop
}

@test "in main: creates a Kitty tab titled with the Branch Slug, focused, with cwd set to the Worktree" {
	local planDirectory="$(_mock_plan_repo)"
	local worktreeDirectory="$(_mock_in_main)"
	_mock_side_effects
	_mock_record_args

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	local -a tabArgs
	mapfile -t tabArgs < "$BATS_TMP_DIR/tab-args.txt"
	[[ "${tabArgs[0]}" == "feat_my-feature" ]]
	[[ " ${tabArgs[*]} " == *" --focus "* ]]
	[[ " ${tabArgs[*]} " == *" --cwd $worktreeDirectory "* ]]
}

@test "in main: the new tab's command runs ralph in an interactive zsh that stays open" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_main > /dev/null
	_mock_side_effects
	_mock_record_args

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	# --cmd value follows the --cmd flag
	local tabCommand="$(grep --after-context=1 "^--cmd$" "$BATS_TMP_DIR/tab-args.txt" | tail -n 1)"
	[[ "$tabCommand" == "zsh -ic 'ralph; exec zsh'" ]]
}

@test "in main: calls claude-stop with --next and a message naming the tab" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_main > /dev/null
	_mock_side_effects
	_mock_record_args

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]

	[[ "$(head -n 1 "$BATS_TMP_DIR/stop-args.txt")" == "--next" ]]
	tail -n +2 "$BATS_TMP_DIR/stop-args.txt" > "$BATS_TMP_DIR/next.txt"

	# Queued command prints the message, apostrophe included
	bats_run_zsh "eval \"\$(<$BATS_TMP_DIR/next.txt)\""
	[[ "$output" == "Plan lancé dans l'onglet feat_my-feature" ]]
}

@test "in main: creates the tab before stopping claude" {
	local planDirectory="$(_mock_plan_repo)"
	_mock_in_main > /dev/null
	_mock_side_effects
	_mock_record_args

	bats_run_zsh "plan-end $planDirectory"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/calls.txt")" == $'kitty-tab-create\nclaude-stop' ]]
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
