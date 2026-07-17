bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
}

@test "returns url from cwd" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-url"
	[ "$status" -eq 0 ]
	[ "$output" = "git@github.com:pixelastic/testrepo.git" ]
}

@test "returns url for named remote from cwd" {
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-url upstream"
	[ "$status" -eq 0 ]
	[ "$output" = "git@github.com:other/testrepo.git" ]
}

@test "returns url with --repo path" {
	bats_run_zsh "git-remote-url --repo $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "git@github.com:pixelastic/testrepo.git" ]
}

@test "returns url for named remote with --repo path" {
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_run_zsh "git-remote-url upstream --repo $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "git@github.com:other/testrepo.git" ]
}
