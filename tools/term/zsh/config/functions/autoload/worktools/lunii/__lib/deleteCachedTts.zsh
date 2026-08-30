# Delete cached TTS files so studio-pack-generator regenerates them
# Usage: deleteCachedTts <isForceTts> <dirs...>
function deleteCachedTts() {
  local isForceTts=$1
  shift
  local dirs=("$@")

  [[ $isForceTts -eq 0 ]] && return 0

  for dir in $dirs; do
    [[ ! -d "$dir" ]] && continue
    find "$dir" -type f \( -name "*-generated.item.mp3" -o -name "*-generated.item.wav" \) -delete
  done
}
