" PYTHON
" Enable python syntax highlighting
let python_highlight_all=1
" Run the file with F5
nnoremap <buffer> <F5> :!clear && python3 %<CR>
" Use indent to create folds
setlocal foldmethod=indent
" PEP8
setlocal tabstop=4 softtabstop=4 expandtab shiftwidth=4
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal formatoptions+=t
