# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH

for item in "${0:A:h}"/**/*.zsh; do
  [[ ${item:t} == "index.zsh" ]] && continue
  source ${item}
done

# Inside of Claude, we disable some non-default aliases
if [[ "$CLAUDECODE" == "1" ]]; then
  unalias 'cat'
  unalias 'cp'
  unalias 'diff'
  unalias 'find'
  unalias 'grep'
  unalias 'ls'
  unalias 'mv'
fi
