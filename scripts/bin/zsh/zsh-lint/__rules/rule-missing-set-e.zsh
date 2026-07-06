# Custom Rule: zshLintRule_missingSetE
# Detects scripts (files with shebang) that lack 'set -e'
# Rule Output: file▮missingSetE▮error▮1▮message
zshLintRule_missingSetE() {
  local code='missingSetE'
  local msg="script must have 'set -e' (add after the comment header, before the first code line)"

  local file="$1"
  local content="$(<"$file")"

  # Only applies to scripts (files with shebang)
  local firstLine="${content%%$'\n'*}"
  [[ ! "$firstLine" =~ '^#!' ]] && return 0

  # Pass if set -e is already present (not in a comment)
  local line
  for line in "${(@f)content}"; do
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ ^[[:space:]]*'set -'[a-zA-Z]*'e'[a-zA-Z]*[[:space:]]*$ ]] && return 0
  done

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" 1 "$_SEP" "$msg"
}
