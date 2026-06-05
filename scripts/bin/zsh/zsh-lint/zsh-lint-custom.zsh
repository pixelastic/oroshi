# Defines zsh-lint-custom() for use by zsh-lint
# Sourced by the orchestrator — not standalone, no shebang
#
# Usage (called by the orchestrator):
# $ zsh-lint-custom file.zsh [file2.zsh ...]

# Guard: skip if already defined (e.g. mocked in tests)
whence zsh-lint-custom >/dev/null && return 0

# Capture directory at source time ($0 is the file path when sourced, not inside a function)
_zshLintRulesDir="${0:A:h}/__rules"

zsh-lint-custom() {
  # Source all rule files (comment a line to disable a rule)
  source "${_zshLintRulesDir}/rule-no-manual-arg-parsing.zsh"
  source "${_zshLintRulesDir}/rule-no-grouped-locals.zsh"
  source "${_zshLintRulesDir}/rule-local-or-return.zsh"
  source "${_zshLintRulesDir}/rule-no-external-basename.zsh"
  source "${_zshLintRulesDir}/rule-no-while-read.zsh"
  source "${_zshLintRulesDir}/rule-single-equals-in-test.zsh"
  source "${_zshLintRulesDir}/rule-no-split-local.zsh"
  source "${_zshLintRulesDir}/rule-no-dash-z.zsh"
  source "${_zshLintRulesDir}/rule-no-dash-n.zsh"
  source "${_zshLintRulesDir}/rule-no-or-guard.zsh"
  source "${_zshLintRulesDir}/rule-no-double-negative.zsh"
  source "${_zshLintRulesDir}/rule-no-arith-flag-test.zsh"

  lint-custom-run \
    --disable-prefix 'zsh-lint-disable' \
    zshLintRule_noManualArgParsing \
    zshLintRule_noGroupedLocals \
    zshLintRule_localOrReturn \
    zshLintRule_noExternalBasename \
    zshLintRule_noWhileRead \
    zshLintRule_singleEqualsInTest \
    zshLintRule_noSplitLocal \
    zshLintRule_noDashZ \
    zshLintRule_noDashN \
    zshLintRule_noOrGuard \
    zshLintRule_noDoubleNegative \
    zshLintRule_noArithFlagTest \
    -- "$@"
}
