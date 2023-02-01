# Displays a colorized version of a commit hash
# Usage:
# $ git-commit-colorize                    # {currentCommit}
# $ git-commit-colorize upstream           # abcdef
# $ git-commit-colorize --with-icon        #  abcdef
function git-commit-colorize() {
  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Commit hash
  local commitHash="$argsp[1]"
  if [[ $commitHash == '' ]]; then
    commitHash="$(git-commit-current)"
  fi

  # If --with-icon is passed, we add an icon
  if [[ "$argsf[--with-icon]" == 1 ]]; then
    colorize " $commitHash" ALIAS_GIT_COMMIT
    return
  fi

  colorize "$commitHash" ALIAS_GIT_COMMIT
  return
}
