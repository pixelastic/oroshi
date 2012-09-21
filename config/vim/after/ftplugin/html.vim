" HTML
" Add manual folding around tags
function! HTMLFoldTag()
	if foldclosed('.')==-1
		normal zfat
	else
		normal zo
	endif
endfunction
setlocal foldmethod=manual
nnoremap <buffer> za :call HTMLFoldTag()<CR>

" Clean the whole file with F4
nnoremap <buffer> <F4> :silent %!tidy -config ~/.tidyrc<CR>:silent call IndentWithTabs()<CR>
" Run the file in browser with F5
nnoremap <buffer> <F5> :!gui chromium-browser %<CR><CR>
