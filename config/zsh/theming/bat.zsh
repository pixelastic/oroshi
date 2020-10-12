# Bat
#
# Configures the theme to use for the syntax highlight provided by the bat (cat
# clone) command
#
# See https://github.com/sharkdp/bat#highlighting-theme
#
# TODO: Add a custom theme
# https://github.com/sharkdp/bat#adding-new-themes

export BAT_THEME="ansi-dark"
# Use bat to color man
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
