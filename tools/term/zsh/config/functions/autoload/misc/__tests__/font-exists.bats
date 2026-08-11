bats_load_library 'helper'

@test "exits 0 when font is found" {
	fc-list() { echo "/usr/share/fonts/test.ttf: DejaVu Sans:style=Regular"; }
	bats_mock fc-list

	bats_run_zsh "font-exists 'dejavu sans'"
	[[ "$status" -eq 0 ]]
}

@test "exits 0 when font with specific style is found" {
	fc-list() { echo "/usr/share/fonts/test.ttf: DejaVu Sans:style=Bold"; }
	bats_mock fc-list

	bats_run_zsh "font-exists 'dejavu sans-bold'"
	[[ "$status" -eq 0 ]]
}

@test "exits 1 when font is not found" {
	fc-list() { echo "/usr/share/fonts/test.ttf: DejaVu Sans:style=Regular"; }
	bats_mock fc-list

	bats_run_zsh "font-exists nonexistent"
	[[ "$status" -eq 1 ]]
}
