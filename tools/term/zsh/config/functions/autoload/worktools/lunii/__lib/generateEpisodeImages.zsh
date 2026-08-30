# Generate SVG illustrations via Claude API for episodes missing images
# Usage: generateEpisodeImages <packDir> <isForceImg>
function generateEpisodeImages() {
  local packDir=$1
  local isForceImg=$2

  # Delete existing episode images to force regeneration
  [[ $isForceImg -eq 1 ]] && find "$packDir" -type f \( -name "*.item.png" -o -name "*.item.jpeg" \) -delete

  local svgSystemPrompt="Generate a monochrome SVG illustration. Black shapes on white background. Flat shapes, no gradients, no shadows. Playful and rounded, child-friendly (not corporate). One central object or scene. Use viewBox=\"0 0 320 240\". Output only the SVG markup, no explanation."

  for episodeDir in "$packDir"/*(/N); do
    local dirName="${episodeDir:t}"

    # Skip if image already exists
    local existingImages=("$episodeDir"/*.item.png(N) "$episodeDir"/*.item.jpeg(N))
    [[ ${#existingImages} -gt 0 ]] && continue

    # Extract episode title (strip number prefix like "01 - ")
    local title="${dirName#[0-9]##[ -]#}"

    # Call Claude API to generate SVG illustration
    local message=$(jo role=user content="Illustrate: $title")
    local body=$(jo \
        model=claude-sonnet-4-20250514 \
        max_tokens:=4096 \
        system="$svgSystemPrompt" \
      messages:="$(jo -a "$message")")

    local response=$(curl \
        --silent \
        --header "x-api-key: $ANTHROPIC_API_KEY" \
        --header "anthropic-version: 2023-06-01" \
        --header "content-type: application/json" \
        --data "$body" \
      https://api.anthropic.com/v1/messages)

    local svgContent=$(echo "$response" | jq -r '.content[0].text')

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
