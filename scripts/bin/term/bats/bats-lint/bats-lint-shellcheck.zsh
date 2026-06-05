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
  excludedRules+=(SC2155) # Allow local var="$(cmd)"
  excludedRules+=(SC2317) # Declaring unused functions for mock is ok

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

  # Filter SC2154 for BATS magic variables injected by `run` (output, status, lines, line).
  # ShellCheck cannot see these assignments, so it always flags them as false positives.
  # Message format: "<varname> is referenced but not assigned."
  local batsRunVars='["output","status","lines","line"]'
  scOutput="$(printf '%s' "$scOutput" | jq -c \
    --argjson vars "$batsRunVars" \
    '[.[] | select((.code == 2154 and ((.message | split(" ")[0]) as $v | $vars | contains([$v]))) | not)]')"

  # Transform ShellCheck JSON: add "SC" prefix to integer code, drop fix suggestions
  local transformed="$(printf '%s\n' "$scOutput" | jq -c '[.[] | .code = "SC" + (.code | tostring) | del(.fix)]')"

  printf '%s\n' "$transformed"
  [[ "$(printf '%s' "$transformed" | jq 'length')" -gt 0 ]] && return 1
  return 0
}
