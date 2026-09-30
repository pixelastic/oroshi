# Shared helpers for eslint-lint and eslint-fix
# Resolves the eslint config file, install root, and working directory

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

# Succeed when the package.json declares eslint as a direct dependency
function __package-declares-eslint() {
  local packageJson="$1"

  # No manifest to read
  [[ ! -r $packageJson ]] && return 1

  jq -e '.dependencies.eslint // .devDependencies.eslint // .peerDependencies.eslint' \
    "$packageJson" > /dev/null 2>&1
}

# Return the first yarn workspace whose package.json declares eslint, empty if none
function __eslint-workspace-root() {
  local projectRoot="$1"
  local gitRoot="$(git-directory-root "$projectRoot")"
  local rawWorkspaces="$(yarn-workspace-list-raw "$projectRoot" 2>/dev/null)"

  # Not a monorepo, or no workspaces to inspect
  [[ $rawWorkspaces == "" ]] && return 0

  for rawLine in ${(f)rawWorkspaces}; do
    local fields=(${(@ps/▮/)rawLine})
    local relativePath=$fields[2]
    local workspaceDirectory="$gitRoot/$relativePath"

    # First workspace that declares eslint wins
    if __package-declares-eslint "$workspaceDirectory/package.json"; then
      print "$workspaceDirectory"
      return 0
    fi
  done
}

# Return the directory whose node_modules holds eslint, so eslint_d resolves the project's real install
function __eslint-root() {
  local projectRoot="$1"

  # No project — oroshi's global root holds the bundled eslint
  if [[ $projectRoot == "" ]]; then
    print "$OROSHI_ROOT"
    return 0
  fi

  # The project root resolves eslint directly
  if [[ -d "$projectRoot/node_modules/eslint" ]]; then
    print "$projectRoot"
    return 0
  fi

  # Rare case, but eslint may not be defined at the root, but in a workspace
  local workspaceRoot="$(__eslint-workspace-root "$projectRoot")"
  if [[ $workspaceRoot != "" ]]; then
    print "$workspaceRoot"
    return 0
  fi

  # No workspace declares eslint — use the bundled fallback
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
