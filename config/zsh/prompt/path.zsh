source ~/.oroshi/config/zsh/theming/projects.zsh

# We define an array of all known project path alongs with their short form
knownPaths=()
for key fullPath in "${(@kv)PROJECTS}"; do
  # Skip non-path keys
  [[ $key != *,path ]] &&  continue

  # Build the short form
  local projectName=${key%,*}
  local backgroundColor=$COLORS[$PROJECTS[${projectName},background]]
  local textColor=$COLORS[$PROJECTS[${projectName},text]]
  local icon=$PROJECTS[${projectName},icon]
  local slug=$projectName
  [[ $PROJECTS[${projectName},hideNameInPath] == "1" ]] && slug=""
  local shortPath="%K{$backgroundColor}%F{$textColor} ${icon}${slug} %f%k%F{$backgroundColor}%f "

  # Save real path and short path
  knownPaths+="${fullPath}:${shortPath}"
done


# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function __prompt-path() {
  local currentPath="$(print -D $PWD)/"

  # Remove known paths from the current path, to be replaced with short path
  # later
  local shortPath=""
  for entry in ${(O)knownPaths}; do
    local split=(${(s/:/)entry})
    local knownPath=$split[1]

    # Skip if do not start with this known path
    [[ $currentPath != $knownPath* ]] && continue

    # Store short path
    shortPath=$split[2]
    eval "currentPath=\${currentPath:s_${knownPath}_}"

    # We found it, no need to search for more
    break
  done

  # Simplify string path if too long
  local -a pathArray
  pathArray=(${(s:/:)currentPath})
  if [[ ${#pathArray[*]} -ge 4 ]]; then
    currentPath="${pathArray[1]}/…/${pathArray[-2]}/${pathArray[-1]}/"
  fi

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    echo -n "%F{$COLORS[orange]}  $hostname %f%k"
  fi

  # Add optional known path prefix
  if [[ $shortPath != '' ]]; then
    echo -n $shortPath
  fi

  # Color the string path
  if [[ $currentPath != '' ]]; then
    [[ ! -r $PWD ]] && echo "%F{$COLORS[gray]} ${currentPath}%f " && return
    [[ ! -w $PWD ]] && echo "%F{$COLORS[red]}!${currentPath}%f " && return

    echo "%F{$COLORS[green]}${currentPath}%f " && return
  fi
}
