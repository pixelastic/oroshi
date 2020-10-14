# Environment variables
local hostname="$(hostname)"
export EDITOR=vim
export CHROME_BIN=/usr/bin/google-chrome
export BROWSER=/usr/bin/google-chrome
export LANG=en_US.UTF-8
export TERM=xterm-256color
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
# FZF default config {{{
# Used by Ctrl-P both in zsh and in vim
export FZF_DEFAULT_OPTS=""
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --keep-right"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --border"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=80%"
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# }}}
