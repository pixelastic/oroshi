bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

_lib_dir() {
  echo "${BATS_TEST_DIRNAME}/../__lib"
}

@test "all JPEGs same hash: calls txt2svg for each, produces PNGs, preserves JPEGs" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"

  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    # Parse --output flag
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # txt2svg called once per episode
  [[ -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/txt2svg_calls.txt") -eq 2 ]]

  # PNGs produced
  [[ -f "$episodesDir/20240101 Episode One.item.png" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.png" ]]

  # JPEGs preserved
  [[ -f "$episodesDir/20240101 Episode One.item.jpeg" ]]
  [[ -f "$episodesDir/20240102 Episode Two.item.jpeg" ]]
}

@test "mixed hashes: txt2svg for duplicates, resizeToLunii for unique, all PNGs produced" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  echo "different content" > "$episodesDir/20240103 Episode Three.item.jpeg"

  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    echo "$1" >> "$BATS_TMP_DIR/resize_calls.txt"
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # txt2svg called only for the 2 duplicate-hash episodes
  [[ -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/txt2svg_calls.txt") -eq 2 ]]

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
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  echo "same content" > "$episodesDir/20240103 Episode Three.item.jpeg"
  # Episode One already has a PNG
  touch "$episodesDir/20240101 Episode One.item.png"

  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # txt2svg called for Episode Two and Three (Episode One skipped)
  [[ -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/txt2svg_calls.txt") -eq 2 ]]
}

@test "passes style description to txt2svg prompt" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "same content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "same content" > "$episodesDir/20240102 Episode Two.item.jpeg"

  txt2svg() {
    echo "$@" >> "$BATS_TMP_DIR/txt2svg_args.txt"
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/txt2svg_args.txt")"
  [[ "$args" == *"Monochrome"* ]]
  [[ "$args" == *"320 240"* ]]
}

@test "--force-generate-all forces SVG generation for all episodes even with unique hashes" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "unique content A" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "unique content B" > "$episodesDir/20240102 Episode Two.item.jpeg"
  echo "unique content C" > "$episodesDir/20240103 Episode Three.item.jpeg"

  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    echo "$1" >> "$BATS_TMP_DIR/resize_calls.txt"
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack --force-generate-all"
  [[ "$status" -eq 0 ]]

  # txt2svg called for all 3 episodes despite unique hashes
  [[ -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/txt2svg_calls.txt") -eq 3 ]]

  # resizeToLunii never called on source JPEGs
  run ! grep -q ".item.jpeg" "$BATS_TMP_DIR/resize_calls.txt"
}

@test "idempotent: second run with all PNGs present does nothing" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "content" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "content" > "$episodesDir/20240102 Episode Two.item.jpeg"
  touch "$episodesDir/20240101 Episode One.item.png"
  touch "$episodesDir/20240102 Episode Two.item.png"

  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    echo "<svg></svg>"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() { echo "$1" >> "$BATS_TMP_DIR/resize_calls.txt"; }
  bats_mock txt2svg svg2png resizeToLunii

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/generateEpisodeImages.zsh && generateEpisodeImages $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  # Nothing was called
  [[ ! -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ ! -f "$BATS_TMP_DIR/resize_calls.txt" ]]
}
