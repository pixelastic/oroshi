# Defines zsh-lint-syntax() for use by zsh-lint
# Sourced by the orchestrator — not standalone, no shebang
# Runs `zsh -n` on each file to catch syntax errors (missing done, fi, etc.)
#
# Usage (called by the orchestrator):
# $ zsh-lint-syntax file.zsh [file2.zsh ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence zsh-lint-syntax >/dev/null && return 0

function zsh-lint-syntax() {
  local -a results=()
  local errOutput
  local lineNum
  local msg
  # shellcheck disable=SC2016
  local jqFilter='{file:$f,code:"zshSyntax",level:"error",'
  # shellcheck disable=SC2016
  jqFilter+='line:$l,endLine:$l,column:1,endColumn:1,message:$m}'

  for file in "$@"; do
    [[ -d $file ]] && continue

    errOutput="$(zsh -n "$file" 2>&1)" && continue

    # Parse zsh -n output: "file:line: error message"
    for errLine in ${(f)errOutput}; do
      lineNum="${${errLine#*:}%%:*}"
      msg="${errLine#*:[0-9]##: }"

      results+=("$(jq -n --arg f "$file" --argjson l "${lineNum:-1}" --arg m "$msg" "$jqFilter")")
    done
  done

  if [[ ${#results[@]} -eq 0 ]]; then
    printf '[]\n'
  else
    printf '%s\n' "${results[@]}" | jq -cs '.'
  fi
}
