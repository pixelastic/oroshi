bats_load_library 'helper'

setup() {
	bats_disable_worktree_aware
	bats_tmp_dir
	# Create test images
	magick -size 200x100 xc:white "$BATS_TMP_DIR/landscape.png"
	magick -size 100x200 xc:white "$BATS_TMP_DIR/portrait.png"
	magick -size 100x100 xc:white "$BATS_TMP_DIR/square.png"
}

@test "outputs landscape for wide image" {
	bats_run_zsh "img-orientation $BATS_TMP_DIR/landscape.png"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "landscape" ]]
}

@test "outputs portrait for tall image" {
	bats_run_zsh "img-orientation $BATS_TMP_DIR/portrait.png"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "portrait" ]]
}

@test "outputs landscape for square image" {
	bats_run_zsh "img-orientation $BATS_TMP_DIR/square.png"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "landscape" ]]
}

@test "handles multiple images" {
	bats_run_zsh "img-orientation $BATS_TMP_DIR/portrait.png $BATS_TMP_DIR/landscape.png"
	[[ "$status" -eq 0 ]]
	[[ "${lines[0]}" == "portrait" ]]
	[[ "${lines[1]}" == "landscape" ]]
}

@test "skips non-existent files" {
	bats_run_zsh "img-orientation /nonexistent/file.png"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
