bats_load_library 'helper'

setup() {
	bats_tmp_dir

	git-directory-is-github() { return 0; }
	git-directory-url() { echo "https://github.com/pixelastic/my-repo"; }
	bats_mock git-directory-is-github git-directory-url
}

@test "opens PR list page when no number given" {
	# Create a fake browser script that records the URL it's called with
	echo '#!/bin/sh' > "$BATS_TMP_DIR/fake-browser"
	echo 'echo "$1" > "'"$BATS_TMP_DIR"'/opened-url.txt"' >> "$BATS_TMP_DIR/fake-browser"
	chmod +x "$BATS_TMP_DIR/fake-browser"

	bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-pullrequest-open"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/opened-url.txt")" == "https://github.com/pixelastic/my-repo/pulls" ]]
}

@test "opens specific PR when number given" {
	echo '#!/bin/sh' > "$BATS_TMP_DIR/fake-browser"
	echo 'echo "$1" > "'"$BATS_TMP_DIR"'/opened-url.txt"' >> "$BATS_TMP_DIR/fake-browser"
	chmod +x "$BATS_TMP_DIR/fake-browser"

	bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-pullrequest-open 42"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/opened-url.txt")" == "https://github.com/pixelastic/my-repo/pull/42" ]]
}

@test "fails when not in a GitHub repo" {
	git-directory-is-github() { return 1; }
	bats_mock git-directory-is-github

	bats_run_zsh "git-pullrequest-open"
	[[ "$status" -ne 0 ]]
}
