# Ctrl-F: Search inside of text files in the current directory
oroshi-fzf-regexp-subdir-widget() {
	# Stop if not available
	if ! command -v fzf >/dev/null; then
		echo "fzf is not installed"
		zle reset-prompt
		return
	fi

	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-regexp-subdir)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	# nvim has no way to open multiple files, each at a different line.
	# The trick is to write in a temporary script all the files we want to open,
	# and then run that script on startup.
	local tmpScriptPath=$OROSHI_TMP_FOLDER/fzf/nvim-startup-script.tmp
	rm $tmpScriptPath
	
	for item in ${=selection}; do
    local split=(${(@s/:/)item})
		local filepath=$split[1]
		local lineNumber=$split[2]
		echo "tabedit ${filepath} | ${lineNumber}" >> $tmpScriptPath
	done
	echo "tabfirst | quit!" >> $tmpScriptPath

	nvim -S $tmpScriptPath

	return 0
}
zle -N oroshi-fzf-regexp-subdir-widget
bindkey 'Ⓖ' oroshi-fzf-regexp-subdir-widget
