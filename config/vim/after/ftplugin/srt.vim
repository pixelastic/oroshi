" SRT

" Clean the file
function! b:CleanFile()
	silent! call ConvertLineEndingsToUnix()
	silent! call ConvertToUTF8()
endfunction
