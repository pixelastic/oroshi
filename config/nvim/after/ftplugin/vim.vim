" VIM
" Fold {{{
setlocal foldmethod=marker
"}}}
" Misc {{{
setlocal omnifunc=syntaxcomplete#Complete
" Note: It seems that simply doing `setlocal iskeyword-=_` does not actually
" remove the _
setlocal iskeyword=@,48-57,192-255,-,#
" }}}
