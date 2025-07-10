# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function oroshi_theming_index() {
	local colorsDefinitionPath=$ZSH_CONFIG_PATH/theming/env/colors.zsh
  local colorsGeneratePath=$ZSH_CONFIG_PATH/theming/src/env-generate-colors

  local projectsDefinitionPath=$ZSH_CONFIG_PATH/theming/env/projects.zsh
  local projectsGeneratePath=$ZSH_CONFIG_PATH/theming/src/env-generate-projects

  local filetypesDefinitionPath=$ZSH_CONFIG_PATH/theming/env/filetypes.zsh
  local filetypesGeneratePath=$ZSH_CONFIG_PATH/theming/src/env-generate-filetypes

	# Generate env vars if missing, and load them
	# Note: We wrap this in functions that we immediably call to provide a more
	# precise stacktrace when running zprof
	function oroshi_theming_colors() {
		[[ ! -r $colorsDefinitionPath ]] && $colorsGeneratePath
		source $colorsDefinitionPath
	}
	oroshi_theming_colors && unfunction oroshi_theming_colors

	function oroshi_theming_projects() {
		[[ ! -r $projectsDefinitionPath ]] && $projectsGeneratePath
		source $projectsDefinitionPath
	}
	oroshi_theming_projects && unfunction oroshi_theming_projects

	function oroshi_theming_filetypes() {
		[[ ! -r $filetypesDefinitionPath ]] && $filetypesGeneratePath
		source $filetypesDefinitionPath
	}
	oroshi_theming_filetypes && unfunction oroshi_theming_filetypes
}
oroshi_theming_index
unfunction oroshi_theming_index
