# Shared helpers for eslint-lint and eslint-fix
# Resolves the eslint binary, config file, and working directory

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
