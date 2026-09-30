# Shared helpers for eslint-lint and eslint-fix
# Resolves the eslint binary, config file, install root, and working directory

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

# Succeed when the resolved config lives inside the project rather than in oroshi
function __eslint-config-is-project-owned() {
  local projectRoot="$1"
  local configFile="$(__eslint-config "$projectRoot")"

  [[ $projectRoot != "" && $configFile == "$projectRoot/"* ]]
}

# Return the eslint_d binary path: project-local only with a project-local config, global otherwise
function __eslint-binary() {
  local projectRoot="$1"
  local localBinary="$projectRoot/node_modules/.bin/eslint_d"

  # Project has its own config and its own eslint_d
  if __eslint-config-is-project-owned "$projectRoot" && [[ -f $localBinary ]]; then
    print "$localBinary"
    return 0
  fi

  # Fall back to global eslint_d
  print "eslint_d"
}

# Return the root holding the eslint install: the config's owner, so binary and config always match
function __eslint-root() {
  local projectRoot="$1"

  # The project owns the config, so it owns the matching eslint
  if __eslint-config-is-project-owned "$projectRoot"; then
    print "$projectRoot"
    return 0
  fi

  # Oroshi's config needs oroshi's eslint
  print "$OROSHI_ROOT"
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
