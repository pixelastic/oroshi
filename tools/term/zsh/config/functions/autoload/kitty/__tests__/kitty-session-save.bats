bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"

	# Mock kitty-remote to log all calls
	kitty-remote() { echo "$*" >> "$BATS_TMP_DIR/kitty-remote-calls"; }
	bats_mock kitty-remote
}

@test "flashes the active window green first" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	local firstCall="$(sed -n '1p' "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$firstCall" == *"set-colors"* ]]
	[[ "$firstCall" == *"--match=recent:0"* ]]
	[[ "$firstCall" == *"#1a3a1a"* ]]
}

@test "saves the session to the expected path" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	local secondCall="$(sed -n '2p' "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$secondCall" == *"action save_as_session"* ]]
	[[ "$secondCall" == *"--save-only"* ]]
	[[ "$secondCall" == *"$BATS_TMP_DIR/kitty/session.kitty-session"* ]]
}

@test "resets colors after saving" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	local thirdCall="$(sed -n '3p' "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$thirdCall" == *"set-colors"* ]]
	[[ "$thirdCall" == *"--match=recent:0"* ]]
	[[ "$thirdCall" == *"--reset"* ]]
}

@test "calls kitty-remote exactly 3 times" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	local callCount="$(wc -l < "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$callCount" -eq 3 ]]
}

@test "silent output" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	[[ "$output" = "" ]]
}
