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

  # Run shellcheck with bash dialect (BATS files embed bash, not sh); || true so errexit doesn't abort on findings
  local scOutput="$(shellcheck \
    --shell=bash \
    --external-sources \
    --format=json \
    --exclude="${(j:,:)excludedRules}" \
    "${input[@]}" || true)"
  [[ "$scOutput" == "" ]] && scOutput="[]"

  # Transform ShellCheck JSON to shared format: {file, line, col, code, message}
  local transformed="$(printf '%s\n' "$scOutput" | jq -c '[.[] | {
    file: .file,
    line: .line,
    col: .column,
    code: ("SC" + (.code | tostring)),
    message: .message
  }]')"

  printf '%s\n' "$transformed"
  [[ "$(printf '%s' "$transformed" | jq 'length')" -gt 0 ]] && return 1
  return 0
}
