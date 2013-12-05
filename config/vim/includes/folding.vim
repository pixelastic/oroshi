" FOLDING
" Do not auto-fold code by default
set foldlevel=0
" Short aliases to fold to predefined depth
nnoremap <silent> z& :setlocal foldlevel=1<CR>
nnoremap <silent> zé :setlocal foldlevel=2<CR>
nnoremap <silent> z" :setlocal foldlevel=3<CR>
nnoremap <silent> z' :setlocal foldlevel=4<CR>
nnoremap <silent> z( :setlocal foldlevel=5<CR>
nnoremap <silent> z- :setlocal foldlevel=6<CR>
nnoremap <silent> zè :setlocal foldlevel=7<CR>
nnoremap <silent> z_ :setlocal foldlevel=8<CR>
nnoremap <silent> zç :setlocal foldlevel=9<CR>
nnoremap <silent> zà :setlocal foldlevel=0<CR>
" Custom foldtext
set foldtext=OroshiFoldText()
function! OroshiFoldText(...)
	let textleft = '{{{ '

	" Add indentation
	let textleft .= repeat(' ', indent(v:foldstart))
	
	" Add title
	let textleft .= (a:0 == 1 ) ? a:1 : StrUncomment(getline(v:foldstart))

	" Number of lines in the fold
	let textright = (v:foldend - v:foldstart) . ' lines }}}'

	" Padding between the left and right parts. Making sure it neatly fit on
	" screen.
	let width = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
	if &textwidth < width
		let width = &textwidth + 1
	endif
	let padding = repeat(' ', width - len(textleft) - len(textright))

	return textleft.padding.textright
endfunction

" VIM-JAVASCRIPT {{{
augroup javascript_folding
	" Note: Because of the order in which files are loaded, we need to define the
	" `au Filetype` in vimrc.
	au!
	function! JavascriptEnableFolding()
		syntax clear jsFuncBlock
		syntax region foldBraces start=/{/ end=/}/ transparent fold keepend extend
	endfunction
	au Filetype javascript call JavascriptEnableFolding()
augroup END
" }}}

