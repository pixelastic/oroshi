# Fit+pad pack-level images to exactly 320x240 with black padding
# Handles thumbnail and 0-item at the pack root
# Usage: resizePodcastThumbnail <packDir>
function resizePodcastThumbnail() {
  local packDir=$1

  local images=(
    "$packDir"/thumbnail.png(N)
    "$packDir"/thumbnail.jpeg(N)
    "$packDir"/thumbnail.jpg(N)
    "$packDir"/0-item.png(N)
    "$packDir"/0-item.jpeg(N)
    "$packDir"/0-item.jpg(N)
  )

  for img in "${images[@]}"; do
    local dimensions=$(img-dimensions "$img")
    [[ "$dimensions" == "320x240" ]] && continue

    resizeToLunii "$img"
  done

  # Clean up source JPEGs that now have a PNG
  for jpeg in "$packDir"/thumbnail.jpeg(N) "$packDir"/thumbnail.jpg(N) \
    "$packDir"/0-item.jpeg(N) "$packDir"/0-item.jpg(N); do
    [[ -f "${jpeg:r}.png" ]] && rm -f "$jpeg"
  done
}
