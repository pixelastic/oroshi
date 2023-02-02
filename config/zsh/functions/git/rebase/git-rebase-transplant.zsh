# Returns the name of the current commit being transplanted
function git-rebase-transplant() {
  gitRoot="$(git-directory-root)"
  rebaseDir="${gitRoot}/.git/rebase-apply"
  transplantFile="${rebaseDir}/head-name"
  transplantName="$(cat "$transplantFile")"

  echo "$transplantName" | sed 's/refs\/heads\///'
}
