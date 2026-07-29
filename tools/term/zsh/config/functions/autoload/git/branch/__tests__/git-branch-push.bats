bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'

	# Create a bare remote to push to
	BARE_REMOTE="$BATS_TMP_DIR/bare-remote.git"
	git init --bare "$BARE_REMOTE" --quiet
	bats_git remote add origin "$BARE_REMOTE"
}

@test "pushes current branch of target repo when called with --repo /path" {
	bats_run_zsh "git-branch-push --repo $BATS_GIT_DIR"
	[[ "$status" -eq 0 ]]

	# Verify the branch was pushed to the bare remote
	local remoteBranch="$(git -C "$BARE_REMOTE" branch --list main)"
	[[ "$remoteBranch" == *"main"* ]]
}
