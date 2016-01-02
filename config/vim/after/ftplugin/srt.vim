" SRT

" Clean the file
inoremap <silent> <buffer> <F4> <Esc>:call CleanSrtFile()<CR>
nnoremap <silent> <buffer> <F4> :call CleanSrtFile()<CR>
function! CleanSrtFile()
	silent! call ConvertLineEndingsToUnix()
	silent! call ConvertToUTF8()
endfunction
