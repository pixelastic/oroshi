bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/ai/meetup-announce/__lib/download-assets.zsh'"
  ASSETS_DIR="$BATS_TMP_DIR/assets"
  mkdir -p "$ASSETS_DIR"

  # Mock curl: write the URL to the output file instead of downloading
  curl() {
    zparseopts -E -D \
      -output:=flagOutput \
      -location=flagLocation \
      -fail=flagFail \
      -silent=flagSilent \
      -show-error=flagShowError
    # shellcheck disable=SC2154
    local output=${flagOutput[2]}
    local url="$1"
    echo "$url" > "$output"
  }
  bats_mock curl
}

# -- Happy path --

@test "downloads files for all present attachment fields" {
  local meetupJson
  meetupJson="$(jo \
    pictureMain="$(jo -a "$(jo url=https://example.com/main.png filename=main.png)")" \
    pictureLogo="$(jo -a "$(jo url=https://example.com/logo.jpg filename=logo.jpg)")" \
    pictureBackground="$(jo -a "$(jo url=https://example.com/bg.webp filename=bg.webp)")" \
    horizontalScreen="$(jo -a "$(jo url=https://example.com/h.mp4 filename=h.mp4)")" \
    verticalScreen="$(jo -a "$(jo url=https://example.com/v.mp4 filename=v.mp4)")" \
    signagePrint="$(jo -a "$(jo url=https://example.com/s.pdf filename=s.pdf)")" \
  )"

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
  [[ -f "$ASSETS_DIR/pictureLogo.jpg" ]]
  [[ -f "$ASSETS_DIR/pictureBackground.webp" ]]
  [[ -f "$ASSETS_DIR/horizontalScreen.mp4" ]]
  [[ -f "$ASSETS_DIR/verticalScreen.mp4" ]]
  [[ -f "$ASSETS_DIR/signagePrint.pdf" ]]
}

@test "names files as fieldName.extension" {
  local meetupJson
  meetupJson="$(jo \
    pictureMain="$(jo -a "$(jo url=https://example.com/some-random-name.png filename=some-random-name.png)")" \
  )"

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
  # The original filename is irrelevant — only fieldName and extension matter
  [[ ! -f "$ASSETS_DIR/some-random-name.png" ]]
}

@test "overwrites existing files" {
  echo "old content" > "$ASSETS_DIR/pictureMain.png"
  local meetupJson
  meetupJson="$(jo \
    pictureMain="$(jo -a "$(jo url=https://example.com/new.png filename=new.png)")" \
  )"

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  # Mock curl writes the URL to the file — should no longer be "old content"
  [[ "$(cat "$ASSETS_DIR/pictureMain.png")" != "old content" ]]
}

# -- Escaped newlines in JSON --

@test "extracts URLs correctly when JSON contains escaped newlines in other fields" {
  # JSON with \n escape sequences in string values — mimics Airtable API output
  local meetupJson='{"description":"Line one\nLine two","notes":"Note\nwith newlines","pictureMain":[{"url":"https://example.com/main.png","filename":"main.png"}]}'

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
}

# -- Partial data --

@test "skips null fields without error" {
  local meetupJson
  meetupJson="$(jo \
    pictureMain="$(jo -a "$(jo url=https://example.com/main.png filename=main.png)")" \
    pictureLogo=null \
  )"

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
  [[ ! -f "$ASSETS_DIR/pictureLogo" ]]
}

@test "skips empty array fields without error" {
  # Inline JSON avoids jo -e hanging on empty array values
  local meetupJson='{"pictureMain":[{"url":"https://example.com/main.png","filename":"main.png"}],"pictureLogo":[]}'

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
  [[ ! -f "$ASSETS_DIR/pictureLogo" ]]
}

@test "still downloads other fields when some are missing" {
  local meetupJson
  meetupJson="$(jo \
    pictureMain="$(jo -a "$(jo url=https://example.com/main.png filename=main.png)")" \
    signagePrint="$(jo -a "$(jo url=https://example.com/s.pdf filename=s.pdf)")" \
  )"

  bats_run_zsh "$sourcePrefix && download-assets '$meetupJson' '$ASSETS_DIR'"
  [[ "$status" -eq 0 ]]
  [[ -f "$ASSETS_DIR/pictureMain.png" ]]
  [[ -f "$ASSETS_DIR/signagePrint.pdf" ]]
  # Fields not in JSON are simply not downloaded
  [[ ! -f "$ASSETS_DIR/pictureLogo" ]]
  [[ ! -f "$ASSETS_DIR/horizontalScreen" ]]
}
