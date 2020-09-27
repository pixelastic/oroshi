# Highlighting as I type {{{
source ~/.oroshi/config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation: 
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
# Methods (yellow)
ZSH_HIGHLIGHT_STYLES[alias]="fg=$COLOR[yellow]"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$COLOR[yellow]"
ZSH_HIGHLIGHT_STYLES[command]="fg=$COLOR[yellow]"
ZSH_HIGHLIGHT_STYLES[function]="fg=$COLOR[yellow]"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$COLOR[yellow]"
# Path (green)
ZSH_HIGHLIGHT_STYLES[path]="fg=$COLOR[green]"
# Arguments (orange)
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$COLOR[indigo]"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=$COLOR[indigo]"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$COLOR[indigo]"
# Strings (blue)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$COLOR[blue7]"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$COLOR[blue5]"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$COLOR[blue7]"
# Numbers (bold blue)
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLOR[blue]"
# Punctuation
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=$COLOR[teal7]"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$COLOR[teal7]"
# Variables
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=$COLOR[orange]"
ZSH_HIGHLIGHT_STYLES[assign]="fg=$COLOR[orange]"
# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$COLOR[red]"


# Even if the following styles are documented, I could not make them work last
# time I tried
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[path-prefix]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[comment]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[default]="fg=$$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=$COLOR[pink]"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$COLOR[pink]"
# }}}
