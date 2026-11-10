# Turn --body or --body-file into the text of a body
# Sourced by helpers, never called from the shell. It fills `REPLY` (empty when
# neither flag is given), so call it directly and not in a subshell.
# Usage:
# $ source body-resolve.zsh
# $ git-github-body-resolve --body "Some text"
# $ git-github-body-resolve --body-file ./body.md
# $ print -r -- "$REPLY"
# Fails when both flags are given, or when the file does not exist

function git-github-body-resolve() {
  setopt local_options err_return

  zparseopts -E -D \
    -body:=flagBody \
    -body-file:=flagBodyFile

  local body="${flagBody[2]}"
  local bodyFile="${flagBodyFile[2]}"

  # The source of the text must be unambiguous
  if (( ${#flagBody} > 0 && ${#flagBodyFile} > 0 )); then
    print -u 2 "Give --body or --body-file, not both"
    return 1
  fi

  # Without a file, the body is the text of --body, or empty
  if (( ${#flagBodyFile} == 0 )); then
    REPLY="$body"
    return 0
  fi

  # Stop if the body file does not exist
  if [[ ! -f "$bodyFile" ]]; then
    print -u 2 "Body file not found: $bodyFile"
    return 1
  fi

  REPLY="$(<"$bodyFile")"
}
