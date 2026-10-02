bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_FOLDER_CACHE "$BATS_TMP_DIR"
}

@test "reads active-uuid from the CACHE folder" {
	mkdir -p "$BATS_TMP_DIR/kitty"
	echo "test-uuid" > "$BATS_TMP_DIR/kitty/active-uuid"

	bats_run_zsh "kitty-uuid"

	[[ "$status" -eq 0 ]]
	[[ "$output" == "test-uuid" ]]
}
