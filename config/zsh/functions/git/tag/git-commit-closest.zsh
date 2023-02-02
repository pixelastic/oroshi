#!/usr/bin/env zsh
# Given two commit, display the one that is closer
# Usage:
# $ git-commit-closest {sha1} {sha2}
function git-commit-closest() {
  local sha1=$1
  local sha2=$2
  if [[ $sha1 == '' || $sha2 == '' ]]; then
    echo "You need to pass two commits"
    exit 1
  fi

  typeset -i dist1
  dist1=$(git-commit-count $sha1)
  typeset -i dist2
  dist2=$(git-commit-count $sha2)

  [[ $dist1 -gt $dist2 ]] && echo $sha2 && exit 0
  echo $sha1
}
