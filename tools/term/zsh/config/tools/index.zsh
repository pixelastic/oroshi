# Custom shell tools, like nvm, rbenv, etc
for item in $OROSHI_ROOT/tools/term/zsh/config/tools/*.zsh; do
	[[ ${item:t} == "index.zsh" ]] && continue
	source ${item}
done
