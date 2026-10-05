# Shared helpers for eslint-lint and eslint-fix
# Resolves the eslint config file, install root, and working directory

source "${0:A:h}/tool-helpers.zsh"

# Return the project eslint config file path, empty if the project has none
function __eslint-project-config() {
  local projectRoot="$1"

  # No project, no project config
  [[ $projectRoot == "" ]] && return 0

  # Flat config takes precedence over legacy
  if [[ -f "$projectRoot/eslint.config.js" ]]; then
    print "$projectRoot/eslint.config.js"
    return 0
  fi
  if [[ -f "$projectRoot/.eslintrc.js" ]]; then
    print "$projectRoot/.eslintrc.js"
    return 0
  fi
}

# Return the directory whose node_modules holds eslint, so eslint_d resolves the project's real install
# The project's eslint is used only with a project config, oroshi's bundled one otherwise
function __eslint-root() {
  local projectRoot="$1"

  # Project has no eslint config, so it does not use eslint on its own
  if [[ "$(__eslint-project-config "$projectRoot")" == "" ]]; then
    print "$OROSHI_ROOT"
    return 0
  fi

  # Project has a config but no eslint installed
  local toolRoot="$(__tool-root eslint "$projectRoot")"
  if [[ $toolRoot == "" ]]; then
    print "$OROSHI_ROOT"
    return 0
  fi

  print "$toolRoot"
}

# Return the eslint config file path: the project's with the project's eslint, oroshi's otherwise
function __eslint-config() {
  local projectRoot="$1"

  # Bundled eslint, bundled config
  if [[ "$(__eslint-root "$projectRoot")" == "$OROSHI_ROOT" ]]; then
    print "$OROSHI_ROOT/eslint.config.js"
    return 0
  fi

  __eslint-project-config "$projectRoot"
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
