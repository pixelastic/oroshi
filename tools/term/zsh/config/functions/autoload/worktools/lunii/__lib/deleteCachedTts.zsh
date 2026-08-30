# Delete cached TTS files so studio-pack-generator regenerates them
# Usage: deleteCachedTts <packDir>
function deleteCachedTts() {
  local packDir=$1

  local files=(
    "$packDir"/**/*-generated.item.mp3(N)
    "$packDir"/**/*-generated.item.wav(N)
  )
  if [[ ${#files} -gt 0 ]]; then
    rm -f $files
  fi
}
