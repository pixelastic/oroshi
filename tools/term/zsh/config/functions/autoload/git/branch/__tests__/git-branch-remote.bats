bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_git config branch.main.remote upstream
}

@test "returns remote of current branch from cwd" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}

@test "returns remote of named branch from cwd" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote main"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}

@test "returns remote from --repo path" {
	bats_run_zsh "git-branch-remote --repo $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}

@test "returns remote of named branch with --repo path" {
	bats_run_zsh "git-branch-remote main --repo $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}

@test "defaults to origin when branch has no remote configured" {
	bats_git config --unset branch.main.remote
	bats_run_zsh "git-branch-remote --repo $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "origin" ]
}
