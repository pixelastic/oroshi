" NERDTree
augroup nerdtree
	" Start NERDTree if vim opened without arg
	autocmd VimEnter * if !argc() | NERDTree | endif
	" Close vim if NERDTree is the last opened buffer
	autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
augroup END


