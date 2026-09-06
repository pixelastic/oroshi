# Second pass: repack the folder into a proper Studio zip
# Usage: repackAsZip <packDir>
function repackAsZip() {
  local packDir=$1

  studio-pack-generator \
    --skip-audio-convert \
    --skip-image-convert \
    --skip-audio-item-gen \
    --skip-image-item-gen \
    --skip-extract-image-from-mp-3 \
    --output-folder . \
    "$packDir"
}
