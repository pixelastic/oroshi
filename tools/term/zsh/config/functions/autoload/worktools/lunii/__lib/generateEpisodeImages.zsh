# Generate episode images via hash-dedup: duplicate covers get Claude SVG, unique covers get resized
# Usage: generateEpisodeImages <packDir>
function generateEpisodeImages() {
  setopt local_options err_return

  local packDir=$1
  local episodesDir="$packDir/Choose your story"

  local svgStyle="Monochrome, white shapes on black background. Flat shapes, no gradients, no shadows. Playful and rounded, child-friendly. One central object or scene. viewBox 0 0 320 240."

  # Collect JPEGs that still need a PNG
  local jpegsToProcess=()
  for jpeg in "$episodesDir"/*.item.jpeg(N); do
    local pngPath="${jpeg:r}.png"

    # Skip if PNG already exists
    [[ -f "$pngPath" ]] && continue

    jpegsToProcess+=("$jpeg")
  done

  # Nothing to process
  [[ ${#jpegsToProcess} -eq 0 ]] && return 0

  # Build hash → count map to detect duplicates
  local -A hashCount
  for jpeg in "${jpegsToProcess[@]}"; do
    local hash="$(md5sum "$jpeg" | cut -d' ' -f1)"
    hashCount[$hash]=$(( ${hashCount[$hash]:-0} + 1 ))
  done

  # Process each JPEG based on whether its hash is duplicated
  local total=${#jpegsToProcess}
  local current=0
  for jpeg in "${jpegsToProcess[@]}"; do
    current=$((current + 1))
    local hash="$(md5sum "$jpeg" | cut -d' ' -f1)"
    local pngPath="${jpeg:r}.png"
    local baseName="${jpeg:t}"
    local title="${baseName#[0-9]## }"
    title="${title#- }"
    title="${title%.item.jpeg}"

    if [[ ${hashCount[$hash]} -gt 1 ]]; then
      # Duplicate hash: same cover reused → generate SVG illustration
      echo "[$current/$total] Generating SVG: $title"
      local tmpSvg=$(mktemp --suffix=.svg)
      txt2svg --output "$tmpSvg" "$svgStyle $title"

      echo "[$current/$total] Converting to PNG: $title"
      svg2png "$tmpSvg"
      local tmpPng="${tmpSvg%.svg}.png"
      resizeToLunii "$tmpPng"
      mv "$tmpPng" "$pngPath"
      rm -f "$tmpSvg"
    else
      # Unique hash: distinct artwork → resize JPEG to PNG
      echo "[$current/$total] Resizing: $title"
      resizeToLunii "$jpeg"
    fi
  done
}
