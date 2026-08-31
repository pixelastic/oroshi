# Delete cached episode images to force regeneration
# Preserves .item.jpeg files (RSS download cache)
# Usage: deleteCachedImages <packDir>
function deleteCachedImages() {
  local packDir=$1

  local files=("$packDir"/**/*.item.png(N))

  # Nothing to delete
  [[ ${#files} -eq 0 ]] && return 0

  rm -f $files
}
