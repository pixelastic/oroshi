bats_load_library 'helper'

setup() {
	bats_tmp_dir
	# Create a tiny test image
	magick -size 10x10 xc:white "$BATS_TMP_DIR/test.png"
}

# API key validation

@test "exits non-zero when WHATFONTIS_API_KEY is not set" {
	curl() { :; }
	bats_mock curl

	unset WHATFONTIS_API_KEY
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	[[ "$status" -ne 0 ]]
}

@test "prints error message to stderr when API key is missing" {
	curl() { :; }
	bats_mock curl

	unset WHATFONTIS_API_KEY
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	[[ "$output" == *"WHATFONTIS_API_KEY"* ]]
}

# JSON output

@test "outputs valid JSON array on success" {
	curl() {
		echo '[{"title":"Roboto","url":"https://example.com","type":"free","site":"google","image":"x","image1":"x","image2":"x"}]'
	}
	bats_mock curl

	export WHATFONTIS_API_KEY="test-key"
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	[[ "$status" -eq 0 ]]
	echo "$output" | jq empty
}

@test "each element has title, url, type, and site keys" {
	curl() {
		echo '[{"title":"Roboto","url":"https://example.com","type":"free","site":"google","image":"x","image1":"x","image2":"x"}]'
	}
	bats_mock curl

	export WHATFONTIS_API_KEY="test-key"
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	local keys
	keys=$(echo "$output" | jq -r '.[0] | keys[]' | sort)
	[[ "$keys" == $'site\ntitle\ntype\nurl' ]]
}

# API call

@test "sends image as base64 in the request" {
	curl() {
		echo "$@" > "$BATS_TMP_DIR/curl_args.txt"
		echo '[]'
	}
	bats_mock curl

	export WHATFONTIS_API_KEY="test-key"
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	local args
	args=$(cat "$BATS_TMP_DIR/curl_args.txt")
	[[ "$args" == *"IMAGEBASE64=1"* ]]
	[[ "$args" == *"urlimagebase64="* ]]
}

@test "passes limit=20 to the API" {
	curl() {
		echo "$@" > "$BATS_TMP_DIR/curl_args.txt"
		echo '[]'
	}
	bats_mock curl

	export WHATFONTIS_API_KEY="test-key"
	bats_run_zsh "img-extract-fonts $BATS_TMP_DIR/test.png"
	local args
	args=$(cat "$BATS_TMP_DIR/curl_args.txt")
	[[ "$args" == *"limit=20"* ]]
}
