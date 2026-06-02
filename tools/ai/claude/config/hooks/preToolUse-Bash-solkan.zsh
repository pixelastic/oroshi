# Defines preToolUse-Bash-solkan() for use by preToolUse-Bash
# Sourced by the hook; hookDir must be set in the calling scope
# Not standalone — no shebang, not chmod +x
#
# Usage (called by the hook):
# $ preToolUse-Bash-solkan "git status"     # exit 0 (allowed)
# $ preToolUse-Bash-solkan "wget evil.com"  # exit 1 (rejected)

# Guard: skip if already defined (e.g. mocked in tests)
whence preToolUse-Bash-solkan > /dev/null && return 0

preToolUse-Bash-solkan() {
  solkan \
    --allow-list-file "${hookDir}/allowlist.json" \
    "$1"
}
