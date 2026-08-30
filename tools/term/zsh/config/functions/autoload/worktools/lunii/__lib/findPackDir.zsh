# Find the pack folder created by studio-pack-generator
# Compares directory listings before and after to detect the new folder
# Usage: findPackDir <dirsBefore...> --- (sentinel)
# Prints the pack directory path to stdout
function findPackDir() {
  local dirsBefore=()
  while [[ $# -gt 0 && "$1" != "---" ]]; do
    dirsBefore+=("$1")
    shift
  done
  shift # consume "---"

  local dirsAfter=("${(@f)$(print -l ./*(/N))}")
  local packDir=""

  for dir in $dirsAfter; do
    if [[ ${dirsBefore[(I)$dir]} -eq 0 ]]; then
      packDir=$dir
      break
    fi
  done

  # Fall back to the only directory if none was new (re-run scenario)
  if [[ "$packDir" == "" && ${#dirsAfter} -eq 1 ]]; then
    packDir=$dirsAfter[1]
  fi

  if [[ "$packDir" == "" ]]; then
    echoerr "Could not determine pack folder, skipping image resize"
    return 0
  fi

  echo "$packDir"
}
