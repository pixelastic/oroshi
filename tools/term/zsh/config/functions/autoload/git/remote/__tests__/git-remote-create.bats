bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'
	bats_git remote add origin git@github.com:pixelastic/my-repo.git
}

@test "fails when no remote name given" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-create"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"must pass the name"* ]]
}

@test "creates remote with explicit url" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-create upstream git@github.com:other/my-repo.git"
	[[ "$status" -eq 0 ]]

	local url="$(git -C "$BATS_GIT_DIR" remote get-url upstream)"
	[[ "$url" == "git@github.com:other/my-repo.git" ]]
}

@test "creates remote by deriving url from origin when no url given" {
	# Mock git-remote-colorize to avoid color dependency
	git-remote-colorize() { echo "$1"; }
	bats_mock git-remote-colorize
	bats_disable_worktree_aware

	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-create tim"
	[[ "$status" -eq 0 ]]

	local url="$(git -C "$BATS_GIT_DIR" remote get-url tim)"
	[[ "$url" == "git@github.com:tim/my-repo.git" ]]
}

@test "enables prune on created remote" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-create upstream git@github.com:other/my-repo.git"
	[[ "$status" -eq 0 ]]

	local prune="$(git -C "$BATS_GIT_DIR" config remote.upstream.prune)"
	[[ "$prune" == "true" ]]
}
