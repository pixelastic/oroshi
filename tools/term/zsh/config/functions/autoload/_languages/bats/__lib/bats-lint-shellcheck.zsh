# Defines bats-lint-shellcheck() for use by bats-lint
# Sourced by the orchestrator — not standalone, no shebang
# Delegates to shellcheck-lint, which the orchestrator must source first
#
# Usage (called by the orchestrator):
# $ bats-lint-shellcheck file.bats [file2.bats ...]

function bats-lint-shellcheck() {
  # Shellcheck rules excluded for all BATS files (grow incrementally as false positives are found)
  local -a excludedRules=()
  excludedRules+=(SC2016) # $var in single-quoted printf is intentional in bats fixtures
  excludedRules+=(SC2155) # Allow local var="$(cmd)"
  excludedRules+=(SC2317) # Allowing declaring unused functions (useful in mocks)
  excludedRules+=(SC2034) # Allowing declaring unused vars (useful in mocks)
  excludedRules+=(SC2030) # Modification of var is local to subshell caused by @test
  excludedRules+=(SC2031) # Var was modified in a subshell; change might be lost in @test

  # Run shellcheck through the shared helper (directories skipped, unified schema)
  local scOutput="$(shellcheck-lint --json --exclude "${(j:,:)excludedRules}" "$@")"

  # shellcheck-lint prints nothing when shellcheck itself failed (error already on stderr)
  [[ "$scOutput" == "" ]] && return 1

  # Filter SC2154 for BATS magic variables injected by `run` (output, status, lines, line).
  # ShellCheck cannot see these assignments, so it always flags them as false positives.
  # Message format: "<varname> is referenced but not assigned."
  local batsRunVars='["output","status","lines","line"]'
  local filtered="$(printf '%s' "$scOutput" | jq --compact-output \
    --argjson vars "$batsRunVars" \
  '[
        .[] | select(
          (.code == "SC2154" and ((.message | split(" ")[0]) as $v | $vars | contains([$v]))
        )
      | not)]')"

  printf '%s\n' "$filtered"
  [[ "$filtered" != "[]" ]] && return 1
  return 0
}
