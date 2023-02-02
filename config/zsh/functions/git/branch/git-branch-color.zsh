# Return the string color of a specific branch
# Usage:
# $ git-branch-color             # (current branch) blue
# $ git-branch-color master      # blue
function git-branch-color() {

  # Branch name
  local branchName="$1"
  if [[ $branchName == '' ]]; then
    branchName="$(git-branch-current)"
  fi

  local DEFAULT_BRANCH_COLOR='ORANGE'

  declare -A BRANCH_COLORS
  BRANCH_COLORS=()
  BRANCH_COLORS[HEAD]='RED'
  BRANCH_COLORS[develop]='YELLOW'
  BRANCH_COLORS[master]='BLUE'
  BRANCH_COLORS[main]='BLUE'

  # Known branch
  local knownColor=$BRANCH_COLORS[$branchName]
  if [[ $knownColor != '' ]]; then
    echo $knownColor
    return
  fi

  # Default branch
  echo $DEFAULT_BRANCH_COLOR
}
