" SECURITY {{{
" We disable the "vim: set ai tw=75" type of strings in source files.
" This is used to change nvim settings on a per file basis, but could also allow
" malicious modeline to execute arbitrary code.
" Source: https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline
" }}}

