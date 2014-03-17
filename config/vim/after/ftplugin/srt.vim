" SRT

" Clean the file
inoremap <silent> <buffer> <F4> <Esc>:call b:CleanSrtFile()<CR>
nnoremap <silent> <buffer> <F4> :call b:CleanSrtFile()<CR>
function! b:CleanSrtFile()
	silent! call ConvertLineEndingsToUnix()
	silent! call ConvertToUTF8()
endfunction
