# To replace $otherVariable by "replacement" in input
local result="${input//${otherVariable}/replacement}"

# Use only one / to replace only the first occurence

# To use backreferences, it's a little more complex:
# - setop EXTENDED_GLOB turns on advanced syntax
# - (#b) turns on backreferences (just put it at the beginning)
# - ${match[x]} targets the parenthesis groups in order
setopt EXTENDED_GLOB
local input="tim-42"
echo ${input//(#b)(*)-([0-9]*)/${match[2]}:${match[1]}} # 42:tim
