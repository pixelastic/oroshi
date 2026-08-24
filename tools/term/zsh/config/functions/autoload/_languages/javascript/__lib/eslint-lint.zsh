# Lint files via eslint_d
# Usage:
# $ eslint-lint file.js              # Stylish output (default)
# $ eslint-lint --json file.js       # Unified JSON output
# $ eslint-lint file1.js file2.js    # Multiple files
function eslint-lint() {
  setopt local_options err_return

  zparseopts -E -D \
    -json=flagJson

  local isJson=${#flagJson}

  # Resolve eslint config file
  local configFile=~/.oroshi/eslint.config.js
  local firstFile="${1:a}"
  local projectRoot="$(yarn-root ${firstFile:h} --force)"
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

  local eslintArgs=(--config "$configFile")
  [[ $isJson == 1 ]] && eslintArgs+=(--format json)

  # JSON mode: transform eslint output to unified schema
  if [[ $isJson == 1 ]]; then
    local rawOutput="$($eslintBin ${eslintArgs[@]} "$@" 2>/dev/null)"

    local result="$(printf '%s' "$rawOutput" | jq '[.[] | .filePath as $file | .messages[] | {
      file: $file,
      code: .ruleId,
      level: (if .severity == 2 then "error" elif .severity == 1 then "warn" else "info" end),
      line: .line,
      column: .column,
      message: .message
    }]')"

    printf '%s\n' "$result"
    [[ "$result" != "[]" ]] && return 1
    return 0
  fi

  # Stylish mode: passthrough eslint_d output
  local rawOutput="$($eslintBin ${eslintArgs[@]} "$@" 2>/dev/null)"
  [[ "$rawOutput" == "" ]] && return 0
  printf '%s\n' "$rawOutput"
  return 1
}
