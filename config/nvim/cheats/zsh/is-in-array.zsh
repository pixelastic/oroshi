# To check if an element is in an array, we need to get its index with (ie) and
# make sure the result is not more than the size of the array
#
if [[ ! ${myArray[(ie)${myVar}]} -gt ${#myArray} ]]; then
  # It's in the array
fi

# For large arrays, it's better to build an inverted list
declare -A invertedList
local invertedList=()
for item in ${(f)invertedList}; do
  invertedList[$item]="1"
done
