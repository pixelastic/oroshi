bats_load_library 'helper'

setup() {
	bats_disable_worktree_aware
	bats_tmp_dir
	# Create a simple test PNG with transparency
	magick -size 50x50 xc:none -fill red -draw "circle 25,25 25,1" "$BATS_TMP_DIR/input.png"
}

@test "creates mask at default path with .mask.png suffix" {
	bats_run_zsh "png-mask-create $BATS_TMP_DIR/input.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/input.mask.png" ]]
}

@test "creates mask at custom path with --output" {
	bats_run_zsh "png-mask-create --output $BATS_TMP_DIR/custom.png $BATS_TMP_DIR/input.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/custom.png" ]]
}
