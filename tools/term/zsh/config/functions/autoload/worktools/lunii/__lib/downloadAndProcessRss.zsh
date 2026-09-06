# Read an RSS and download all podcasts
# Generate Speech-To-Text titles
# DO NOT Generate images
# DO NOT Build final .zip
# Usage: downloadAndProcessRss <url> [--output-dir <path>]
function downloadAndProcessRss() {
  zparseopts -E -D -output-dir:=flagOutputDir
  local url=$1
  local outputDir="${flagOutputDir[2]:-.}"

  studio-pack-generator \
    --skip-zip-generation \
    --skip-image-convert \
    --use-open-ai-tts \
    --open-ai-api-key "$OPENAI_API_KEY" \
    --open-ai-voice nova \
    --lang fr \
    --rss-split-length 9999 \
    --rss-episode-numbers \
    --rss-use-image-as-thumbnail \
    --output-folder "$outputDir" \
    "$url"
}
