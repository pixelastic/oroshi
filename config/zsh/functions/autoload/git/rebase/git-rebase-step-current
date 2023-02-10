# Returns the current step of the current rebase
function git-rebase-step-current() {
  gitRoot="$(git-directory-root)"
  rebaseDir="${gitRoot}/.git/rebase-apply"
  currentStep="${rebaseDir}/next"

  cat "$currentStep"
}
