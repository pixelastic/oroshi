bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "produces a PNG file at the output path given a valid video input" {
	touch "$BATS_TMP_DIR/video.mp4"

	# Mock video-duration to return 60 seconds
	video-duration() { echo "60.000000"; }
	# Mock ffmpeg to create the output file (last arg)
	ffmpeg() { touch "${@[-1]}"; }
	bats_mock video-duration ffmpeg

	bats_run_zsh "video-thumbnail $BATS_TMP_DIR/video.mp4 $BATS_TMP_DIR/output.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/output.png" ]]
}

@test "works for very short videos (under 2 seconds)" {
	touch "$BATS_TMP_DIR/short.mp4"

	# Mock video-duration to return 1.5 seconds
	video-duration() { echo "1.500000"; }
	# Mock ffmpeg to create the output file
	ffmpeg() { touch "${@[-1]}"; }
	bats_mock video-duration ffmpeg

	bats_run_zsh "video-thumbnail $BATS_TMP_DIR/short.mp4 $BATS_TMP_DIR/output.png"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/output.png" ]]
}

@test "defaults output to same basename with .png extension" {
	touch "$BATS_TMP_DIR/clip.mkv"

	# Mock video-duration to return 30 seconds
	video-duration() { echo "30.000000"; }
	# Mock ffmpeg to create the output file
	ffmpeg() { touch "${@[-1]}"; }
	bats_mock video-duration ffmpeg

	bats_run_zsh "video-thumbnail $BATS_TMP_DIR/clip.mkv"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/clip.png" ]]
}

@test "returns non-zero for missing input file" {
	# Mock video-duration to fail (simulates missing file)
	video-duration() { return 1; }
	bats_mock video-duration

	bats_run_zsh "video-thumbnail $BATS_TMP_DIR/nonexistent.mp4 $BATS_TMP_DIR/output.png"
	[[ "$status" -ne 0 ]]
}
