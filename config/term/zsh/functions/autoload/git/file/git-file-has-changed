# Check if a specific file changed, relative to commits
# Usage:
# $ git-file-has-changed package.json  # Checks working dir against last commit
# $ git-file-has-changed package.json abcdef # Checks working dir against specific commit
# $ git-file-has-changed package.json abcdef d34db33f # Checks between two specific commits

function git-file-has-changed() {
  local filepath=$1
  local commitStart=$2
  local commitEnd=$3

  local changed=''

  # Changes in working directory
  if [[ $commitStart == '' && $commitEnd == '' ]]; then
    changed="$(git diff --name-only $filepath)"
  fi

  # Changes since specific commit
  if [[ $commitStart != '' && $commitEnd == '' ]]; then
   changed="$(git diff --name-only ${commitStart}.. -- $filepath)"
  fi

  # Changes between two commits
  if [[ $commitStart != '' && $commitEnd != '' ]]; then
    diff="$(git diff --name-only ${commitStart}..${commitEnd} -- $filepath)"
  fi

  # The file hasn't been changed, so we fail the script
  if [[ $changed == '' ]]; then
    return 1
  fi
  return 0
}
