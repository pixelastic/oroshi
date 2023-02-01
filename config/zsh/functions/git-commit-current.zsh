# Display the current commit hash
# Usage
# $ git-commit-current     # Current commit hash
function git-commit-current() {
  git log \
    --format='%h' \
    --max-count 1
}
