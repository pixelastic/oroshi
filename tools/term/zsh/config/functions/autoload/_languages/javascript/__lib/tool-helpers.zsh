# Shared helpers for the JS tools (eslint, vitest)
# Finds where a tool is installed in a project

# Return the directory whose node_modules/.bin holds the tool, empty if none
# The project root is tried first, then the yarn workspaces (tools that are not hoisted)
function __tool-root() {
  local toolName="$1"
  local projectRoot="$2"

  # No project, nothing to look into
  [[ $projectRoot == "" ]] && return 0

  # Usual case: the tool is installed at the project root
  if [[ -e "$projectRoot/node_modules/.bin/$toolName" ]]; then
    print "$projectRoot"
    return 0
  fi

  # Not a monorepo, or no workspaces to inspect
  local gitRoot="$(git-directory-root "$projectRoot" 2>/dev/null)"
  local rawWorkspaces="$(yarn-workspace-list-raw "$projectRoot" 2>/dev/null)"
  [[ $rawWorkspaces == "" ]] && return 0

  # Rare case: the tool is only installed in a workspace
  for rawLine in ${(f)rawWorkspaces}; do
    local fields=(${(@ps/▮/)rawLine})
    local workspaceDirectory="$gitRoot/$fields[2]"

    # First workspace that has the binary wins
    if [[ -e "$workspaceDirectory/node_modules/.bin/$toolName" ]]; then
      print "$workspaceDirectory"
      return 0
    fi
  done
}
