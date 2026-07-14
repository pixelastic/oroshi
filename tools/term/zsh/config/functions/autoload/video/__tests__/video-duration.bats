bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "--seconds returns raw duration in seconds" {
	# Mock video-info to return JSON with 65.5 seconds duration
	video-info() { echo '{"format":{"duration":"65.500000"}}'; }
	bats_mock video-info

	bats_run_zsh "video-duration --seconds $BATS_TMP_DIR/video.mp4"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "65.500000" ]]
}
