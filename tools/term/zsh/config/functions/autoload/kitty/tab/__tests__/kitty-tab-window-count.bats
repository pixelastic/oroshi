bats_load_library 'helper'

@test "returns window count for a given tab" {
	# Mock kitty-remote to return JSON with a tab containing 3 windows
	kitty-remote() {
		cat <<'MOCK_JSON'
[{"tabs":[{"id":1,"windows":[{},{},{}]},{"id":2,"windows":[{}]}]}]
MOCK_JSON
	}
	bats_mock kitty-remote

	bats_run_zsh "kitty-tab-window-count 1"
	[[ "$status" -eq 0 ]]
	[[ "$output" -eq 3 ]]
}

@test "errors when no tab id provided" {
	bats_run_zsh "kitty-tab-window-count"
	[[ "$status" -ne 0 ]]
}
