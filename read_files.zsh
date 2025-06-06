#!/usr/bin/env zsh
# Script to read all files in the current directory

# Print a header
echo "Reading all files in the current directory..."
echo "----------------------------------------"

# Loop through all regular files in the current directory
for file in *(.)
do
  echo "Contents of $file:"
  echo "----------------------------------------"
  cat "$file"
  echo "----------------------------------------"
  echo ""
done

echo "Finished reading all files."

