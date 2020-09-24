# Path
# Displays the current path in a shortened form:
# - If the path is too long, only the first and 2 last will be displayed
# - Known directories are replaced with an icon
# - Unwritable directories are written in red
function __prompt-path() {
  local promptPath="$(print -D $PWD)"
  promptPath=${promptPath:s/~/ }

  local -a splitPath
  splitPath=(${(s:/:)promptPath})

  # Keep only first and last dirs if too long
  if [[ ${#splitPath[*]} -ge 4 ]]; then
    promptPath="${splitPath[1]}/…${splitPath[-2]}/${splitPath[-1]}/"
    # promptPath=${promptPath:s/\//}
  fi

  # Write in red for unwritable paths
  [[ ! -w $PWD ]] && echo "%F{$COLOR[red]}!${promptPath}%f " && return
  echo "%F{$COLOR[green]}${promptPath}%f " && return
}
