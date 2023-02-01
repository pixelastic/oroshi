# Gets the url of a given remote
# Usage:
# $ git-remote-url               # Uses current remote
# $ git-remote-url {remoteName}  # Uses {remoteName}
function git-remote-url() {
  local remote=$1
  [[ $remote == '' ]] && remote="$(git-remote-current)"

  # Find the remote url
  local remoteUrl="$(git config --get remote.${remote}.url)"

  # Fails if no remote
  if [[ $remoteUrl == '' ]]; then
    return 1
  fi

  echo $remoteUrl
}
