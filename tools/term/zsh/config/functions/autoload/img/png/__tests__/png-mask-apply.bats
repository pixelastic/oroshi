bats_load_library 'helper'

setup() {
	bats_disable_worktree_aware
	bats_tmp_dir
	# Create a test image and a test mask
	magick -size 50x50 xc:red "$BATS_TMP_DIR/image.png"
	magick -size 50x50 xc:white -fill black -draw "circle 25,25 25,1" "$BATS_TMP_DIR/mask.png"
}

@test "applies mask at default path with .masked.png suffix" {
	bats_run_zsh "png-mask-apply $BATS_TMP_DIR/image.png $BATS_TMP_DIR/mask.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/image.masked.png" ]]
}

@test "applies mask at custom path with --output" {
	bats_run_zsh "png-mask-apply --output $BATS_TMP_DIR/result.png $BATS_TMP_DIR/image.png $BATS_TMP_DIR/mask.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/result.png" ]]
}
