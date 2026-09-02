# Alias lifecycle hooks
# This ensure aliases are enabled for me, the user, in the CLI, but not in
# sourced .zsh files or $() expansions.

# precmd: Enable aliases right before I type my command in the CLI
function oroshi-aliases-precmd() {
  setopt ALIASES
}

# preexec: Disable alias right before the command gets executed (but after aliases are expanded)
function oroshi-aliases-preexec() {
  setopt NO_ALIASES
}
