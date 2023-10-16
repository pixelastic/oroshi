# Extract a substring

local input="Hello World"
echo $input[0]    # Nothing, zsh starts at 1
echo $input[1]    # H
echo $input[1,5]  # Hello
echo $input[7,11] # World
echo $input[7,-1] # World

# ===
