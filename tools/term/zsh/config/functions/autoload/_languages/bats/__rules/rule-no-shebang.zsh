# Custom Rule: batsLintRule_noShebang
# Detects shebang lines (#!) on line 1 of .bats files.
# Bats files must not have a shebang — they are sourced, not executed directly.
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-shebang.zsh
#   batsLintRule_noShebang <file.bats>
function batsLintRule_noShebang() {
  local code='noShebang'
  local msg='Bats files must not have a shebang on line 1'

  local file="$1"
  local firstLine
  read -r firstLine < "$file"

  # Only flag if first line starts with #!
  [[ "$firstLine" != '#!'* ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" 1 "$_SEP" "$msg"
}
