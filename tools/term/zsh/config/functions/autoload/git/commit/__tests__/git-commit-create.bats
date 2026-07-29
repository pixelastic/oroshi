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
