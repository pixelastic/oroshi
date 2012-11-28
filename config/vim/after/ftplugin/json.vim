" JSON
" Use javascript syntax highlighting
au BufEnter <buffer> setlocal syntax=javascript

" Clean the file
function! b:CleanFile()
	silent execute '%!jq "."'
endfunction
