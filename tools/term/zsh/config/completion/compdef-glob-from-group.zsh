# Build a _files -g glob from all FILETYPES entries in a given group
# Usage:
# $ compdef-glob-from-group archive   # => *.{7z,bz2,gz,...}
function compdef-glob-from-group() {
  setopt local_options err_return
  local group="$1"

  filetypes-load-definitions

  local -a exts=()
  for key in ${(k)FILETYPES}; do
    # Only process :group keys matching the target group
    [[ "$key" != *:group ]] && continue
    [[ "${FILETYPES[$key]}" != "$group" ]] && continue

    local name="${key%:group}"
    local pattern="${FILETYPES[${name}:pattern]}"

    # Skip entries with no pattern
    [[ "$pattern" == "" ]] && continue

    exts+=("${pattern#*.}")
  done

  local sorted=(${(o)exts})
  echo "*.{${(j:,:)sorted}}"
}
