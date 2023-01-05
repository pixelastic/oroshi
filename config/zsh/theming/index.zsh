# The COLORS, PROJECTS and FILETYPES constants are used in many other config
# files so it should be sourced early.
source ~/.oroshi/config/zsh/theming/colors.zsh
source ~/.oroshi/config/zsh/theming/projects.zsh
source ~/.oroshi/config/zsh/theming/filetypes.zsh

# We bubble up the COLOR_* and PROJECT_* env variables to tmux.
# We do it only once as it will probably don't change often
if [[ $OROSHI_THEME_LOADED != "1" ]]; then
  colors-refresh

  OROSHI_THEME_LOADED=1
  tmux setenv -g OROSHI_THEME_LOADED $OROSHI_THEME_LOADED
fi
