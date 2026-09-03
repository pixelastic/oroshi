# Download Airtable attachment files to the assets directory
# Usage:
# $ download-assets <meetupJson> <assetsDir>

# Guard: skip if already defined (e.g. mocked in tests)
whence download-assets >/dev/null && return 0

function download-assets() {
  setopt local_options err_return

  local meetupJson="$1"
  local assetsDir="$2"

  local fields=(
    pictureMain
    pictureLogo
    pictureBackground
    horizontalScreen
    verticalScreen
    signagePrint
  )

  for field in "${fields[@]}"; do
    local jqPrefix=".${field}[0]"

    local url="$(jq -r "${jqPrefix}.url // empty" <<< "$meetupJson")"

    # Skip null or empty fields
    [[ "$url" == "" ]] && continue

    local filename="$(jq -r "${jqPrefix}.filename // empty" <<< "$meetupJson")"
    local ext="${filename:e}"
    local target="$assetsDir/$field.$ext"

    curl \
      --location \
      --fail \
      --silent \
      --show-error \
      --output "$target" \
      "$url"
  done
}
