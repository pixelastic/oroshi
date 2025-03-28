# Allow special chars (^ or ?) in aliases, otherwise they are treated as regexp
# markers
unsetopt NOMATCH

for item in "$ZSH_CONFIG_PATH"/aliases/**/*.zsh; do
	[[ ${item:t} == "index.zsh" ]] && continue
	source ${item}
done
