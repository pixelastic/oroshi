" NERDTREE
" Open directories and files with l, Space or Enter
if !exists('*NERDTreeOpenDirOrFile')
	function! NERDTreeOpenDirOrFile()
		let line=getline('.')
		if match(line, '/') >= 0
			call nerdtree#invokeKeyMap("o")
		else
			call nerdtree#invokeKeyMap("T")
		endif
	endfunction
endif
nnoremap <buffer> <silent> l :call NERDTreeOpenDirOrFile()<CR>
nnoremap <buffer> <silent> <Space> :call NERDTreeOpenDirOrFile()<CR>
nnoremap <buffer> <silent> <CR> :call NERDTreeOpenDirOrFile()<CR>

