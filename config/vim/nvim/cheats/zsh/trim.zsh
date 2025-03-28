# Trim a string
local value="Hello World     "
echo ${value%%[[:space:]]} # "Hello World"
