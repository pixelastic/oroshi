# Hook orchestration
autoload -Uz add-zsh-hook

# Definitions {{{
source ${0:A:h}/aliases.zsh
source ${0:A:h}/exit-store.zsh
source ${0:A:h}/pwd-guard.zsh
source ${0:A:h}/git-env.zsh
source ${0:A:h}/prompt-populate.zsh
source ${0:A:h}/slow.zsh
source ${0:A:h}/chpwd.zsh
# }}}

# precmd {{{
add-zsh-hook precmd oroshi-aliases-precmd # must be first
add-zsh-hook precmd oroshi-last-command-exit-store
add-zsh-hook precmd oroshi-pwd-guard
add-zsh-hook precmd oroshi-git-env-store
add-zsh-hook precmd oroshi-prompt-synchronous-populate
add-zsh-hook precmd oroshi-prompt-asynchronous-populate
add-zsh-hook precmd oroshi-slow-command-precmd
# }}}

# preexec {{{
add-zsh-hook preexec oroshi-slow-command-preexec
add-zsh-hook preexec oroshi-aliases-preexec # must be last
# }}}

# chpwd {{{
add-zsh-hook chpwd oroshi-chpwd
# }}}
