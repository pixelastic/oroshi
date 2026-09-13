# Custom Rule: zshLintRule_noOrBlock
# Detects || { — prefer if ! cmd; then ... fi for multi-instruction blocks
# Rule Output: file▮noOrBlock▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_noOrBlock() {
  local code='noOrBlock'
  # zsh-lint disable=noOrBlock
  local msg='Prefer if ! cmd; then ... fi over cmd || { ... } for multi-instruction blocks'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # zsh-lint disable=noChainedAnd
    [[ ! "$line" =~ '\|\|[[:space:]]*\{' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
