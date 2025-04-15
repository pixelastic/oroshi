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

	# nvim has no way to open multiple files, each at a different line. The hack
	# is to open vim, then chain vim commands to open the files files at their
	# respective lines
	local nvimArguments=()
	for item in ${=selection}; do
    local split=(${(@s/:/)item})
		local filepath=$split[1]
		local lineNumber=$split[2]
		nvimArguments+=(-c "tabedit $filepath | $lineNumber")
	done
	# Close the first tab (empty file)
	nvimArguments+=(-c 'tabfirst | quit!')

	nvim $nvimArguments

	return 0
}
zle -N oroshi-fzf-regexp-subdir-widget
bindkey 'Ⓖ' oroshi-fzf-regexp-subdir-widget
