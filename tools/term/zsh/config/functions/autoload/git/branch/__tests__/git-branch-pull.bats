bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'

	# Create a bare remote and push main to it
	BARE_REMOTE="$BATS_TMP_DIR/bare-remote.git"
	git init --bare "$BARE_REMOTE" --quiet
	bats_git remote add origin "$BARE_REMOTE"
	bats_git push --quiet --set-upstream origin main

	# Publish new commits from a second clone, so there is something to pull:
	# one on main and one on a develop branch
	local otherClone="$BATS_TMP_DIR/other-clone"
	git clone --quiet "$BARE_REMOTE" "$otherClone"
	git -C "$otherClone" config user.email "bats@oroshi"
	git -C "$otherClone" config user.name "Bats"
	echo "main content" >"$otherClone/main.txt"
	git -C "$otherClone" add main.txt
	git -C "$otherClone" commit --quiet --message="update main"
	git -C "$otherClone" push --quiet origin main
	git -C "$otherClone" checkout --quiet -b develop
	echo "develop content" >"$otherClone/develop.txt"
	git -C "$otherClone" add develop.txt
	git -C "$otherClone" commit --quiet --message="add develop"
	git -C "$otherClone" push --quiet origin develop

	# Dependencies update is out of scope here
	git-dependencies-update() { :; }
	bats_mock git-dependencies-update
	bats_disable_worktree_aware
}

@test "pulls the current branch without the flag" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_GIT_DIR/main.txt" ]]
	[[ "$output" != *"Enumerating objects"* ]]
}

@test "prints git progress lines when pulling the current branch with --progress" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull --progress"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_GIT_DIR/main.txt" ]]
	[[ "$output" == *"Enumerating objects"* ]]
}

@test "prints git progress lines and switches when pulling another branch with --progress" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull develop --progress"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Enumerating objects"* ]]
	[[ "$(bats_git branch --show-current)" == "develop" ]]
	[[ -f "$BATS_GIT_DIR/develop.txt" ]]
}

@test "accepts --progress before the branch name" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull --progress develop"
	[[ "$status" -eq 0 ]]
	[[ "$(bats_git branch --show-current)" == "develop" ]]
}

@test "fails when the branch is missing on the remote, with or without --progress" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull missing"
	local statusWithout="$status"
	[[ "$statusWithout" -ne 0 ]]

	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-pull missing --progress"
	[[ "$status" -eq "$statusWithout" ]]
}
