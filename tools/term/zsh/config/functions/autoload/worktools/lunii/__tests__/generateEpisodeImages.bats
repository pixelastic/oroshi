bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

_lib_dir() {
  echo "${BATS_TEST_DIRNAME}/../__lib"
}

@test "all JPEGs same hash: calls claude-api for each, produces PNGs, preserves JPEGs" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choisis ton histoire"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"

  claude-api() {
    echo "called" >> "$BATS_TMP_DIR/claude_api_calls.txt"
    echo "<svg></svg>"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock claude-api svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # claude-api called once per episode
  [[ -f "$BATS_TMP_DIR/claude_api_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/claude_api_calls.txt") -eq 2 ]]

  # PNGs produced
  [[ -f "$episodesDir/20240101 Episode One.item.png" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.png" ]]

  # JPEGs preserved
  [[ -f "$episodesDir/20240101 Episode One.item.jpeg" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.jpeg" ]]
}

@test "mixed hashes: claude-api for duplicates, resizeToLunii for unique, all PNGs produced" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choisis ton histoire"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  echo "different content" > "$episodesDir/20240103 Episode Three.item.jpeg"

  claude-api() {
    echo "called" >> "$BATS_TMP_DIR/claude_api_calls.txt"
    echo "<svg></svg>"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    echo "$1" >> "$BATS_TMP_DIR/resize_calls.txt"
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock claude-api svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # claude-api called only for the 2 duplicate-hash episodes
  [[ -f "$BATS_TMP_DIR/claude_api_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/claude_api_calls.txt") -eq 2 ]]

  # resizeToLunii called on the unique JPEG directly
  [[ -f "$BATS_TMP_DIR/resize_calls.txt" ]]
  grep -q "Episode Three.item.jpeg" "$BATS_TMP_DIR/resize_calls.txt"

  # All PNGs produced
  [[ -f "$episodesDir/20240101 Episode One.item.png" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.png" ]]
  [[ -f "$episodesDir/20240103 Episode Three.item.png" ]]

  # All JPEGs preserved
  [[ -f "$episodesDir/20240101 Episode One.item.jpeg" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.jpeg" ]]
  [[ -f "$episodesDir/20240103 Episode Three.item.jpeg" ]]
}

@test "skips episodes with existing .item.png" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choisis ton histoire"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  echo "same content" > "$episodesDir/20240103 Episode Three.item.jpeg"
  # Episode One already has a PNG
  touch "$episodesDir/20240101 Episode One.item.png"

  claude-api() {
    echo "called" >> "$BATS_TMP_DIR/claude_api_calls.txt"
    echo "<svg></svg>"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock claude-api svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # claude-api called for Episode Two and Three (Episode One skipped)
  [[ -f "$BATS_TMP_DIR/claude_api_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/claude_api_calls.txt") -eq 2 ]]
}

@test "idempotent: second run with all PNGs present does nothing" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choisis ton histoire"
  mkdir -p "$episodesDir"
  echo "content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  touch "$episodesDir/20240101 Episode One.item.png"
  touch "$episodesDir/20240102 Episode Two.item.png"

  claude-api() {
    echo "called" >> "$BATS_TMP_DIR/claude_api_calls.txt"
    echo "<svg></svg>"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() { echo "$1" >> "$BATS_TMP_DIR/resize_calls.txt"; }
  bats_mock claude-api svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # Nothing was called
  [[ ! -f "$BATS_TMP_DIR/claude_api_calls.txt" ]]
  [[ ! -f "$BATS_TMP_DIR/resize_calls.txt" ]]
}
