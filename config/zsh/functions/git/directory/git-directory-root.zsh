# Returns the path to the git root
# Usage:
# $ git-directory-root               # Path to the root
# $ git-directory-root /path/to/file # Root of the given path
# $ git-directory-root -f            # Goes all the way up submodules
# TODO: Write tests
# TODO: Refactor argsp/argsf parsing
function git-directory-root {

  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Check from the given directory, or the current one if none specified
  local targetPath="$argsp[1]"
  [[ $targetPath == "" ]] && targetPath="$PWD"
  [[ ! -d "$targetPath" ]] && targetPath="${targetPath:r}"

  local gitRoot="$(cd $targetPath && git pwd)"

  # If -f is not passed, we can safely display this path
  if [[ $argsf[-f] != "1" ]]; then
    echo $gitRoot
    return 0
  fi

  # If not in a submodule, we can stop
  if ! git-is-submodule; then
    echo $gitRoot
    return 0
  fi

  # In a submodule, so we test the parent directory, recursively
  local parentDirectory="${gitRoot}/.."
  git-directory-root -f "${parentDirectory:a}"
}



