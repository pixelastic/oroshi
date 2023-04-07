# Custom completions
#
# We map in this file which completion functions to call with which commands
# Completion functions start with _ and are stored in ./compdef/
#
# To make dev and debug easier, those completion functions actually call real
# function (starting with complete- instead of the _) that are autoloaded and
# can be manually tested. Those functions are stored in ./functions/autoload/completion
#
# Sources:
# https://unix.stackexchange.com/questions/239528/dynamic-zsh-autocomplete-for-custom-commands
# https://unix.stackexchange.com/questions/27236/zsh-autocomplete-ls-command-with-directories-only
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
#
# Note: Because of compdef cache, compdef association defined here can stay
# active even if deleted from this file. To be sure to remove them:
# - rm -f ~/.zcompdump 
# - reload the shell


compdef _jumps unmark j
compdef _oroshi_bat bat

# Git {{{
compdef _git-branches-local git-branch-switch git-branch-remove git-branch-merge
compdef _git-branches-remote git-branch-pull git-branch-remove-remote
compdef _git-files-dirty git-file-add
# }}}
# Docker {{{
compdef _docker-images-remote docker-image-pull
compdef _docker-images-local docker-image-list docker-image-count
compdef _docker-images-local-with-tags docker-image-exists docker-image-remove
# }}}
# JavaScript {{{
compdef _package-scripts yarn-run
compdef _nvm-lazyload lazyloadNvm
# }}}
# Python {{{
compdef _pyenv-lazyload lazyloadPyenv
# }}}
# SSH {{{
compdef _ssh-known-hosts ssh
# }}}
