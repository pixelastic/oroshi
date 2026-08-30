# Delete cached episode images to force regeneration
# Usage: deleteCachedImages <packDir>
function deleteCachedImages() {
  local packDir=$1

  local files=(
    "$packDir"/**/*.item.png(N)
    "$packDir"/**/*.item.jpeg(N)
  )
  if [[ ${#files} -gt 0 ]]; then
    rm -f $files
  fi
}
