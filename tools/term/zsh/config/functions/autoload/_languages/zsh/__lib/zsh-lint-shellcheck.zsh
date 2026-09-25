# Defines zsh-lint-shellcheck() for use by zsh-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ zsh-lint-shellcheck file.zsh [file2.zsh ...]

function zsh-lint-shellcheck() {
  # Shellcheck rules not relevant in zsh.
  # Each rule has a short reason for exclusion.
  local -a excludedRules=(
    SC1009  # syntax error was in this if expression
    SC1035  # missing space after !
    SC1036  # '(' is invalid here
    SC1058  # expected 'do'
    SC1061  # couldn't find 'done' (zsh glob qualifiers)
    SC1062  # expected 'done' (companion to SC1061)
    SC1072  # expected test to end here
    SC1073  # couldn't parse this test expression
    SC1085  # forgot to move ;; (zsh glob parens in case)
    SC1087  # use braces when expanding arrays
    SC1088  # invalid use of parentheses
    SC1090  # can't follow non-constant source
    SC1091  # not following: file does not exist
    SC1099  # syntax error was in this simple command
    SC2004  # $/{} unnecessary on arithmetic variables
    SC2034  # variable appears unused
    SC2035  # use ./*glob* so dashes won't become options
    SC2051  # bash doesn't support variables in brace range
    SC2054  # use spaces not commas (zsh array slice)
    SC2066  # double quoted won't word split
    SC2068  # double quote array expansions
    SC2076  # remove quotes from =~ right-hand side
    SC2079  # (( )) doesn't support decimals
    SC2086  # double quote to prevent globbing
    SC2102  # ranges can only match single chars
    SC2124  # assigning array to string
    SC2125  # brace expansions literal in assignments
    SC2128  # expanding array without index
    SC2139  # expands when defined not when used
    SC2154  # variable referenced but not assigned
    SC2155  # declare and assign separately
    SC2157  # argument to implicit -n always true
    SC2164  # use cd || exit (covered by err_return)
    SC2168  # local only valid in functions
    SC2190  # associative arrays need index
    SC2193  # arguments can never be equal
    SC2203  # globs ignored in [[ ]] except right of =
    SC2206  # quote to prevent word splitting
    SC2207  # prefer mapfile or read -a
    SC2231  # quote expansions in for loop glob
    SC2296  # parameter expansions can't start with (
    SC2298  # ${${x}} is invalid
    SC2299  # parameter expansions can't be nested
    SC2300  # parameter expansion on command substitution
  )

  # Exclude directories from the inputs
  local -a input=()
  for item in "$@"; do
    [[ -d $item ]] && continue
    input+=("$item")
  done

  if [[ ${#input} -eq 0 ]]; then
    printf '[]\n'
    return 0
  fi

  # Run shellcheck (|| true so a non-zero exit on findings doesn't abort)
  local scOutput="$(shellcheck \
    --shell=bash \
    --external-sources \
    --format=json \
    --exclude="${(j:,:)excludedRules}" \
    "${input[@]}" || true)"
  [[ "$scOutput" == "" ]] && scOutput="[]"

  printf '%s\n' "$scOutput"
  [[ "$(printf '%s' "$scOutput" | jq 'length')" -gt 0 ]] && return 1
  return 0
}
