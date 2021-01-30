# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function __prompt-path() {
  # zsh does not keep order with associative array, so we'll use two arrays for
  # the known path and its data. It is important they are checked in order, so
  # the most specific are defined first
  local -a knownPaths knownData
  knownPaths+=("~/local/www/doctolib/doctolib/")
  knownData+=("blue5:black: doctolib")

  knownPaths+=("~/local/www/doctolib/kube/")
  knownData+=("blue7:blue1:⎈ kube")

  knownPaths+=("~/local/www/doctolib/dashboards/")
  knownData+=("blue3:black: dashboards")

  knownPaths+=("~/local/www/projects/golgoth/")
  knownData+=("orange:orange1: golgoth")

  knownPaths+=("~/local/www/projects/firost/")
  knownData+=("green:gray9:❯ firost")

  knownPaths+=("~/local/www/projects/on-circle/")
  knownData+=("red3:gray9:⬤ on-circle")

  knownPaths+=("~/local/www/projects/norska/")
  knownData+=("blue3:gray8:煮norska")

  knownPaths+=("~/local/www/projects/norska-theme-docs/")
  knownData+=("blue3:gray8: theme-docs")

  knownPaths+=("~/local/www/projects/norska-theme-search/")
  knownData+=("blue5:white: theme-search")

  knownPaths+=("~/local/www/projects/norska-theme-search-infinite/")
  knownData+=("blue3:gray8: theme-search-infinite")

  knownPaths+=("~/local/www/projects/norska-theme-slides/")
  knownData+=("green8:white: theme-search-slides")

  knownPaths+=("~/local/www/projects/aberlaas/")
  knownData+=("yellow7:gray9: aberlaas")

  knownPaths+=("~/local/www/pixelastic.com/gamemaster/gods/")
  knownData+=("purple6:gray4:  gods")

  knownPaths+=("~/local/www/pixelastic.com/gamemaster/maps/")
  knownData+=("blue6:gray4:  maps")

  knownPaths+=("~/.oroshi/")
  knownData+=("green:gray9:x oroshi")
  knownPaths+=("~/")
  knownData+=("green:green1:")

  # Remove known paths from the current path
  local pathString="$(print -D $PWD)/"
  local pathSymbolString=""
  for knownPath in $knownPaths; do
    if [[ $pathString == ${knownPath}* ]]; then
      local knownPathIndex=${knownPaths[(ie)$knownPath]}
      pathSymbolString=$knownData[$knownPathIndex]
      eval "pathString=\${pathString:s_${knownPath}_}"
      break
    fi
  done

  # Simplify string path if too long
  local -a pathArray
  pathArray=(${(s:/:)pathString})
  if [[ ${#pathArray[*]} -ge 4 ]]; then
    pathString="${pathArray[1]}/…/${pathArray[-2]}/${pathArray[-1]}/"
  fi

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    echo -n "%F{$COLOR[orange]}  $hostname %f%k"
  fi

  # Add optional known path prefix
  if [[ $pathSymbolString != '' ]]; then
    local -a pathSymbolArray
    pathSymbolArray=(${(s/:/)pathSymbolString})
    local symbolBackground=$pathSymbolArray[1]
    local symbolColor=$pathSymbolArray[2]
    local symbolIcon=$pathSymbolArray[3]
    echo -n "%K{$COLOR[$symbolBackground]}%F{$COLOR[$symbolColor]} $symbolIcon %f%k"
    echo -n "%F{$COLOR[$symbolBackground]}%f "
  fi

  # Color the string path
  if [[ $pathString != '' ]]; then
    [[ ! -r $PWD ]] && echo "%F{$COLOR[gray]} ${pathString}%f " && return
    [[ ! -w $PWD ]] && echo "%F{$COLOR[red]}!${pathString}%f " && return

    echo "%F{$COLOR[green]}${pathString}%f " && return
  fi
}
