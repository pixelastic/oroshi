# Fix files via eslint_d --fix
# Usage:
# $ eslint-fix file.js                              # Fix in-place
# $ eslint-fix file.js --original-path /real/path   # Config from real path
source "${0:A:h}/eslint-helpers.zsh"

function eslint-fix() {
  setopt local_options err_return

  zparseopts -E -D \
    -original-path:=flagOriginalPath

  local originalPath=${flagOriginalPath[2]}
  local files=("$@")

  # --original-path is single-file only
  if [[ $originalPath != "" && $# -gt 1 ]]; then
    echoerr "Error: --original-path can only be used with a single file"
    return 1
  fi

  # Resolve config from original path or first file
  local configDir="${1:a:h}"
  [[ $originalPath != "" ]] && configDir="${originalPath:h}"

  local projectRoot="$(yarn-root $configDir --force)"

  local eslintBin="$(__eslint-binary "$projectRoot")"
  local configFile="$(__eslint-config "$projectRoot")"

  # If --original-path is passed, we use it as the workingDirectory base
  [[ $originalPath != "" ]] && files=("$originalPath")
  local workingDirectory="$(__eslint-working-directory "$projectRoot" "${files[@]}")"

  # Point eslint_d to the right node_modules/eslint
  local -x ESLINT_D_ROOT="${projectRoot:-$OROSHI_ROOT}"

  local eslintArgs=(--config "$configFile" --fix)

  cd "$workingDirectory" && $eslintBin ${eslintArgs[@]} "$@" 2>/dev/null
}
