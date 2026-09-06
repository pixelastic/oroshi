# Second pass: repack the folder into a proper Studio zip
# Usage: repackAsZip <packDir> [--output-dir <path>]
function repackAsZip() {
  zparseopts -E -D -output-dir:=flagOutputDir
  local packDir=$1
  local outputDir="${flagOutputDir[2]:-.}"

  studio-pack-generator \
    --skip-audio-convert \
    --skip-image-convert \
    --skip-audio-item-gen \
    --skip-image-item-gen \
    --skip-extract-image-from-mp-3 \
    --output-folder "$outputDir" \
    "$packDir"
}
