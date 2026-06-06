# Rebuild $PATH from the given root's scripts/bin/ subdirectories
# Usage:
# $ oroshi-reload-path            # Uses $OROSHI_ROOT
# $ oroshi-reload-path [root]     # Uses given root instead
function oroshi-reload-path() {
  local root="${1:-$OROSHI_ROOT}"
  local hostname="$(hostname)"

  # Build the list of subdirs in ./scripts/bin
  local localBinariesPath=()
  for directory in $root/scripts/bin/**/; do
    # Skip all directories starting with __
    [[ $directory == */__* ]] && continue
    # As well as node_modules added by zx
    [[ $directory == */node_modules* ]] && continue

    localBinariesPath+=(${directory:0:-1})
  done

  # Node
  if [[ -f ~/.nvm/alias/default ]]; then
    local nodeBinariesPath=$OROSHI_TMP_FOLDER/node/bin
  fi

  # Python
  if [[ -d ~/.pyenv/ ]]; then
    # The default python version to use is the one saved in ~/.pyenv/version Note:
    # The default method of using pyenv is relying on its shims, but they spawn so
    # many wrapped bash shell scripts that using them adds 1-2 seconds delay to
    # each python command. Instead, we specifically add the binaries from the
    # current version to the PATH
    local defaultPythonVersion="$(<~/.pyenv/version)"
    local pythonBinariesPath=$HOME/.pyenv/versions/${defaultPythonVersion}/bin
  fi

  path=(
    # Local binaries
    $root/private/scripts/bin/local/$hostname

    # Private binaries
    $root/private/scripts/bin

    # Custom binaries
    $localBinariesPath

    # Installed binaries
    ~/local/bin
    ~/.local/bin
    ~/local/src/fzf/bin

    # Language binaries
    $nodeBinariesPath
    ~/.rbenv/bin
    ~/.rbenv/shims
    ~/.pyenv/bin
    $pythonBinariesPath
    ~/.cargo/bin

    # System paths
    # (Check /etc/environment for the exact list)
    /usr/local/sbin
    /usr/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    /usr/games
    /usr/local/games
    /snap/bin
  )
}
