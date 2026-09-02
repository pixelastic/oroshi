# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH

for item in "${0:A:h}"/**/*.zsh; do
  [[ ${item:t} == "index.zsh" ]] && continue
  source ${item}
done

# Inside of Claude, disable all alias expansion
if [[ "$CLAUDECODE" == "1" ]]; then
  setopt NO_ALIASES
fi
