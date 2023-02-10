  # Check if currently in a yarn monorepo
function yarn-is-monorepo() {
  # No yarn
  [[ ! $commands[yarn] ]] && exit 1

  local gitRoot="$(git-directory-root)"
  local packageJsonPath="${gitRoot}/package.json"

  # Not in git repo
  [[ $gitRoot == "" ]] && exit 1

  # No package.json
  [[ ! -r $packageJsonPath ]] && exit 1

  # We simply check if the root package.json contains the string "workspaces":
  # This is fast, but not 100% reliable (false positive, package.json not at the
  # git root, etc)
  grep \
    --quiet \
    '"workspaces":' \
    $packageJsonPath &>/dev/null
}
