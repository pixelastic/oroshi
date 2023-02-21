# Custom completions
#
# Sources:
# https://unix.stackexchange.com/questions/239528/dynamic-zsh-autocomplete-for-custom-commands
# https://unix.stackexchange.com/questions/27236/zsh-autocomplete-ls-command-with-directories-only
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org

compdef _jumps unmark j

# Git {{{
compdef _git-branch-remote git-branch-pull
compdef _git-files-dirty git-file-add
# }}}
