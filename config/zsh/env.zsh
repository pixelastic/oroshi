# Environment variables
local hostname="$(hostname)"
export EDITOR=vim
export CHROME_BIN=/usr/bin/google-chrome
export BROWSER=/usr/bin/google-chrome
export LANG=en_US.UTF-8
path=(
  ~/.yarn/bin 
  ~/.rbenv/bin
  ~/.rbenv/shims
  ~/.pyenv/bin
  ~/.cargo/bin
  ~/.oroshi/scripts/bin
  ~/.oroshi/scripts/bin/vit/bin
  ~/.oroshi/scripts/bin/img/bin
  ~/.oroshi/scripts/bin/video/bin
  ~/.oroshi/scripts/bin/pdf/bin
  ~/.oroshi/scripts/bin/convert/bin
  ~/.oroshi/scripts/bin/coriolis/bin
  ~/.oroshi/private/scripts/bin
  ~/.oroshi/scripts/bin/local/$hostname
  ~/.oroshi/private/scripts/bin/local/$hostname
  ~/local/bin
  $path
  ~/.local/bin
  ~/.config/yarn/global/node_modules/.bin 
)
# Deduplicate entries in path
# See: http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html
typeset -U path PATH
# }}}
#
