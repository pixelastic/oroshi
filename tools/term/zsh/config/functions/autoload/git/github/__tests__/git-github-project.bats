bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
}

@test "returns owner/name from SSH GitHub URL" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-github-project"
	[ "$status" -eq 0 ]
	[ "$output" = "pixelastic/testrepo" ]
}

@test "returns owner/name from HTTPS GitHub URL" {
	bats_git remote remove origin
	bats_git remote add origin https://github.com/pixelastic/testrepo.git
	bats_run_zsh "cd $BATS_GIT_DIR && git-github-project"
	[ "$status" -eq 0 ]
	[ "$output" = "pixelastic/testrepo" ]
}

@test "returns owner/name when given a path argument" {
	bats_run_zsh "git-github-project $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "pixelastic/testrepo" ]
}

@test "returns owner/name for a specific --remote" {
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_run_zsh "cd $BATS_GIT_DIR && git-github-project --remote upstream"
	[ "$status" -eq 0 ]
	[ "$output" = "other/testrepo" ]
}

@test "returns owner/name with path and --remote combined" {
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_run_zsh "git-github-project $BATS_GIT_DIR --remote upstream"
	[ "$status" -eq 0 ]
	[ "$output" = "other/testrepo" ]
}

@test "returns 1 when no remote" {
	bats_git remote remove origin
	bats_run_zsh "cd $BATS_GIT_DIR && git-github-project"
	[ "$status" -eq 1 ]
}
