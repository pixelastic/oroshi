# Splitting a raw text output, line by line
for rawLine in ${(f)rawOutput}; do
  local splitLine=(${(@s/▮/)rawLine})
done
