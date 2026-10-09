# Defines shellcheck-lint() for use by zsh-lint
# Runs shellcheck in bash mode and converts its findings to the unified JSON schema
#
# Usage (called by the orchestrator):
# $ shellcheck-lint --json file.sh [file2.sh ...]
# $ shellcheck-lint --json --exclude SC2086,SC2155 file.sh

function shellcheck-lint() {
  setopt local_options err_return

  zparseopts -E -D \
    -json=flagJson \
    -exclude:=flagExclude

  local excludedRules="${flagExclude[2]}"

  # Exclude directories from the inputs
  local -a input=()
  for item in "$@"; do
    [[ -d $item ]] && continue
    input+=("$item")
  done

  # Nothing to lint once directories are removed
  if [[ ${#input} -eq 0 ]]; then
    printf '[]\n'
    return 0
  fi

  local -a shellcheckArgs=(
    --shell=bash
    --external-sources
    --format=json
  )
  [[ "$excludedRules" != "" ]] && shellcheckArgs+=(--exclude="$excludedRules")

  # shellcheck exits 0 when clean, 1 on findings and above 1 on internal errors
  local rawOutput
  local exitCode=0
  rawOutput="$(shellcheck "${shellcheckArgs[@]}" "${input[@]}")" || exitCode=$?
  if [[ $exitCode -gt 1 ]]; then
    echoerr "Error: shellcheck failed (exit $exitCode)"
    return 1
  fi

  # Transform shellcheck output to unified schema
  local result="$(printf '%s' "$rawOutput" | jq --compact-output '[.[] | {
    file: .file,
    code: "SC\(.code)",
    level: ({warning: "warn", style: "hint"}[.level] // .level),
    line: .line,
    endLine: .endLine,
    column: .column,
    endColumn: .endColumn,
    message: .message
  }]')"

  printf '%s\n' "$result"
  [[ "$result" != "[]" ]] && return 1
  return 0
}
