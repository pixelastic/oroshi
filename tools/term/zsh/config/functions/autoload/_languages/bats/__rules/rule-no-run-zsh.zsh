# Custom Rule: batsLintRule_noRunZsh
# Detects `run zsh` in BATS files; use bats_run_zsh instead
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-run-zsh.zsh
#   batsLintRule_noRunZsh <file.bats>
function batsLintRule_noRunZsh() {
  local code='noRunZsh'
  local msg='Use bats_run_zsh instead of run zsh'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip lines where run zsh is not a command (strings, titles, comments)
    [[ ! "$line" =~ '^[[:space:]]*run zsh' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
