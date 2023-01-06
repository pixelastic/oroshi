# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function () {
  local themingPath=~/.oroshi/config/zsh/theming
  local colorsFilePath=${themingPath}/env/colors.zsh
  local projectsFilePath=${themingPath}/env/projects.zsh
  local filetypesFilePath=${themingPath}/env/filetypes.zsh

  # Generate env vars if missing, and load them
  [[ ! -r ${colorsFilePath} ]] && env-generate-colors
  source ${colorsFilePath}

  [[ ! -r ${projectsFilePath} ]] && env-generate-projects
  source ${projectsFilePath}

  [[ ! -r ${filetypesFilePath} ]] && env-generate-filetypes
  source ${filetypesFilePath}
}
