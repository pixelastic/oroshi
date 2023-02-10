# Gets the name of the project name of the given remote
# Usage:
# $ git-github-remote-owner               # pixelastic/oroshi
# $ git-github-remote-owner {remote}

function git-github-remote-project() {
  local remoteName=$1
  [[ $remoteName == '' ]] && remoteName=$(git-remote-current)

  local remoteUrl=$(git-remote-url $remoteName)

  echo $remoteUrl \
    | sed \
      --regexp-extended \
      's_.git$__; s_^git@github.com:(.*)/(.*)_\1/\2_'
}
