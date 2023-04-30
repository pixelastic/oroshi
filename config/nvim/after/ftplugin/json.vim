" JSON
" Fixing
let b:ale_fixers = ['prettier']
" Linting
let b:ale_linters = ['jsonlint', 'prettier']
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Folding {{{
setlocal foldmethod=syntax
" }}}
" Syntax Highligting {{{
" Use javascript syntax highlighting
augroup ftplugin_json
  autocmd!
  autocmd BufEnter <buffer> setlocal syntax=javascript
augroup END
" }}}
