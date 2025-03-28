# Returns the name of the branch we're transplanting to.
# Git does not expose this information by default, but we have a custom hook
# that saves this information in a file in the .git folder
function git-rebase-onto() {
  gitRoot="$(git-directory-root)"
  rebaseDir="${gitRoot}/.git/rebase-apply"
  ontoBranch="${rebaseDir}/x-onto-branch"

  if [[ -r "$ontoBranch" ]]; then
    cat "$ontoBranch"
    return 0
  fi
  return 1
}
