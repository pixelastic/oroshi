# Check if current repo is currently rebasing
function git-rebase-in-progress() {
  local gitRoot="$(git-directory-root)"
  local rebaseDir="${gitRoot}/.git/rebase-apply"

  # No rebase in progress
  if [[ ! -r $rebaseDir/rebasing ]]; then
    return 1
  fi
  return 0
}
