# Custom Rule: batsLintRule_preferZshAutoload
# Detects CURRENT assignments using the long $OROSHI_ROOT/tools/term/zsh/config/functions/autoload path.
# Use $OROSHI_ZSH_AUTOLOAD (exported by the bats helper) instead.
# Rule Output: file▮code▮severity▮line▮message
# Usage:
#   source rule-prefer-zsh-autoload.zsh
#   batsLintRule_preferZshAutoload <file.bats>
batsLintRule_preferZshAutoload() {
  local code='preferZshAutoload'
  # shellcheck disable=SC2016
  local msg='Use $OROSHI_ZSH_AUTOLOAD instead of $OROSHI_ROOT/tools/term/zsh/config/functions/autoload'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Only flag CURRENT= assignment lines using the long autoload path
    # shellcheck disable=SC2016
    [[ ! "$line" =~ '^[[:space:]]*CURRENT=.*\$OROSHI_ROOT.*tools/term/zsh/config/functions/autoload' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
