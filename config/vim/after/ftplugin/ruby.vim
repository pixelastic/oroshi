" RUBY
" Indentation {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}
" #{} interpolation {{{
inoremap <buffer> ## #{}<Left>
let b:surround_35 = "#{\r}"
" }}}
" Helpers {{{
inoremap <buffer> Fep File.expand_path(
inoremap <buffer> Fbn File.basename(
inoremap <buffer> Fdn File.dirname(
inoremap <buffer> Fen File.extname(
" }}}
" Folds {{{
setlocal foldmethod=syntax
" }}}
" Linters {{{
let b:syntastic_checkers = ['rubocop', 'mri']
" }}}
" Misc {{{
setlocal omnifunc=rubycomplete#Complete
setlocal iskeyword-=_
" }}}

