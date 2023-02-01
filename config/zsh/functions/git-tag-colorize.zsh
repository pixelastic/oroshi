# Displays a colorized version of a tag name
# Usage:
# $ git-tag-colorize                    # {currentTag}
# $ git-tag-colorize master             # v1.0
# $ git-tag-colorize --with-icon        # 炙v1.0
function git-tag-colorize() {
  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  local currentTag="$(git-tag-current)"

  # Tag name
  local tagName="$argsp[1]"
  # Use the closest tag if none is passed
  if [[ $tagName == '' ]]; then
    tagName="$currentTag"
  fi
  # Stop if still no tag found
  if [[ $tagName == '' ]]; then
    return 0
  fi

  # If --with-icon is not passed, we simply display the colored tag
  if [[ "$argsf[--with-icon]" != 1 ]]; then
    colorize $colorizeArguments "$tagName" TEAL
    return
  fi

  local tagStatus="$(git-tag-status "$tagName")"

  # Exact: The tag points specifically to the current commit
  if [[ "$tagStatus" = "exact" ]]; then
    colorize " $tagName" CYAN_5
    return
  fi

  # Closest: The tag is the closest in the branch
  if [[ "$tagStatus" = "closest" ]]; then
    colorize " $tagName" CYAN
    return
  fi

  # Parent: The tag is somewhere in the branch
  if [[ "$tagStatus" = "parent" ]]; then
    colorize "炙$tagName" CYAN_8
    return
  fi

  # Unrelated: The tag is not in the branch
  if [[ "$tagStatus" = "unrelated" ]]; then
    colorize "炙$tagName" GRAY
    return
  fi

  # Fallback on unknown status
  colorize " $tagName" RED
  return
}
