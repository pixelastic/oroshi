# Check if a string contains another string
local bigString="Maybe I contain a smallString";

if [[ $bigString = *"smallString"* ]]; then
  echo "It contains it"
fi
