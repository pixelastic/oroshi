# Highlighting as I type {{{
source ~/.oroshi/config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation: 
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
# Methods
ZSH_HIGHLIGHT_STYLES[alias]="fg=$COLORS[yellow]"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$COLORS[yellow]"
ZSH_HIGHLIGHT_STYLES[command]="fg=$COLORS[yellow]"
ZSH_HIGHLIGHT_STYLES[function]="fg=$COLORS[yellow]"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$COLORS[yellow]"
# Path
ZSH_HIGHLIGHT_STYLES[path]="fg=$COLORS[green]"
# Arguments
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$COLORS[indigo4]"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=$COLORS[indigo4]"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$COLORS[indigo4]"
# Strings (blue)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$COLORS[blue7]"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$COLORS[blue5]"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$COLORS[blue7]"
# Numbers (bold blue)
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLORS[blue]"
# Punctuation
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=$COLORS[teal7]"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$COLORS[teal7]"
# Variables
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=$COLORS[orange]"
ZSH_HIGHLIGHT_STYLES[assign]="fg=$COLORS[orange]"
# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$COLORS[red]"


# Even if the following styles are documented, I could not make them work last
# time I tried
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[path-prefix]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[comment]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[default]="fg=$$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=$COLORS[pink]"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$COLORS[pink]"
# }}}
