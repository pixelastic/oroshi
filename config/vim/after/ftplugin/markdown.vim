" MARKDOWN
" Add headers with ,(1|2|3|4|5)
nnoremap <buffer> <leader>& yypVr=j
nnoremap <buffer> <leader>é yypVr-j
nnoremap <buffer> <leader>" I### <Esc>j
nnoremap <buffer> <leader>' I#### <Esc>j
nnoremap <buffer> <leader>( I##### <Esc>j
" `Code`
nnoremap <buffer> <leader>c viw<Esc>g`>a`<Esc>g`<i`<Esc>
vnoremap <buffer> <leader>c <Esc>mzg`>a`<Esc>g`<i`<Esc>`zl
" _Italic_
nnoremap <buffer> <leader>i viw<Esc>g`>a_<Esc>g`<i_<Esc>
vnoremap <buffer> <leader>i <Esc>mzg`>a_<Esc>g`<i_<Esc>`zl
" **Bold**
nnoremap <buffer> <leader>b viw<Esc>g`>a**<Esc>g`<i**<Esc>
vnoremap <buffer> <leader>b <Esc>mzg`>a**<Esc>g`<i**<Esc>`zl

" Create an html file for this file with F5
nnoremap <buffer> <F5> :!markdown % > %.html<CR><CR>
