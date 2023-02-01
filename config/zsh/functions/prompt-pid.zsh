# Returns the PID of the topmost terminal window running the current script
# Usage:
# $ prompt-pid
function prompt-pid() {
  # Get the tree of all processes down to the current script
  local pidTree="$(pstree -psa $$)";

  # Read each line of the tree
  while read -r line; do
    # Line looks like:
    # "      `-zsh,1776668 /path/to/command"

    # Remove display clutter
    local trimmedLine="$(text-trim $line | text-substring 2)"

    # Keep only lines starting with zsh
    if [[ $trimmedLine != zsh* ]]; then
      continue
    fi

    # PID is between comma and space
    echo $trimmedLine \
      | text-split " " \
      | text-select-line 1 \
      | text-split "," \
      | text-select-line 2

    # Stop because we found it
    break

  done <<<$pidTree
}
