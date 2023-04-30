" SH
" Fixing
let b:ale_fixers = ['shfmt']
" Linting
let b:ale_linters = ['shellcheck']
" Use markers for folding
setlocal foldmethod=marker
" Word selection {{{
setlocal iskeyword=@,48-57,192-255
" }}}
