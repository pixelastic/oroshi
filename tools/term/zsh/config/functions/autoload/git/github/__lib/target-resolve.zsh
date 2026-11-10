# Tell whether a helper targets an issue or a pull request
# Sourced by helpers, never called from the shell. It fills `reply` with the
# kind (`issue` or `pullrequest`) and the id, so call it directly and not in a
# subshell.
# Usage:
# $ source target-resolve.zsh
# $ git-github-target-resolve --issueId 42
# $ git-github-target-resolve --pullrequestId 108
# $ print -r -- "${reply[1]} ${reply[2]}"
# Fails when both flags are given, or when none is

function git-github-target-resolve() {
  setopt local_options err_return

  zparseopts -E -D \
    -issueId:=flagIssueId \
    -pullrequestId:=flagPullrequestId

  # The target must be unambiguous
  if (( ${#flagIssueId} > 0 && ${#flagPullrequestId} > 0 )); then
    print -u 2 "Give --issueId or --pullrequestId, not both"
    return 1
  fi

  # Stop if there is no target
  if (( ${#flagIssueId} + ${#flagPullrequestId} == 0 )); then
    print -u 2 "Give --issueId or --pullrequestId"
    return 1
  fi

  reply=(issue "${flagIssueId[2]}")
  (( ${#flagPullrequestId} > 0 )) && reply=(pullrequest "${flagPullrequestId[2]}")
  return 0
}
