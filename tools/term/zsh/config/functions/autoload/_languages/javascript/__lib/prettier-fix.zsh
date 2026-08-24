# Fix files via prettier --write
# Usage:
# $ prettier-fix --parser json file.json                              # Fix in-place
# $ prettier-fix --parser json file.json --original-path /real/path   # Config from real path
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

  # Resolve prettier binary
  local prettierBin="prettier"
  if [[ $projectRoot != "" && -f "$projectRoot/node_modules/.bin/prettier" ]]; then
    prettierBin="$projectRoot/node_modules/.bin/prettier"
  fi

  # Resolve prettier config file
  local configFile=$OROSHI_ROOT/prettier.config.js
  if [[ $projectRoot != "" ]]; then
    [[ -f "$projectRoot/prettier.config.js" ]] && configFile="$projectRoot/prettier.config.js"
    [[ -f "$projectRoot/.prettierrc.js" ]] && configFile="$projectRoot/.prettierrc.js"
  fi

  local prettierArgs=(
    --config "$configFile"
    --ignore-path=
    --parser "$parser"
    --write
  )

  $prettierBin ${prettierArgs[@]} "$@" >/dev/null 2>&1
}
