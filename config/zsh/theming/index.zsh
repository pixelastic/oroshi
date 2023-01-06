# We'll load the COLORS_, PROJECTS_ and FILETYPES_ environment variables from
# static files. If those files do not yet exist, we generate them.
function () {
  local themingPath=~/.oroshi/config/zsh/theming
  local colorsFilePath=${themingPath}/dist/colors.zsh
  local projectsFilePath=${themingPath}/dist/projects.zsh
  local filetypesFilePath=${themingPath}/dist/filetypes.zsh

  # Generate env vars if missing, and load them
  [[ ! -r ${colorsFilePath} ]] && env-generate-colors
  source ${colorsFilePath}

  [[ ! -r ${projectsFilePath} ]] && env-generate-projects
  source ${projectsFilePath}

  [[ ! -r ${filetypesFilePath} ]] && env-generate-filetypes
  source ${filetypesFilePath}

}

# TODO:
#
# We check if a theming-env.zsh file exists in a shared location
# If it does, we source it
# If not, we load colors-refresh
#
# colors-refresh will source the colors, projects and filetypes files
# and save its output in the theming-env.zsh file
# (it will first reload the kitty config, and finally update tmux)
#
# quand tmux a besoin des définition, il suffit aux script de charger le fichier
#
#
# The COLORS, PROJECTS and FILETYPES constants are used in many other config
# files so it should be sourced early.
# source ~/.oroshi/config/zsh/theming/colors.zsh
# source ~/.oroshi/config/zsh/theming/projects.zsh
# source ~/.oroshi/config/zsh/theming/filetypes.zsh

# We bubble up the COLOR_* and PROJECT_* env variables to tmux.
# We do it only once as it will probably don't change often
# TODO: Faut trouver un meilleur moyen de passer les vars de projet/couleur
# à tmux
# En les passant comme ça ça:
# - rame à fond actuellement
# - pollue les variables de tous les autres shells, donc obligé de tout fermer 
# - soit on load le fichier qui parse la config à chaque fois...
# - soit on l'écrit sur disque à la première ouvertue de shell
# - et tmux le lit quand il en a besoin
# 
# Donc, on checke si le fichier de définition existe
# Si oui, on le load
# si non, on le génère
# Si colors-refresh, ça le génère again
# if [[ $OROSHI_THEME_LOADED != "1" ]]; then
#   colors-refresh

#   OROSHI_THEME_LOADED=1
#   tmux setenv -g OROSHI_THEME_LOADED $OROSHI_THEME_LOADED
# fi
