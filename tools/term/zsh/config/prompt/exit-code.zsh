# shellcheck disable=SC2154
# Exit code
# Display a color-coded prompt character based on the last command exit code:
# - Green if success
# - Red if error
# - Purple if any other error code
function oroshi-prompt-populate:exit_code() {
	OROSHI_PROMPT_PARTS[exit_code]=""

	# Error
	if [[ $OROSHI_LAST_COMMAND_EXIT == 1 ]]; then
		OROSHI_PROMPT_PARTS[exit_code]="%F{$colors[ERROR]}$ICONS[zsh-prompt] %f"
		return
	fi

	# Warning
	if [[ $OROSHI_LAST_COMMAND_EXIT -gt 1 ]]; then
		OROSHI_PROMPT_PARTS[exit_code]="%F{$colors[NOTICE]}$ICONS[zsh-prompt] %f"
		return
	fi

	OROSHI_PROMPT_PARTS[exit_code]="%F{$colors[SUCCESS]}$ICONS[zsh-prompt] %f"
}
# }}}
