" VIM
" Linting
let b:ale_linters = ['vint']
" Fold {{{
setlocal foldmethod=marker
"}}}
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Misc {{{
setlocal omnifunc=syntaxcomplete#Complete
" Note: It seems that simply doing `setlocal iskeyword-=_` does not actually
" remove the _
setlocal iskeyword=@,48-57,192-255,-
" }}}
" }}}
