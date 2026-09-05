# Replace English labels in the episodes folder with French assets
# studio-pack-generator creates "Choose your story" with English mp3/png even with --lang fr
# Usage: localizeEpisodesFolder <packDir>
function localizeEpisodesFolder() {
  setopt local_options err_return

  local packDir=$1
  local episodesDir="$packDir/Choose your story"
  local assetsDir="${functions_source[localizeEpisodesFolder]:A:h}/../__assets"

  # No episodes folder yet
  [[ ! -d "$episodesDir" ]] && return 0

  \cp "$assetsDir/choisis-ton-histoire.mp3" "$episodesDir/0-item.mp3"
  \cp "$assetsDir/choisis-ton-histoire.png" "$episodesDir/0-item.png"
}
