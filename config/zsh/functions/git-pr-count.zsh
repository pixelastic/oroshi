# Count how many open PRs the current repo has
# Usage:
# $ git-pr-count
function git-pr-count() {
  # Stop if not in a GitHub repo
  git-directory-is-github || return 1

  gh pr list --limit=1000 --json=number \
    | cat '-' \
    | jq length
}

