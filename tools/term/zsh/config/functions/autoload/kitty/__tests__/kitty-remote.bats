bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_FOLDER_CACHE "$BATS_TMP_DIR"

	# Mock kitty to log all args
	kitty() { echo "$*" > "$BATS_TMP_DIR/kitty-args"; }
	# Mock kitty-uuid to return a stable value
	kitty-uuid() { echo "test-uuid"; }
	bats_mock kitty kitty-uuid
}

@test "targets a socket under the CACHE folder" {
	bats_run_zsh "kitty-remote ls"

	[[ "$status" -eq 0 ]]
	local args="$(cat "$BATS_TMP_DIR/kitty-args")"
	[[ "$args" == *"unix:$BATS_TMP_DIR/kitty/socket-test-uuid"* ]]
}
