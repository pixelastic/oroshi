# Check if the given branch exists
# Usage:
# $ git-branch-exists master         # Check a local branch
# $ git-branch-exists origin/master  # Check a remote branch
function git-branch-exists() {
  local branchName="$1"
  if [[ "$branchName" == "" ]]; then
    echo "✘ You must pass the name of the branch"
    return 1
  fi

  # Checking a remote branch instead
  if [[ "$branchName" =~ "/" ]]; then
    local branchSplit=(${(@s:/:)branchName})
    local remoteName="$branchSplit[1]"
    branchName="$branchSplit[2]"

    git-branch-exists-remote "$branchName" "$remoteName"
    return $?
  fi

  # Check locally if the branch exists
  git show-ref --quiet "refs/heads/${branchName}";
}
