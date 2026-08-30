# Fit+pad the pack thumbnail to exactly 320x240 with black padding
# Usage: resizeThumbnail <packDir>
function resizeThumbnail() {
  local packDir=$1

  local thumbnails=("$packDir"/thumbnail.png(N) "$packDir"/thumbnail.jpeg(N) "$packDir"/0-item.png(N))
  [[ ${#thumbnails} -eq 0 ]] && return 0

  local thumbnail=$thumbnails[1]
  local dimensions=$(img-dimensions "$thumbnail")
  [[ "$dimensions" == "320x240" ]] && return 0

  magick "$thumbnail" \
    -resize 320x240 \
    -background black \
    -gravity center \
    -extent 320x240 \
    "$thumbnail"
}
