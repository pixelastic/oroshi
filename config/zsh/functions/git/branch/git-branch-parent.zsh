# Return the closest parent branch of the current branch
# In other words: the nearest commit that resides on another branch, and what
# branch is that?
# Usage:
# $ git-branch-parent
function git-branch-parent() {
  git log --format=%d \
    | text-remove-empty-lines \
    | text-select-line 2 \
    | text-trim \
    | text-substring 1 -1 \
    | text-split ", " \
    | text-select-line 1
}