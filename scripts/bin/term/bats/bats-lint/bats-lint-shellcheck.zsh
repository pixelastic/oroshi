# Defines bats-lint-shellcheck() for use by bats-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ bats-lint-shellcheck file.bats [file2.bats ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence bats-lint-shellcheck >/dev/null && return 0

bats-lint-shellcheck() {
  # Shellcheck rules excluded for all BATS files (grow incrementally as false positives are found)
  local -a excludedRules=()
  excludedRules+=(SC2016) # $var in single-quoted printf is intentional in bats fixtures

  # Exclude directories from the inputs
  local -a input=()
  for item in "$@"; do
    [[ -d $item ]] && continue
    input+=("$item")
  done

  [[ ${#input} -eq 0 ]] && printf '[]\n' && return 0

  # Run shellcheck
  local scOutput="$(shellcheck \
    --shell=bash \
    --external-sources \
    --format=json \
    --exclude="${(j:,:)excludedRules}" \
    "${input[@]}")"
  [[ "$scOutput" == "" ]] && scOutput="[]"

  # Transform ShellCheck JSON: add "SC" prefix to integer code, drop fix suggestions
  local transformed="$(printf '%s\n' "$scOutput" | jq -c '[.[] | .code = "SC" + (.code | tostring) | del(.fix)]')"

  printf '%s\n' "$transformed"
  [[ "$(printf '%s' "$transformed" | jq 'length')" -gt 0 ]] && return 1
  return 0
}
