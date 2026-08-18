bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'
	echo "hello" > "$BATS_GIT_DIR/tracked.txt"
	bats_git add tracked.txt
	bats_git commit --quiet -m "add tracked"
}

@test "creates a commit in target repo when called with --repo /path" {
	echo "change" >> "$BATS_GIT_DIR/tracked.txt"
	git -C "$BATS_GIT_DIR" add --all

	bats_run_zsh "git-commit-create --repo $BATS_GIT_DIR 'test commit'"
	[[ "$status" -eq 0 ]]

	# Verify commit was created in the target repo
	local lastMessage="$(git -C "$BATS_GIT_DIR" log -1 --format=%s)"
	[[ "$lastMessage" == "test commit" ]]
}

@test "calls plan-commit with message and repo path after successful commit" {
	plan-commit() { echo "$@" > "$BATS_TMP_DIR/plan-commit-args"; }
	bats_mock plan-commit
	bats_disable_worktree_aware

	echo "change" >> "$BATS_GIT_DIR/tracked.txt"
	git -C "$BATS_GIT_DIR" add --all

	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-create 'my commit'"
	[[ "$status" -eq 0 ]]

	# plan-commit called with commit message and repo root
	[[ "$(cat "$BATS_TMP_DIR/plan-commit-args")" == "my commit $BATS_GIT_DIR" ]]
}

@test "plan-commit not called when worktree commit fails" {
	plan-commit() { echo "called" > "$BATS_TMP_DIR/plan-commit-called"; }
	bats_mock plan-commit
	bats_disable_worktree_aware

	# Nothing staged — commit will fail
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-create 'my commit'"
	[[ "$status" -ne 0 ]]

	# plan-commit was never called
	[[ ! -f "$BATS_TMP_DIR/plan-commit-called" ]]
}

@test "passes --repo target to plan-commit, not cwd" {
	plan-commit() { echo "$@" > "$BATS_TMP_DIR/plan-commit-args"; }
	bats_mock plan-commit

	echo "change" >> "$BATS_GIT_DIR/tracked.txt"
	git -C "$BATS_GIT_DIR" add --all

	bats_run_zsh "git-commit-create --repo $BATS_GIT_DIR 'my commit'"
	[[ "$status" -eq 0 ]]

	# plan-commit receives the --repo path
	[[ "$(cat "$BATS_TMP_DIR/plan-commit-args")" == "my commit $BATS_GIT_DIR" ]]
}
