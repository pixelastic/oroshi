# Shared helpers for prettier-fix
# Resolves the prettier binary and config file

# Return the prettier config file path: project-local if available, oroshi fallback otherwise
function __prettier-config() {
  local projectRoot="$1"

  # No project — use oroshi's global config
  if [[ $projectRoot == "" ]]; then
    print "$OROSHI_ROOT/prettier.config.js"
    return 0
  fi

  # Project-local config (prettier.config.js takes precedence over .prettierrc.js)
  if [[ -f "$projectRoot/prettier.config.js" ]]; then
    print "$projectRoot/prettier.config.js"
    return 0
  fi
  if [[ -f "$projectRoot/.prettierrc.js" ]]; then
    print "$projectRoot/.prettierrc.js"
    return 0
  fi

  # Project exists but has no prettier config
  print "$OROSHI_ROOT/prettier.config.js"
}

# Return the prettier binary path: project-local only with a project-local config, global otherwise
function __prettier-binary() {
  local projectRoot="$1"
  local configFile="$(__prettier-config "$projectRoot")"
  local localBinary="$projectRoot/node_modules/.bin/prettier"

  # Project has its own config and its own prettier
  if [[ $projectRoot != "" && $configFile == "$projectRoot/"* && -f $localBinary ]]; then
    print "$localBinary"
    return 0
  fi

  # Fall back to global prettier
  print "prettier"
}
