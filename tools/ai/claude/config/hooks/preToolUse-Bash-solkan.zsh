# Defines preToolUse-Bash-solkan() for use by preToolUse-Bash
# Sourced by the hook; hookDir must be set in the calling scope
# Not standalone — no shebang, not chmod +x
# Sources Bash-approval.zsh for the session allow-list path
#
# Usage (called by the hook):
# $ preToolUse-Bash-solkan "git status"     # exit 0 (allowed)
# $ preToolUse-Bash-solkan "wget evil.com"  # exit 1 (rejected)

# Guard: skip if already defined (e.g. mocked in tests)
whence preToolUse-Bash-solkan > /dev/null && return 0

source "${hookDir}/Bash-approval.zsh"

function preToolUse-Bash-solkan() {
  local repoRoot="$(git-directory-root)"
  local localAllowList="${repoRoot}/.claude/allow-list.json"
  local sessionAllowList="$(sessionAllowListFile)"
  local localRewriteList="${repoRoot}/.claude/rewrite-list.json"
  local localTokenSavingList="${repoRoot}/.claude/rewrite-list-token-saving.json"

  local solkanArgs=(
    --allow-list-file "${hookDir}/allow-list.json"
    --rewrite-list-file "${hookDir}/rewrite-list.json"
  )

  # Extra allow-list from repo-local config
  [[ -f "$localAllowList" ]] && solkanArgs+=(--allow-list-file "$localAllowList")

  # Extra allow-list from commands approved often enough this session (absolute path: Solkan resolves relative ones wrongly)
  [[ -f "$sessionAllowList" ]] && solkanArgs+=(--allow-list-file "$sessionAllowList")

  # Extra rewrite-list from repo-local config
  [[ -f "$localRewriteList" ]] && solkanArgs+=(--rewrite-list-file "$localRewriteList")

  # First pass without token-saving: Solkan tells how many commands there are
  local solkanJson=""
  local exitCode=0
  solkanJson="$(solkan "${solkanArgs[@]}" "$1")" || exitCode=$?

  # How many commands do we have?
  local commandCount="$(jq '.allow | (.allowed + .rejected) | length' <<<"$solkanJson" 2>/dev/null)"

  # If more than one, we run it
  if [[ "$commandCount" != "1" ]]; then
    print -r -- "$solkanJson"
    return $exitCode
  fi

  # If only one command, we rewrite it to include the token-saving version (if any)
  solkanArgs+=(--rewrite-list-file "${hookDir}/rewrite-list-token-saving.json")
  [[ -f "$localTokenSavingList" ]] && solkanArgs+=(--rewrite-list-file "$localTokenSavingList")
  solkan "${solkanArgs[@]}" "$1"
}
