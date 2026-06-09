# Python {{{
# Note: Currently unused
function oroshi_prompt_python() {
	true
	# # In a global pyenv environment
	# [[ ! $PYENV_VERSION == "" ]] && display="$ICONS[python] $PYENV_VERSION "
	# # In a local pipenv shell (the [] help remember to press Ctrl-D to get out)
	# [[ $PIPENV_ACTIVE == "1" ]] && display="[$ICONS[python] $(python-version)] "

	# if [[ $display == '' ]]; then
	#   return
	# fi
	# echo "$FG[green9]${display}%f"
}
# }}}
