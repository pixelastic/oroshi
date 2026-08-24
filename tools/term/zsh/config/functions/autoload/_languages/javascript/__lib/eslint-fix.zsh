# Fix files via eslint_d --fix
# Usage:
# $ eslint-fix file.js                              # Fix in-place
# $ eslint-fix file.js --original-path /real/path   # Config from real path
function eslint-fix() {
  setopt local_options err_return

  zparseopts -E -D \
    -original-path:=flagOriginalPath

  local originalPath=${flagOriginalPath[2]}

  # --original-path is single-file only
  if [[ $originalPath != "" && $# -gt 1 ]]; then
    echoerr "Error: --original-path can only be used with a single file"
    return 1
  fi

  # Resolve config from original path or first file
  local configDir="${1:a:h}"
  [[ $originalPath != "" ]] && configDir="${originalPath:h}"

  local configFile=~/.oroshi/eslint.config.js
  local projectRoot="$(yarn-root $configDir --force)"
  if [[ $projectRoot != "" ]]; then
    cd "$projectRoot" || return 1
    [[ -f "$projectRoot/.eslintrc.js" ]] && configFile="$projectRoot/.eslintrc.js"
    [[ -f "$projectRoot/eslint.config.js" ]] && configFile="$projectRoot/eslint.config.js"
  fi

  # Resolve eslint binary
  local eslintBin="eslint_d"
  if [[ $projectRoot != "" && -f "$projectRoot/node_modules/.bin/eslint_d" ]]; then
    eslintBin="$projectRoot/node_modules/.bin/eslint_d"
  fi

  local eslintArgs=(--config "$configFile" --fix)

  $eslintBin ${eslintArgs[@]} "$@" 2>/dev/null
}
