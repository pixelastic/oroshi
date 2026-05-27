# Custom Rule: luaLintRule_noVimDeepcopy
# Detects vim.deepcopy( calls; prefer F.clone instead
# Rule Output: file▮noVimDeepcopy▮error▮line▮message
luaLintRule_noVimDeepcopy() {
  local code='noVimDeepcopy'
  local msg='Use F.clone instead of vim.deepcopy'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'--' ]] && continue
    [[ ! "$line" =~ 'vim\.deepcopy\(' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
