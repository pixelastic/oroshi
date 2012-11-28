" JSON

" Clean the file
function! b:CleanFile()
	silent execute '%!jq "."'
endfunction
