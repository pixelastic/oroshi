# Update node dependencies if they changed since the specified commit
function git-dependencies-update-node() {
  local originCommit="$1"

  local gitRoot="$(git-directory-root)"
  local beaconFilepath="${gitRoot}/yarn.lock"

  local updateCommand="yarn install"
  local lockfilePath="${gitRoot}/.git/oroshi_yarn_install_in_progress"

  # Fail quickly if no such beacon file
  if [[ ! -f "$beaconFilepath" ]]; then
    return 1
  fi

  # Beacon file didn't change since the commit
  if ! git-file-has-changed $beaconFilepath $originCommit; then
    return 1
  fi

  # Update dependencies and write a lockfile while doing it
  fork "$updateCommand" "$lockfilePath"
}
