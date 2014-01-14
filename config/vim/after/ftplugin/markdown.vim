" MARKDOWN
" Add headers with ,(1|2|3|4|5)
nnoremap <buffer> <leader>& I# <Esc>j
nnoremap <buffer> <leader>é I## <Esc>j
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

" Auto-wrap text
setlocal formatoptions+=t

" Run file
function! b:RunFile()
	let htmlFile = expand('%:p:r') . '.html'
	" Create the html file
	silent execute '!markdown % > ' . htmlFile
	" Run it
	call OpenUrlInBrowser(htmlFile)
endfunction
