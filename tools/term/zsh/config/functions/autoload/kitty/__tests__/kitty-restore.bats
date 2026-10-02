bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"
	bats_mock_env OROSHI_FOLDER_CACHE "$BATS_TMP_DIR"

	# Mock kitty to log all args
	kitty() { echo "$*" > "$BATS_TMP_DIR/kitty-args"; }
	# Mock uuidgen to return a stable value
	uuidgen() { echo "test-uuid"; }
	bats_mock kitty uuidgen
}

@test "passes --session when session file exists" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	touch "$BATS_TMP_DIR/kitty/session.kitty-session"

	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" == *"--session"* ]]
	[[ "$args" == *"$BATS_TMP_DIR/kitty/session.kitty-session"* ]]
}

@test "passes --listen-on when session file exists" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	touch "$BATS_TMP_DIR/kitty/session.kitty-session"

	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" == *"--listen-on"* ]]
}

@test "starts kitty without --session when no session file exists" {
	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" != *"--session"* ]]
}

@test "passes --listen-on when no session file exists" {
	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" == *"--listen-on"* ]]
}

@test "listens on a socket under the CACHE folder" {
	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" == *"unix:$BATS_TMP_DIR/kitty/socket-test-uuid"* ]]
}

@test "writes active-uuid under the CACHE folder" {
	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/kitty/active-uuid")" == "test-uuid" ]]
}

@test "removes pre-existing sockets before launch" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	touch "$BATS_TMP_DIR/kitty/socket-old" "$BATS_TMP_DIR/kitty/socket-older"

	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	[[ ! -e "$BATS_TMP_DIR/kitty/socket-old" ]]
	[[ ! -e "$BATS_TMP_DIR/kitty/socket-older" ]]
}

@test "leaves non-socket files in the folder untouched" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	touch "$BATS_TMP_DIR/kitty/active-uuid"

	bats_run_zsh "kitty-restore"

	[[ "$status" -eq 0 ]]
	[[ -e "$BATS_TMP_DIR/kitty/active-uuid" ]]
}
