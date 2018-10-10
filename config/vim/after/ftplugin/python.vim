" PYTHON
" Consider camel_case parts as different words
setlocal iskeyword=@,48-57,192-255,-,#
" Enable python syntax highlighting
let python_highlight_all=1
" PEP8
setlocal tabstop=4 softtabstop=4 expandtab shiftwidth=4
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal formatoptions+=t
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call PythonClean()<CR>
function! PythonClean() 
  let l:initialLine = line('.')
  execute '%!autopep8 - '
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}
" Folding {{{
setlocal foldmethod=indent
augroup python_fold
  autocmd!
  autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
  autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<"
augroup END
" }}}
