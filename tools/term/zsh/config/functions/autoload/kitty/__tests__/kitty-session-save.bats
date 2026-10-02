bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"

	# Kitty answers remote control by default
	kitty-is-running() { return 0; }

	# Mock kitty-remote: log calls, and emulate a dump by writing to the
	# path passed to save_as_session (the atomic temp file)
	kitty-remote() {
		echo "$*" >> "$BATS_TMP_DIR/kitty-remote-calls"
		[[ "$*" == *save_as_session* ]] && echo "DUMP" > "${@[-1]}"
		return 0
	}
	bats_mock kitty-is-running kitty-remote
}

@test "writes nothing and exits 0 when kitty is down" {
	kitty-is-running() { return 1; }
	bats_mock kitty-is-running

	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	[[ ! -e "$BATS_TMP_DIR/kitty-remote-calls" ]]
	[[ ! -e "$BATS_TMP_DIR/kitty/session.kitty-session" ]]
}

@test "produces the dump at the STATE path" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/kitty/session.kitty-session")" == "DUMP" ]]
}

@test "saves atomically to a temp file then moves it over the dump" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	local saveCall="$(grep save_as_session "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$saveCall" == *"--save-only"* ]]
	# save_as_session targets a temp path, never the final dump directly
	[[ "$saveCall" != *" $BATS_TMP_DIR/kitty/session.kitty-session" ]]
}

@test "leaves a pre-existing dump unchanged when the dump fails" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	echo "PREVIOUS" > "$BATS_TMP_DIR/kitty/session.kitty-session"
	kitty-remote() { return 1; }
	bats_mock kitty-remote

	bats_run_zsh "kitty-session-save"

	[[ "$status" -ne 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/kitty/session.kitty-session")" == "PREVIOUS" ]]
}

@test "default run does not flash" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	[[ "$(grep -c set-colors "$BATS_TMP_DIR/kitty-remote-calls")" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/kitty/session.kitty-session" ]]
}

@test "--flash wraps the save with a green flash then reset" {
	# Inject a known green so the flash reads from COLORS, not a literal
	colors-load-definitions() {
		typeset -gA COLORS
		COLORS[green-0:hex]="#0f1a0f"
	}
	bats_mock colors-load-definitions

	bats_run_zsh "kitty-session-save --flash"

	[[ "$status" -eq 0 ]]
	local firstCall="$(sed -n '1p' "$BATS_TMP_DIR/kitty-remote-calls")"
	local lastCall="$(tail -n 1 "$BATS_TMP_DIR/kitty-remote-calls")"
	[[ "$firstCall" == *"set-colors"* ]]
	[[ "$firstCall" == *"#0f1a0f"* ]]
	[[ "$lastCall" == *"set-colors"* ]]
	[[ "$lastCall" == *"--reset"* ]]
	[[ -f "$BATS_TMP_DIR/kitty/session.kitty-session" ]]
}

@test "silent output by default" {
	bats_run_zsh "kitty-session-save"

	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
