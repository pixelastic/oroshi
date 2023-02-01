# Displays a colorized version of a remote name
# Usage:
# $ git-remote-colorize                    # {currentRemote}
# $ git-remote-colorize upstream           # upstream
# $ git-remote-colorize upstream/master    # upstream/master
# $ git-remote-colorize --with-icon        #  upstream

function git-remote-colorize() {
  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Remote name
  local remoteName="$argsp[1]"
  if [[ $remoteName == '' ]]; then
    remoteName="$(git-remote-current)"
  fi

  # If the remote contains the name of the branch, we color based on the remote,
  # but display the full version
  local displayRemoteName="$remoteName"
  if [[ "$remoteName" =~ "/" ]]; then
    local remoteSplit=(${(@s:/:)remoteName})
    remoteName="$remoteSplit[1]"
  fi

  local remoteColor="$(git-remote-color $remoteName)"

  # If --with-icon is not passed, we simply display the colored commit
  if [[ "$argsf[--with-icon]" != 1 ]]; then
    colorize "$displayRemoteName" "$remoteColor"
    return
  fi

  colorize " $displayRemoteName" "$remoteColor"
  return
}
