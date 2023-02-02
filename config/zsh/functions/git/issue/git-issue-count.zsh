# Count how many open issues the current repo has
# Usage:
# $ git-issue-count
function git-issue-count() {
  # Stop if not in a GitHub repo
  git-directory-is-github || return 1

  gh issue list --limit=1000 --json=number \
    | cat '-' \
    | jq length
}

