# Fit+pad an image to exactly 320x240 with black padding, output as PNG
# Usage: resizeToLunii <filePath>
function resizeToLunii() {
  setopt local_options err_return

  local filePath=$1
  local outputPath="${filePath:r}.png"

  magick "$filePath" \
    -resize 320x240 \
    -background black \
    -gravity center \
    -extent 320x240 \
    "$outputPath"
}
