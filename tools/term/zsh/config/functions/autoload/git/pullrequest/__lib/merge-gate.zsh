# Decide if a pull request may be merged, from its merge state
# Sourced by helpers, never called from the shell. Only the `clean` state
# passes, any other state stops with an error that names it
# Usage:
# $ source merge-gate.zsh
# $ git-pullrequest-merge-gate 42
# $ git-pullrequest-merge-gate 42 --repo pixelastic/imoen
# Fails when the pull request does not exist, or when its state is not clean

function git-pullrequest-merge-gate() {
  setopt local_options err_return pipe_fail

  zparseopts -E -D \
    -repo:=flagRepo

  local id="$1"
  local repo="${flagRepo[2]}"

  local ghArgs=()
  [[ "$repo" != "" ]] && ghArgs+=(--repo "$repo")

  local view="$(
    gh pr view "$id" \
      --json mergeStateStatus \
      "${ghArgs[@]}"
  )"

  # Stop if gh found no pull request, as `local` hides its exit code
  [[ "$view" == "" ]] && return 1

  local state="$(jq --raw-output '.mergeStateStatus | ascii_downcase' <<< "$view")"

  # Only a clean pull request may be merged
  [[ "$state" == "clean" ]] && return 0

  print -u 2 "Pull request $id is not clean, its merge state is $state."
  print -u 2 "Run git-pullrequest-read $id ${ghArgs[*]} to see the checks"
  return 1
}
