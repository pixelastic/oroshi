# Fix files via eslint_d --fix
# Usage:
# $ eslint-fix file.js                              # Fix in-place
# $ eslint-fix file.js --original-path /real/path   # Config from real path
source "${0:A:h}/eslint-helpers.zsh"

# Fix the given files in place, and return the eslint exit code
# Args: workingDirectory configFile originalPath files...
function __eslint-fix-in-place() {
  local workingDirectory="$1"
  local configFile="$2"
  shift 3

  # Change subshell to allow linting files outside of the caller's working dir
  (cd "$workingDirectory" && eslint_d --config "$configFile" --fix "$@" >/dev/null)
}

# Fix the content of a single file as if it was named originalPath, and return
# the eslint exit code. The file is a copy under another name: eslint reads it
# from stdin, so name-specific rules (like package.json ones) apply
# Args: workingDirectory configFile originalPath file
function __eslint-fix-as-original() {
  local workingDirectory="$1"
  local configFile="$2"
  local originalPath="$3"
  local file="$4"

  local fixedFile="$(mktemp)"
  local exitCode=0
  local eslintArgs=(
    --config "$configFile"
    --stdin
    --stdin-filename "$originalPath"
    --fix-to-stdout
  )
  (cd "$workingDirectory" && eslint_d "${eslintArgs[@]}" < "$file" > "$fixedFile") || exitCode=$?

  # Only overwrite the file when eslint did not crash and returned some code
  [[ $exitCode -le 1 && -s "$fixedFile" ]] && cp "$fixedFile" "$file"
  rm -f "$fixedFile"
  return $exitCode
}

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

  local configFile="$(__eslint-config "$projectRoot")"

  # If --original-path is passed, we use it as the workingDirectory base
  [[ $originalPath != "" ]] && files=("$originalPath")
  local workingDirectory="$(__eslint-working-directory "$projectRoot" "${files[@]}")"

  # Point eslint_d to the right node_modules/eslint
  local -x ESLINT_D_ROOT="$(__eslint-root "$projectRoot")"

  # Change subshell to allow linting files outside of the caller's working dir
  local exitCode=0
  local fixer=__eslint-fix-in-place
  [[ $originalPath != "" ]] && fixer=__eslint-fix-as-original
  $fixer "$workingDirectory" "$configFile" "${originalPath:a}" "$@" || exitCode=$?

  # eslint exit code 0: everything is fixed, no problem remains
  [[ $exitCode -eq 0 ]] && return 0

  # eslint exit code 1: fixed what it could, some problems remain, but we still
  # consider that a success of eslint-fix
  [[ $exitCode -eq 1 ]] && return 0

  # Any other exit code: eslint itself failed (bad config, crash)
  echoerr "Error: eslint failed (exit $exitCode)"
  return 1
}
