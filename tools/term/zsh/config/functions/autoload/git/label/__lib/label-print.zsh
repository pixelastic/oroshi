# Print a label as JSON, read back from the repo after a write
# Sourced by helpers, never called from the shell.
# Usage:
# $ source label-print.zsh
# $ git-label-print bug
# $ git-label-print bug --repo pixelastic/imoen
# {"name","color","description"}
# The name is matched without regard to case, like GitHub does
# Fails when the repo has no such label

function git-label-print() {
  setopt local_options err_return pipe_fail

  zparseopts -E -D \
    -repo:=flagRepo

  local name="$1"

  local listArgs=()
  (( ${#flagRepo} > 0 )) && listArgs+=(--repo "${flagRepo[2]}")

  local rawLine
  for rawLine in ${(f)"$(git-label-list-raw "${listArgs[@]}")"}; do
    local fields=("${(@ps/▮/)rawLine}")

    # Skip the labels that are not the one asked for
    [[ "${(L)fields[1]}" != "${(L)name}" ]] && continue

    jq \
      --null-input \
      --arg name "${fields[1]}" \
      --arg color "${fields[2]}" \
      --arg description "${fields[3]}" \
      '{name: $name, color: $color, description: $description}'
    return 0
  done

  print -u 2 "Label not found: $name"
  return 1
}
