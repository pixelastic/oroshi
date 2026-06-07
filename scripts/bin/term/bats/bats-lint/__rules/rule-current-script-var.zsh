# Custom Rule: batsLintRule_currentScriptVar
# Detects when the script under test is not assigned to CURRENT.
# A variable assigned "$BATS_TEST_DIRNAME/../{basename}" (where basename is
# the test filename without .bats) must be named CURRENT.
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-current-script-var.zsh
#   batsLintRule_currentScriptVar <file.bats>
batsLintRule_currentScriptVar() {
  local code='currentScriptVar'

  local file="$1"
  local basename="${${1:t}%.bats}"
  local content="$(<"$file")"
  local lineno=0
  local line
  # Both brace forms: $BATS_TEST_DIRNAME and ${BATS_TEST_DIRNAME}
  # dollar var avoids single-quoted $VARNAME (SC2016)
  local dollar='$'
  local pat1="^[[:space:]]*([A-Z_][A-Z0-9_]*)=\"\\${dollar}BATS_TEST_DIRNAME/\\.\\./""${basename}""\"$"
  local pat2="^[[:space:]]*([A-Z_][A-Z0-9_]*)=\"\\${dollar}\\{BATS_TEST_DIRNAME\\}/\\.\\./""${basename}""\"$"

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ ! "$line" =~ $pat1 && ! "$line" =~ $pat2 ]] && continue
    [[ "$line" =~ '^[[:space:]]*CURRENT=' ]] && continue
    [[ "$line" =~ '^[[:space:]]*([A-Z_][A-Z0-9_]*)=' ]]
    local varname="${match[1]}"
    local msg="prefer using CURRENT, not \`${varname}\` for script under test"
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
