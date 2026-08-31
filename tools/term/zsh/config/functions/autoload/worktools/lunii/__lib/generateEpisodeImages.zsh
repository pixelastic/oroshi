# Generate SVG illustrations via Claude API for episodes missing images
# Usage: generateEpisodeImages <packDir>
function generateEpisodeImages() {
  local packDir=$1

  local svgSystemPrompt="Generate a monochrome SVG illustration. Black shapes on white background. Flat shapes, no gradients, no shadows. Playful and rounded, child-friendly (not corporate). One central object or scene. Use viewBox=\"0 0 320 240\". Output only the SVG markup, no explanation."

  for episodeDir in "$packDir"/*(/N); do
    local dirName="${episodeDir:t}"

    # Skip if image already exists
    local existingImages=("$episodeDir"/*.item.png(N) "$episodeDir"/*.item.jpeg(N))
    [[ ${#existingImages} -gt 0 ]] && continue

    # Extract episode title (strip number prefix like "01 - ")
    local title="${dirName#[0-9]##[ -]#}"

    # Call Claude API to generate SVG illustration
    local svgContent=$(claude-api --system "$svgSystemPrompt" "Illustrate: $title")

    # Save SVG, convert to PNG, resize to Lunii dimensions
    local tmpSvg=$(mktemp --suffix=.svg)
    echo "$svgContent" > "$tmpSvg"
    svg2png "$tmpSvg"
    local tmpPng="${tmpSvg%.svg}.png"
    img-resize "$tmpPng" 320x240 --no-ratio
    mv "$tmpPng" "$episodeDir/${dirName}.item.png"
    rm -f "$tmpSvg"
  done
}
