# Defines bats-lint-custom() for use by bats-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ bats-lint-custom file.bats [file2.bats ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence bats-lint-custom >/dev/null && return 0

# Capture directory at source time
_batsLintRulesDir="${0:A:h}/__rules"

bats-lint-custom() {
  # Source all rule files
  source "${_batsLintRulesDir}/rule-no-run-zsh.zsh"
  source "${_batsLintRulesDir}/rule-no-inline-function.zsh"
  source "${_batsLintRulesDir}/rule-no-top-level-var.zsh"
  source "${_batsLintRulesDir}/rule-prefer-zsh-autoload.zsh"
  source "${_batsLintRulesDir}/rule-prefer-batch-mock.zsh"

  lint-custom-run \
    --disable-prefix 'bats-lint' \
    batsLintRule_noRunZsh \
    batsLintRule_noInlineFunction \
    batsLintRule_noTopLevelVar \
    batsLintRule_preferZshAutoload \
    batsLintRule_preferBatchMock \
    -- "$@"
}
