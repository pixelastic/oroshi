" PYTHON

" Fixing
let b:ale_fixers = ['black']
" Linting
let b:ale_linters = ['flake8']

" Basic syntax formatting
setlocal tabstop=4 softtabstop=4 expandtab shiftwidth=4
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal formatoptions+=t
setlocal iskeyword=@,48-57,192-255,-,#

" Folding {{{
setlocal foldmethod=indent
augroup python_fold
  autocmd!
  autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
  autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<"
augroup END
" }}}
