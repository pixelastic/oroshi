bats_load_library 'helper'

setup() {
	bats_tmp_dir
	bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "success: creates reload beacon at correct path" {
	kitty-redraw() { :; }
	bats_mock kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[[ -f "$BATS_TMP_DIR/kitty/beacons/reload" ]]
}

@test "success: calls kitty-redraw" {
	kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }
	bats_mock kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[[ -f "$BATS_TMP_DIR/redraw-called" ]]
}

@test "success: silent output" {
	kitty-redraw() { :; }
	bats_mock kitty-redraw

	bats_run_zsh "kitty-reload"

	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}
