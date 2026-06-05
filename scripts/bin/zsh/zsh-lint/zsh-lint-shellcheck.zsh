# Defines zsh-lint-shellcheck() for use by zsh-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ zsh-lint-shellcheck file.zsh [file2.zsh ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence zsh-lint-shellcheck >/dev/null && return 0

zsh-lint-shellcheck() {
  # List of shellcheck rules not relevant in zsh
  local -a excludedRules=()
  excludedRules+=(SC1009) # note: The mentioned syntax error was in this if expression.
  excludedRules+=(SC1035) # error: You are missing a required space after the !.
  excludedRules+=(SC1036) # error: '(' is invalid here. Did you forget to escape it?
  excludedRules+=(SC1058) # error: Expected 'do'.
  excludedRules+=(SC1072) # error: Expected test to end here (don't wrap commands in []/[[]]). Fix any mentioned problems and try again.
  excludedRules+=(SC1073) # error: Couldn't parse this test expression. Fix to allow more checks.
  excludedRules+=(SC1087) # error: Use braces when expanding arrays, e.g. ${array[idx]} (or ${var}[.. to quiet).
  excludedRules+=(SC1088) # error: Parsing stopped here. Invalid use of parentheses?
  excludedRules+=(SC1090) # warning: ShellCheck can't follow non-constant source. Use a directive to specify location.
  excludedRules+=(SC1091) # note: Not following: ./path/to/file openBinaryFile: does not exist (No such file or directory)
  excludedRules+=(SC1099) # note: The mentioned syntax error was in this simple command.
  excludedRules+=(SC2004) # note: $/${} is unnecessary on arithmetic variables.
  excludedRules+=(SC2034) # warning: {var} appears unused. Verify use (or export if used externally).
  excludedRules+=(SC2035) # note: Use ./*glob* or -- *glob* so names with dashes won't become options.
  excludedRules+=(SC2051) # warning: Bash doesn't support variables in brace range expansions. [SC2051]
  excludedRules+=(SC2054) # error: Use spaces, not commas, to separate array elements. (false positive: zsh array slice syntax $array[start,end])
  excludedRules+=(SC2066) # error: Since you double quoted this, it will not word split, and the loop will only run once
  excludedRules+=(SC2068) # error: Double quote array expansions to avoid re-splitting elements.
  excludedRules+=(SC2076) # warning: Remove quotes from right-hand side of =~ to match as a regex rather than literally. [SC2076]
  excludedRules+=(SC2079) # error: (( )) doesn't support decimals. Use bc or awk.
  excludedRules+=(SC2086) # note: Double quote to prevent globbing and word splitting.
  excludedRules+=(SC2102) # note: Ranges can only match single chars (mentioned due to duplicates)
  excludedRules+=(SC2124) # warning: Assigning an array to a string! Assign as array, or use * instead of @ to concatenate.
  excludedRules+=(SC2125) # warning: Brace expansions and globs are literal in assignments. Quote it or use an array.
  excludedRules+=(SC2128) # warning: Expanding an array without an index only gives the first element.
  excludedRules+=(SC2139) # warning: This expands when defined, not when used. Consider escaping.
  excludedRules+=(SC2154) # warning: match is referenced but not assigned.
  excludedRules+=(SC2155) # warning: Declare and assign separately to avoid masking return values.
  excludedRules+=(SC2164) # warning: Use 'cd ... || exit' in case cd fails. (covered by setopt errexit in zsh)
  excludedRules+=(SC2157) # error: Argument to implicit -n is always true due to literal strings.
  excludedRules+=(SC2168) # error: 'local' is only valid in functions.
  excludedRules+=(SC2190) # warning: Elements in associative arrays need index, e.g. array=( [index]=value ) .
  excludedRules+=(SC2193) # warning: The arguments to this comparison can never be equal. Make sure your syntax is correct.
  excludedRules+=(SC2203) # error: Globs are ignored in [[ ]] except right of =/!=. Use a loop.
  excludedRules+=(SC2206) # warning: Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
  excludedRules+=(SC2207) # warning: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
  excludedRules+=(SC2231) # note: Quote expansions in this for loop glob to prevent wordsplitting, e.g. "$dir"/*.txt
  excludedRules+=(SC2296) # error: Parameter expansions can't start with (. Double check syntax.
  excludedRules+=(SC2298) # error: ${${x}} is invalid. For expansion, use ${x}. For indirection, use arrays, ${!x} or (for sh) eval.
  excludedRules+=(SC2299) # error: Parameter expansions can't be nested. Use temporary variables. [SC2299]
  excludedRules+=(SC2300) # error: Parameter expansion can't be applied to command substitutions. Use temporary variables.

  # Exclude directories from the inputs
  local -a input=()
  for item in "$@"; do
    [[ -d $item ]] && continue
    input+=("$item")
  done

  [[ ${#input} -eq 0 ]] && printf '[]\n' && return 0

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
