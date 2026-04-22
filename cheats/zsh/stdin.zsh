# Check if input is coming from stdin (pipe)
# and read it with /usr/bin/cat

local input="$1"

# Read from pipe if available
[[ -p /dev/stdin ]] && input="$(/usr/bin/cat -)"

# Process the input
echo "$input"
