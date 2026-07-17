bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
	bats_mock_env OROSHI_ROOT "/home/user/oroshi"
}

@test "beacon contains worktree root when in an oroshi worktree" {
	mkdir -p "$BATS_TMP_DIR/worktree"
	kitty-pwd() { echo "$BATS_TMP_DIR/worktree"; }
	git-worktree-is-oroshi() { return 0; }
	git-directory-root() { echo "$BATS_TMP_DIR/worktree"; }
	kitty-redraw() { :; }
	bats_mock kitty-pwd git-worktree-is-oroshi git-directory-root kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[ "$(cat "$BATS_TMP_DIR/kitty/beacons/reload")" = "$BATS_TMP_DIR/worktree" ]
}

@test "beacon contains OROSHI_ROOT when not in an oroshi worktree" {
	mkdir -p "$BATS_TMP_DIR/other-project"
	kitty-pwd() { echo "$BATS_TMP_DIR/other-project"; }
	git-worktree-is-oroshi() { return 1; }
	kitty-redraw() { :; }
	bats_mock kitty-pwd git-worktree-is-oroshi kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[ "$(cat "$BATS_TMP_DIR/kitty/beacons/reload")" = "/home/user/oroshi" ]
}

@test "calls kitty-redraw after writing beacon" {
	mkdir -p "$BATS_TMP_DIR/other-project"
	kitty-pwd() { echo "$BATS_TMP_DIR/other-project"; }
	git-worktree-is-oroshi() { return 1; }
	kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }
	bats_mock kitty-pwd git-worktree-is-oroshi kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[[ -f "$BATS_TMP_DIR/redraw-called" ]]
}

@test "silent output" {
	mkdir -p "$BATS_TMP_DIR/other-project"
	kitty-pwd() { echo "$BATS_TMP_DIR/other-project"; }
	git-worktree-is-oroshi() { return 1; }
	kitty-redraw() { :; }
	bats_mock kitty-pwd git-worktree-is-oroshi kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}
