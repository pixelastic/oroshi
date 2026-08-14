bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "extracts URLs from a file" {
	cat > "$BATS_TMP_DIR/input.txt" <<'INPUT'
Visit https://example.com for details
Also see http://foo.bar/page for more
INPUT

	bats_run_zsh "file-url-list $BATS_TMP_DIR/input.txt"
	[[ "$status" -eq 0 ]]
	[[ "$(echo "$output" | sed -n '1p')" == "https://example.com" ]]
	[[ "$(echo "$output" | sed -n '2p')" == "http://foo.bar/page" ]]
}

@test "deduplicates URLs" {
	cat > "$BATS_TMP_DIR/input.txt" <<'INPUT'
First http://duplicate.com in text
Second http://duplicate.com in text
Third http://unique.org in text
INPUT

	bats_run_zsh "file-url-list $BATS_TMP_DIR/input.txt"
	[[ "$status" -eq 0 ]]
	local count
	count="$(echo "$output" | wc -l)"
	[[ "$count" -eq 2 ]]
}

@test "preserves file order instead of sorting alphabetically" {
	cat > "$BATS_TMP_DIR/input.txt" <<'INPUT'
First https://zebra.com here
Then https://alpha.com here
Last https://middle.com here
INPUT

	bats_run_zsh "file-url-list $BATS_TMP_DIR/input.txt"
	[[ "$status" -eq 0 ]]
	[[ "$(echo "$output" | sed -n '1p')" == "https://zebra.com" ]]
	[[ "$(echo "$output" | sed -n '2p')" == "https://alpha.com" ]]
	[[ "$(echo "$output" | sed -n '3p')" == "https://middle.com" ]]
}
