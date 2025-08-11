# shellcheck disable=SC2154

# Check if an array is not empty
if ((${#array[@]})); then
  echo "Array is not empty"
else
  echo "Array is empty"
fi

# Check if an array is not empty
if ((${#array[@]} == 0)); then
  echo "Array is empty"
else
  echo "Array is not empty"
fi
