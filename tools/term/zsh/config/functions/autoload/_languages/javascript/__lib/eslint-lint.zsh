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
      column: .column,
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

# Return the eslint config file path: project-local if available, oroshi fallback otherwise
function __eslint-config() {
  local projectRoot="$1"

  # No project — use oroshi's global config
  if [[ $projectRoot == "" ]]; then
    print "$OROSHI_ROOT/eslint.config.js"
    return 0
  fi

  # Project-local config (flat config takes precedence over legacy)
  if [[ -f "$projectRoot/eslint.config.js" ]]; then
    print "$projectRoot/eslint.config.js"
    return 0
  fi
  if [[ -f "$projectRoot/.eslintrc.js" ]]; then
    print "$projectRoot/.eslintrc.js"
    return 0
  fi

  # Project exists but has no eslint config
  print "$OROSHI_ROOT/eslint.config.js"
}

# Return the working directory for eslint
function __eslint-working-directory() {
  local projectRoot="$1"
  shift
  local -a files=("$@")

  # In a project, files are always under the project root
  if [[ $projectRoot != "" ]]; then
    print "$projectRoot"
    return 0
  fi

  # Outside any project, use the deepest common ancestor of all files
  path-common-ancestor "${files[@]}"
}

# Return the eslint_d binary path: project-local if available, global otherwise
function __eslint-binary() {
  local projectRoot="$1"

  # Project has its own eslint_d
  if [[ $projectRoot != "" && -f "$projectRoot/node_modules/.bin/eslint_d" ]]; then
    print "$projectRoot/node_modules/.bin/eslint_d"
    return 0
  fi

  # Fall back to global eslint_d
  print "eslint_d"
}
