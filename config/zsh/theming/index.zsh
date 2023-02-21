# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function () {
  local colorsFilePath=$ZSH_CONFIG_PATH/theming/env/colors.zsh
  local projectsFilePath=$ZSH_CONFIG_PATH/theming/env/projects.zsh
  local filetypesFilePath=$ZSH_CONFIG_PATH/theming/env/filetypes.zsh

  # Generate env vars if missing, and load them
  [[ ! -r ${colorsFilePath} ]] && env-generate-colors
  source ${colorsFilePath}

  [[ ! -r ${projectsFilePath} ]] && env-generate-projects
  source ${projectsFilePath}

  [[ ! -r ${filetypesFilePath} ]] && env-generate-filetypes
  source ${filetypesFilePath}
}

