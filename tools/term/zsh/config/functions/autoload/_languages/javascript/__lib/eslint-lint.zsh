# Lint files via eslint_d
# Usage:
# $ eslint-lint file.js              # Stylish output (default)
# $ eslint-lint --json file.js       # Unified JSON output
# $ eslint-lint file1.js file2.js    # Multiple files
source "${0:A:h}/eslint-helpers.zsh"

function eslint-lint() {
  setopt local_options err_return

  zparseopts -E -D \
    -json=flagJson

  local isJson=${#flagJson}

  local firstFile="${1:a}"
  local projectRoot="$(yarn-root ${firstFile:h} --force)"

  local eslintBin="$(__eslint-binary "$projectRoot")"
  local configFile="$(__eslint-config "$projectRoot")"
  local workingDirectory="$(__eslint-working-directory "$projectRoot" "$@")"

  # Point eslint_d to the right node_modules/eslint
  local -x ESLINT_D_ROOT="${projectRoot:-$OROSHI_ROOT}"

  local eslintArgs=(--config "$configFile")
  [[ $isJson == 1 ]] && eslintArgs+=(--format json)

  local rawOutput="$(cd "$workingDirectory" && $eslintBin ${eslintArgs[@]} "$@" 2>/dev/null)"

  # JSON mode: transform eslint output to unified schema
  if [[ $isJson == 1 ]]; then
    local result="$(printf '%s' "$rawOutput" | jq '[.[] | .filePath as $file | .messages[] | {
      file: $file,
      code: .ruleId,
      level: (if .severity == 2 then "error" elif .severity == 1 then "warn" else "info" end),
      line: .line,
      endLine: (.endLine // .line),
      column: .column,
      endColumn: (.endColumn // .column),
      message: .message
    }]')"

    printf '%s\n' "$result"
    [[ "$result" != "[]" ]] && return 1
    return 0
  fi

  # Stylish mode: passthrough eslint_d output
  [[ "$rawOutput" == "" ]] && return 0
  printf '%s\n' "$rawOutput"
  return 1
}
