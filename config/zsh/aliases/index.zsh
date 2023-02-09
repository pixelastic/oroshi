# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH

for aliasPath in ~/.oroshi/config/zsh/aliases/**/*.zsh; do
  [[ ${aliasPath:t} == 'index.zsh' ]] && continue
  source $aliasPath
done

