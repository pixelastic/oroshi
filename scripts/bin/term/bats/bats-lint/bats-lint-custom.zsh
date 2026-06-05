# Defines bats-lint-custom() for use by bats-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ bats-lint-custom file.bats [file2.bats ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence bats-lint-custom >/dev/null && return 0

# Capture directory at source time ($0 is the file path when sourced, not inside a function)
_batsLintRulesDir="${0:A:h}/__rules"

bats-lint-custom() {
  # Source all rule files (comment a line to disable a rule)
  source "${_batsLintRulesDir}/rule-no-run-zsh.zsh"
  source "${_batsLintRulesDir}/rule-no-inline-function.zsh"
  lint-custom-run \
    --disable-prefix 'bats-lint-disable' \
    batsLintRule_noRunZsh \
    batsLintRule_noInlineFunction \
    -- "$@"
}
