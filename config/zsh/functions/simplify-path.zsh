# Simplifies a path by only displaying the important bits
# Usage:
# $ simplify-path /path/to/somewhere
function simplify-path () {
  local fullPath="$1"

  local -a pathArray
  pathArray=(${(s:/:)fullPath})
  if [[ ${#pathArray[*]} -lt 4 ]]; then
    echo $fullPath
    exit 0
  fi

  echo "${pathArray[1]}/…/${pathArray[-2]}/${pathArray[-1]}/"
}
