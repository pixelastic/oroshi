" Default zsh syntax highlighter does not highlight --XXX, so we add it back
" Source: https://github.com/chrisbra/vim-zsh/blob/master/syntax/zsh.vim#L352
syn match zshSwitches '\s\zs--\=[a-zA-Z0-9-]\+'
