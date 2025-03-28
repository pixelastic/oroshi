# Custom shell tools, like nvm, rvm, etc
for item in $ZSH_CONFIG_PATH/tools/*.zsh; do
	[[ ${item:t} == "index.zsh" ]] && continue
	source ${item}
done
