# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function oroshi_theming_index() {
	local colorsFilePath=$ZSH_CONFIG_PATH/theming/env/colors.zsh
	local projectsFilePath=$ZSH_CONFIG_PATH/theming/env/projects.zsh
	local filetypesFilePath=$ZSH_CONFIG_PATH/theming/env/filetypes.zsh

	# Generate env vars if missing, and load them
	# Note: We wrap this in functions that we immediably call to provide a more
	# precise stacktrace when running zprof
	function oroshi_theming_colors() {
		[[ ! -r ${colorsFilePath} ]] && env-generate-colors
		source ${colorsFilePath}
	}
	oroshi_theming_colors && unfunction oroshi_theming_colors

	function oroshi_theming_projects() {
		[[ ! -r ${projectsFilePath} ]] && env-generate-projects
		source ${projectsFilePath}
	}
	oroshi_theming_projects && unfunction oroshi_theming_projects

	function oroshi_theming_filetypes() {
		[[ ! -r ${filetypesFilePath} ]] && env-generate-filetypes
		source ${filetypesFilePath}
	}
	oroshi_theming_filetypes && unfunction oroshi_theming_filetypes
}
oroshi_theming_index
unfunction oroshi_theming_index
