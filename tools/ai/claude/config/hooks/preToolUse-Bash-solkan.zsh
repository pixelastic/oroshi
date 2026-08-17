# Defines preToolUse-Bash-solkan() for use by preToolUse-Bash
# Sourced by the hook; hookDir must be set in the calling scope
# Not standalone — no shebang, not chmod +x
#
# Usage (called by the hook):
# $ preToolUse-Bash-solkan "git status"     # exit 0 (allowed)
# $ preToolUse-Bash-solkan "wget evil.com"  # exit 1 (rejected)

# Guard: skip if already defined (e.g. mocked in tests)
whence preToolUse-Bash-solkan > /dev/null && return 0

function preToolUse-Bash-solkan() {
  local repoRoot="$(git-directory-root)"
  local localAllowList="${repoRoot}/.claude/allow-list.json"
  local localRewriteList="${repoRoot}/.claude/rewrite-list.json"

  local solkanArgs=(
    --allow-list-file "${hookDir}/allow-list.json"
    --rewrite-list-file "${hookDir}/rewrite-list.json"
  )

  # Extra allow-list from repo-local config
  [[ -f "$localAllowList" ]] && solkanArgs+=(--allow-list-file "$localAllowList")

  # Extra rewrite-list from repo-local config
  [[ -f "$localRewriteList" ]] && solkanArgs+=(--rewrite-list-file "$localRewriteList")

  solkan "${solkanArgs[@]}" "$1"
}
