# Custom shell tools, like nvm, rbenv, etc
for item in ${0:A:h}/*.zsh; do
	[[ ${item:t} == "index.zsh" ]] && continue
	source ${item}
done
