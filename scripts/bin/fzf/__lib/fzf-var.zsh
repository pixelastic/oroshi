# Persist arbitrary key-value pairs scoped to the current Kitty window.
# Stored as files on disk under $OROSHI_TMP_FOLDER/fzf/var/$KITTY_WINDOW_ID/
# Source this: source "${0:h}/__lib/fzf-var.zsh"

# Save a value under the given key.
# Usage: fzf-var-write {key} {value}
fzf-var-write() {
  local key="$1"
  local value="$2"
  local saveFilepath="${OROSHI_TMP_FOLDER}/fzf/var/${KITTY_WINDOW_ID}/${key}"
  mkdir -p "${saveFilepath:h}"
  echo "$value" > "$saveFilepath"
}

# Read a value previously saved with fzf-var-write.
# Usage: fzf-var-read {key} [{defaultValue}]
fzf-var-read() {
  local key="$1"
  local defaultValue="$2"
  local saveFilepath="${OROSHI_TMP_FOLDER}/fzf/var/${KITTY_WINDOW_ID}/${key}"
  if [[ -f "$saveFilepath" ]]; then
    cat "$saveFilepath"
    return 0
  fi
  echo "$defaultValue"
}
