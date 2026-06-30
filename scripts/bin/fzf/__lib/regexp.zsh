# Shared ripgrep invocation for regexp FZF scripts
# Usage: regexp-run <query> <directory>
regexp-run() {
  local query="$1"
  local directory="$2"

  # Nothing to search if query is empty
  [[ "$query" == "" ]] && return 0

  rg \
    --color=always \
    --no-heading \
    --with-filename \
    --line-number \
    --column \
    --field-match-separator='⦙' \
    --field-context-separator='⦙' \
    -- "$query" \
    "$directory" || true
}
