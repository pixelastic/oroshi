# Custom Rule: zshLintRule_missingErrReturn
# Detects autoloaded functions (in $OROSHI_ROOT/tools/term/zsh/config/functions/autoload, no shebang, no .zsh extension) that lack 'setopt local_options err_return'
# Rule Output: file▮missingErrReturn▮error▮1▮message
zshLintRule_missingErrReturn() {
  local code='missingErrReturn'
  local msg="autoloaded function must have 'setopt local_options err_return' (add after the comment header)"

  local file="$1"
  local content="$(<"$file")"

  # Only applies to autoloaded functions (no shebang)
  local firstLine="${content%%$'\n'*}"
  [[ "$firstLine" =~ '^#!' ]] && return 0

  # Only applies to files inside the autoloaded functions directory
  local autoloadDir="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload"
  [[ "$file" != "$autoloadDir"/* ]] && return 0

  # Skip sourced utility files (.zsh extension)
  [[ "${file:e}" != "" ]] && return 0

  # Pass if setopt err_return is already present (not in a comment)
  local line
  for line in "${(@f)content}"; do
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ 'setopt'[[:space:]].*'err_return' ]] && return 0
  done

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" 1 "$_SEP" "$msg"
}
