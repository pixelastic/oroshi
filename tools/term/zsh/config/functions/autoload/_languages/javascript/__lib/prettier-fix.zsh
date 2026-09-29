# Fix files via prettier --write
# Usage:
# $ prettier-fix --parser json file.json                              # Fix in-place
# $ prettier-fix --parser json file.json --original-path /real/path   # Config from real path
source "${0:A:h}/prettier-helpers.zsh"

function prettier-fix() {
  setopt local_options err_return

  zparseopts -E -D \
    -parser:=flagParser \
    -original-path:=flagOriginalPath

  local parser=${flagParser[2]}
  local originalPath=${flagOriginalPath[2]}

  # --parser is required
  if [[ $parser == "" ]]; then
    echoerr "Error: --parser is required"
    return 1
  fi

  # --original-path is single-file only
  if [[ $originalPath != "" && $# -gt 1 ]]; then
    echoerr "Error: --original-path can only be used with a single file"
    return 1
  fi

  # Resolve config from original path or first file
  local configDir="${1:a:h}"
  [[ $originalPath != "" ]] && configDir="${originalPath:h}"

  local projectRoot="$(yarn-root $configDir --force)"

  local prettierBin="$(__prettier-binary "$projectRoot")"
  local configFile="$(__prettier-config "$projectRoot")"

  local prettierArgs=(
    --config "$configFile"
    --ignore-path=
    --parser "$parser"
    --write
  )

  # Hide the list of formatted files, but keep errors visible
  $prettierBin ${prettierArgs[@]} "$@" >/dev/null
}
