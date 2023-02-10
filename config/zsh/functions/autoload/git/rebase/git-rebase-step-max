# Returns the max number of steps of the current rebase
function git-rebase-step-max() {
  gitRoot="$(git-directory-root)"
  rebaseDir="${gitRoot}/.git/rebase-apply"
  maxStep="${rebaseDir}/last"

  cat "$maxStep"
}
