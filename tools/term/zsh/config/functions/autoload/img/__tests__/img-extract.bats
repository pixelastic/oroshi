bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

# Merged output

@test "outputs JSON with both colors and fonts keys" {
	img-extract-colors() { echo '{"Vibrant":"#ff0000"}'; }
	img-extract-fonts() {
		echo '[{"title":"Roboto","url":"https://example.com","type":"free","site":"google"}]'
	}
	bats_mock img-extract-colors img-extract-fonts

	bats_run_zsh "img-extract $BATS_TMP_DIR/test.png"
	[[ "$status" -eq 0 ]]
	local keys
	keys=$(echo "$output" | jq -r 'keys[]' | sort)
	[[ "$keys" == $'colors\nfonts' ]]
}

@test "colors value matches img-extract-colors output" {
	img-extract-colors() { echo '{"Vibrant":"#ff0000","Muted":"#888888"}'; }
	img-extract-fonts() { echo '[]'; }
	bats_mock img-extract-colors img-extract-fonts

	bats_run_zsh "img-extract $BATS_TMP_DIR/test.png"
	local colors
	colors=$(echo "$output" | jq -r '.colors.Vibrant')
	[[ "$colors" == "#ff0000" ]]
}

@test "fonts value matches img-extract-fonts output" {
	img-extract-colors() { echo '{}'; }
	img-extract-fonts() {
		echo '[{"title":"Roboto","url":"https://example.com","type":"free","site":"google"}]'
	}
	bats_mock img-extract-colors img-extract-fonts

	bats_run_zsh "img-extract $BATS_TMP_DIR/test.png"
	local title
	title=$(echo "$output" | jq -r '.fonts[0].title')
	[[ "$title" == "Roboto" ]]
}

# Error propagation

@test "exits non-zero when img-extract-colors fails" {
	img-extract-colors() { return 1; }
	img-extract-fonts() { echo '[]'; }
	bats_mock img-extract-colors img-extract-fonts

	bats_run_zsh "img-extract $BATS_TMP_DIR/test.png"
	[[ "$status" -ne 0 ]]
}

@test "exits non-zero when img-extract-fonts fails" {
	img-extract-colors() { echo '{}'; }
	img-extract-fonts() { return 1; }
	bats_mock img-extract-colors img-extract-fonts

	bats_run_zsh "img-extract $BATS_TMP_DIR/test.png"
	[[ "$status" -ne 0 ]]
}
