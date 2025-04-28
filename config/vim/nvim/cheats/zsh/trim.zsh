# Trim a string
local value="   Hello World     "

value="${value#"${value%%[![:space:]]*}"}"  # Trim spaces at beginning
value="${value%"${value##*[![:space:]]}"}"  # Trip spaces at end
echo $value
