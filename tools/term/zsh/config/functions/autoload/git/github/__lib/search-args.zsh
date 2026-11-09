# Build the gh arguments shared by the issue and pullrequest search commands
# Sourced by the search commands, never called from the shell. It fills the
# `reply` array, so call it directly and not in a subshell.
# Usage:
# $ source search-args.zsh
# $ git-github-search-args --state closed --date-min 2026-01-01 --repo owner/name
# $ gh issue list "${reply[@]}"
# Flags: --state (default open), --date-min, --date-max, --repo, --query

function git-github-search-args() {
  setopt local_options err_return

  zparseopts -E -D \
    -state:=flagState \
    -date-min:=flagDateMin \
    -date-max:=flagDateMax \
    -repo:=flagRepo \
    -query:=flagQuery

  local state="${flagState[2]:-open}"
  local dateMin="${flagDateMin[2]}"
  local dateMax="${flagDateMax[2]}"
  local repo="${flagRepo[2]}"
  local query="${flagQuery[2]}"

  reply=(--state "$state")
  [[ "$repo" != "" ]] && reply+=(--repo "$repo")

  # A date without a time is midnight UTC
  [[ "$dateMin" != "" && "$dateMin" != *T* ]] && dateMin+="T00:00:00Z"
  [[ "$dateMax" != "" && "$dateMax" != *T* ]] && dateMax+="T00:00:00Z"

  # GitHub search holds the query and the dates in one string
  local searchTerms=()
  [[ "$query" != "" ]] && searchTerms+=("$query")
  [[ "$dateMin" != "" ]] && searchTerms+=("created:>=$dateMin")
  [[ "$dateMax" != "" ]] && searchTerms+=("created:<=$dateMax")
  (( ${#searchTerms} > 0 )) && reply+=(--search "${searchTerms[*]}")

  return 0
}
