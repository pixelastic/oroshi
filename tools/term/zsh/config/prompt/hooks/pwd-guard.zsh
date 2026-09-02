# If current directory no longer exists (if deleted externally), go up to the
# closest existing parent instead

function oroshi-pwd-guard() {
  [[ -d "$PWD" ]] && return

  local parent="$PWD"
  while [[ "$parent" != "/" ]]; do
    parent="${parent:h}"
    # Go to that parent if it exists
    if [[ -d "$parent" ]]; then
      cd "$parent"
      return
    fi
  done
  # Fallback to home if no parent found
  cd "$HOME"
}
